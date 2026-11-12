#!/usr/bin/env python3
# snap_lef.py - Routing-only copy of a LEF with every RECT snapped to the manufacturing grid.
# PIN shapes shrink inward (router never lands outside real metal); OBS shapes grow outward
# (router keeps clear of real metal). The std-cell GDS is not touched.
# Usage: python3 flow/snap_lef.py <in.lef> <out.lef> [grid=0.005]
import math, re, sys

src, dst = sys.argv[1], sys.argv[2]
g = float(sys.argv[3]) if len(sys.argv) > 3 else 0.005

def snap(v, mode):
    """Snap v to grid g: 'up' = ceil, 'down' = floor."""
    q = v / g
    q = math.ceil(q - 1e-9) if mode == "up" else math.floor(q + 1e-9)
    return round(q * g, 3)

section = None                                   # 'pin' or 'obs' while inside one
pin_name = None                                  # Current PIN name (its block ends at "END <name>")
fixed = 0
out = []
for line in open(src):
    w = line.split()
    k = w[0].upper() if w else ""
    if k == "PIN" and len(w) > 1:
        section, pin_name = "pin", w[1]          # PIN x ... PORT ... END ... END x
    elif k == "OBS":
        section = "obs"                          # OBS ... END
    elif k == "END":
        if section == "pin" and len(w) > 1 and w[1] == pin_name:
            section = None                       # End of the PIN block
        elif section == "obs" and len(w) == 1:
            section = None                       # End of the OBS block
    m = re.match(r"(\s*RECT\s+)([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)(\s*;.*)", line, re.I)
    if m and section:
        x1, y1, x2, y2 = (float(m.group(i)) for i in range(2, 6))
        lo, hi = ("up", "down") if section == "pin" else ("down", "up")
        nx1, ny1, nx2, ny2 = snap(min(x1, x2), lo), snap(min(y1, y2), lo), snap(max(x1, x2), hi), snap(max(y1, y2), hi)
        if (nx1, ny1, nx2, ny2) != (min(x1, x2), min(y1, y2), max(x1, x2), max(y1, y2)):
            fixed += 1
        line = "%s%.3f %.3f %.3f %.3f%s\n" % (m.group(1), nx1, ny1, nx2, ny2, m.group(6))
    out.append(line)
open(dst, "w").writelines(out)
print("snap_lef: %d RECTs snapped -> %s" % (fixed, dst))
