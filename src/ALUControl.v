module ALUControl(
    input wire clk,
    input wire [6:0] opcode,
    input wire [6:0] funct7,
    input wire [2:0] funct3,
    output reg [3:0] alu_control
);

    always @(*) begin
        if (opcode == `OP_LOAD || opcode == `OP_STORE) begin
            alu_control = 4'b0010; // Load/Store: ADD
        end else if (opcode == `OP_JAL || opcode == `OP_JALR) begin
            alu_control = 4'b0010; // JAL/JALR: ADD
        end else if (opcode == `OP_IMM) begin
            case (funct3)
                3'b000: alu_control = 4'b0010; // ADDI
                3'b111: alu_control = 4'b0000; // ANDI
                3'b110: alu_control = 4'b0001; // ORI
                3'b010: alu_control = 4'b0111; // SLTI
            endcase
        end else if (opcode == `OP_R_TYPE) begin
            case (funct3)
                3'b000: begin
                    if (funct7 == 7'b0100000) begin
                        alu_control = 4'b0110; // SUB
                    end else begin
                        alu_control = 4'b0010; // ADD
                    end
                end
                3'b111: alu_control = 4'b0000; // AND
                3'b110: alu_control = 4'b0001; // OR
                3'b010: alu_control = 4'b0111; // SLT
            endcase
        end else if (opcode == `OP_BRANCH) begin
            case (funct3)
                3'b000: alu_control = 4'b0110; // BEQ
            endcase
        end else begin
            alu_control = 4'b1111; // NOP or undefined
            
        end
    end

endmodule
