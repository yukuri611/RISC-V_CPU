iverilog -I src/include -f file_list.txt -o a.out
vvp a.out
gtkwave .\CPU_testbench.vcd
