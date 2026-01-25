module CPU_testbench;
    reg clk = 0;
    reg reset = 0;
    wire [5:0] o_led;

    always #1 begin 
        clk = ~clk;
    end

    initial begin
        $dumpfile("CPU_testbench.vcd");
        $dumpvars(0, CPU_testbench);
    end
    
    CPU CPU(
        .clk(clk),
        .reset(reset),
        .o_led(o_led)
    );

    initial begin
        reset = 0;
        #2
        reset = 1;
        #300
        $finish;
    end

endmodule
