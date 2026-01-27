module DMem(
    input clk,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire mem_read,
    input wire mem_write,
    output reg [31:0] read_data
);

   
    reg [31:0] memory [0:4095];

    `ifdef IVARILOG
    initial begin 
        for (integer i = 0; i < 4096; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end
    `endif
    
    always @(negedge clk) begin
        if (mem_write) begin
            memory[addr[13:2]] <= write_data;
        end
        if (mem_read) begin
            read_data <= memory[addr[13:2]];
        end
    end
endmodule
