module IMem(
    input clk,
    input wire [31:0] addr,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:4095];

    initial begin
        $readmemh("program/hex/button.hex", memory);
    end
    
    always @(negedge clk) begin
        instruction <= memory[addr[13:2]];
    end
endmodule
