#!/usr/bin/env python3
# make_diagrams.py - Draw the teaching-document diagrams (block diagram, FSM, design flow) as PNGs.
# Usage: python3 docs/make_diagrams.py   (writes docs/img/block.png, fsm.png, flow.png)
import math, os
from PIL import Image, ImageDraw, ImageFont

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "img")
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
FONTB = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
INK, BLUE, GREEN, ORANGE, GREY = (30, 30, 30), (31, 78, 121), (46, 125, 50), (196, 96, 0), (110, 110, 110)
FILL = {"reg": (220, 232, 245), "logic": (226, 241, 226), "ext": (252, 236, 214), "ctl": (240, 228, 245)}

def font(sz, bold=False):
    return ImageFont.truetype(FONTB if bold else FONT, sz)

def box(d, xy, text, kind, sub=None):
    x1, y1, x2, y2 = xy
    d.rounded_rectangle(xy, 14, fill=FILL[kind], outline=INK, width=3)
    f = font(30, True)
    tw = d.textlength(text, font=f)
    cy = (y1 + y2) / 2 - (18 if sub else 0)
    d.text(((x1 + x2 - tw) / 2, cy - 17), text, font=f, fill=INK)
    if sub:
        fs = font(22)
        for i, line in enumerate(sub.split("|")):
            sw = d.textlength(line, font=fs)
            d.text(((x1 + x2 - sw) / 2, cy + 20 + i * 27), line, font=fs, fill=GREY)

def arrow(d, pts, color=INK, label=None, lpos=None, w=4):
    d.line(pts, fill=color, width=w, joint="curve")
    (xa, ya), (xb, yb) = pts[-2], pts[-1]
    ang = math.atan2(yb - ya, xb - xa)
    L = 18
    p1 = (xb - L * math.cos(ang - 0.4), yb - L * math.sin(ang - 0.4))
    p2 = (xb - L * math.cos(ang + 0.4), yb - L * math.sin(ang + 0.4))
    d.polygon([(xb, yb), p1, p2], fill=color)
    if label:
        f = font(22)
        x, y = lpos if lpos else ((xa + xb) / 2, (ya + yb) / 2)
        d.text((x, y), label, font=f, fill=color)

# ---- 1. Block diagram -------------------------------------------------------------------------
img = Image.new("RGB", (2000, 1420), "white"); d = ImageDraw.Draw(img)
d.text((40, 25), "acc4cpu — datapath and control", font=font(38, True), fill=BLUE)
box(d, (90, 200, 420, 370), "PC", "reg", "5-bit program|counter")
box(d, (90, 520, 420, 690), "IR", "reg", "8-bit instruction|register")
box(d, (620, 360, 940, 540), "Address", "logic", "mux: PC (FETCH)|or IR[4:0] (EXEC)")
box(d, (1220, 160, 1660, 420), "External", "ext", "32 x 8 memory|(FPGA / Arduino)")
box(d, (1220, 680, 1580, 860), "ALU", "logic", "AND OR ADD SUB|sel = opcode[1:0]")
box(d, (900, 940, 1240, 1110), "ACC", "reg", "4-bit|accumulator")
box(d, (380, 960, 720, 1140), "FSM", "ctl", "FETCH -> EXEC|-> HALT")
box(d, (1720, 950, 1960, 1100), "Zero", "logic", "ACC == 0")
arrow(d, [(420, 285), (520, 285), (520, 420), (620, 420)], label="pc", lpos=(530, 330))
arrow(d, [(420, 570), (540, 570), (540, 500), (620, 500)], label="ir[4:0]", lpos=(430, 530))
arrow(d, [(940, 450), (1080, 450), (1080, 300), (1220, 300)], BLUE, "addr[4:0]", (960, 405))
arrow(d, [(1440, 420), (1440, 680)], ORANGE, "din[3:0]", (1455, 630))
arrow(d, [(1440, 610), (470, 610), (470, 650), (420, 650)], ORANGE, "din[7:0] (instruction)", (700, 570))
arrow(d, [(1400, 860), (1400, 1020), (1240, 1020)], INK, "alu_y", (1410, 900))
arrow(d, [(1070, 940), (1070, 770), (1220, 770)], INK, "acc", (1080, 840))
arrow(d, [(1240, 1070), (1720, 1070)], INK, None)
arrow(d, [(1240, 970), (1690, 970), (1690, 300), (1660, 300)], GREEN, "dout[3:0] = acc", (1700, 600))
arrow(d, [(1840, 1100), (1840, 1260), (650, 1260), (650, 1140)], GREY, "zero (for JZ)", (1150, 1265))
arrow(d, [(550, 960), (550, 840), (255, 840), (255, 690)], GREY, "load IR / PC", (290, 800))
arrow(d, [(720, 1050), (900, 1050)], GREY, "load ACC", (735, 1060))
arrow(d, [(380, 1050), (40, 1050), (40, 120), (1440, 120), (1440, 160)], GREEN, "rd, we, halt", (600, 80))
d.text((40, 1360), "Blue: address bus   Orange: data in   Green: data / strobes out   Grey: control", font=font(24), fill=GREY)
img.save(os.path.join(OUT, "block.png"))

# ---- 2. FSM ---------------------------------------------------------------------------------------
img = Image.new("RGB", (1700, 800), "white"); d = ImageDraw.Draw(img)
d.text((40, 25), "Control FSM (2 clocks per instruction)", font=font(38, True), fill=BLUE)
def state(cx, cy, name, sub):
    d.ellipse((cx - 170, cy - 110, cx + 170, cy + 110), fill=FILL["ctl"], outline=INK, width=4)
    f = font(34, True); tw = d.textlength(name, font=f); d.text((cx - tw / 2, cy - 45), name, font=f, fill=INK)
    fs = font(21)
    for i, line in enumerate(sub.split("|")):
        sw = d.textlength(line, font=fs); d.text((cx - sw / 2, cy + 5 + i * 26), line, font=fs, fill=GREY)
state(300, 400, "FETCH", "addr = PC, rd = 1|IR <= din, PC <= PC+1")
state(900, 400, "EXEC", "addr = IR[4:0]|do the instruction")
state(1450, 400, "HALT", "halt = 1|wait for reset")
arrow(d, [(470, 360), (730, 360)], INK, "run = 1", (545, 320))
arrow(d, [(730, 450), (470, 450)], INK, "run = 1 (not self-JMP)", (470, 465))
arrow(d, [(1070, 400), (1280, 400)], INK, "JMP to own", (1100, 330))
d.text((1100, 358), "address", font=font(22), fill=INK)
arrow(d, [(130, 620), (130, 400)], ORANGE, "rst_n = 0 (async)", (20, 640))
d.text((260, 680), "run = 0 in any state: every register holds (single-step from the FPGA)", font=font(24), fill=GREY)
img.save(os.path.join(OUT, "fsm.png"))

# ---- 3. Flow ---------------------------------------------------------------------------------------
steps = [
    ("RTL", "Verilog-2005", "rtl/*.v"), ("Simulate", "Icarus + self-check", "tb/*.v"),
    ("Synthesize", "Yosys -> C1D cells", "syn/*.ys"), ("Gate sim", "c1d.v models", "tb + -gspecify"),
    ("Floorplan", "rows, pins, power", "OpenROAD"), ("Place", "global + detailed + resize", "OpenROAD"),
    ("Clock tree", "CDRI01 drivers", "OpenROAD CTS"), ("Route", "2 metal layers", "TritonRoute"),
    ("DEF -> GDS", "real cell layouts", "KLayout"), ("DRC / LVS", "SCL decks", "KLayout"),
    ("Chip", "frame + core + wires", "assemble_chip.py"), ("Signoff", "RCX, STA, SDF sim", "OpenRCX / OpenSTA"),
    ("Package", "OS0084 GDS, DRC, MD5", "finalize.sh"),
]
cols, bw, bh, gx, gy = 4, 400, 150, 70, 90
rows = math.ceil(len(steps) / cols)
img = Image.new("RGB", (cols * bw + (cols + 1) * gx, rows * bh + (rows + 1) * gy + 80), "white"); d = ImageDraw.Draw(img)
d.text((gx, 25), "RTL to GDSII flow used for acc4cpu", font=font(38, True), fill=BLUE)
pos = []
for i, (t, s, tool) in enumerate(steps):
    r, c = divmod(i, cols)
    if r % 2: c = cols - 1 - c                   # Snake layout so arrows stay short
    x1 = gx + c * (bw + gx); y1 = 80 + gy + r * (bh + gy)
    kind = "logic" if i < 4 else ("reg" if i < 8 else ("ctl" if i < 12 else "ext"))
    box(d, (x1, y1, x1 + bw, y1 + bh), t, kind, s + "|" + tool)
    pos.append((x1, y1))
for i in range(len(pos) - 1):
    (xa, ya), (xb, yb) = pos[i], pos[i + 1]
    if ya == yb:
        if xb > xa: arrow(d, [(xa + bw, ya + bh / 2), (xb, yb + bh / 2)])
        else:       arrow(d, [(xa, ya + bh / 2), (xb + bw, yb + bh / 2)])
    else:
        arrow(d, [(xa + bw / 2, ya + bh), (xb + bw / 2, yb)])
img.save(os.path.join(OUT, "flow.png"))
print("diagrams written to", OUT)
