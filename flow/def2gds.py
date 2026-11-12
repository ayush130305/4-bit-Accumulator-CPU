# def2gds.py - Stream a routed DEF to GDS, using SCL's real std-cell GDS for every macro
# Usage: klayout -b -rd def=<routed.def> -rd techlef=<tech.lef> -rd celllef=<cells.lef>
#                   -rd cellgds=<core_c1d.gds> -rd map=<scl_c1d.map> -rd out=<out.gds> -r flow/def2gds.py
import pya

cells = pya.Layout()                             # SCL std-cell layouts
cells.read(cellgds)

opt = pya.LoadLayoutOptions()
cfg = opt.lefdef_config
cfg.map_file = map                               # DEF layer -> GDS layer/datatype (SCL map)
cfg.read_lef_with_def = False
cfg.lef_files = [techlef, celllef]
cfg.macro_resolution_mode = 2                    # Never use LEF geometry: macros come from GDS
cfg.macro_layouts = [cells]
cfg.produce_cell_outlines = False
cfg.produce_placement_blockages = False
cfg.produce_regions = False

ly = pya.Layout()
ly.read(def_file if "def_file" in globals() else globals()["def"], opt)
top = ly.top_cells()[0]

# Every instantiated cell must carry real geometry from the GDS
empty = [c.name for c in ly.each_cell() if c.cell_index() != top.cell_index() and c.bbox().empty()]
if empty:
    raise RuntimeError("cells without layout: %s" % ", ".join(sorted(set(empty))))

ly.write(out)
print("DEF2GDS: top=%s cells=%d bbox=%s -> %s" % (top.name, ly.cells(), top.dbbox(), out))
