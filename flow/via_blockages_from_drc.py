# via_blockages_from_drc.py - Append a via1 blockage for every DRC marker that touches a router via
# Usage: klayout -b -rd rdbf=<drc.lyrdb> -rd gds=<core.gds> -rd out=<via_blockages.txt> -r flow/via_blockages_from_drc.py
# Each line written is "x1 y1 x2 y2" (um, core-local); pnr_core.tcl turns them into via1 obstructions.
import pya, re, xml.etree.ElementTree as ET

ly = pya.Layout(); ly.read(gds); top = ly.top_cells()[0]
via_li = ly.find_layer(9, 0)                     # via1 in SCL C1D GDS
vias = pya.Region(top.begin_shapes_rec(via_li))  # Every via1 cut in the layout
root = ET.parse(rdbf).getroot()
new = []
for item in root.iter("item"):
    for v in item.iter("value"):
        nums = [float(n) for n in re.findall(r"-?\d+\.?\d*", v.text or "")]
        xs, ys = nums[0::2], nums[1::2]
        if not xs:
            continue
        mark = pya.DBox(min(xs), min(ys), max(xs), max(ys)).enlarged(1.0).to_itype(ly.dbu)
        for p in vias.interacting(pya.Region(mark)).each():
            b = p.bbox().to_dtype(ly.dbu).enlarged(0.5)   # Block the cut and a margin
            new.append("%.3f %.3f %.3f %.3f" % (b.left, b.bottom, b.right, b.top))
old = open(out).read().split("\n") if __import__("os").path.exists(out) else []
lines = [l for l in old if l.strip()] + sorted(set(new) - set(old))
open(out, "w").write("\n".join(lines) + "\n")
print("VIA_BLOCKAGES: +%d (total %d) -> %s" % (len(set(new) - set(old)), len(lines), out))
