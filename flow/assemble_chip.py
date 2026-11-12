# assemble_chip.py - Frame + routed core + core-to-pad channel wiring -> chip GDS and chip CDL
# Usage:
#   klayout -b -rd padmap=<padmap.json> -rd edges=<edge_pins.json> -rd coredef=<4_route.def>
#           -rd coregds=<core.gds> -rd top=<TOPCELL> -rd outgds=<chip.gds> -rd outcdl=<chip.cdl>
#           -rd corecir=<core.cir> -rd cellcdl=<core_iolib_c1d.cdl> -r flow/assemble_chip.py
#
# Channel routing (per side): every net gets  M2 "normal" leg out of its pad stub
#   -> M1 "parallel" leg at its own track -> M2 normal leg into its core pin (via onto M1 pins / stripes).
# Track order per side is chosen by exhaustive search so no two nets overlap or violate spacing on a layer.
import itertools, json, math, os, re
import pya

M1, V1, M2, M2T, M1T = (8, 0), (9, 0), (10, 0), (10, 7), (8, 7)
CUT, CUT_SP, ENC = 1.5, 1.5, 0.5               # via1 size, spacing, metal enclosure
SPACE = 4.0                                     # Clearance kept between different nets (> 1.5/1.7 rules)
G = 0.005

pm = json.load(open(padmap))
edge = json.load(open(edges))
ox, oy = pm["core_origin"]
W, H = pm["die_size"]
ws, wp = pm["signal_width"], pm["power_width"]
RING_IN = (304.9, 2695.1)                       # Inner edge of the 3 mm pad ring

def snap(v): return round(round(v / G) * G, 3)

# ---- Core pins from the routed DEF (core-local -> frame coords) -----------------------------------
dtxt = open(coredef).read()
dbu_def = int(re.search(r"UNITS DISTANCE MICRONS (\d+)", dtxt).group(1))
core_pins = {}
for m in re.finditer(r"- (\S+) \+ NET \S+.*?\+ LAYER (metal\d) \( (-?\d+) (-?\d+) \) \( (-?\d+) (-?\d+) \).*?\+ (?:PLACED|FIXED) \( (-?\d+) (-?\d+) \) (\w+)", dtxt, re.S):
    name = m.group(1).replace("\\", "")
    x, y = int(m.group(7)) / dbu_def + ox, int(m.group(8)) / dbu_def + oy
    core_pins[name] = (x, y, m.group(2))

# ---- Build net list per side -------------------------------------------------------------------------
def side_of(net):
    return edge[net][0][0]
def stub_centre(net):
    s, l, x1, y1, x2, y2 = edge[net][0]
    return ((x1 + x2) / 2, (y1 + y2) / 2)

nets = {"S": [], "N": [], "W": [], "E": []}
for port, padnet in pm["pins"].items():
    s = side_of(padnet)
    sx, sy = stub_centre(padnet)
    cx, cy, lay = core_pins[port]
    p = sx if s in "SN" else sy
    c = cx if s in "SN" else cy
    nets[s].append(dict(name=port, pad=padnet, p=p, c=c, w=ws, kind="sig", core_layer=lay))
for pwr in ("VDD", "VSS"):
    yc = pm["power"][pwr]["stripe_y_frame"]
    for s, l, x1, y1, x2, y2 in edge[pwr]:
        if s in "WE" and l == "m2":             # PVDD01 / PVSS01 metal2 stubs on the W/E sides
            nets[s].append(dict(name=pwr, pad=pwr, p=(y1 + y2) / 2, c=yc, w=wp, kind="pwr", core_layer="metal1"))

# Side geometry: e = pad edge coordinate, k = core edge coordinate, d = inward direction (+1/-1)
geom = {"S": (RING_IN[0], oy, +1), "N": (RING_IN[1], oy + H, -1),
        "W": (RING_IN[0], ox, +1), "E": (RING_IN[1], ox + W, -1)}

def segs(n, t, s):
    """Rectangles (layer, box in frame coords) for one net at track t on side s, plus via squares."""
    e, k, d = geom[s]
    h = n["w"] / 2
    a0, a1 = e - 3 * d, t + h * d                # Pad leg: starts 3 um into the stub
    deep = 22.0 if n["kind"] == "pwr" else 3.0   # How far the core leg enters the core block
    c0, c1 = t - h * d, k + deep * d
    q0, q1 = min(n["p"], n["c"]) - h, max(n["p"], n["c"]) + h
    def rect(nlo, nhi, plo, phi):                # (normal range, parallel range) -> DBox
        nlo, nhi = min(nlo, nhi), max(nlo, nhi)
        return pya.DBox(plo, nlo, phi, nhi) if s in "SN" else pya.DBox(nlo, plo, nhi, phi)
    out = [(M2, rect(a0, a1, n["p"] - h, n["p"] + h)),
           (M1, rect(t - h, t + h, q0, q1)),
           (M2, rect(c0, c1, n["c"] - h, n["c"] + h))]
    vias = [rect(t - h, t + h, n["p"] - h, n["p"] + h), rect(t - h, t + h, n["c"] - h, n["c"] + h)]
    if n["kind"] == "pwr":                       # Land on the M1 edge stripe just inside the core
        vias.append(rect(k + 2 * d, k + deep * d, n["c"] - h, n["c"] + h))
    elif n["core_layer"] == "metal1":            # W/E signal pins are M1: via at the pin
        vias.append(rect(k + 1.5 * d, k + 4.5 * d, n["c"] - 1.5, n["c"] + 1.5))
        out[2] = (M2, rect(c0, k + 4.5 * d, n["c"] - h, n["c"] + h))
    return out, vias

def clash(a, b):
    """True if two nets' shapes come within SPACE on the same layer."""
    for la, ba in a:
        for lb, bb in b:
            if la == lb and ba.enlarged(SPACE / 2).overlaps(bb.enlarged(SPACE / 2)):
                return True
    return False

plan = {}
for s, lst in nets.items():
    e, k, d = geom[s]
    n = len(lst)
    span = abs(k - e)
    tracks = [e + d * (30 + i * (span - 60) / max(n - 1, 1)) for i in range(n)]
    tracks = [snap(t) for t in tracks]
    best = None
    for perm in itertools.permutations(range(n)):
        shapes = [segs(lst[i], tracks[j], s)[0] for j, i in enumerate(perm)]
        if any(clash(shapes[a], shapes[b]) for a in range(n) for b in range(a + 1, n)):
            continue
        wl = sum(abs(lst[i]["p"] - lst[i]["c"]) for i in perm)
        best = perm
        break
    if best is None:
        raise RuntimeError("no planar track order on side %s" % s)
    plan[s] = [(lst[i], tracks[j]) for j, i in enumerate(best)]
    print("SIDE %s: " % s + ", ".join("%s@%.1f" % (nn["name"], t) for nn, t in plan[s]))

# ---- Build the layout ----------------------------------------------------------------------------------
ly = pya.Layout(); ly.dbu = 0.001
ly.read(pm["frame_gds"])
frame_top = [c for c in ly.top_cells()][0]
core_ly = pya.Layout(); core_ly.read(coregds)
core_src = core_ly.top_cells()[0]
core = ly.create_cell(core_src.name)
core.copy_tree(core_src)
chip = ly.create_cell(top)
chip.insert(pya.DCellInstArray(frame_top.cell_index(), pya.DTrans(0, 0)))
chip.insert(pya.DCellInstArray(core.cell_index(), pya.DTrans(ox, oy)))
L = {k: ly.layer(*k) for k in (M1, V1, M2, M1T, M2T)}

def via_array(box):
    """Fill a metal overlap box with via1 cuts (1.5 um, 1.5 um spacing, 0.5 um enclosure)."""
    inner = box.enlarged(-ENC)
    nx = max(1, int((inner.width() + CUT_SP) // (CUT + CUT_SP)))
    ny = max(1, int((inner.height() + CUT_SP) // (CUT + CUT_SP)))
    used_x = nx * CUT + (nx - 1) * CUT_SP
    used_y = ny * CUT + (ny - 1) * CUT_SP
    x0 = inner.left + (inner.width() - used_x) / 2
    y0 = inner.bottom + (inner.height() - used_y) / 2
    for i in range(nx):
        for j in range(ny):
            x, y = snap(x0 + i * (CUT + CUT_SP)), snap(y0 + j * (CUT + CUT_SP))
            chip.shapes(L[V1]).insert(pya.DBox(x, y, x + CUT, y + CUT))

def snapbox(b):
    return pya.DBox(snap(b.left), snap(b.bottom), snap(b.right), snap(b.top))

for s, lst in plan.items():
    for n, t in lst:
        shapes, vias = segs(n, t, s)
        for lay, b in shapes:
            chip.shapes(L[lay]).insert(snapbox(b))
        for b in vias:
            if n["kind"] == "pwr" or b.width() >= 2.5:
                chip.shapes(L[M1]).insert(snapbox(b))   # Make sure both metals cover the via
                chip.shapes(L[M2]).insert(snapbox(b))
                via_array(snapbox(b))

# Top-level labels for LVS: copy the frame's pad / power labels into the chip top cell
for lk in (M1T, M2T):
    for sh in frame_top.shapes(ly.layer(*lk)).each():
        if sh.is_text():
            t = sh.dtext
            chip.shapes(L[lk]).insert(pya.DText(t.string, pya.DTrans(snap(t.x), snap(t.y))))

# Flatten nothing; drop the old frame/core tops from the top-cell list by keeping them as children only
ly.write(outgds)
print("CHIP: top=%s bbox=%s -> %s" % (top, chip.dbbox(), outgds))

# ---- Chip CDL -------------------------------------------------------------------------------------------
fcdl = open(pm["frame_cdl"]).read()
fhead = re.search(r"(?is)\.subckt\s+(\S+)\s+(.*?)\n(?!\+)", re.sub(r"\n\+", " ", fcdl))
frame_name, frame_ports = fhead.group(1), fhead.group(2).split()
core_head = re.search(r"(?im)^\.subckt\s+(\S+)\s+(.*)$", open(corecir).read())
core_name, core_ports = core_head.group(1), core_head.group(2).split()
core_map = {p: (pm["pins"].get(p) or p) for p in core_ports}
pads = ["PAD%d" % i for i in range(1, 25)]
cdl_dir = os.path.dirname(os.path.abspath(outcdl))
with open(outcdl, "w") as f:
    f.write("* %s chip netlist generated by flow/assemble_chip.py\n" % top)
    f.write(".include %s\n" % os.path.relpath(os.path.abspath(pm["frame_cdl"]), cdl_dir))
    f.write(".include %s\n" % os.path.relpath(os.path.abspath(cellcdl), cdl_dir))
    f.write(".include %s\n" % os.path.relpath(os.path.abspath(corecir), cdl_dir))
    f.write(".SUBCKT %s %s VDD VSS\n" % (top, " ".join(pads)))
    f.write("Xframe %s %s\n" % (" ".join(frame_ports), frame_name))
    f.write("Xcore %s %s\n" % (" ".join(core_map[p] for p in core_ports), core_name))
    f.write(".ENDS %s\n" % top)
print("CDL: %s (frame %s, core %s)" % (outcdl, frame_name, core_name))
