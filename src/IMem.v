module IMem(
    input clk,
    input wire [31:0] addr,
    output wire [31:0] instruction
);
    reg [31:0] memory [0:255];
    assign instruction = memory[addr[9:2]];
    

    initial begin
        $readmemh("program/hex/r_type.hex", memory);
    end
    
    
endmodule
