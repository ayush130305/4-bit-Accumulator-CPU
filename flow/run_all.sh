#!/usr/bin/env bash
# run_all.sh - Netlist -> signed-off chip GDS for one design. Stops at the first failing check.
#   1 synth   2 P&R core   3 core GDS + DRC (via-fix loop)   4 core LVS
#   5 chip assembly (frame + core + pad wiring)   6 chip DRC + LVS   7 RCX/STA/SDF post-layout sim
# Usage: flow/run_all.sh [TOPCELL]      (default OS0000 placeholder until SCL issues the Silicon No.)
set -euo pipefail
. "$(dirname "$0")/env.sh"
cd "$PROJ"
TOP="${1:-OS0000}"
MAP=flow/padmap_acc4.json
DESIGN=acc4_core
PNR=pnr/$DESIGN
step() { echo; echo "=== $*"; }

step "0. pad frame: AIPAD00 -> OPAD04, renamed, labelled; DRC + LVS"
mkdir -p layout/frame
klayout -b -rd frame="$PADF/pad_frame_gds/frame3mmx3mm.gds" -rd lib="$PADF/klayout/gds/io_pad_c1d.gds" \
        -rd old=AIPAD00 -rd new=OPAD04 -rd out=layout/frame/frame3mmx3mm_opad.gds -rd newtop=frame3mmx3mm_opad \
        -rd pin_x=191.575 -rd pin_y=2.0 -rd suffix=_IN -rd label_layer=10/7 -r flow/swap_pads.py | tail -1
cp "$PADF/klayout/lvs_cdl/io_pad_c1d.cdl" layout/frame/io_pad_c1d.cdl
python3 flow/frame_cdl.py "$PADF/pad_frame_cdl/frame3mmx3mm.cdl" layout/frame/frame3mmx3mm_opad.cdl frame3mmx3mm_opad io_pad_c1d.cdl
flow/run_drc.sh layout/frame/frame3mmx3mm_opad.gds checks/frame_drc | head -3
flow/run_lvs.sh layout/frame/frame3mmx3mm_opad.gds layout/frame/frame3mmx3mm_opad.cdl checks/frame_lvs
klayout -b -rd gds=layout/frame/frame3mmx3mm_opad.gds -rd js=pnr/edge_pins.json -r flow/edge_pins.py > /dev/null

step "1. synthesis"
yosys -q -l syn/synth_core.log syn/synth_acc4_core.ys
grep -A3 "Number of cells" syn/synth_core.log | tail -4 | head -1

step "2-3. P&R + core DRC (via-fix loop; retries other placement densities if a marker won't clear)"
mkdir -p "$PNR"
CLEAN=0
for DENS in ${DENSITIES:-0.35 0.32 0.38 0.30 0.40 0.34}; do
  [ "${SKIP_PNR:-0}" = 1 ] && { CLEAN=1; break; }
  [ "${KEEP_BLOCKAGES:-0}" = 1 ] || : > "$PNR/via_blockages.txt"
  for i in 1 2 3; do
    echo "--- density $DENS, pass $i"
    PL_DENSITY=$DENS flow/run_pnr.sh "$MAP" | tail -1
    grep -q "FLOW: done" "$PNR/pnr.log" || { echo "P&R failed: $PNR/pnr.log"; break; }
    klayout -b -rd def="$PNR/4_route.def" -rd techlef="$C1D/lef/tech_c1d.lef" -rd celllef="$C1D/lef/core_c1d.lef" \
            -rd cellgds="$C1D/gds/core_c1d.gds" -rd map="$KTECH/scl_c1d.map" -rd out=layout/core/$DESIGN.gds \
            -r flow/def2gds.py | grep DEF2GDS
    flow/run_drc.sh layout/core/$DESIGN.gds checks/core_drc | head -4
    N=$(grep -c '<item>' checks/core_drc/drc.lyrdb || true)
    [ "$N" = 0 ] && { CLEAN=1; break; }
    ADD=$(klayout -b -rd rdbf=checks/core_drc/drc.lyrdb -rd gds=layout/core/$DESIGN.gds -rd out="$PNR/via_blockages.txt" \
            -r flow/via_blockages_from_drc.py | sed -n 's/.*+\([0-9]*\).*/\1/p')
    [ "${ADD:-0}" = 0 ] && break        # nothing new to block -> try another density
  done
  [ "$CLEAN" = 1 ] && { echo "core DRC clean at density $DENS"; echo "$DENS" > "$PNR/density_used.txt"; break; }
done
[ "$CLEAN" = 1 ] || { echo "core DRC not clean at any density"; exit 1; }

step "4. core LVS"
python3 flow/cdl_filter.py "$C1D/cdl/core_iolib_c1d.cdl" layout/frame/io_pad_c1d.cdl lvs/core_cells.cdl
python3 flow/v2spice.py "$PNR/${DESIGN}_rt.v" lvs/core_cells.cdl lvs/$DESIGN.cir $DESIGN
printf '.include core_cells.cdl\n.include %s.cir\n' $DESIGN > lvs/${DESIGN}_lvs.cdl
flow/run_lvs.sh layout/core/$DESIGN.gds lvs/${DESIGN}_lvs.cdl checks/core_lvs $DESIGN

step "5. chip assembly ($TOP)"
mkdir -p layout/chip
klayout -b -rd padmap=$MAP -rd edges=pnr/edge_pins.json -rd coredef="$PNR/4_route.def" \
        -rd coregds=layout/core/$DESIGN.gds -rd top="$TOP" -rd outgds=layout/chip/$TOP.gds \
        -rd outcdl=lvs/chip.cdl -rd corecir=lvs/$DESIGN.cir -rd cellcdl=lvs/core_cells.cdl -r flow/assemble_chip.py

step "6. chip DRC + LVS"
flow/run_drc.sh layout/chip/$TOP.gds checks/chip_drc "$TOP" | head -6
[ "$(grep -c '<item>' checks/chip_drc/drc.lyrdb || true)" = 0 ] || { echo "chip DRC not clean"; exit 1; }
flow/run_lvs.sh layout/chip/$TOP.gds lvs/chip.cdl checks/chip_lvs "$TOP"

step "7. RCX / STA / SDF post-layout simulation"
flow/run_signoff.sh $DESIGN
echo; echo "=== run_all: done ($TOP)"
