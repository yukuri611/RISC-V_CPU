`timescale 1ns/1ps

module Top_testbench;

    reg sys_clk = 0;
    reg sys_rst_n = 0;
    reg button_in = 1;
    wire [5:0] led;

    Top uut(
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .button_in(button_in),
        .led(led)
    );

    always #1 begin 
        sys_clk = ~sys_clk;
    end

    initial begin
        $dumpfile("Top_testbench.vcd");
        $dumpvars(0, Top_testbench);
    end

    initial begin 
        sys_rst_n = 0;
        button_in = 1;
        #10;
        sys_rst_n = 1;
        #1000;
        button_in = 0;
        #200;
        button_in = 1;
        #1000;
        $finish;
    end


endmodule
