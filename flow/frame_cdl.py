#!/usr/bin/env python3
# frame_cdl.py - Derive the CDL of a pad frame whose AIPAD00 outputs were swapped to OPAD04
#   "xN VSS PADn VDD AIPAD00"  ->  "xN VSS PADn PADn_IN VDD OPAD04"  and PADn_IN added as ports.
# Usage: python3 flow/frame_cdl.py <frame.cdl> <out.cdl> <new_subckt_name> <pad_cdl_basename>
import re, sys

src, dst, name, padcdl = sys.argv[1:5]
s = open(src).read()
ins = []
def rep(m):
    ins.append(m.group(2) + "_IN")
    return "%sVSS %s %s_IN VDD OPAD04" % (m.group(1), m.group(2), m.group(2))
s = re.sub(r"(?m)^(x\d+\s+)VSS (PAD\d+) VDD AIPAD00\s*$", rep, s)
head = re.search(r"(?im)^\.subckt\s+(\S+)\s+(.*)$", s)
old_name, ports = head.group(1), head.group(2).split()
ports = [p for p in ports if p not in ("VDD", "VSS")] + ins + ["VDD", "VSS"]
s = s[:head.start()] + ".SUBCKT %s %s" % (name, " ".join(ports)) + s[head.end():]
s = re.sub(r"(?im)^\.ends\s+%s" % re.escape(old_name), ".ends %s" % name, s)
# KLayout's CDL reader splits unquoted .include paths at '-', so include the pad CDL by bare name
s = re.sub(r"(?im)^\.include\s+.*$", ".include %s" % padcdl, s)
open(dst, "w").write(s)
print("FRAME_CDL: %d AIPAD00 -> OPAD04, subckt %s -> %s" % (len(ins), name, dst))
