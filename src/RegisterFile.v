module RegisterFile(
    input wire clk,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data,
    input wire reg_write,   
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);

    reg [31:0] register[0:31];

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) register[i] = 0;
    end

    always @(posedge clk) begin
    if (reg_write && (write_reg != 5'd0)) begin
        register[write_reg] <= write_data;
    end
    end

    assign read_data1 = (read_reg1 == 5'd0) ? 32'd0 : register[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? 32'd0 : register[read_reg2];

endmodule
