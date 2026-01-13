module ALUControl(
    input wire clk,
    input wire [1:0] ALUOp,
    input wire [2:0] funct3,
    output reg [3:0] alu_control
);

    always @(*) begin
        if (ALUOp == 2'b00) begin
            alu_control = 4'b0010; // Load/Store: ADD
        end else begin
            case (funct3)
                3'b000: alu_control = 4'b0010; // ADDI
                3'b111: alu_control = 4'b0000; // ANDI
                3'b110: alu_control = 4'b0001; // ORI
                3'b010: alu_control = 4'b0111; // SLTI
            endcase
        end
    end

endmodule
