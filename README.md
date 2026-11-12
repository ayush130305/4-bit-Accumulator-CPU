# acc4cpu: 4-bit accumulator CPU on SCL 1.2 um C1D (Silicon No. OS0084)

A 4-bit accumulator CPU taped out on SCL's 1.2 um C1D open PDK, in the standard 3 mm x 3 mm pad frame
(28-pin DIP chip-on-board).

- **ISA:** 8-bit instructions, `[7:5]` opcode, `[4:0]` address, 32-word external memory.
  LOAD, STORE, ADD, SUB, AND, OR, JMP, JZ. JMP to its own address = HALT. 2 clocks per instruction.
- **Pins:** even pads = inputs (IPAD00): clk, rst_n, run, din[7:0]. Odd pads = outputs (OPAD04): addr[4:0],
  dout[3:0], rd, we, halt. 2 x PVDD01 / 2 x PVSS01. Full pad map in `rtl/acc4_top.v`.
- **Timing:** signed off at 10 MHz (100 ns), worst setup slack +74.96 ns, hold +2.03 ns.
- **Verification:** RTL, ALU (1,024 cases), gate-level and post-layout SDF simulation pass at min/typ/max; LVS match;
  DRC 0 violations with `c1d_drc.drc` v1.1.

## Layout of this repo

| Folder | Contents |
|---|---|
| `rtl/` | Verilog-2005 RTL: `acc4_cpu.v` (core FSM), `acc4_alu.v`, `acc4_core.v`, `acc4_top.v` (chip top + pads) |
| `tb/` | Self-checking testbenches, simulation logs and waveform |
| `syn/` | Yosys scripts, logs and synthesised netlists |
| `flow/` | Place-and-route, GDS assembly and check scripts (OpenROAD in the OpenLane 1.0.2 container, KLayout) |
| `pnr/` | DEFs per P&R stage, routed and power netlists, pin placement |
| `signoff/` | STA at min/typ/max: SDF, SPEF, timing and DRV reports |
| `lvs/` | Design netlists for LVS |
| `checks/` | DRC / LVS logs and DRC marker databases, grid audit, submission DRC reports |
| `layout/art/` | Chip art (metal-only) |
| `submission/` | DRC report and MD5 of the submitted v3 GDS |
| `docs/` | Runbook, teaching guide, diagrams, KLayout 2.5D script |

## Not in this repo

These are SCL's or are not redistributable:

- the SCL C1D PDK and anything copied from it: standard-cell / IO-pad libraries (LEF, CDL, Verilog models),
  the pad frame, the DRC/LVS decks
- GDS files that contain SCL cells or the pad frame (core, chip and submission GDS), the OpenROAD database,
  transistor-level LVS extractions, and compiled simulations that bundle SCL's cell models
- the SCL-issued Silicon No. block and requisition, and the submission paperwork

To rebuild, get the PDK from SCL / eChipHub, put it under `~/scl/` as the scripts expect, and follow `docs/RUNBOOK.md`.
