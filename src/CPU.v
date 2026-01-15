module CPU(
    input wire clk,
    input wire reset
);

    `include "src/include/define.vh"

    // =========================================================================
    // 1. IF Stage (Instruction Fetch)
    // =========================================================================

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

    // IF/ID Pipeline Register
    reg [31:0] IF_ID_PC;
    reg [31:0] IF_ID_Instruction;


    // =========================================================================
    // 2. ID Stage (Instruction Decode)
    // =========================================================================
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm;
    wire [3:0] alu_control;
    wire [31:0] reg_read_data1, reg_read_data2;
    
    reg [31:0] reg_write_data;

    Decoder Decoder(
        .clk(clk),
        .instruction(IF_ID_instruction),
        .imm(imm),
        .funct7(funct7),
        .rs2(rs2),
        .rs1(rs1),
        .funct3(funct3),
        .rd(rd),
        .opcode(opcode)
    );

    ALUControl ALUControl(
        .clk(clk),
        .opcode(opcode),
        .funct7(funct7),
        .funct3(funct3),
        .alu_control(alu_control)
    );


    RegisterFile RegisterFile(
        .clk(clk),
        .read_reg1(rs1),
        .read_reg2(rs2),
        .write_reg(Mem_WB_rd_index),
        .write_data(reg_write_data),
        .reg_write(Mem_WB_Reg_Write),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    // Control Unit Logic
    reg reg_write_ctrl;
    reg alu_src_ctrl;
    reg mem_to_reg_ctrl;

    always @(*) begin
        // RegWrite
        case (opcode)
            `OP_R_TYPE, `OP_IMM, `OP_LOAD, `OP_JAL, `OP_JALR: reg_write_ctrl = 1'b1;
            default: reg_write_ctrl = 1'b0;
        endcase

        // ALUSrc
        case (opcode)
            `OP_IMM, `OP_LOAD, `OP_STORE, `OP_JALR: alu_src_ctrl = 1'b1;
            default: alu_src_ctrl = 1'b0;
        endcase

        // MemtoReg
        case (opcode)
            `OP_LOAD: mem_to_reg_ctrl = 1'b1;
            default:  mem_to_reg_ctrl = 1'b0;
        endcase
    end
    
    // branch jump logic
    reg [31:0] pc_plus_4;
    reg [31:0] pc_branch;
    reg branch_taken;
    wire is_equal = (reg_read_data1 == reg_read_data2);
    wire is_less_signed = ($signed(reg_read_data1) < $signed(reg_read_data2));
    wire is_less_unsigned = (reg_read_data1 < reg_read_data2);


    always @(*) begin
        branch_taken = 1'b0;
        pc_plus_4 = IF_ID_PC + 4;
        pc_branch = 32'b0;
        case (opcode)
            `OP_JAL: begin
                branch_taken = 1'b1;
                pc_branch = IF_ID_PC + imm;
            end
            `OP_JALR: begin
                branch_taken = 1'b1;
                pc_branch = (reg_read_data1 + imm) & ~32'b1;
            end
            `OP_BRANCH: begin
                case (funct3)
                    3'b000: branch_taken = is_equal;        // BEQ
                    3'b001: branch_taken = !is_equal;       // BNE
                    3'b100: branch_taken = is_less_signed;  // BLT
                    3'b101: branch_taken = !is_less_signed; // BGE
                    3'b110: branch_taken = is_less_unsigned;// BLTU
                    3'b111: branch_taken = !is_less_unsigned;// BGEU
                    default: branch_taken = 1'b0;
                endcase
                if (branch_taken) begin
                    pc_branch = IF_ID_PC + imm;
                end
            end
        endcase
        next_pc = branch_taken ? pc_branch : pc_plus_4;
    end


    // ID/Ex Pipeline Register
    reg ID_Ex_Mem_Read, ID_Ex_Mem_Write, ID_Ex_Reg_Write, ID_Ex_Mem_to_Reg;
    reg [31:0] ID_Ex_rs1_data, ID_Ex_rs2_data, ID_Ex_imm, ID_Ex_PC;
    reg [4:0]  ID_Ex_rd_index;
    reg [3:0]  ID_Ex_ALU_Control;
    reg        ID_Ex_ALU_Src;


    // =========================================================================
    // 3. EX Stage (Execute)
    // =========================================================================
    reg [31:0] alu_input1;
    reg [31:0] alu_input2;
    wire [31:0] alu_result;

    always @(*) begin
        alu_input1 = ID_Ex_rs1_data;
        alu_input2 = ID_Ex_ALU_Src ? ID_Ex_imm : ID_Ex_rs2_data;
    end

    ALU ALU(
        .clk(clk),
        .operand1(alu_input1),
        .operand2(alu_input2),
        .alu_control(ID_Ex_ALU_Control),
        .alu_result(alu_result)
    );

    // Ex/Mem Pipeline Register
    reg Ex_Mem_Mem_Read, Ex_Mem_Mem_Write, Ex_Mem_Reg_Write, Ex_Mem_Mem_to_Reg;
    reg [31:0] Ex_Mem_ALU_Result, Ex_Mem_rs2_data;
    reg [4:0]  Ex_Mem_rd_index;


    // =========================================================================
    // 4. MEM Stage (Memory Access)
    // =========================================================================
    wire [31:0] mem_read_data;
    DMem DMem(
        .clk(clk),
        .addr(Ex_Mem_ALU_Result),
        .write_data(Ex_Mem_rs2_data),
        .mem_read(Ex_Mem_Mem_Read),
        .mem_write(Ex_Mem_Mem_Write),
        .read_data(mem_read_data)
    );

    // Mem/WB Pipeline Register
    reg Mem_WB_Reg_Write, Mem_WB_Mem_to_Reg;
    reg [31:0] Mem_WB_Read_Data, Mem_WB_ALU_Result;
    reg [4:0]  Mem_WB_rd_index;


    // =========================================================================
    // 5. WB Stage (Write Back)
    // =========================================================================

    always @(*) begin
        reg_write_data = Mem_WB_Mem_to_Reg ? Mem_WB_Read_Data : Mem_WB_ALU_Result;
    end


    // =========================================================================
    // Pipeline Register Update Logic
    // =========================================================================
    always @(posedge clk or negedge reset) begin
        if(!reset) begin
            // IF/ID Pipeline Register
            IF_ID_PC <= 32'b0;
            IF_ID_Instruction <= 32'b0;
            
            // ID/Ex Pipeline Register
            ID_Ex_Mem_Read <= 1'b0;
            ID_Ex_Mem_Write <= 1'b0;
            ID_Ex_Reg_Write <= 1'b0;
            ID_Ex_Mem_to_Reg <= 1'b0;
            ID_Ex_rs1_data <= 32'b0;
            ID_Ex_rs2_data <= 32'b0;
            ID_Ex_imm <= 32'b0;
            ID_Ex_rd_index <= 5'b0;
            ID_Ex_ALU_Src <= 1'b0;
            ID_Ex_ALU_Control <= 4'b0;
            ID_Ex_PC <= 32'b0;
            
            // Ex/Mem Pipeline Register
            Ex_Mem_Mem_Read <= 1'b0;
            Ex_Mem_Mem_Write <= 1'b0;
            Ex_Mem_Reg_Write <= 1'b0;
            Ex_Mem_Mem_to_Reg <= 1'b0;
            Ex_Mem_ALU_Result <= 32'b0;
            Ex_Mem_rs2_data <= 32'b0;
            Ex_Mem_rd_index <= 5'b0;
            
            // Mem/WB Pipeline Register
            Mem_WB_Reg_Write <= 1'b0;
            Mem_WB_Mem_to_Reg <= 1'b0;
            Mem_WB_Read_Data <= 32'b0;
            Mem_WB_ALU_Result <= 32'b0;
            Mem_WB_rd_index <= 5'b0;
        end else begin
            // IF/ID Stage
            IF_ID_PC <= current_pc;
            IF_ID_Instruction <= instruction;
            
            // ID/Ex Stage
            ID_Ex_Mem_Read <= (opcode == `OP_LOAD);
            ID_Ex_Mem_Write <= (opcode == `OP_STORE);
            ID_Ex_Reg_Write <= reg_write_ctrl;
            ID_Ex_Mem_to_Reg <= mem_to_reg_ctrl;
            ID_Ex_rs1_data <= reg_read_data1;
            ID_Ex_rs2_data <= reg_read_data2;
            ID_Ex_imm <= imm;
            ID_Ex_rd_index <= rd;
            ID_Ex_ALU_Src <= alu_src;
            ID_Ex_ALU_Control <= alu_control;
            ID_Ex_PC <= current_pc;
            
            // Ex/Mem Stage
            Ex_Mem_Mem_Read <= ID_Ex_Mem_Read;
            Ex_Mem_Mem_Write <= ID_Ex_Mem_Write;
            Ex_Mem_Reg_Write <= ID_Ex_Reg_Write;
            Ex_Mem_Mem_to_Reg <= ID_Ex_Mem_to_Reg;
            Ex_Mem_ALU_Result <= alu_result;
            Ex_Mem_rs2_data <= ID_Ex_rs2_data;
            Ex_Mem_rd_index <= ID_Ex_rd_index;
            
            // Mem/WB Stage
            Mem_WB_Reg_Write <= Ex_Mem_Reg_Write;
            Mem_WB_Mem_to_Reg <= Ex_Mem_Mem_to_Reg;
            Mem_WB_Read_Data <= mem_read_data;
            Mem_WB_ALU_Result <= Ex_Mem_ALU_Result;
            Mem_WB_rd_index <= Ex_Mem_rd_index;
        end
    end

endmodule
