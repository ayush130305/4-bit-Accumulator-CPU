#!/usr/bin/env python3
# v2spice.py - Structural Verilog (OpenROAD write_verilog) -> SPICE/CDL subckt for KLayout LVS
# Keeps escaped identifiers intact (SCL's verilog2spice.py collapses "\u_cpu.x" names), gives each
# unconnected cell pin its own net, and adds VDD/VSS to every cell from the CDL pin order.
# Usage: python3 flow/v2spice.py <netlist.v> <cells.cdl> <out.sp> [top]
import re, sys

vfile, cdl, out = sys.argv[1], sys.argv[2], sys.argv[3]
src = open(vfile).read()
src = re.sub(r"//.*", "", src)                   # Drop line comments

# Cell pin order from the CDL (".subckt NAME pin pin ...", with "+" continuations)
pins = {}
text = re.sub(r"\n\+", " ", open(cdl).read())
for m in re.finditer(r"(?im)^\.subckt\s+(\S+)\s+(.*)$", text):
    pins[m.group(1).upper()] = m.group(2).split()

def tokens(s):
    """Split Verilog into tokens, keeping escaped identifiers (\\name<space>) whole."""
    return re.findall(r"\\\S+|\w+(?:\s*\[\s*\d+\s*\])?|\[\s*\d+\s*:\s*\d+\s*\]|[().,;]", s)

def norm(net):
    """Spice-safe net name: strip escape, remove spaces, keep brackets and dots."""
    net = net.strip()
    if net.startswith("\\"):
        net = net[1:]
    return re.sub(r"\s+", "", net)

mods = list(re.finditer(r"(?s)\bmodule\s+(\w+)\s*\((.*?)\)\s*;(.*?)\bendmodule", src))
top = sys.argv[4] if len(sys.argv) > 4 else mods[-1].group(1)
mod = [m for m in mods if m.group(1) == top][0]
body = mod.group(3)

# Port list with bus expansion
ports = []
for m in re.finditer(r"(?m)^\s*(input|output|inout)\s*(\[\s*(\d+)\s*:\s*(\d+)\s*\])?\s*([^;]+);", body):
    names = [n.strip() for n in m.group(5).split(",")]
    for n in names:
        if m.group(2):
            hi, lo = int(m.group(3)), int(m.group(4))
            for i in (range(hi, lo - 1, -1) if hi >= lo else range(hi, lo + 1)):
                ports.append("%s[%d]" % (n, i))
        else:
            ports.append(n)

lines, nc, ninst = [], 0, 0
for m in re.finditer(r"(?s)^\s*(\w+)\s+(\\\S+|\w+)\s*\((.*?)\)\s*;", body, re.M):
    cell, inst, conns = m.group(1), m.group(2), m.group(3)
    if cell in ("input", "output", "inout", "wire", "assign", "module"):
        continue
    order = pins.get(cell.upper())
    if order is None:
        sys.exit("v2spice: cell %s not in %s" % (cell, cdl))
    conn = {}
    for cm in re.finditer(r"\.(\w+)\s*\(\s*([^()]*?)\s*\)", conns):
        if cm.group(2):
            conn[cm.group(1).upper()] = norm(cm.group(2))
    nets = []
    for p in order:
        pu = p.upper()
        if pu in ("VDD", "VSS"):
            nets.append(pu)
        elif pu in conn:
            nets.append(conn[pu])
        else:
            nc += 1
            nets.append("NC_%s_%s" % (norm(inst), p))  # Unique net for an unconnected pin
    lines.append("X%s %s %s" % (norm(inst), " ".join(nets), cell))
    ninst += 1

with open(out, "w") as f:
    f.write("* %s from %s by flow/v2spice.py\n" % (top, vfile))
    f.write(".SUBCKT %s %s VDD VSS\n" % (top, " ".join(ports)))
    f.write("\n".join(lines) + "\n")
    f.write(".ENDS %s\n" % top)
print("V2SPICE: %s %d ports %d instances %d unconnected pins -> %s" % (top, len(ports), ninst, nc, out))
