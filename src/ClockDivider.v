module ClockDivider(
    input wire clk_in,
    input wire reset_in,
    output reg clk_out
);
    reg [24:0] counter = 25'b0;

    `ifdef __ICARUS__
        localparam THRESHOLD = 25'd2;
    `else
        localparam THRESHOLD = 25'd100;
    `endif
    
    always @(posedge clk_in or negedge reset_in) begin
        if (!reset_in) begin
            counter <= 25'b0;
            clk_out <= 1'b0;
        end else if (counter == THRESHOLD - 1) begin
            counter <= 25'b0;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 25'b1;
        end
    end

endmodule
