module Decoder(
    input wire clk,
    input wire [31:0] instruction,
    output reg [31:0] imm,
    output wire [6:0] funct7,
    output wire [4:0] rs2,
    output wire [4:0] rs1,
    output wire [2:0] funct3,
    output wire [4:0] rd,
    output wire [6:0] opcode
);
    `include "define.vh"
    
    assign funct7 = instruction[31:25];
    assign rs2 = instruction[24:20];
    assign rs1 = instruction[19:15];
    assign funct3 = instruction[14:12];
    assign rd = instruction[11:7];
    assign opcode = instruction[6:0];
    
    always @(*) begin
        case (opcode) 
            `OP_STORE: begin // S-type
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; 
            end
            `OP_BRANCH: begin // B-type
                imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            end
            `OP_JAL: begin // J-type
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0}; 
            end // I-type
            `OP_LUI, `OP_AUIPC: begin
                imm = {instruction[31:12], 12'b0};
            end
            default: begin
                imm = {{20{instruction[31]}}, instruction[31:20]};
            end
        endcase
    end    
endmodule
