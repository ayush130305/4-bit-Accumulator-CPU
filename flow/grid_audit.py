# grid_audit.py - List every off-grid (0.005 um) vertex in a GDS by cell, and attribute each one to its
# source: SCL Silicon No. block, SCL library cell, SCL pad frame original geometry, or our own geometry.
# Usage: klayout -b -rd gds=<final.gds> -rd block=<OSxxxx.gds> [-rd block_dx=<um> -rd block_dy=<um>] -rd origframe=<frame3mmx3mm.gds>
#                   -rd libs=<a.gds,b.gds,...> -rd csv=<out.csv> -r flow/grid_audit.py
import pya
G = 5                                             # 0.005 um in 0.001 um database units
ly = pya.Layout(); ly.read(gds); top = ly.top_cells()[0]

def pts_of(shape):
    if shape.is_box(): b = shape.box; return [b.p1, b.p2]
    if shape.is_polygon() or shape.is_simple_polygon():
        p = shape.polygon; out = list(p.each_point_hull())
        for h in range(p.holes()): out += list(p.each_point_hole(h))
        return out
    if shape.is_path(): return list(shape.path.each_point())
    if shape.is_text(): return [pya.Point(shape.text.x, shape.text.y)]
    return []

def off(p): return p.x % G or p.y % G

# Reference geometry from SCL's own files
lib_names = set()
for f in libs.split(","):
    L = pya.Layout(); L.read(f); lib_names |= {c.name for c in L.each_cell()}
bl = pya.Layout(); bl.read(block); btop = bl.top_cells()[0]
try:                                              # Block placement offset (um) if it was translated
    bdx, bdy = int(round(float(block_dx) / ly.dbu)), int(round(float(block_dy) / ly.dbu))
except NameError:
    bdx = bdy = 0
block_cells = {c.name for c in bl.each_cell()}
block_pts = set()                                 # Off-grid vertices of the block's top cell, per layer
for li in bl.layer_indexes():
    info = bl.get_info(li)
    for s in btop.shapes(li).each():
        for p in pts_of(s):
            if off(p): block_pts.add((info.layer, info.datatype, p.x + bdx, p.y + bdy))
of = pya.Layout(); of.read(origframe); oft = of.top_cells()[0]
frame_pts = set()
for li in of.layer_indexes():
    info = of.get_info(li)
    for s in oft.shapes(li).each():
        if s.is_text(): continue
        for p in pts_of(s):
            if off(p): frame_pts.add((info.layer, info.datatype, p.x, p.y))

rows, summary = [], {}
for c in ly.each_cell():
    for li in ly.layer_indexes():
        info = ly.get_info(li)
        for s in c.shapes(li).each():
            for p in pts_of(s):
                if not off(p): continue
                key = (info.layer, info.datatype, p.x, p.y)
                if c.name in lib_names and c.name not in ("frame3mmx3mm",):
                    src = "SCL library cell"
                elif c.name in block_cells and c.cell_index() != top.cell_index():
                    src = "SCL Silicon No. block (char cell)"
                elif c.cell_index() == top.cell_index() and key in block_pts:
                    src = "SCL Silicon No. block (top-cell shapes, as issued)"
                elif c.name == "frame3mmx3mm_opad" and key in frame_pts:
                    src = "SCL pad frame original geometry"
                else:
                    src = "OURS"
                rows.append((c.name, src, "%d/%d" % (info.layer, info.datatype), p.x * ly.dbu, p.y * ly.dbu))
                summary[(c.name, src)] = summary.get((c.name, src), 0) + 1
    for inst in c.each_inst():                    # Placements must be on grid too
        d = inst.trans.disp
        if off(d):
            rows.append((c.name, "OURS (instance placement of %s)" % inst.cell.name, "-", d.x * ly.dbu, d.y * ly.dbu))
            summary[(c.name, "OURS placement")] = summary.get((c.name, "OURS placement"), 0) + 1
bb = top.bbox()
die_ok = not (off(bb.p1) or off(bb.p2))
with open(csv, "w") as f:
    f.write("cell,source,layer,x_um,y_um\n")
    for r in rows: f.write("%s,%s,%s,%.4f,%.4f\n" % r)
print("%-24s %-52s %s" % ("cell", "source", "off-grid vertices"))
for (c, s), n in sorted(summary.items(), key=lambda kv: (kv[0][1], kv[0][0])):
    print("%-24s %-52s %d" % (c, s, n))
ours = sum(n for (c, s), n in summary.items() if s.startswith("OURS"))
print("TOTAL off-grid vertices: %d   |   in OUR geometry: %d   |   die boundary on grid: %s" % (len(rows), ours, die_ok))
