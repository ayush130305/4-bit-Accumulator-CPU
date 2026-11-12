# check_gds_rules.py - SCL submission checks on a GDS: top cell name, origin, even top-right corner,
# 0.005 um grid for every vertex (per cell, so library vs. our own cells are reported separately).
# Usage: klayout -b -rd gds=<file.gds> -rd top=<expected top cell> -r flow/check_gds_rules.py
import pya, sys

ly = pya.Layout(); ly.read(gds)
tops = [c.name for c in ly.top_cells()]
ok = True
def report(cond, msg):
    global ok
    print(("PASS " if cond else "FAIL ") + msg)
    ok = ok and cond

report(tops == [top], "single top cell named %s (found %s)" % (top, tops))
t = ly.cell(tops[0])
b = t.dbbox()
report(abs(b.left) < 1e-9 and abs(b.bottom) < 1e-9, "bottom-left at (0,0) (bbox %s)" % b)
report(abs(b.right - round(b.right)) < 1e-9 and round(b.right) % 2 == 0 and
       abs(b.top - round(b.top)) < 1e-9 and round(b.top) % 2 == 0,
       "top-right on even whole um (%.3f, %.3f)" % (b.right, b.top))

grid = int(round(0.005 / ly.dbu))                # Grid in database units
bad = {}
for c in ly.each_cell():
    n = 0
    for li in ly.layer_indexes():
        for s in c.shapes(li).each():
            if s.is_box():
                bx = s.box; pts = [bx.p1, bx.p2]
            elif s.is_polygon() or s.is_simple_polygon():
                pts = list(s.polygon.each_point_hull())
            elif s.is_path():
                pts = list(s.path.each_point())
            elif s.is_text():
                pts = [pya.Point(s.text.x, s.text.y)]
            else:
                continue
            n += sum(1 for p in pts if p.x % grid or p.y % grid)
    for inst in c.each_inst():                   # Instance placements must be on grid too
        d = inst.trans.disp
        if d.x % grid or d.y % grid:
            n += 1
    if n:
        bad[c.name] = n
report(not bad, "all vertices / placements on 0.005 um grid" + ("" if not bad else ": off-grid " + ", ".join("%s(%d)" % kv for kv in sorted(bad.items()))))
print("GDS_RULES: %s" % ("ALL PASS" if ok else "FAILURES"))
