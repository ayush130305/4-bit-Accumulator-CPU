// tb_acc4_cpu.v - Self-checking testbench for acc4_cpu (RTL and gate-level)
// Uses only top-level ports, so the same bench runs on the Yosys netlist.
// RTL:  iverilog -o sim.vvp ../rtl/acc4_alu.v ../rtl/acc4_cpu.v tb_acc4_cpu.v && vvp sim.vvp
// Gate: iverilog -gspecify -Tmax -o gl.vvp <c1d.v> ../syn/acc4_cpu_netlist.v tb_acc4_cpu.v && vvp gl.vvp
// Chip top (core + OPAD04 pads): add -DDUT_TOP, <c1d.v>, ../rtl/acc4_top.v and either the RTL
//   (../rtl/acc4_alu.v ../rtl/acc4_cpu.v ../rtl/acc4_core.v) or ../syn/acc4_core_netlist.v

`timescale 1ns/1ps

module tb_acc4_cpu;

    localparam HALF        = 50;   // Half clock period in ns (10 MHz)
    localparam EXP_CYCLES  = 32;   // 16 instructions x 2 clocks to reach HALT
    localparam MAX_CYCLES  = 80;   // Watchdog limit for one program run

    reg        clk;            // Clock driven by the tick task
    reg        rst_n;          // Active-low reset to DUT
    reg        run;            // Run / freeze control to DUT
    wire [7:0] din;            // Memory read data to DUT
    wire [4:0] addr;           // Address from DUT
    wire [3:0] dout;           // Write data from DUT
    wire       rd;             // Read strobe from DUT
    wire       we;             // Write enable from DUT
    wire       halt;           // Halt flag from DUT

    reg  [7:0] mem [0:31];     // 32 x 8 external memory model
    integer    errors;         // Count of failed checks
    integer    cycles;         // Clock counter for the current run
    integer    i;              // Loop variable
    reg  [4:0] addr_hold;      // Address captured before a freeze

    assign din = mem[addr];    // Combinational memory read, same cycle

`ifdef DUT_TOP
    // This contains the instantiation for acc4_top
    acc4_top dut (
`else
    // This contains the instantiation for acc4_cpu
    acc4_cpu dut (
`endif
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

    // Memory write port: store {0, dout} on rising clk when we=1
    always @(posedge clk) begin
        if (we)                               // Write requested by DUT
            mem[addr] <= {4'h0, dout};        // Store accumulator in low nibble
    end

    // One full clock starting and ending mid-low-phase, so inputs set and
    // checks made between ticks never coincide with a rising edge
    task tick;
        begin
            #(HALF/2);                        // Rest of low phase (inputs stable)
            clk = 1'b1;                       // Rising edge
            #HALF;                            // High phase
            clk = 1'b0;                       // Falling edge
            #(HALF/2);                        // First half of low phase (outputs settled)
        end
    endtask

    // Compare a value against its expected value and log the result
    task check;
        input [255:0] name;                   // Label printed with the check
        input [7:0]   got;                    // Observed value
        input [7:0]   exp;                    // Expected value
        begin
            if (got !== exp) begin            // Mismatch, X or Z
                errors = errors + 1;          // Count the failure
                $display("FAIL %0s: got %h expected %h (t=%0t)", name, got, exp, $time);  // Report it
            end else                          // Match
                $display("pass %0s = %h", name, got);  // Log the pass
        end
    endtask

    // Load the test program and data into memory
    task load_program;
        begin
            for (i = 0; i < 32; i = i + 1)    // Clear every word
                mem[i] = 8'hEE;               // Recognisable fill value
            mem[0]  = {3'b000, 5'd20};        // LOAD  20  -> ACC = 5
            mem[1]  = {3'b010, 5'd21};        // ADD   21  -> ACC = 8
            mem[2]  = {3'b001, 5'd25};        // STORE 25  -> mem25 = 8
            mem[3]  = {3'b011, 5'd22};        // SUB   22  -> ACC = 0
            mem[4]  = {3'b111, 5'd7};         // JZ    7   (taken)
            mem[5]  = {3'b001, 5'd30};        // STORE 30  (must be skipped)
            mem[6]  = {3'b001, 5'd30};        // STORE 30  (must be skipped)
            mem[7]  = {3'b000, 5'd23};        // LOAD  23  -> ACC = C
            mem[8]  = {3'b100, 5'd24};        // AND   24  -> ACC = 8
            mem[9]  = {3'b101, 5'd21};        // OR    21  -> ACC = B
            mem[10] = {3'b001, 5'd26};        // STORE 26  -> mem26 = B
            mem[11] = {3'b111, 5'd5};         // JZ    5   (not taken)
            mem[12] = {3'b010, 5'd27};        // ADD   27  -> ACC = 2 (wraps)
            mem[13] = {3'b110, 5'd15};        // JMP   15  (normal jump)
            mem[14] = {3'b001, 5'd30};        // STORE 30  (must be skipped)
            mem[15] = {3'b001, 5'd28};        // STORE 28  -> mem28 = 2
            mem[16] = {3'b011, 5'd21};        // SUB   21  -> ACC = F (borrow)
            mem[17] = {3'b001, 5'd29};        // STORE 29  -> mem29 = F
            mem[18] = {3'b110, 5'd18};        // JMP   18  -> HALT
            mem[20] = 8'hF5;                  // Data 5 (upper nibble must be ignored)
            mem[21] = 8'h93;                  // Data 3
            mem[22] = 8'h68;                  // Data 8
            mem[23] = 8'h0C;                  // Data C
            mem[24] = 8'h5A;                  // Data A
            mem[27] = 8'h37;                  // Data 7
            mem[30] = 8'h55;                  // Sentinel, must never be written
        end
    endtask

    // Apply asynchronous reset in the low clock phase
    task do_reset;
        begin
            rst_n = 1'b0;                     // Assert reset
            #(HALF/2);                        // Hold briefly
            rst_n = 1'b1;                     // Release reset
            #(HALF/2);                        // Settle before next edge
        end
    endtask

    // Check memory results after the program has halted
    task check_results;
        begin
            check("mem25 (LOAD/ADD/STORE)", mem[25], 8'h08);  // 5 + 3
            check("mem26 (AND/OR)",         mem[26], 8'h0B);  // (C & A) | 3
            check("mem28 (ADD wrap, JMP)",  mem[28], 8'h02);  // B + 7 mod 16
            check("mem29 (SUB borrow)",     mem[29], 8'h0F);  // 2 - 3 mod 16
            check("mem30 sentinel",         mem[30], 8'h55);  // Skipped stores
            check("halt",                   {7'd0, halt}, 8'h01);  // Halted
            check("addr at halt",           {3'd0, addr}, 8'd18);  // PC on HALT jump
        end
    endtask

`ifdef SDF_FILE
    // Back-annotate post-layout delays onto the routed core (SCL readme: POSTLAYOUT SIMULATION)
    initial begin
        $sdf_annotate(`SDF_FILE, dut.u_core);  // SDF from flow/rcx_sta.tcl
    end
`endif

    // Main test sequence
    initial begin
        $dumpfile("tb_acc4_cpu.vcd");         // Waveform file for GTKWave
        $dumpvars(0, tb_acc4_cpu);            // Dump everything
        errors = 0;                           // No failures yet
        clk    = 1'b0;                        // Clock idle low
        run    = 1'b1;                        // Running by default
        rst_n  = 1'b1;                        // Reset released

        // Test 1: run program to HALT and check exact cycle count
        $display("--- Test 1: full program ---");  // Section header
        load_program;                         // Fill memory
        do_reset;                             // Reset CPU
        check("addr after reset", {3'd0, addr}, 8'd0);  // PC starts at 0
        check("rd in FETCH",      {7'd0, rd},   8'd1);  // Fetch reads memory
        cycles = 0;                           // Start count
        while (!halt && cycles < MAX_CYCLES) begin  // Run until halt or watchdog
            tick;                             // One clock
            cycles = cycles + 1;              // Count it
        end
        check("cycles to HALT", cycles[7:0], EXP_CYCLES);  // 2 clocks per instruction
        check_results;                        // Verify memory

        // Test 2: HALT holds - no bus writes, addr frozen
        $display("--- Test 2: HALT holds ---");  // Section header
        for (i = 0; i < 6; i = i + 1) begin   // A few more clocks
            if (we) begin                     // No writes allowed when halted
                errors = errors + 1;          // Count failure
                $display("FAIL we asserted while halted");  // Report
            end
            tick;                             // Clock
        end
        check("still halted", {7'd0, halt}, 8'd1);      // Stays halted
        check("addr held",    {3'd0, addr}, 8'd18);     // Address unchanged

        // Test 3: run=0 freezes mid-program, then completes identically
        $display("--- Test 3: run freeze ---");  // Section header
        load_program;                         // Fresh memory
        do_reset;                             // Reset CPU
        for (i = 0; i < 5; i = i + 1)         // Execute a little (into EXEC of instr 2)
            tick;                             // Clock
        run = 1'b0;                           // Freeze
        #20;                                  // Let strobes settle (real pad + gate delays)
        addr_hold = addr;                     // Remember address
        check("rd gated by run", {7'd0, rd}, 8'd0);     // No read while frozen
        check("we gated by run", {7'd0, we}, 8'd0);     // No write while frozen (STORE pending)
        for (i = 0; i < 7; i = i + 1)         // Clock while frozen
            tick;                             // Clock
        check("addr frozen", {3'd0, addr}, {3'd0, addr_hold});  // No progress
        check("mem25 untouched", mem[25], 8'hEE);       // STORE did not fire
        run = 1'b1;                           // Resume
        cycles = 5;                           // Already did 5 running clocks
        while (!halt && cycles < MAX_CYCLES) begin  // Run to halt
            tick;                             // Clock
            cycles = cycles + 1;              // Count running clocks
        end
        check("cycles with freeze", cycles[7:0], EXP_CYCLES);  // Frozen clocks not counted
        check_results;                        // Same results as Test 1

        // Test 4: asynchronous reset mid-run, no clock edge needed
        $display("--- Test 4: async reset ---");  // Section header
        load_program;                         // Fresh memory
        do_reset;                             // Reset CPU
        for (i = 0; i < 9; i = i + 1)         // Run into the program
            tick;                             // Clock
        rst_n = 1'b0;                         // Assert reset with clk low
        #5;                                   // Wait less than a clock
        check("addr async reset", {3'd0, addr}, 8'd0);  // PC cleared at once
        check("halt async reset", {7'd0, halt}, 8'd0);  // Not halted
        check("dout async reset", {4'd0, dout}, 8'd0);  // ACC cleared
        rst_n = 1'b1;                         // Release
        #(HALF - 5);                          // Back on the tick grid
        cycles = 0;                           // Restart count
        while (!halt && cycles < MAX_CYCLES) begin  // Run to halt
            tick;                             // Clock
            cycles = cycles + 1;              // Count
        end
        check("cycles after reset", cycles[7:0], EXP_CYCLES);  // Clean restart
        check_results;                        // Same results again

        // Summary
        if (errors == 0)                      // All checks passed
            $display("ALL TESTS PASSED");     // Success banner
        else                                  // Something failed
            $display("TESTS FAILED: %0d error(s)", errors);  // Failure banner
        $finish;                              // End simulation
    end

endmodule
