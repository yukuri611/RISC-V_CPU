module ALU(
    input wire clk,
    input wire [31:0] operand1,
    input wire [31:0] operand2,
    input wire [3:0] alu_control,
    output reg [31:0] alu_result
);
    always @(*) begin // Combinational logic
        case (alu_control)

            4'b0000: alu_result <= operand1 & operand2; 
            4'b0001: alu_result <= operand1 | operand2;
            4'b0010: alu_result <= operand1 + operand2;
            4'b0110: alu_result <= operand1 - operand2;
            4'b0111: alu_result <= (operand1 < operand2);
            4'b1100: alu_result <= ~(operand1 | operand2);
        endcase
    end
endmodule
