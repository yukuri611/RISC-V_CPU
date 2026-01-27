module ClockDivider(
    input wire clk_in,
    input wire reset_in,
    output reg clk_out
);
    reg [24:0] counter = 25'h00000000;

    localparam THRESHOLD = 25'd13500000;

    always @(posedge clk_in or negedge reset_in) begin
        if (!reset_in) begin
            counter <= 25'h00000000;
            clk_out <= 1'b0;
        end else
        if (counter == THRESHOLD) begin
            counter <= 25'h00000000;
            clk_out <= ~clk_out;
        end else begin
            counter <= counter + 1;
            clk_out <= clk_out;
        end
    end

endmodule
