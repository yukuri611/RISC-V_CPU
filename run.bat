iverilog -DIVARILOG -I src/include -f file_list.txt -o a.out
vvp a.out
gtkwave .\Top_testbench.vcd
