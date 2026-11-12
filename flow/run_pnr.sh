#!/usr/bin/env bash
# run_pnr.sh - Run flow/pnr_core.tcl in the OpenLane container for the design in flow/padmap_*.json
# Usage: flow/run_pnr.sh [padmap.json]   (default flow/padmap_acc4.json)
set -euo pipefail
. "$(dirname "$0")/env.sh"
cd "$PROJ"
MAP="${1:-flow/padmap_acc4.json}"
read -r DESIGN DIE_W DIE_H CORE_M OX OY VDD_F VSS_F < <(python3 -c "
import json;m=json.load(open('$MAP'))
print(m['design'],m['die_size'][0],m['die_size'][1],m['core_margin'],m['core_origin'][0],m['core_origin'][1],
      m['power']['VDD']['stripe_y_frame'],m['power']['VSS']['stripe_y_frame'])")
OUT="$PROJ_NS/pnr/$DESIGN"; mkdir -p "$OUT"; touch "$OUT/via_blockages.txt"
mkdir -p pnr/lef
python3 flow/snap_lef.py "$C1D/lef/core_c1d.lef" pnr/lef/core_c1d_snapped.lef > /dev/null
klayout -b -rd gds="$(python3 -c "import json;print(json.load(open('$MAP'))['frame_gds'])")" \
        -rd js="$PROJ/pnr/edge_pins.json" -r flow/edge_pins.py > /dev/null
python3 flow/gen_pins.py "$MAP" pnr/edge_pins.json "$OUT/pins.tcl" > "$OUT/pins.txt"
# Edge-stripe centres in core-local coordinates
VDD_Y=$(python3 -c "print(round($VDD_F-$OY,3))")
VSS_Y=$(python3 -c "print(round($VSS_F-$OY,3))")
CNAME="acc4flow_$$_$RANDOM"; trap 'docker kill "$CNAME" >/dev/null 2>&1 || true' EXIT
  timeout ${RUN_TIMEOUT:-1200} docker run --rm --name "$CNAME" --memory=6g --memory-swap=6g --cpus=4 -v "$HOME:$HOME" --user "$(id -u):$(id -g)" \
  -e C1D="$C1D" -e CORE_LEF="$PROJ_NS/pnr/lef/core_c1d_snapped.lef" -e MIN_GAP="${MIN_GAP:-20}" -e PNR_CORNER="${PNR_CORNER:-typ}" -e BLOCKAGES="$OUT/via_blockages.txt" -e NETLIST="$PROJ_NS/syn/${DESIGN}_netlist.v" -e DESIGN="$DESIGN" -e OUT="$OUT" \
  -e PINS_TCL="$OUT/pins.tcl" -e DIE_W="$DIE_W" -e DIE_H="$DIE_H" -e CORE_M="$CORE_M" \
  -e VDD_Y="$VDD_Y" -e VSS_Y="$VSS_Y" -e CLK_PERIOD="${CLK_PERIOD:-100}" -e PL_DENSITY="${PL_DENSITY:-0.35}" \
  "$OL_IMAGE" openroad -no_init -exit "$PROJ_NS/flow/pnr_core.tcl" > "$OUT/pnr.log" 2>&1 || true
grep -E "FLOW:|ERROR|Number of violations|Total wire length =" "$OUT/pnr.log" | tail -8
