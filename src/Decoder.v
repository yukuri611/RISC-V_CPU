module Decoder(
    input wire clk,
    input wire [31:0] instruction,
    output reg [11:0] imm,
    output wire [6:0] funct7,
    output wire [4:0] rs2,
    output wire [4:0] rs1,
    output wire [2:0] funct3,
    output wire [4:0] rd,
    output wire [6:0] opcode
);
    `include "src/include/define.vh"
    
    assign funct7 = instruction[31:25];
    assign rs2 = instruction[24:20];
    assign rs1 = instruction[19:15];
    assign funct3 = instruction[14:12];
    assign rd = instruction[11:7];
    assign opcode = instruction[6:0];
    
    always @(*) begin
        if (opcode == `OP_STORE) begin
            imm = {instruction[31:25], instruction[11:7]};
        end else begin
            imm = instruction[31:20];
        end
    end    
endmodule
