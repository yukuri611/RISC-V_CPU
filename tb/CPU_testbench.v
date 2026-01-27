module CPU_testbench;
    reg clk = 0;
    reg reset = 0;
    wire [5:0] o_led;
    reg i_button = 1;

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
        .i_button(i_button),
        .o_led(o_led)
    );

    initial begin
        reset = 0;
        #10
        reset = 1;
        #1000
        i_button = 0;
        #200
        $finish;
    end

endmodule
