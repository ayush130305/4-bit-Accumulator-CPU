// acc4_core.v - Place-and-route block for acc4: CPU plus output inversion for OPAD04 pads
// OPAD04 output pads invert (PAD = ~IN1), so every output leaves the core active-low
// through an INVR06 driver and the pad restores the true level.
// This is the module OpenLane places inside the frame. Simulate with c1d.v (INVR06 model).

`timescale 1ns/1ps

module acc4_core (
    input  wire       clk,       // System clock (from IPAD00 OUT1)
    input  wire       rst_n,     // Asynchronous active-low reset (from IPAD00 OUT1)
    input  wire       run,       // Run / freeze control (from IPAD00 OUT1)
    input  wire [7:0] din,       // Memory data / instruction (from IPAD00 OUT1)
    output wire [4:0] addr_pn,   // Inverted address, to OPAD04 IN1
    output wire [3:0] dout_pn,   // Inverted write data, to OPAD04 IN1
    output wire       rd_pn,     // Inverted read strobe, to OPAD04 IN1
    output wire       we_pn,     // Inverted write enable, to OPAD04 IN1
    output wire       halt_pn    // Inverted halt flag, to OPAD04 IN1
);

    wire [4:0] addr;   // True-polarity address from the CPU
    wire [3:0] dout;   // True-polarity write data from the CPU
    wire       rd;     // True-polarity read strobe from the CPU
    wire       we;     // True-polarity write enable from the CPU
    wire       halt;   // True-polarity halt flag from the CPU

    // This contains the instantiation for acc4_cpu
    acc4_cpu u_cpu (
        .clk   (clk),
        .rst_n (rst_n),
        .run   (run),
        .din   (din),
        .addr  (addr),
        .dout  (dout),
        .rd    (rd),
        .we    (we),
        .halt  (halt)
    );

    // Each output gets an INVR06 (1.86 pF max load) to drive the 0.99 pF OPAD04 input;
    // the inversion is undone by the inverting OPAD04 pad.

    // This contains the instantiation for INVR06
    INVR06 u_drv_addr0 (.IN1(addr[0]), .OUT1(addr_pn[0]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_addr1 (.IN1(addr[1]), .OUT1(addr_pn[1]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_addr2 (.IN1(addr[2]), .OUT1(addr_pn[2]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_addr3 (.IN1(addr[3]), .OUT1(addr_pn[3]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_addr4 (.IN1(addr[4]), .OUT1(addr_pn[4]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_dout0 (.IN1(dout[0]), .OUT1(dout_pn[0]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_dout1 (.IN1(dout[1]), .OUT1(dout_pn[1]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_dout2 (.IN1(dout[2]), .OUT1(dout_pn[2]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_dout3 (.IN1(dout[3]), .OUT1(dout_pn[3]));

    // This contains the instantiation for INVR06
    INVR06 u_drv_rd (.IN1(rd), .OUT1(rd_pn));

    // This contains the instantiation for INVR06
    INVR06 u_drv_we (.IN1(we), .OUT1(we_pn));

    // This contains the instantiation for INVR06
    INVR06 u_drv_halt (.IN1(halt), .OUT1(halt_pn));

endmodule
