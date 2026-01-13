module CPU(
    input wire clk,
    input wire reset
);

    `include "src/include/define.vh"

    wire [31:0] current_pc;
    reg [31:0] next_pc;

    PC PC(
        .clk(clk), 
        .reset(reset),
        .pc_in(next_pc),
        .pc_out(current_pc)
    );  

    wire [31:0] instruction;

    IMem IMem(
        .clk(clk),
        .addr(current_pc),
        .instruction(instruction)
    );

    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm;

    Decoder Decoder(
        .clk(clk),
        .instruction(instruction),
        .imm(imm),
        .funct7(funct7),
        .rs2(rs2),
        .rs1(rs1),
        .funct3(funct3),
        .rd(rd),
        .opcode(opcode)
    );

    wire [31:0] reg_read_data1;
    wire [31:0] reg_read_data2;
    reg [31:0] reg_write_data;
    wire reg_write = 1'b1; 
    RegisterFile RegisterFile(
        .clk(clk),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(rd),
        .write_data(reg_write_data),
        .reg_write(reg_write),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    wire [3:0] alu_control;
    
    ALUControl ALUControl(
        .clk(clk),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .alu_control(alu_control)
    );


    reg [31:0] alu_input1;
    reg [31:0] alu_input2;
    wire [31:0] alu_result;

    always @(*) begin
        case (opcode) 
            `OP_IMM: begin
                alu_input1 = reg_read_data1;
                alu_input2 = imm;
            end
            `OP_LOAD: begin
                alu_input1 = reg_read_data1;
                alu_input2 = imm;
            end
            `OP_STORE: begin
                alu_input1 = reg_read_data1;
                alu_input2 = imm;
            end
            `OP_R_TYPE: begin
                alu_input1 = reg_read_data1;
                alu_input2 = reg_read_data2;
            end
            `OP_BRANCH: begin
                alu_input1 = reg_read_data1;
                alu_input2 = reg_read_data2;
            end
            `OP_JALR: begin
                alu_input1 = reg_read_data1;
                alu_input2 = imm;
            end
            default: begin
                alu_input1 = reg_read_data1;
                alu_input2 = 32'd0;
            end
        endcase
    end

    ALU ALU(
        .clk(clk),
        .operand1(alu_input1),
        .operand2(alu_input2),
        .alu_control(alu_control),
        .alu_result(alu_result)
    );


    wire [31:0] mem_read_data;
    DMem DMem(
        .clk(clk),
        .addr(alu_result),
        .write_data(reg_read_data2),
        .mem_read(opcode == `OP_LOAD),
        .mem_write(opcode == `OP_STORE),
        .read_data(mem_read_data)
    );


    reg MemtoReg;
    always @(*) begin
        case (opcode)
            `OP_LOAD:    MemtoReg = 1'b1;
            `OP_IMM:  MemtoReg = 1'b0;
            `OP_STORE:      MemtoReg = 1'b0;
            default:     MemtoReg = 1'b0;
        endcase
    end

    always @(*) begin
        case (opcode)
            `OP_JAL,
            `OP_JALR: reg_write_data = pc_plus_4;
            default:
                reg_write_data = MemtoReg ? mem_read_data : alu_result;
        endcase
    end

    reg [31:0] pc_plus_4;
    reg [31:0] pc_branch;
    reg branch_taken;

    always @(*) begin
        branch_taken = 1'b0;
        pc_plus_4 = current_pc + 4;
        pc_branch = 32'b0;
        case (opcode)
            `OP_JAL: begin
                branch_taken = 1'b1;
                pc_branch = current_pc + imm;
            end
            `OP_JALR: begin
                branch_taken = 1'b1;
                pc_branch = (reg_read_data1 + imm) & ~32'b1;
            end
            `OP_BRANCH: begin
                if (alu_result == 32'b0) begin
                    branch_taken = 1'b1;
                    pc_branch = current_pc + imm;
                end
            end
        endcase
        next_pc = branch_taken ? pc_branch : pc_plus_4;
    end



endmodule
