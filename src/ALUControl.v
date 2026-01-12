module ALUControl(
    input wire clk,
    input wire [2:0] funct3,
    output reg [3:0] alu_control
);

    always @(posedge clk) begin
        case (funct3)
            3'b000: alu_control = 4'b0010; // ADDI
            3'b111: alu_control = 4'b0000; // AND
            3'b110: alu_control = 4'b0001; // OR
            3'b010: alu_control = 4'b0111; // SLT
        endcase
    end

endmodule
