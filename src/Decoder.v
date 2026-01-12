module Decoder(
    input wire clk,
    input wire [31:0] instruction,
    output wire [6:0] opcode,
    output wire [4:0] rs1,
    output wire [4:0] rd,
    output wire [2:0] funct3,
    output wire [11:0] imm
);
    assign opcode = instruction[6:0];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign imm = instruction[31:20];
    
endmodule
