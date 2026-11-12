// acc4_top.v - Chip-level top for acc4 in the SCL C1D 3mm x 3mm standard pad frame
// Inputs : IPAD00 (series resistor + ESD, passive) on even pads -> wired straight to the core.
//          IPAD00 has no Verilog model, so the input pads are not instantiated here.
// Outputs: AIPAD00 on odd pads replaced by OPAD04 (inverting output driver, PAD = ~IN1).
// Power  : PVDD01 / PVSS01 positions unchanged (frame requirement).
// Simulate with c1d.v (provides OPAD04). Port names match acc4_cpu so tb_acc4_cpu.v drives either.
//
// Pad map (3mm frame, PAD1..PAD24):
//   PAD1  addr[0]  PAD2  clk     PAD13 dout[1]  PAD14 din[3]
//   PAD3  addr[1]  PAD4  rst_n   PAD15 dout[2]  PAD16 din[4]
//   PAD5  addr[2]  PAD6  run     PAD17 dout[3]  PAD18 din[5]
//   PAD7  addr[3]  PAD8  din[0]  PAD19 rd       PAD20 din[6]
//   PAD9  addr[4]  PAD10 din[1]  PAD21 we       PAD22 din[7]
//   PAD11 dout[0]  PAD12 din[2]  PAD23 halt     PAD24 unused input (tie low on board)

`timescale 1ns/1ps

module acc4_top (
    input  wire       clk,    // PAD2  - system clock
    input  wire       rst_n,  // PAD4  - asynchronous active-low reset
    input  wire       run,    // PAD6  - run / freeze control
    input  wire [7:0] din,    // PAD8..PAD22 (even) - memory data / instruction
    output wire [4:0] addr,   // PAD1..PAD9 (odd)   - memory address
    output wire [3:0] dout,   // PAD11..PAD17 (odd) - memory write data
    output wire       rd,     // PAD19 - memory read strobe
    output wire       we,     // PAD21 - memory write enable
    output wire       halt    // PAD23 - halt flag
);

    wire [4:0] addr_pn;   // Inverted address from core to OPAD04
    wire [3:0] dout_pn;   // Inverted write data from core to OPAD04
    wire       rd_pn;     // Inverted read strobe from core to OPAD04
    wire       we_pn;     // Inverted write enable from core to OPAD04
    wire       halt_pn;   // Inverted halt flag from core to OPAD04

    // This contains the instantiation for acc4_core
    acc4_core u_core (
        .clk     (clk),
        .rst_n   (rst_n),
        .run     (run),
        .din     (din),
        .addr_pn (addr_pn),
        .dout_pn (dout_pn),
        .rd_pn   (rd_pn),
        .we_pn   (we_pn),
        .halt_pn (halt_pn)
    );

    // This contains the instantiation for OPAD04
    OPAD04 pad01_addr0 (.PAD(addr[0]), .IN1(addr_pn[0]));

    // This contains the instantiation for OPAD04
    OPAD04 pad03_addr1 (.PAD(addr[1]), .IN1(addr_pn[1]));

    // This contains the instantiation for OPAD04
    OPAD04 pad05_addr2 (.PAD(addr[2]), .IN1(addr_pn[2]));

    // This contains the instantiation for OPAD04
    OPAD04 pad07_addr3 (.PAD(addr[3]), .IN1(addr_pn[3]));

    // This contains the instantiation for OPAD04
    OPAD04 pad09_addr4 (.PAD(addr[4]), .IN1(addr_pn[4]));

    // This contains the instantiation for OPAD04
    OPAD04 pad11_dout0 (.PAD(dout[0]), .IN1(dout_pn[0]));

    // This contains the instantiation for OPAD04
    OPAD04 pad13_dout1 (.PAD(dout[1]), .IN1(dout_pn[1]));

    // This contains the instantiation for OPAD04
    OPAD04 pad15_dout2 (.PAD(dout[2]), .IN1(dout_pn[2]));

    // This contains the instantiation for OPAD04
    OPAD04 pad17_dout3 (.PAD(dout[3]), .IN1(dout_pn[3]));

    // This contains the instantiation for OPAD04
    OPAD04 pad19_rd    (.PAD(rd),      .IN1(rd_pn));

    // This contains the instantiation for OPAD04
    OPAD04 pad21_we    (.PAD(we),      .IN1(we_pn));

    // This contains the instantiation for OPAD04
    OPAD04 pad23_halt  (.PAD(halt),    .IN1(halt_pn));

endmodule
