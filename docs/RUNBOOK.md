# acc4 — SCL 1.2 µm C1D tapeout runbook

Every command used to take acc4 from RTL to a submission GDS on Ubuntu 26.04, in order,
with each error hit along the way and its fix. Written so you can rerun it, or reuse it for
the next submission (new design or new Silicon No.).

Conventions: run from the project root (`~/Desktop/4bit ACC CPU`) unless a `cd` says
otherwise. `. flow/env.sh` sets all PDK paths. Anything marked **YOU** needs your login,
signature or an SCL-issued file.

---

## 0. Machine setup (one time)

```bash
lsb_release -a                       # Ubuntu 26.04.1 LTS here
sudo apt update && sudo apt upgrade -y
sudo apt install -y git make unzip python3-pip python3-venv iverilog gtkwave yosys \
                    ngspice xschem magic klayout docker.io
sudo usermod -aG docker $USER
sudo reboot                          # new kernel + docker group
docker run --rm hello-world          # must print "Hello from Docker!" without sudo
```

Versions that worked: Yosys 0.52, Icarus 12.0, KLayout 0.30.0 (apt), ngspice 45.2, magic 8.3,
Docker 29.1.3, OpenLane 1.0.2 image `ff5509f6…`.

| Error | Cause | Fix |
|---|---|---|
| `sudo: timed out` | password prompt left unanswered | rerun the apt command |
| `sg: command not found` | `sg`/`newgrp` not shipped on 26.04 | reboot (or log out/in) for docker group |
| `docker: permission denied` before reboot | group not active in current login | reboot |

### OpenLane (only the image, not sky130)

```bash
cd ~ && git clone https://github.com/The-OpenROAD-Project/OpenLane.git
cd ~/OpenLane && make get-openlane          # plain `make` also downloads sky130 — not needed
I=ghcr.io/the-openroad-project/openlane:ff5509f65b17bfa4068d5336495ab1718987ff69
docker tag $I $I-amd64                      # `make mount` runs the -amd64 tag
```

| Error | Cause | Fix |
|---|---|---|
| `make mount` would pull a missing `…-amd64` tag | Makefile appends `-$(DOCKER_ARCH)` | `docker tag` as above |
| `[ERROR STA-0511] cannot open '/tmp/…'` in container | only `$HOME` is mounted | keep scripts under `$HOME` |

### PDK

```bash
P="$HOME/Desktop/4bit ACC CPU/SCL 1.2 µm PDK/SCL_C1D_PDK_17092026"
mkdir -p ~/scl && cp "$P/Digital_C1D/my_dtech.zip" "$P/PadFrame_C1D/PadFrame_C1D.zip" ~/scl/
cd ~/scl && unzip -q my_dtech.zip && unzip -q PadFrame_C1D.zip
grep -rlE '/(\./)+my_dtech' ~/scl/my_dtech | xargs sed -i -E "s#/(\./)+my_dtech#$HOME/scl/my_dtech#g"
grep -rlE '/(\./)+my_dtech' ~/scl/my_dtech | wc -l     # must be 0 (was 14 files)
```

### Validate KLayout decks on SCL's own frame (must be clean)

```bash
flow/run_drc.sh ~/scl/PadFrame_C1D/pad_frame_gds/frame3mmx3mm.gds ~/scl/checks/padframe3mm
flow/run_lvs.sh ~/scl/PadFrame_C1D/pad_frame_gds/frame3mmx3mm.gds \
                ~/scl/PadFrame_C1D/pad_frame_cdl/frame3mmx3mm.cdl ~/scl/checks/padframe3mm
```

Result: DRC 0 items in 72 rule categories; LVS "Netlists match" — same as SCL's PNG reports.

| Error | Cause | Fix |
|---|---|---|
| `Unable to open file …/klayout/lvs_cdl/io_pad_c1d.cdl` | concatenated CDLs broke the frame's relative `.include` | pass the original CDL from `pad_frame_cdl/` |

---

## 1. RTL and simulation

Files: `rtl/acc4_alu.v`, `rtl/acc4_cpu.v`, `rtl/acc4_core.v`, `rtl/acc4_top.v`,
`tb/tb_acc4_alu.v`, `tb/tb_acc4_cpu.v`.

```bash
. flow/env.sh
cd tb
iverilog -o alu.vvp ../rtl/acc4_alu.v tb_acc4_alu.v && vvp -n alu.vvp           # 1024 cases
iverilog -o sim.vvp ../rtl/acc4_alu.v ../rtl/acc4_cpu.v tb_acc4_cpu.v && vvp -n sim.vvp
iverilog -DDUT_TOP -o top.vvp $C1D_V ../rtl/acc4_alu.v ../rtl/acc4_cpu.v \
         ../rtl/acc4_core.v ../rtl/acc4_top.v tb_acc4_cpu.v && vvp -n top.vvp
cd ..
```

Expect `ALL TESTS PASSED` (and `ALU: ALL 1024 CASES PASSED`).

| Error | Cause | Fix |
|---|---|---|
| gate-level only: `FAIL cycles with freeze: got 21 expected 20` | testbench changed `run` in the same timestep as the rising clock edge | `tick` task now changes inputs / checks outputs mid low phase |
| `Some modules have no timescale` | RTL lacked `` `timescale `` | added `` `timescale 1ns/1ps `` to RTL |

### Output pad decision

The 3 mm frame ships AIPAD00 "output" pads, which are only ESD + a series resistor (no driver).
PDDR04 is a *pre-driver* for the bidirectional BPD pads (outputs `P_EN`/`N_EN`), so it doesn't apply.
Core cells are rated ≤ 2.5 pF against ~10–15 pF of pad + package + board + FPGA load.
Decision: replace the 12 AIPAD00 with **OPAD04** (driver pad, `PAD = ~IN1`, 49.6 pF max).
SCL's frame doc allows replacing I/O pads; only the power pads are fixed.

- OPAD04 inverts → `acc4_core` drives every output through an **INVR06** (inverting, 1.86 pF max),
  because OPAD04's `IN1` is 0.99 pF, above the 0.81 pF limit of the cells that drove it before.
- Pad map is in the header of `rtl/acc4_top.v` (odd PADs = outputs, even PADs = inputs, PAD24 unused).

---

## 2. Synthesis

```bash
yosys -l syn/synth.log      syn/synth_acc4.ys        # CPU only  -> syn/acc4_cpu_netlist.v
yosys -l syn/synth_core.log syn/synth_acc4_core.ys   # P&R block -> syn/acc4_core_netlist.v
```

acc4_core: 169 cells, 19 DFCL11, 12 INVR06, area 448.9.

```bash
cd tb
for T in max typ min; do
  iverilog -DDUT_TOP -gspecify -T$T -o topgl.vvp $C1D_V ../syn/acc4_core_netlist.v \
           ../rtl/acc4_top.v tb_acc4_cpu.v && vvp -n topgl.vvp | tail -2
done
cd ..
```

| Error | Cause | Fix |
|---|---|---|
| `Wire acc4_cpu.\addr is used but has no driver` (×12) | liberty cells unknown to `check` → no pin directions | `read_liberty -lib <lib>` first |
| extra DFPR11, 20 flops instead of 19 | Yosys FSM recoding | `synth -nofsm` |
| `sed` replaced the `<MY_DTECH>` placeholder in a comment too | placeholder also appeared in the comment | the script now has the real path baked in |

---

## 3. Pad frame with OPAD04

```bash
. flow/env.sh
klayout -b -rd frame=$PADF/pad_frame_gds/frame3mmx3mm.gds -rd lib=$PADF/klayout/gds/io_pad_c1d.gds \
        -rd old=AIPAD00 -rd new=OPAD04 -rd out=layout/frame/frame3mmx3mm_opad.gds \
        -rd pin_x=191.575 -rd pin_y=2.0 -rd suffix=_IN -rd label_layer=10/7 -r flow/swap_pads.py
flow/run_drc.sh layout/frame/frame3mmx3mm_opad.gds checks/frame_drc
flow/run_lvs.sh layout/frame/frame3mmx3mm_opad.gds layout/frame/frame3mmx3mm_opad.cdl checks/frame_lvs
```

The CDL (`layout/frame/frame3mmx3mm_opad.cdl`) replaces each `VSS PADn VDD AIPAD00` with
`VSS PADn PADn_IN VDD OPAD04` and adds `PADn_IN` ports. Result: DRC 0, LVS match.

| Error | Cause | Fix |
|---|---|---|
| `Unable to open file: /home//ayush` | KLayout's CDL reader splits an unquoted `.include` path at `-` (`ayush-jain`) | copy `io_pad_c1d.cdl` next to the CDL, `.include io_pad_c1d.cdl` |
| LVS mismatch: extracted OPAD04 has 3 pins | `IN1` floating in a frame-only layout → not a pin | `swap_pads.py` labels each `IN1` as `PADn_IN` (layer 10/7) |

---

## 4. One command for everything after RTL

```bash
flow/run_all.sh OS0000          # frame -> synth -> P&R -> DRC loop -> LVS -> chip -> DRC/LVS -> STA/SDF sim
flow/finalize.sh OS0084 acc4cpu v1 gds/OS0084.gds             # Silicon No. OS0084 + SCL's block
```

`run_all.sh` stops at the first failing check. Useful knobs (environment variables):
`CLK_PERIOD=100` (ns), `PL_DENSITY=0.35`, `MIN_GAP=20` (µm, see 5.3), `IO_DELAY=10`, `OUT_LOAD=1.0`,
`SKIP_PNR=1` (reuse the routed core), `KEEP_BLOCKAGES=1` (keep earlier via fixes).

What each step runs, and the problems each one solved, are below.

---

## 5. Place & route of the core (`flow/run_pnr.sh` → `flow/pnr_core.tcl`)

Based on SCL's `scripts_template/*.tcl` (floorplan → pdn → placement → cts → routing) merged into one
parameterized OpenROAD run inside the OpenLane container. Design-specific inputs live in
`flow/padmap_acc4.json` (die size, where the core sits in the frame, which core port goes to which pad,
power stripe positions) — **for a new design, edit only that file and the synth script.**

- Die 1600 × 1600 µm placed at (700, 700) in the 3 mm frame; core area margin 100 µm.
- SCL: delete every other row after `initialize_floorplan` (14 rows kept, row pitch 97.4 µm).
- Pins are placed with `place_pin` facing their pads (`flow/gen_pins.py`).
- Power: M1/M2 ring (12 µm), 9 µm followpins, plus one 20 µm M1 **edge stripe** per net (VDD at core
  y = 608.75, VSS at 998.35 — both row-gap centres) running die edge to die edge so the frame's PVDD01 /
  PVSS01 can be wired to the core from the W and E sides.
- `repair_design` (resizer) after global placement, clock tree from CDRI01 clock drivers.
- Cells abutted after CTS (`abut_rows`), no fillers, then 2-metal routing.

| Error / symptom | Cause | Fix |
|---|---|---|
| `[ERROR STA-0404] Usage: source …` | project path has spaces (`4bit ACC CPU`) | space-free link `~/acc4` (`PROJ_NS` in `env.sh`) used for every container path |
| `[ERROR PDN-1009] The -pitch argument is required.` | single strap still needs `-pitch` | — then replaced by OpenDB stripes (next row) |
| edge stripes silently missing from the DEF | pdngen drops `-nets` stripes / stripes that overlap followpins | `add_edge_stripe` proc creates them with OpenDB + VIA12 arrays on the same-net ring legs |
| `[ERROR DRT-0416] … offgrid pin shape … not a multiple of the manufacturing grid 5` | SCL `core_c1d.lef` has 1463 RECTs off the 0.005 µm grid | `flow/snap_lef.py` → `pnr/lef/core_c1d_snapped.lef` (pins shrink inward, OBS grow outward). Routing abstract only; the cell GDS is untouched |
| run killed, exit 141 | `… \| head -60` closed the pipe and killed OpenROAD | write the full log, grep afterwards |
| `[ERROR DPL-0036] Detailed placement failed` (2 cells) | cells left in a deleted-row gap beyond the default search distance | `detailed_placement -max_displacement {500 200}` |
| `repair_design` after CTS ran > 7 min with no output | resizer stall on the clock-buffered netlist | only run `repair_design` once, before CTS |

### 5.1 DEF → GDS
`flow/def2gds.py` streams the routed DEF with SCL's `scl_c1d.map` and takes every macro from SCL's
`core_c1d.gds` (`macro_resolution_mode = 2`, never LEF geometry); it fails if any cell comes out empty.

### 5.2 Core DRC problems and fixes

| DRC rule | Where | Cause | Fix |
|---|---|---|---|
| 5.7.1 boron spacing 1.5 µm (11×), 5.4.1 / 5.5.1 | always a FILLER next to a logic cell | `SITE CORE` is 0.01 µm wide, so cells land 0.0x µm apart; SCL fillers only bridge boron in y 33–40 µm of the row, leaving < 1.5 µm notches, and FILLER5's boron square reaches into neighbour ndiff | after CTS, abut any two cells closer than `MIN_GAP` = 20 µm (left shifts only → no overlaps) and use **no fillers**. 20 µm also clears nwell spacing (7 µm) |
| 9.3.1 via–contact 1.5 µm, 9.4.1 via–poly 1.2 µm (13×) | all on NND201 pins | router lands via1 on the NND201 pin square too close to its contact / gate | `abc -dont_use NND201` in synthesis (ABC builds the logic from other cells) |
| `@GUIDELINE-6 avoid placing vias on diff edges` (1×) | one AND201 via | — | DRC-driven via fix loop: `flow/via_blockages_from_drc.py` turns each marker's via into a via1 obstruction (`via_blockages.txt`), re-route; `run_all.sh` repeats up to 5× |

Tried and dropped (kept here so you don't repeat it): adding poly/contact as via1 OBS in a routing LEF,
or growing LEF pins to the full metal1 of the pin → `[ERROR DRT-0073] No access point` on ~90 pins.

### 5.3 Core LVS
`flow/v2spice.py` converts the routed netlist to SPICE using SCL's CDL pin order.

| Error | Cause | Fix |
|---|---|---|
| every `\u_cpu.*` net became `\U_CP` | SCL's `verilog2spice.py` mangles escaped Verilog identifiers | own converter `flow/v2spice.py` |
| `Redefinition of circuit BPD220 in core_iolib_c1d.cdl` | SCL's std-cell CDL also defines the IO pads | `flow/cdl_filter.py` keeps only cells not in the pad CDL → `lvs/core_cells.cdl` |

---

## 6. Chip assembly (`flow/assemble_chip.py`)

Frame + core + wiring in one top cell (`OS0000` until you have the Silicon No.).
For every net on every side: M2 leg out of the pad stub → M1 along its own track → M2 leg into the core
pin (via onto M1 pins on W/E, via arrays onto the edge stripes for power). The track order on each side
is found by exhaustive search so no two nets share a layer within 4 µm. The frame's pad labels are copied
into the top cell so LVS sees the chip's pins. It also writes `lvs/chip.cdl`.

Negative test done once: swapping two pad connections in `chip.cdl` makes LVS fail — so a match is real.

---

## 7. Signoff (`flow/run_signoff.sh` → `flow/rcx_sta.tcl`)

OpenRCX with SCL's `scl_c1d.rcx.lib` → SPEF; OpenSTA at min / typ / max liberty → reports + SDF;
then the same self-checking testbench on the routed netlist with `$sdf_annotate` (`-DSDF_FILE`).
Constraints: 100 ns clock, 10 ns input/output delay, 1.0 pF output load (OPAD04 input = 0.99 pF),
`rst_n` false path.

| Error | Cause | Fix |
|---|---|---|
| post-layout sim: `FAIL we gated by run` | bench checked `we` 1 ns after dropping `run`; real pad + gate delay is longer | bench waits 20 ns |
| ~270 max-slew violations (7 ns vs 2.5 ns limit) | 1.2 µm cells, long wires, SCL template has no resizer | `repair_design` after placement, CDRI01 clock tree |

---

## 8. Submission package (`flow/finalize.sh`)

Silicon No. **OS0084**, design name **acc4cpu**. The SCL-issued block `gds/OS0084.gds` is not in this repo (it comes with your Silicon No.).

```bash
flow/finalize.sh OS0084 acc4cpu v1 gds/OS0084.gds
```

1. SCL's block `gds/OS0084.gds` has one top cell already named `OS0084` (270 × 60 µm at origin, built from
   `char_*` cells). That cell becomes the chip's top cell **as received** — same coordinates, no move,
   scale or edit — and the assembled chip is merged into it. The block lands in the frame's lower-left
   corner directly under SCL's `OS_SCL_logo` (225–275, 60–125), which is where the frame expects it.
2. checks top cell / origin (0,0) / even top-right / 0.005 µm grid (`flow/check_gds_rules.py`),
3. DRC with SCL's deck → `OS0084_acc4cpu_<ddmmyyyy>_v1_drc.txt`,
4. LVS again with the final top cell,
5. `md5sum` → `OS0084_acc4cpu_<ddmmyyyy>_v1_md5.txt`.

| Error | Cause | Fix |
|---|---|---|
| block didn't fit the 210 µm reserved spot | block is 270 × 60 µm | keep it at its own origin (frame corner under the SCL logo) |
| `a cell named OS0084 already exists` | block top cell = required chip top cell name | block cell *is* the top; chip goes inside it |
| LVS mismatch, nets named `$2.PAD4` | chip as a child cell → its labels became hierarchical | chip instance flattened one level into `OS0084` |

Files go to `submission/`. Upload on echiphub: GDS, signed tapeout form, DRC report, MD5 report.

### Things only you can do (YOU)
- Request the Silicon No. on echiphub (same login as the PDK download) → you get the number and its GDS block.
- Check the portal for a newer DRC deck than the one in the PDK (`c1d_drc.drc`, Sep 2026). If there is
  one, drop it into `$KTECH/drc/` and rerun `flow/finalize.sh`.
- Sign the Design Tapeout Submission Form; check the shuttle deadline.

---

## 9. Reusing this for another submission

1. New RTL in `rtl/`, testbench in `tb/`, synth script in `syn/` (keep `read_liberty -lib`, `-nofsm`, `-dont_use NND201`).
2. Copy `flow/padmap_acc4.json`, set `design`, `pins` (core port → `PADn_IN` / `PADn_OUT`), die size.
   Pick power stripe y values at row-gap centres: core-local 219.15 + 97.4·k, frame y = that + core origin y.
3. Point `run_all.sh` at the new padmap / design name and run it.
4. For a different frame size, run `flow/edge_pins.py` on it — every pad's inner-edge stub comes out in
   `pnr/edge_pins.json`, which `gen_pins.py` and `assemble_chip.py` use.

---

## 10. Results of the v1 package (08-11-2026)

`submission/OS0084_acc4cpu_08112026_v1.gds`, MD5 `96fdba6fec37dd4bf3161fae605ada44`

| Check | Result |
|---|---|
| Frame (OPAD04) DRC / LVS | 0 violations / match |
| Core DRC / LVS | 0 (clean at placement density 0.38 after the via-fix loop) / match |
| Chip DRC (SCL deck, 72 rules) / LVS | 0 / match |
| STA setup / hold slack (min, typ, max) | +77.0 / +2.0, +75.6 / +3.3, +75.0 / +3.7 ns at 100 ns clock |
| Post-layout SDF simulation (min, typ, max) | ALL TESTS PASSED at all three |
| Max-slew violators (limit 2.5 ns) | 110 (max) – 158 (min); median 4 ns, worst 12 ns — open item |
| Top cell / origin / even corner | PASS |
| 0.005 µm grid | only SCL-supplied geometry is off-grid: std cells, pads, the OS0084 block (998 pts, identical in `gds/OS0084.gds`), one frame ring polygon. All our geometry is on grid |

### Viewing in KLayout
```bash
. flow/env.sh
klayout -l $KTECH/scl_c1d.lyp submission/OS0084_acc4cpu_08112026_v1.gds \
        -m checks/final_drc/drc.lyrdb -mn checks/final_lvs/lvs.lvsdb
```

### Slew clean-up attempts after v1 (08-11-2026) — not adopted

| Attempt in `pnr_core.tcl` | Result |
|---|---|
| `repair_design -slew_margin 25 -cap_margin 25 -max_wire_length 500`, slow-corner lib | `RSZ-0065 max wire length less than 36981u…`, then run died silently; laptop hung |
| `repair_design -slew_margin 25 -cap_margin 25`, slow-corner lib | stuck in resizer, laptop hung and rebooted |
| `repair_design -slew_margin 20`, typ lib | resizer hit the 8 GB container cap (killed safely) |
| `set_wire_rc … metal1` + `set_max_fanout 4` + plain `repair_design` | resizer hit the 6 GB cap (killed safely) |

Conclusion: in this OpenROAD build (OpenLane 1.0.2 image) `repair_design` only completes with the exact v1
settings (typ lib, metal2 RC, no margin, no fanout limit). Any extra constraint makes it allocate memory
until killed. v1 is therefore the release; its slew violations are documented in section 10.

Safety now built into `run_pnr.sh` / `run_signoff.sh`: each OpenROAD container is named, limited to
6–8 GB RAM and 4 CPUs, and killed after `RUN_TIMEOUT` seconds (default 1200), so a runaway tool can no
longer freeze the laptop.

Ideas if you want to take slew further later (on a machine where a crash doesn't matter):
a newer OpenROAD (OpenLane 2 image), a smaller die (shorter wires: try 1400 × 1400 and re-pick the
stripe y values), or hand-instantiated INVR04/INVR06 drivers on the high-fanout flop outputs in `rtl/`.

---

## 11. Chip art (v2): the monkey from tt_compax

Source: `macros/compax_art.gds` in github.com/ayush130305/tt_compax (sky130 met4 `71/20`, 32 × 42 µm,
0.5 µm squares on a 0.8 µm art grid). Only the monkey is kept (shapes above y = 10 µm); the "COMPAX" text
below it is dropped.

```bash
git clone --depth 1 https://github.com/ayush130305/tt_compax.git ~/scl/work/ext/tt_compax
klayout -b -rd src=$HOME/scl/work/ext/tt_compax/macros/compax_art.gds -rd layer=71/20 -rd ymin=10 \
        -rd px=8 -rd name=acc4_monkey -rd out=layout/art/acc4_monkey.gds -r flow/make_art.py
flow/run_drc.sh layout/art/acc4_monkey.gds checks/art_drc acc4_monkey          # 0 violations
ART=layout/art/acc4_monkey.gds ART_X=576.5 ART_Y=431 flow/finalize.sh OS0084 acc4cpu v2 gds/OS0084.gds
```

- `make_art.py` recovers the art's own pixel grid (0.8 µm), redraws each pixel as an 8 µm metal2 square
  (264 × 256 µm total) and bridges 10 corner-only contacts (they would fail DRC).
- The art is a floating metal2-only cell `acc4_monkey` (custom name), placed in the free patch between the
  PAD1/PAD2 wiring and the core; `finalize_gds.py` refuses if anything comes within 10 µm.
- Pictures: `docs/img/monkey_on_chip.png`, `docs/img/chip_v2.png`.

| v2 result | |
|---|---|
| GDS | `submission/OS0084_acc4cpu_08112026_v2.gds`, MD5 `ac8ba8759037bc53f242f9c37748df0b` |
| DRC (72 rules) / LVS | 0 / match |
| Art cell on 0.005 µm grid | yes |
| Everything else | identical to v1 (same routed core, timing and post-layout sims) |
