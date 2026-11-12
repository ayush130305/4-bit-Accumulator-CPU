#!/usr/bin/env bash
# finalize.sh - Build the SCL submission package from layout/chip/OS0000.gds
# Usage: flow/finalize.sh <SiliconNo> <DesignName> <Version> [SiliconNo_block.gds]
#   e.g. flow/finalize.sh OS0123 acc4cpu v1 ~/Downloads/OS0123.gds
# Produces in submission/:
#   <SiNo>_<Design>_<ddmmyyyy>_<ver>.gds       top cell = <SiNo>
#   <SiNo>_<Design>_<ddmmyyyy>_<ver>_drc.txt   DRC report (SCL deck)
#   <SiNo>_<Design>_<ddmmyyyy>_<ver>_md5.txt   md5sum of the GDS
#   ..._lvs.log, ..._gds_rules.txt             extra evidence (not required by SCL)
set -euo pipefail
. "$(dirname "$0")/env.sh"
cd "$PROJ"
SINO="${1:?Silicon No. e.g. OS0123}"; NAME="${2:?design name}"; VER="${3:?version e.g. v1}"; BLOCK="${4:-}"
[[ "$SINO" =~ ^OS[0-9]{4}$ ]] || { echo "Silicon No. must look like OS0001 (upper case)"; exit 1; }
DATE=$(date +%d%m%Y)
BASE="${SINO}_${NAME}_${DATE}_${VER}"
OUT=submission; mkdir -p "$OUT"
GDS="$OUT/$BASE.gds"

ARGS=(-rd ingds=layout/chip/OS0000.gds -rd oldtop=OS0000 -rd sino="$SINO" -rd outgds="$GDS")
[ -n "$BLOCK" ] && ARGS+=(-rd block="$(realpath "$BLOCK")")
# Optional chip art: ART=layout/art/acc4_monkey.gds ART_X=576.5 ART_Y=431 flow/finalize.sh ...
# Optional Silicon No. block position: BLOCK_X=314.9 BLOCK_Y=349.9 flow/finalize.sh ...
[ -n "${BLOCK_X:-}" ] && ARGS+=(-rd block_x="$BLOCK_X" -rd block_y="$BLOCK_Y")
[ -n "${ART:-}" ] && ARGS+=(-rd art="$(realpath "$ART")" -rd art_x="$ART_X" -rd art_y="$ART_Y")
klayout -b "${ARGS[@]}" -r flow/finalize_gds.py

echo "--- SCL GDS rules"
klayout -b -rd gds="$GDS" -rd top="$SINO" -r flow/check_gds_rules.py | tee "$OUT/${BASE}_gds_rules.txt"

echo "--- DRC"
flow/run_drc.sh "$GDS" "checks/final_drc" "$SINO" | head -4
python3 flow/drc_report_txt.py checks/final_drc/drc.lyrdb "$GDS" "$KTECH/drc/c1d_drc.drc" "$SINO" "$OUT/${BASE}_drc.txt"

echo "--- LVS"
sed "s/\bOS0000\b/$SINO/g" lvs/chip.cdl > "lvs/${SINO}.cdl"
flow/run_lvs.sh "$GDS" "lvs/${SINO}.cdl" checks/final_lvs "$SINO"
cp checks/final_lvs/lvs.log "$OUT/${BASE}_lvs.log"

echo "--- MD5"
( cd "$OUT" && md5sum "$BASE.gds" | tee "${BASE}_md5.txt" )
echo; echo "Package in $OUT/:"; ls -la "$OUT" | grep "$BASE"
[ -z "$BLOCK" ] && echo "NOTE: no Silicon No. GDS block inserted - this package is NOT final until you rerun with it."
