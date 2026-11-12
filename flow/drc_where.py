# drc_where.py - List each DRC marker's location and the cell instances under it
# Usage: klayout -b -rd rdbf=<drc.lyrdb> -rd gds=<layout.gds> -r flow/drc_where.py
import pya, re, xml.etree.ElementTree as ET
ly = pya.Layout(); ly.read(gds); top = ly.top_cells()[0]
root = ET.parse(rdbf).getroot()
for item in root.iter("item"):
    cat = (item.findtext("category") or "").strip("'")
    for v in item.iter("value"):
        nums = [float(n) for n in re.findall(r"-?\d+\.?\d*", v.text or "")]
        xs, ys = nums[0::2], nums[1::2]
        if not xs: continue
        b = pya.DBox(min(xs), min(ys), max(xs), max(ys))
        hits = sorted({i.cell.name for i in top.each_overlapping_inst(b.enlarged(0.5).to_itype(ly.dbu))})
        print("%-6s (%8.2f,%8.2f)-(%8.2f,%8.2f) %s" % (cat[:6], b.left, b.bottom, b.right, b.top, " ".join(hits) or "-"))
