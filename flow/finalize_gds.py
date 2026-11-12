# finalize_gds.py - Make the SCL submission top cell from the chip GDS and SCL's Silicon No. block.
# SCL's block GDS has a single top cell already named after the Silicon No. (e.g. OS0084, 270 x 60 um
# at origin). That cell is used AS the chip's top cell, copied 1:1 at its own coordinates (no move,
# scale or edit); the assembled chip goes inside it as one instance at (0,0). The block lands in the
# frame's lower-left corner, directly under SCL's OS_SCL_logo (225..275, 60..125).
# Without a block, the chip top is simply renamed to the Silicon No.
# Usage: klayout -b -rd ingds=<chip.gds> -rd oldtop=OS0000 -rd sino=<OSxxxx> -rd outgds=<out.gds>
#                   [-rd block=<OSxxxx.gds>] [-rd chipcell=<name for the chip cell>] -r flow/finalize_gds.py
import pya

ly = pya.Layout(); ly.read(ingds)
chip = ly.cell(oldtop)
if chip is None or len(ly.top_cells()) != 1:
    raise RuntimeError("expected one top cell %s, found %s" % (oldtop, [c.name for c in ly.top_cells()]))
if ly.cell(sino) is not None:
    raise RuntimeError("a cell named %s already exists in the chip" % sino)

try:
    block
except NameError:
    block = ""
try:
    chipcell
except NameError:
    chipcell = "chip_" + sino.lower()

if block:
    bl = pya.Layout(); bl.read(block)
    btops = bl.top_cells()
    if len(btops) != 1 or btops[0].name != sino:
        raise RuntimeError("block must have one top cell named %s, found %s" % (sino, [c.name for c in btops]))
    if abs(bl.dbu - ly.dbu) > 1e-12:
        raise RuntimeError("block dbu %g differs from chip dbu %g" % (bl.dbu, ly.dbu))
    for c in bl.each_cell():                     # Block sub-cells (char_*) must not clash with ours
        if c.cell_index() != btops[0].cell_index() and ly.cell(c.name) is not None:
            raise RuntimeError("block cell %s clashes with a chip cell" % c.name)
    chip.name = chipcell                         # Our assembled chip becomes a child cell
    top = ly.create_cell(sino)
    top.copy_tree(btops[0])                      # Block geometry + its char_* cells, 1:1
    # Optional placement: pure translation of the block's own shapes and char instances
    # (-rd block_x=<um> -rd block_y=<um>); no scaling, rotation or edit. The block cell is the top
    # cell, so it cannot be instanced elsewhere without renaming SCL's cell.
    try:
        block_x
    except NameError:
        block_x = block_y = None
    if block_x is not None:
        bdx = round(round(float(block_x) / 0.005) * 0.005, 3)
        bdy = round(round(float(block_y) / 0.005) * 0.005, 3)
        top.transform(pya.DTrans(bdx, bdy))
        print("BLOCK: translated by (%.3f, %.3f) um" % (bdx, bdy))
    bb = top.dbbox()
    if block_x is not None:                      # Nothing in the chip may come within 10 um of the moved block
        keep = pya.Region()
        for li in ly.layer_indexes():
            info = ly.get_info(li)
            if info.datatype == 7 or info.layer in (28, 999):
                continue
            keep += pya.Region(chip.begin_shapes_rec(li))   # chip sits at (0,0)
        hit = keep & pya.Region(bb.enlarged(10.0).to_itype(ly.dbu))
        if not hit.is_empty():
            raise RuntimeError("moved block at %s comes within 10 um of chip geometry at %s" % (bb, hit.bbox().to_dtype(ly.dbu)))
    inst = top.insert(pya.DCellInstArray(chip.cell_index(), pya.DTrans(0, 0)))
    # Flatten the chip one level into the top so its pad labels, wiring and frame/core instances sit
    # directly in OS00xx (LVS needs top-level labels); the block's own shapes are not touched.
    inst.flatten(1)
    if chip.parent_cells() == 0:
        ly.delete_cell(chip.cell_index())
    print("BLOCK: %s %.1f x %.1f um placed at %s; chip merged into the top cell" % (sino, bb.width(), bb.height(), bb))
else:
    chip.name = sino
    top = chip
    print("BLOCK: none given (insert SCL's Silicon No. GDS block before the real submission)")

# Optional chip art: a floating metal-only cell placed in a free patch; refused if anything else in the
# chip comes within 10 um of it. Extra args: -rd art=<art.gds> -rd art_x=<um> -rd art_y=<um>
try:
    art
except NameError:
    art = ""
if art:
    al = pya.Layout(); al.read(art)
    asrc = al.top_cells()[0]
    if ly.cell(asrc.name) is not None:
        raise RuntimeError("art cell name %s clashes with a chip cell" % asrc.name)
    acell = ly.create_cell(asrc.name)
    acell.copy_tree(asrc)
    tr = pya.DTrans(round(float(art_x) / 0.005) * 0.005, round(float(art_y) / 0.005) * 0.005)
    keep = pya.Region()                          # Everything already in the chip (labels / markers excluded)
    for li in ly.layer_indexes():
        info = ly.get_info(li)
        if info.datatype == 7 or info.layer in (28, 999):
            continue
        keep += pya.Region(top.begin_shapes_rec(li))
    area = acell.dbbox().transformed(tr)
    clash = keep & pya.Region(area.enlarged(10.0).to_itype(ly.dbu))
    if not clash.is_empty():
        raise RuntimeError("chip art at %s comes within 10 um of existing shapes at %s" % (area, clash.bbox().to_dtype(ly.dbu)))
    top.insert(pya.DCellInstArray(acell.cell_index(), tr))
    print("ART: %s %.1f x %.1f um placed at %s" % (asrc.name, area.width(), area.height(), area))

ly.write(outgds)
print("FINAL: top=%s bbox=%s -> %s" % (sino, top.dbbox(), outgds))
