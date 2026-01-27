module CPU(
    input wire clk,
    input wire reset,
    input wire i_button,
    output reg [5:0] o_led
);

    `include "src/include/define.vh"

    // =========================================================================
    // 0. Declarations
    // =========================================================================

    // --- Button Synchronization Signals ---
    reg button_sync_0, button_sync_1;

    // --- IF Stage Signals ---
    wire [31:0] current_pc;
    reg [31:0] next_pc;
    reg [31:0] next_pc_final;
    wire [31:0] instruction;
    
    // --- IF/ID Pipeline Register ---
    reg [31:0] IF_ID_PC;
    reg [31:0] IF_ID_Instruction;

    // --- ID Stage Signals ---
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm;
    wire [3:0] alu_control;
    wire [31:0] reg_read_data1, reg_read_data2;
    reg [31:0] reg_write_data;
    
    // Control Unit Signals
    reg reg_write_ctrl;
    reg alu_src_ctrl;
    reg mem_to_reg_ctrl;
    reg is_link_control;
    reg [1:0] alu_src_a_ctrl;

    
    // Hazard & Branch Logic Signals
    wire stall;          
    reg branch_taken;
    wire is_branch_instruction;
    reg [31:0] pc_plus_4;
    reg [31:0] pc_branch;
    reg [31:0] branch_op1, branch_op2;
    wire is_equal;
    wire is_less_signed;
    wire is_less_unsigned;


    // ---ID/Ex Pipeline Register---
    reg ID_Ex_Reg_Write, ID_Ex_ALU_Src, ID_Ex_Mem_to_Reg, ID_Ex_Is_Link, ID_Ex_ALU_Src_A, ID_Ex_Mem_Read, ID_Ex_Mem_Write;
    reg [31:0] ID_Ex_rs1_data, ID_Ex_rs2_data, ID_Ex_imm, ID_Ex_PC;
    reg [4:0]  ID_Ex_rd_index, ID_Ex_rs1_index, ID_Ex_rs2_index;
    reg [3:0]  ID_Ex_ALU_Control;


    // --- EX Stage Signals ---
    reg [31:0] alu_input1;
    reg [31:0] alu_input2;
    wire [31:0] alu_result;
    
    // Forwarding Signals
    reg [1:0] forward_a, forward_b;
    reg [31:0] forwarded_rs1_data;
    reg [31:0] forwarded_rs2_data;

    // --- Ex/Mem Pipeline Register ---
    reg Ex_Mem_Mem_Read, Ex_Mem_Mem_Write, Ex_Mem_Reg_Write, Ex_Mem_Mem_to_Reg;
    reg [31:0] Ex_Mem_ALU_Result, Ex_Mem_rs2_data;
    reg [4:0]  Ex_Mem_rd_index;

    // --- MEM Stage Signals ---
    localparam LED_ADDRESS    = 32'h0000007A;
    localparam BUTTON_ADDRESS = 32'h0000007B;
    wire is_led_access;
    wire dmem_write_enable;
    wire [31:0] mem_read_data;

    // --- Mem/WB Pipeline Register ---
    reg Mem_WB_Reg_Write, Mem_WB_Mem_to_Reg;
    reg [31:0] Mem_WB_Read_Data, Mem_WB_ALU_Result;
    reg [4:0]  Mem_WB_rd_index;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            button_sync_0 <= 1'b1;
            button_sync_1 <= 1'b1;
        end else begin
            button_sync_0 <= i_button;
            button_sync_1 <= button_sync_0;
        end
    end


    PC PC(
        .clk(clk), 
        .reset(reset),
        .write_enable(!stall),
        .pc_in(next_pc_final),
        .pc_out(current_pc)
    );      

    always @(*) begin
        if (stall) begin
            next_pc_final = current_pc;
        end else begin
            next_pc_final = next_pc;
        end
    end
    

    IMem IMem(
        .clk(clk),
        .addr(current_pc),
        .instruction(instruction)
    );


    // =========================================================================
    // 2. ID Stage (Instruction Decode)
    // =========================================================================

    Decoder Decoder(
        .clk(clk),
        .instruction(IF_ID_Instruction),
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

    assign is_branch_instruction = ((opcode == `OP_BRANCH) || (opcode == `OP_JAL) || (opcode == `OP_JALR));


    HazardDetectionUnit HazardDetectionUnit(
        .ID_Ex_Mem_Read(ID_Ex_Mem_Read),
        .Ex_Mem_Mem_Read(Ex_Mem_Mem_Read),
        .ID_Ex_rd(ID_Ex_rd_index),
        .IF_Id_rs1(rs1),
        .IF_Id_rs2(rs2),
        .is_branch(is_branch_instruction),
        .ID_Ex_Reg_Write(ID_Ex_Reg_Write),
        .Ex_Mem_Reg_Write(Ex_Mem_Reg_Write),
        .Ex_Mem_rd(Ex_Mem_rd_index),
        .stall(stall)
    );

    // Control Unit Logic
    always @(*) begin
        // RegWrite
        case (opcode)
            `OP_R_TYPE, `OP_IMM, `OP_LOAD, `OP_JAL, `OP_JALR, `OP_LUI, `OP_AUIPC: reg_write_ctrl = 1'b1;
            default: reg_write_ctrl = 1'b0;
        endcase

        // ALUSrc
        case (opcode)
            `OP_IMM, `OP_LOAD, `OP_STORE, `OP_LUI, `OP_AUIPC: alu_src_ctrl = 1'b1; // immediate
            default: alu_src_ctrl = 1'b0; // register
        endcase

        // MemtoReg
        case (opcode)
            `OP_LOAD: mem_to_reg_ctrl = 1'b1;
            default:  mem_to_reg_ctrl = 1'b0;
        endcase

        // Is Link Control
        case (opcode)
            `OP_JAL, `OP_JALR: is_link_control = 1'b1;
            default: is_link_control = 1'b0;
        endcase

        // ALUSrcA Control
        case (opcode)
            `OP_AUIPC: alu_src_a_ctrl = 2'b01; // PC
            `OP_LUI:  alu_src_a_ctrl = 2'b10; // Zero
            default:  alu_src_a_ctrl = 2'b00; // rs1
        endcase

    end

    //Forwarding MUX
    always @(*) begin
        if (ID_Ex_Reg_Write && (ID_Ex_rd_index != 0) && (ID_Ex_rd_index == rs1)) begin
            branch_op1 = alu_result;
        end else if(Ex_Mem_Reg_Write && (Ex_Mem_rd_index != 0) && (Ex_Mem_rd_index == rs1)) begin
            branch_op1 = Ex_Mem_ALU_Result;
        end else begin
            branch_op1 = reg_read_data1;
        end

        if (ID_Ex_Reg_Write && (ID_Ex_rd_index != 0) && (ID_Ex_rd_index == rs2)) begin
            branch_op2 = alu_result;
        end else if(Ex_Mem_Reg_Write && (Ex_Mem_rd_index != 0) && (Ex_Mem_rd_index == rs2)) begin
            branch_op2 = Ex_Mem_ALU_Result;
        end else begin
            branch_op2 = reg_read_data2;
        end
    end
    
    
    // branch jump logic
    assign is_equal = (branch_op1 == branch_op2);
    assign is_less_signed = ($signed(branch_op1) < $signed(branch_op2));
    assign is_less_unsigned = (branch_op1 < branch_op2);
    always @(*) begin
        branch_taken = 1'b0;
        pc_plus_4 = current_pc + 4;
        pc_branch = 32'b0;
        case (opcode)
            `OP_JAL: begin
                branch_taken = 1'b1;
                pc_branch = IF_ID_PC + imm;
            end
            `OP_JALR: begin
                branch_taken = 1'b1;
                pc_branch = (branch_op1 + imm) & ~32'b1;
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


    // =========================================================================
    // 3. EX Stage (Execute)
    // =========================================================================

    // Forwarding Mux
    always @(*) begin
        if (Ex_Mem_Reg_Write && (Ex_Mem_rd_index != 0) && (Ex_Mem_rd_index == ID_Ex_rs1_index)) begin
            forward_a = 2'b10;
        end else if (Mem_WB_Reg_Write && (Mem_WB_rd_index != 0) && (Mem_WB_rd_index == ID_Ex_rs1_index)) begin            
            forward_a = 2'b01;
        end else begin
            forward_a = 2'b00;
        end

        if (Ex_Mem_Reg_Write && (Ex_Mem_rd_index != 0) && (Ex_Mem_rd_index == ID_Ex_rs2_index)) begin
            forward_b = 2'b10;
        end else if (Mem_WB_Reg_Write && (Mem_WB_rd_index != 0) && (Mem_WB_rd_index == ID_Ex_rs2_index)) begin
            forward_b = 2'b01;
        end else begin
            forward_b = 2'b00;
        end
    end

    always @(*) begin
        case (forward_a)
            2'b00: forwarded_rs1_data = ID_Ex_rs1_data;
            2'b10: forwarded_rs1_data = Ex_Mem_ALU_Result;
            2'b01: forwarded_rs1_data = reg_write_data;
            default: forwarded_rs1_data = ID_Ex_rs1_data;
        endcase

        case (forward_b)
            2'b00: forwarded_rs2_data = ID_Ex_rs2_data;
            2'b10: forwarded_rs2_data = Ex_Mem_ALU_Result;
            2'b01: forwarded_rs2_data = reg_write_data;
            default: forwarded_rs2_data = ID_Ex_rs2_data;
        endcase

        case (ID_Ex_ALU_Src_A)
            2'b00: alu_input1 = forwarded_rs1_data;
            2'b01: alu_input1 = ID_Ex_PC;   // AUIPC
            2'b10: alu_input1 = 32'b0;    // LUI
            default: alu_input1 = forwarded_rs1_data;
        endcase
        alu_input2 = ID_Ex_ALU_Src ? ID_Ex_imm : forwarded_rs2_data;
    end

    ALU ALU(
        .clk(clk),
        .operand1(alu_input1),
        .operand2(alu_input2),
        .alu_control(ID_Ex_ALU_Control),
        .alu_result(alu_result)
    );


    // =========================================================================
    // 4. MEM Stage (Memory Access)
    // =========================================================================
    assign is_led_access = (Ex_Mem_ALU_Result == LED_ADDRESS);
    assign dmem_write_enable = Ex_Mem_Mem_Write && !is_led_access;

    DMem DMem(
        .clk(clk),
        .addr(Ex_Mem_ALU_Result),
        .write_data(Ex_Mem_rs2_data),
        .mem_read(Ex_Mem_Mem_Read),
        .mem_write(dmem_write_enable),
        .read_data(mem_read_data)
    );

    // MMIO - LED Control
    always @(posedge clk) begin
        if (!reset) begin
            o_led <= 6'b111111;
        end else if (Ex_Mem_Mem_Write && is_led_access) begin
            o_led <= Ex_Mem_rs2_data[5:0];
        end
    end


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
            ID_Ex_rs1_index <= 5'b0; 
            ID_Ex_rs2_index <= 5'b0;    
            ID_Ex_rd_index <= 5'b0;
            ID_Ex_ALU_Src <= 1'b0;
            ID_Ex_ALU_Control <= 4'b0;
            ID_Ex_PC <= 32'b0;
            ID_Ex_Is_Link <= 1'b0;
            
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
            if (!stall) begin
                if (branch_taken) begin
                    IF_ID_PC <= 32'b0;
                    IF_ID_Instruction <= 32'b0;
                end
                else begin
                    IF_ID_PC <= current_pc;
                    IF_ID_Instruction <= instruction;                    
                end
            end
            
            // ID/Ex Stage
            if (stall) begin
                // Insert Bubble(reset control signals)
                ID_Ex_Mem_Read  <= 1'b0;
                ID_Ex_Mem_Write <= 1'b0;
                ID_Ex_Reg_Write <= 1'b0;
                ID_Ex_Mem_to_Reg <= 1'b0;
                ID_Ex_Is_Link <= 1'b0;
                ID_Ex_ALU_Src_A <= 1'b0;

                // reset other signals for debugging clarity
                ID_Ex_rd_index  <= 5'b0;
                ID_Ex_rs1_index <= 5'b0; 
                ID_Ex_rs2_index <= 5'b0;
                ID_Ex_PC <= 32'b0;
            end else begin
                ID_Ex_Mem_Read <= (opcode == `OP_LOAD);
                ID_Ex_Mem_Write <= (opcode == `OP_STORE);
                ID_Ex_Reg_Write <= reg_write_ctrl;
                ID_Ex_Mem_to_Reg <= mem_to_reg_ctrl;
                ID_Ex_rs1_data <= reg_read_data1;
                ID_Ex_rs2_data <= reg_read_data2;
                ID_Ex_imm <= imm;
                ID_Ex_rs1_index <= rs1;
                ID_Ex_rs2_index <= rs2;
                ID_Ex_rd_index <= rd;
                ID_Ex_ALU_Src <= alu_src_ctrl;
                ID_Ex_ALU_Control <= alu_control;
                ID_Ex_PC <= IF_ID_PC;
                ID_Ex_Is_Link <= is_link_control;
                ID_Ex_ALU_Src_A <= alu_src_a_ctrl;
            end
            // Ex/Mem Stage
            Ex_Mem_Mem_Read <= ID_Ex_Mem_Read;
            Ex_Mem_Mem_Write <= ID_Ex_Mem_Write;
            Ex_Mem_Reg_Write <= ID_Ex_Reg_Write;
            Ex_Mem_Mem_to_Reg <= ID_Ex_Mem_to_Reg;
            if (ID_Ex_Is_Link) begin
                Ex_Mem_ALU_Result <= ID_Ex_PC + 4; // link address
            end else begin
                Ex_Mem_ALU_Result <= alu_result;
            end
            Ex_Mem_rs2_data <= forwarded_rs2_data;
            Ex_Mem_rd_index <= ID_Ex_rd_index;
            
            // Mem/WB Stage
            Mem_WB_Reg_Write <= Ex_Mem_Reg_Write;
            Mem_WB_Mem_to_Reg <= Ex_Mem_Mem_to_Reg;
            if (Ex_Mem_ALU_Result == BUTTON_ADDRESS) begin
                Mem_WB_Read_Data <= {31'b0 , ~button_sync_1};
            end else begin
                Mem_WB_Read_Data <= mem_read_data;
            end
            Mem_WB_ALU_Result <= Ex_Mem_ALU_Result;
            Mem_WB_rd_index <= Ex_Mem_rd_index;
        end
    end

endmodule
