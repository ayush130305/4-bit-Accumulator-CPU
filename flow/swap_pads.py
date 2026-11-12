# swap_pads.py - Replace every instance of one pad cell with another in an SCL pad frame GDS
# Keeps each instance's exact transform; copies the new pad cell from the SCL pad library.
# Usage:
#   klayout -b -rd frame=<frame.gds> -rd lib=<io_pad_c1d.gds> -rd old=AIPAD00 -rd new=OPAD04 \
#           -rd out=<out.gds> [-rd newtop=<name>] -r flow/swap_pads.py
import pya

frame_layout = pya.Layout()                      # Pad frame being modified
frame_layout.read(frame)                         # Load the standard frame
lib_layout = pya.Layout()                        # SCL IO pad library
lib_layout.read(lib)                             # Load the pad library

top = frame_layout.top_cells()[0]                # Frame top cell
old_cell = frame_layout.cell(old)                # Pad type to remove
if old_cell is None:
    raise RuntimeError("cell %s not in frame" % old)
src = lib_layout.cell(new)                       # Pad type to insert
if src is None:
    raise RuntimeError("cell %s not in library" % new)

dst = frame_layout.cell(new)                     # Reuse if the frame already has it
if dst is None:
    dst = frame_layout.create_cell(new)          # Otherwise create an empty cell
    dst.copy_tree(src)                           # and copy geometry from the library

count = 0                                        # Number of instances swapped
for inst in list(top.each_inst()):               # Snapshot instance list before editing
    if inst.cell_index == old_cell.cell_index():
        inst.cell_index = dst.cell_index()       # Point instance at the new pad, same transform
        count += 1

# Optional: label each new pad's core-side pin "PADn<suffix>" (n taken from the frame's PADn text
# inside that pad) so the net is named for LVS and for core-to-pad routing.
# Extra args: -rd pin_x=191.575 -rd pin_y=2.0 -rd suffix=_IN -rd label_layer=10/7
try:
    pin_x                                        # Defined only when passed with -rd
except NameError:
    pin_x = None
if pin_x is not None:
    ln, dt = [int(v) for v in label_layer.split("/")]
    lyr = frame_layout.layer(ln, dt)             # Label layer (metal2 text in the SCL frame)
    pad_texts = []                               # (name, point) of existing PADn labels
    it = top.shapes(lyr).each()
    for s in it:
        if s.is_text() and s.text_string.startswith("PAD") and "_" not in s.text_string:
            pad_texts.append((s.text_string, pya.DPoint(s.dtext.x, s.dtext.y)))
    for inst in top.each_inst():
        if inst.cell_index != dst.cell_index():
            continue
        box = inst.dbbox()                       # Pad footprint in frame coordinates
        names = [n for n, p in pad_texts if box.contains(p)]
        if len(names) != 1:
            raise RuntimeError("pad at %s matches labels %s" % (box, names))
        p = inst.dcplx_trans * pya.DPoint(float(pin_x), float(pin_y))  # Pin point in frame coords
        top.shapes(lyr).insert(pya.DText(names[0] + suffix, pya.DTrans(p.x, p.y)))
        print("LABEL %s%s at (%.3f, %.3f)" % (names[0], suffix, p.x, p.y))

if old_cell.parent_cells() == 0:                 # Old pad no longer used anywhere
    frame_layout.delete_cell(old_cell.cell_index())

# Snap every top-level label to the 0.005 um grid (SCL's frame labels are off-grid; labels are
# not geometry, so moving them by < 5 nm changes nothing physical)
G = int(round(0.005 / frame_layout.dbu))
for li in frame_layout.layer_indexes():
    for s in list(top.shapes(li).each()):
        if s.is_text():
            t = s.text
            t.x = int(round(t.x / G)) * G; t.y = int(round(t.y / G)) * G
            s.text = t

# A modified frame is a custom cell: it must not keep SCL's library name (procedure doc, Design Kit)
try:
    newtop
except NameError:
    newtop = None
if newtop:
    top.name = newtop

frame_layout.write(out)                          # Save modified frame
print("SWAPPED %d x %s -> %s, wrote %s" % (count, old, new, out))
