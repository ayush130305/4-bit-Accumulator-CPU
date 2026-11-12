#!/usr/bin/env bash
# run_signoff.sh - RCX + STA (min/typ/max) in the OpenLane container, then SDF-annotated gate-level sim
# Usage: flow/run_signoff.sh [design]   (default acc4_core)
set -euo pipefail
. "$(dirname "$0")/env.sh"
cd "$PROJ"
DESIGN="${1:-acc4_core}"
PNR="$PROJ_NS/pnr/$DESIGN"
for CORNER in min typ max; do
  OUT="$PROJ_NS/signoff/$CORNER"; mkdir -p "$OUT"
  CNAME="acc4flow_$$_$RANDOM"; trap 'docker kill "$CNAME" >/dev/null 2>&1 || true' EXIT
  timeout ${RUN_TIMEOUT:-1200} docker run --rm --name "$CNAME" --memory=8g --memory-swap=8g --cpus=4 -v "$HOME:$HOME" --user "$(id -u):$(id -g)" \
    -e C1D="$C1D" -e CORE_LEF="$PROJ_NS/pnr/lef/core_c1d_snapped.lef" -e DEF="$PNR/4_route.def" \
    -e RCX_LIB="$PDK_ROOT/sclc1d/libs.tech/openrcx/scl_c1d.rcx.lib" -e CORNER="$CORNER" -e OUT="$OUT" \
    -e CLK_PERIOD="${CLK_PERIOD:-100}" -e IO_DELAY="${IO_DELAY:-10}" -e OUT_LOAD="${OUT_LOAD:-1.0}" \
    "$OL_IMAGE" openroad -no_init -exit "$PROJ_NS/flow/rcx_sta.tcl" > "$OUT/signoff.log" 2>&1 || true
  grep -E "^STA |ERROR" "$OUT/signoff.log" || { echo "signoff $CORNER failed, see $OUT/signoff.log"; exit 1; }
done

# SDF back-annotated simulation of the chip top (core netlist from routing + OPAD04 models)
cd "$PROJ/tb"
for CORNER in min typ max; do
  T=$CORNER
  iverilog -DDUT_TOP -DSDF_FILE="\"$PROJ_NS/signoff/$CORNER/acc4_core_$CORNER.sdf\"" -gspecify -T$T \
    -o "postlayout_$CORNER.vvp" "$C1D_V" "$PNR/${DESIGN}_rt.v" ../rtl/acc4_top.v tb_acc4_cpu.v 2> "postlayout_$CORNER.compile.log"
  printf "post-layout SDF sim (%s): " "$CORNER"
  vvp -n "postlayout_$CORNER.vvp" > "postlayout_$CORNER.log" 2>&1 || true
  grep -E "ALL TESTS PASSED|TESTS FAILED" "postlayout_$CORNER.log" || { echo "no result"; tail -5 "postlayout_$CORNER.log"; }
  grep -ciE "sdf.*(error|fail)" "postlayout_$CORNER.log" "postlayout_$CORNER.compile.log" | paste -sd' ' | sed 's/^/  sdf warnings: /' || true
done
