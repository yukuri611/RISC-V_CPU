module Top(
    input wire sys_clk,
    input wire sys_rst_n,
    input wire button_in,
    output wire [5:0] led
);

    wire cpu_clk;

    ClockDivider clk_div (
        .clk_in(sys_clk),
        .reset_in(sys_rst_n),
        .clk_out(cpu_clk)
    );

    CPU cpu_inst (
        .clk(cpu_clk),
        .rst_n(sys_rst_n),
        .button(button_in),
        .led(led)
    );
endmodule
