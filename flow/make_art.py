# make_art.py - Turn a pixel-art GDS (e.g. a Tiny Tapeout sky130 art macro) into a DRC-safe
# SCL C1D metal2 art cell: crop a region, recover the art's own pixel grid, re-draw each art pixel
# as a PX x PX um square, and bridge pixels that touch only at a corner (corner contacts fail DRC).
# Usage: klayout -b -rd src=<art.gds> -rd layer=71/20 -rd ymin=<um> -rd px=<um> -rd name=<cell>
#                   -rd out=<out.gds> -r flow/make_art.py
import math
import pya

SRC_LN, SRC_DT = (int(v) for v in layer.split("/"))
YMIN = float(ymin)                              # Keep only source shapes above this y (crop)
PX = float(px)                                  # Output pixel size in um
M2 = (10, 0)                                    # SCL C1D metal2

sl = pya.Layout(); sl.read(src)
st = sl.top_cells()[0]
sq = []                                         # Centres (um) of every source square above YMIN
for p in pya.Region(st.begin_shapes_rec(sl.layer(SRC_LN, SRC_DT))).each():
    b = p.bbox().to_dtype(sl.dbu)
    if b.center().y >= YMIN:
        sq.append(((b.left + b.right) / 2, (b.bottom + b.top) / 2))

def recover(vals):
    """Map the distinct source coordinates to consecutive art-grid indices by clustering gaps."""
    u = sorted(set(round(v, 3) for v in vals))
    steps = [b - a for a, b in zip(u, u[1:])]
    pitch = sorted(steps)[len(steps) // 2]       # Typical step between neighbouring art pixels
    idx, cur, prev = {}, 0, None
    for v in u:
        if prev is not None:
            cur += max(1, int(round((v - prev) / pitch)))
        idx[v] = cur; prev = v
    return idx, pitch

ix, pxs = recover([x for x, _ in sq])
iy, pys = recover([y for _, y in sq])
pix = {(ix[round(x, 3)], iy[round(y, 3)]) for x, y in sq}

# Bridge diagonal-only contacts: if two pixels touch only at a corner, fill one shared neighbour
added = 0
changed = True
while changed:
    changed = False
    for (x, y) in sorted(pix):
        for dx, dy in ((1, 1), (1, -1)):
            if (x + dx, y + dy) in pix and (x + dx, y) not in pix and (x, y + dy) not in pix:
                pix.add((x + dx, y)); added += 1; changed = True

w = max(x for x, _ in pix) + 1
h = max(y for _, y in pix) + 1
for y in range(h - 1, -1, -1):                   # ASCII preview, top row first
    print("".join("#" if (x, y) in pix else "." for x in range(w)))

ly = pya.Layout(); ly.dbu = 0.001
cell = ly.create_cell(name)
m2 = ly.layer(*M2)
reg = pya.Region()
for x, y in pix:
    reg.insert(pya.DBox(x * PX, y * PX, (x + 1) * PX, (y + 1) * PX).to_itype(ly.dbu))
cell.shapes(m2).insert(reg.merged())
ly.write(out)
print("ART: %d pixels (%d bridged) on a %d x %d grid (source pitch %.3f x %.3f um) -> %.1f x %.1f um, cell %s -> %s"
      % (len(pix), added, w, h, pxs, pys, w * PX, h * PX, name, out))
