# render_images.py - PNG renders of the final chip GDS for the README (KLayout batch mode).
# Usage: klayout -b -rd gds=<final.gds> -rd lyp=<scl_c1d.lyp> -rd out=<dir> -r flow/render_images.py
# Pictures only: the GDS (which contains SCL cells) is read, never copied into the output.
import os
import pya

os.makedirs(out, exist_ok=True)
ly = pya.Layout(); ly.read(gds)
top = ly.top_cell()
die = top.dbbox()

# Core and chip-art instances (by cell name), for the zoomed views
def inst_box(name):
    for it in top.begin_instances_rec():
        if it.inst_cell().name == name:
            return it.inst_dtrans() * it.inst_cell().dbbox()
    return None
core = inst_box("acc4_core") or pya.DBox(die.center().x - 800, die.center().y - 800, die.center().x + 800, die.center().y + 800)
art = inst_box("acc4_monkey")

lv = pya.LayoutView()
lv.load_layout(gds, True)
lv.load_layer_props(lyp)
lv.max_hier()
lv.set_config("grid-visible", "false")
lv.set_config("text-visible", "false")

def shot(name, box, w=1800, h=1800, bg="#ffffff"):
    lv.set_config("background-color", bg)
    lv.zoom_box(box)
    lv.save_image_with_options(os.path.join(out, name), w, h, 0, 2, 0, box, False)
    print("wrote", name, box)

m = die.width() * 0.01
shot("chip_full.png", die.enlarged(m, m))
shot("chip_full_dark.png", die.enlarged(m, m), bg="#000000")
shot("core.png", core.enlarged(20, 20))
c = core.center()
shot("core_cells_zoom.png", pya.DBox(c.x - 120, c.y - 80, c.x + 120, c.y + 80), 1800, 1200)
shot("pad_ring_corner.png", pya.DBox(die.right - 700, die.top - 700, die.right, die.top))
shot("pads_edge.png", pya.DBox(die.center().x - 600, die.top - 420, die.center().x + 600, die.top), 2000, 700)
if art:
    shot("chip_art.png", art.enlarged(40, 40))
shot("silicon_no_block.png", pya.DBox(300, 335, 600, 425), 1800, 540)
