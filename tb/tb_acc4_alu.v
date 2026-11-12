// tb_acc4_alu.v - Exhaustive self-checking testbench for acc4_alu (all 1024 cases)
// Run: iverilog -o alu.vvp ../rtl/acc4_alu.v tb_acc4_alu.v && vvp alu.vvp

`timescale 1ns/1ps

module tb_acc4_alu;

    reg  [3:0] a;          // Operand A
    reg  [3:0] b;          // Operand B
    reg  [1:0] sel;        // Operation select
    wire [3:0] y;          // DUT result
    wire       cout;       // DUT carry / not-borrow
    reg  [4:0] exp;        // Expected {cout, y}
    integer    ia;         // Loop index for a
    integer    ib;         // Loop index for b
    integer    is;         // Loop index for sel
    integer    errors;     // Failure count

    // This contains the instantiation for acc4_alu
    acc4_alu dut (
        .a    (a),
        .b    (b),
        .sel  (sel),
        .y    (y),
        .cout (cout)
    );

    // Sweep every a, b, sel and compare with a reference model
    initial begin
        errors = 0;                                       // No failures yet
        for (is = 0; is < 4; is = is + 1)                 // Every operation
            for (ia = 0; ia < 16; ia = ia + 1)            // Every a
                for (ib = 0; ib < 16; ib = ib + 1) begin  // Every b
                    a = ia; b = ib; sel = is;             // Apply inputs
                    #1;                                   // Let logic settle
                    case (is)                             // Reference model
                        0: exp = {1'b0, a & b};           // AND
                        1: exp = {1'b0, a | b};           // OR
                        2: exp = a + b;                   // ADD with carry
                        default: exp = {(a >= b), a - b}; // SUB, cout = not-borrow
                    endcase                               // End model
                    if ({cout, y} !== exp) begin          // Compare
                        errors = errors + 1;              // Count failure
                        $display("FAIL sel=%0d a=%h b=%h got %b_%h exp %b_%h",
                                 sel, a, b, cout, y, exp[4], exp[3:0]);  // Report
                    end
                end
        if (errors == 0)                                  // Summary
            $display("ALU: ALL 1024 CASES PASSED");       // Success
        else                                              // Failure
            $display("ALU: %0d FAILURES", errors);        // Count
        $finish;                                          // Done
    end

endmodule
