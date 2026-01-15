module CPU_testbench;
    reg clk = 0;
    reg reset = 0;

    always #1 begin 
        clk = ~clk;
    end

    initial begin
        $dumpfile("CPU_testbench.vcd");
        $dumpvars(0, CPU_testbench);
    end
    
    CPU CPU(
        .clk(clk),
        .reset(reset)
    );

    initial begin
        reset = 1;
        #4
        reset = 0;
        #3000
        $finish;
    end

endmodule
