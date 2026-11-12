// acc4_cpu.v - 4-bit accumulator CPU core (Verilog-2005, SCL 1.2 um C1D)
// Instruction [7:5] opcode, [4:0] address; 32-word external memory.
// 000 LOAD, 001 STORE, 010 ADD, 011 SUB, 100 AND, 101 OR, 110 JMP, 111 JZ.
// JMP to its own address = HALT. FETCH -> EXEC (2 clocks/instr).
// Memory returns din combinationally in the same cycle; writes on rising clk when we=1.

`timescale 1ns/1ps

module acc4_cpu (
    input  wire       clk,    // System clock
    input  wire       rst_n,  // Asynchronous active-low reset
    input  wire       run,    // 1 = execute, 0 = freeze (single-step from FPGA)
    input  wire [7:0] din,    // Data / instruction from external memory
    output reg  [4:0] addr,   // Memory address
    output wire [3:0] dout,   // Data to external memory (accumulator)
    output reg        rd,     // Memory read strobe
    output reg        we,     // Memory write enable
    output wire       halt    // High when CPU has halted
);

    localparam S_FETCH = 2'b00;  // Fetch instruction from mem[pc]
    localparam S_EXEC  = 2'b01;  // Execute instruction held in ir
    localparam S_HALT  = 2'b10;  // Halted until reset

    localparam OP_LOAD  = 3'b000;  // ACC <= mem[a]
    localparam OP_STORE = 3'b001;  // mem[a] <= ACC
    localparam OP_ADD   = 3'b010;  // ACC <= ACC + mem[a]
    localparam OP_SUB   = 3'b011;  // ACC <= ACC - mem[a]
    localparam OP_AND   = 3'b100;  // ACC <= ACC & mem[a]
    localparam OP_OR    = 3'b101;  // ACC <= ACC | mem[a]
    localparam OP_JMP   = 3'b110;  // PC <= a (HALT if a is its own address)
    localparam OP_JZ    = 3'b111;  // PC <= a if ACC == 0

    reg  [1:0] state;      // FSM state register
    reg  [4:0] pc;         // Program counter
    reg  [7:0] ir;         // Instruction register
    reg  [3:0] acc;        // Accumulator

    wire [2:0] opcode;     // Opcode field of ir
    wire [4:0] opaddr;     // Address field of ir
    wire [4:0] pc_prev;    // Address of the instruction now executing (pc - 1)
    wire       zero;       // Accumulator is zero
    wire [3:0] alu_y;      // ALU result
    wire       alu_cout;   // ALU carry / not-borrow (unused at core level)

    assign opcode  = ir[7:5];         // Split opcode
    assign opaddr  = ir[4:0];         // Split address
    assign pc_prev = pc - 5'd1;       // pc was incremented during FETCH
    assign zero    = (acc == 4'd0);   // Combinational zero flag
    assign dout    = acc;             // Accumulator drives write data
    assign halt    = (state == S_HALT);  // Halt status output

    // This contains the instantiation for acc4_alu
    acc4_alu u_alu (
        .a    (acc),
        .b    (din[3:0]),
        .sel  (opcode[1:0]),
        .y    (alu_y),
        .cout (alu_cout)
    );

    // Combinational bus outputs: address mux and read/write strobes
    always @(*) begin
        addr = pc;                                  // Default: point at program counter
        rd   = 1'b0;                                // Default: no read
        we   = 1'b0;                                // Default: no write
        case (state)                                // Decode bus activity by state
            S_FETCH: rd = run;                      // Read instruction when running
            S_EXEC: begin                           // Execute phase bus activity
                addr = opaddr;                      // Point at operand address
                case (opcode)                       // Decode bus use by opcode
                    OP_LOAD, OP_ADD, OP_SUB,
                    OP_AND,  OP_OR:  rd = run;      // Operand read when running
                    OP_STORE:        we = run;      // Write ACC when running
                    default:         ;              // JMP/JZ use no bus cycle
                endcase                             // End opcode decode
            end                                     // End execute phase
            default: ;                              // HALT: bus idle at pc
        endcase                                     // End state decode
    end

    // Sequential FSM, PC, IR and ACC with asynchronous active-low reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                           // Asynchronous reset
            state <= S_FETCH;                       // Start by fetching
            pc    <= 5'd0;                          // Program starts at address 0
            ir    <= 8'd0;                          // Clear instruction register
            acc   <= 4'd0;                          // Clear accumulator
        end else if (run) begin                     // Advance only when run=1
            case (state)                            // FSM state transitions
                S_FETCH: begin                      // Fetch phase
                    ir    <= din;                   // Latch instruction
                    pc    <= pc + 5'd1;             // Point at next instruction
                    state <= S_EXEC;                // Go execute
                end                                 // End fetch phase
                S_EXEC: begin                       // Execute phase
                    state <= S_FETCH;               // Default: fetch next
                    case (opcode)                   // Execute by opcode
                        OP_LOAD:  acc <= din[3:0];  // Load operand
                        OP_STORE: ;                 // Write done by we strobe
                        OP_JMP: begin               // Unconditional jump
                            pc <= opaddr;           // Jump target
                            if (opaddr == pc_prev)  // Jump to itself?
                                state <= S_HALT;    // Then halt
                        end                         // End JMP
                        OP_JZ: if (zero)            // Jump only if ACC == 0
                                   pc <= opaddr;    // Take the branch
                        default:  acc <= alu_y;     // ADD/SUB/AND/OR result
                    endcase                         // End opcode execute
                end                                 // End execute phase
                default: state <= S_HALT;           // HALT (and illegal 11) stay halted
            endcase                                 // End FSM
        end                                         // run=0: hold all state
    end

endmodule
