#!/usr/bin/env bash
# run_lvs.sh <layout.gds> <schematic.cdl> <out_dir> [top_cell] - SCL C1D KLayout LVS
set -euo pipefail
. "$(dirname "$0")/env.sh"
GDS="$(realpath "$1")"; CDL="$(realpath "$2")"; OUT="$(realpath -m "$3")"; TOP="${4:-}"
mkdir -p "$OUT"
ARGS=(-rd input="$GDS" -rd schematic1="$CDL" -rd target_netlist1="$OUT/extracted.cir" -rd report="$OUT/lvs.lvsdb")
[ -n "$TOP" ] && ARGS+=(-rd top_cell="$TOP")
( cd "$OUT" && klayout -b "${ARGS[@]}" -r "$KTECH/lvs/lvs_os_scl_c1d.lvs" > "$OUT/lvs.log" 2>&1 ) || true
if grep -q "Netlists match" "$OUT/lvs.log"; then echo "LVS: MATCH ($OUT/lvs.lvsdb)"; else echo "LVS: MISMATCH - see $OUT/lvs.log / lvs.lvsdb"; tail -5 "$OUT/lvs.log"; exit 1; fi
