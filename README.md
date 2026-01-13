## 実装済みの命令
- R-type
  - add, sub, and, or, sli
- I-type
  - addi, andi, ori, slti, lw, jalr
- S-type
  - sw
- B-type
  - beq 
- J-type
  - jal


## コンパイル方法
iverilog -f file_list.txt
vvp a.out
gtkwave .\CPU_testbench.vcd

## クロスコンパイル 
[使用したコンパイラー](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases)

riscv-none-elf-as -march=rv32i -o test.o test.s
riscv-none-elf-objdump -d program/machine/load_store.o
(hexファイルに手でコピペ)

