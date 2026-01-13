module DMem(
    input clk,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire mem_read,
    input wire mem_write,
    output wire [31:0] read_data
);

   
    reg [31:0] memory [0:255];

    initial begin 
        for (integer i = 0; i < 256; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[9:2]] <= write_data;
        end
    end

    assign read_data = memory[addr[9:2]];
endmodule
