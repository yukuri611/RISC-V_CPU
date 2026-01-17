module IMem(
    input clk,
    input wire [31:0] addr,
    output wire [31:0] instruction
);
    reg [31:0] memory [0:4095];
    assign instruction = memory[addr[13:2]];
    

    initial begin
        $readmemh("program/hex/u_type.hex", memory);
    end
    
    
endmodule
