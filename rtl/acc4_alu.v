// acc4_alu.v - 4-bit ALU for the acc4_cpu accumulator machine (Verilog-2005)
// sel = opcode[1:0]: 00 AND, 01 OR, 10 ADD, 11 SUB (cout = not-borrow on SUB)

`timescale 1ns/1ps

module acc4_alu (
    input  wire [3:0] a,     // Operand A (accumulator)
    input  wire [3:0] b,     // Operand B (memory data din[3:0])
    input  wire [1:0] sel,   // Operation select (opcode[1:0])
    output reg  [3:0] y,     // 4-bit result
    output reg        cout   // Carry out (ADD) / not-borrow (SUB), 0 for logic ops
);

    localparam SEL_AND = 2'b00;  // Bitwise AND
    localparam SEL_OR  = 2'b01;  // Bitwise OR
    localparam SEL_ADD = 2'b10;  // A + B
    localparam SEL_SUB = 2'b11;  // A - B computed as A + ~B + 1

    wire [4:0] sum_add;          // 5-bit sum for ADD, bit 4 is carry
    wire [4:0] sum_sub;          // 5-bit sum for SUB, bit 4 is not-borrow

    assign sum_add = {1'b0, a} + {1'b0, b};          // Add with carry out
    assign sum_sub = {1'b0, a} + {1'b0, ~b} + 5'd1;  // Two's-complement subtract

    // Combinational result and carry select based on sel
    always @(*) begin
        case (sel)                                   // Decode the operation
            SEL_AND: begin y = a & b;  cout = 1'b0;       end  // AND, no carry
            SEL_OR:  begin y = a | b;  cout = 1'b0;       end  // OR, no carry
            SEL_ADD: begin y = sum_add[3:0]; cout = sum_add[4]; end  // ADD result and carry
            default: begin y = sum_sub[3:0]; cout = sum_sub[4]; end  // SUB result and not-borrow
        endcase                                      // End of operation decode
    end

endmodule
