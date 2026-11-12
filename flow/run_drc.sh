#!/usr/bin/env bash
# run_drc.sh <layout.gds> <out_dir> [top_cell] - SCL C1D KLayout DRC; prints violation count
set -euo pipefail
. "$(dirname "$0")/env.sh"
GDS="$(realpath "$1")"; OUT="$(realpath -m "$2")"; TOP="${3:-}"
mkdir -p "$OUT"
ARGS=(-rd input="$GDS" -rd report1="$OUT/drc.lyrdb")
[ -n "$TOP" ] && ARGS+=(-rd top_cell="$TOP")
klayout -b "${ARGS[@]}" -r "$KTECH/drc/c1d_drc.drc" > "$OUT/drc.log" 2>&1
N=$(grep -c '<item>' "$OUT/drc.lyrdb" || true)
echo "DRC $GDS : $N violation(s)  (report $OUT/drc.lyrdb)"
python3 - "$OUT/drc.lyrdb" <<'PY'
import sys,re,collections
t=open(sys.argv[1]).read()
c=collections.Counter(re.findall(r"<item>.*?<category>'?([^<']+)'?</category>",t,re.S))
for k,v in c.most_common(): print(f"  {v:6d}  {k}")
PY
