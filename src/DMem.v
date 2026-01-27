module DMem(
    input clk,
    input wire [31:0] addr,
    input wire [31:0] write_data,
    input wire mem_read,
    input wire mem_write,
    output wire [31:0] read_data
);

   
    reg [31:0] memory [0:4095];

    `ifdef IVARILOG
    initial begin 
        for (integer i = 0; i < 4096; i = i + 1) begin
            memory[i] = 32'b0;
        end
    end
    `endif
    
    always @(posedge clk) begin
        if (mem_write) begin
            memory[addr[13:2]] <= write_data;
        end
    end

    assign read_data = (mem_read) ? memory[addr[13:2]] : 32'b0;
endmodule
