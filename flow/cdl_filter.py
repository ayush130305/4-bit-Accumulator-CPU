#!/usr/bin/env python3
# cdl_filter.py - Copy a CDL keeping only subckts NOT defined in an exclude CDL
# (SCL's core_iolib_c1d.cdl also defines the IO pads, which clash with the pad-frame CDL in LVS).
# Usage: python3 flow/cdl_filter.py <in.cdl> <exclude.cdl> <out.cdl>
import re, sys

src, excl, dst = sys.argv[1:4]
skip = {m.group(1).upper() for m in re.finditer(r"(?im)^\.subckt\s+(\S+)", open(excl).read())}
out, keep, kept, dropped = [], True, 0, 0
for line in open(src):
    m = re.match(r"(?i)^\.subckt\s+(\S+)", line)
    if m:
        keep = m.group(1).upper() not in skip
        kept += keep; dropped += not keep
    if keep:
        out.append(line)
    if re.match(r"(?i)^\.ends", line):
        keep = True
open(dst, "w").writelines(out)
print("CDL_FILTER: kept %d subckts, dropped %d -> %s" % (kept, dropped, dst))
