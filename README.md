## パイプライン化処理まで実装

## 実装済みの命令
- R-type
  - add, sub, and, or, slt
- I-type
  - addi, andi, ori, slti, lw, jalr, slli
- S-type
  - sw
- B-type
  - beq, bne, blt, bge, bltu, bgeu
- J-type
  - jal
- U-type
  - lui, auipc


## コンパイル方法
./run.bat

## クロスコンパイル 
[使用したコンパイラー](https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases)

./build.bat

