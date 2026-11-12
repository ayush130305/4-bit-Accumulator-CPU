# verify_block_move.py - Prove the Silicon No. block in the final GDS is SCL's issued block, only translated:
# extract it (top-cell shapes in its box + char_* instances), apply the inverse shift, XOR with the issued file.
# Also report leftovers at the old position and any overlap/touch by other cells at the new position.
# Usage: klayout -b -rd gds=<final.gds> -rd block=<OSxxxx.gds> -rd dx=<um> -rd dy=<um> -r flow/verify_block_move.py
import pya
ly = pya.Layout(); ly.read(gds); top = ly.top_cells()[0]; dbu = ly.dbu
bl = pya.Layout(); bl.read(block); bt = bl.top_cells()[0]
sh = pya.DTrans(float(dx), float(dy)).to_itype(dbu)
newbox = bt.bbox().transformed(sh)
print("issued bbox %s -> placed bbox %s" % (bt.dbbox(), newbox.to_dtype(dbu)))
total, ok = 0.0, True
for li in bl.layer_indexes():
    info = bl.get_info(li)
    ref = pya.Region(bt.begin_shapes_rec(li)).merged()
    lf = ly.find_layer(info.layer, info.datatype)
    got = pya.Region()
    if lf is not None:
        got += pya.Region(top.shapes(lf)) & pya.Region(newbox)          # block's own shapes (nothing else is within 10 um)
        for i in top.each_inst():
            if i.cell.name.startswith("char_"):
                got += pya.Region(i.cell.begin_shapes_rec(lf)).transformed(i.trans)
    back = got.transformed(sh.inverted()).merged()
    x = (ref ^ back).area() * dbu * dbu
    total += x; ok = ok and x == 0
    print("  layer %-6s issued %8.3f um2  extracted-and-shifted-back %8.3f um2  XOR %.6f um2" % ("%d/%d" % (info.layer, info.datatype), ref.area()*dbu*dbu, back.area()*dbu*dbu, x))
print("TOTAL XOR = %.6f um2 -> %s" % (total, "IDENTICAL (pure translation)" if ok else "DIFFERENT"))
chars = sorted((i.cell.name, str(i.dcplx_trans)) for i in top.each_inst() if i.cell.name.startswith("char_"))
print("char instances:", chars)
# leftovers at the old origin position
old = pya.Region(bt.bbox())
left = 0
for li in ly.layer_indexes():
    left += (pya.Region(top.shapes(li)) & old).count()
print("top-cell shapes left in the old box (0,0)-(270,60):", left)
# overlap / touch by anything that is not the block, on every layer, at the new position
print("other cells' geometry touching/overlapping the placed block box (+0.001 um):")
for li in ly.layer_indexes():
    info = ly.get_info(li)
    oth = pya.Region()
    for i in top.each_inst():
        if not i.cell.name.startswith("char_"):
            oth += pya.Region(i.cell.begin_shapes_rec(li)).transformed(i.trans)
    oth += pya.Region(top.shapes(li)) - (pya.Region(top.shapes(li)) & pya.Region(newbox))
    hit = oth & pya.Region(newbox.enlarged(1))
    if not hit.is_empty():
        src = [i.cell.name for i in top.each_inst() if not i.cell.name.startswith("char_") and not (pya.Region(i.cell.begin_shapes_rec(li)).transformed(i.trans) & pya.Region(newbox.enlarged(1))).is_empty()]
        print("  layer %-6s area %.1f um2 from %s" % ("%d/%d" % (info.layer, info.datatype), hit.area()*dbu*dbu, src))
