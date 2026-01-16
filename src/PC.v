module PC(
    input clk,
    input reset,
    input write_enable,
    input wire [31:0] pc_in,
    output reg [31:0] pc_out
);
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            pc_out <= 32'b0;
        end else begin
            pc_out <= pc_in;
        end
    end
    
endmodule
