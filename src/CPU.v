module CPU(
    input wire clk,
    input wire reset
);

    wire [31:0] pc_out;

    PC PC(
        .clk(clk), 
        .reset(reset),
        .pc_in(pc_out + 4),
        .pc_out(pc_out)
    );  

    wire [31:0] instruction;

    IMem IMem(
        .clk(clk),
        .addr(pc_out),
        .instruction(instruction)
    );

    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [11:0] imm;

    Decoder Decoder(
        .clk(clk),
        .instruction(instruction),
        .opcode(opcode),
        .rs1(rs1),
        .rd(rd),
        .funct3(funct3),
        .imm(imm)
    );

    wire [31:0] read_data1;
    wire [31:0] write_data;
    wire reg_write = 1'b1; 
    RegisterFile RegisterFile(
        .clk(clk),
        .read_reg1(rs1),
        .write_reg(rd),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1)
    );

    wire [3:0] alu_control;
    ALUControl ALUControl(
        .clk(clk),
        .funct3(funct3),
        .alu_control(alu_control)
    );


    wire [31:0] alu_input1 = read_data1;
    wire [31:0] alu_input2 = {{20{imm[11]}}, imm}; // Sign-extend immediate
    wire [31:0] alu_result;
    ALU ALU(
        .clk(clk),
        .operand1(alu_input1),
        .operand2(alu_input2),
        .alu_control(alu_control),
        .alu_result(alu_result)
    );

    assign write_data = alu_result;

endmodule
