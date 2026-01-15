@echo off
set TARGET=program\hex\matmul
set SOURCE_C=program\c\matmul.c
set SOURCE_ASM=program\assembly\start.s
set OUTPUT_ASM=program\assembly\matmul_dump.s

echo [1/6] Compiling Startup Code...
rem start.s をコンパイル
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -c -o program\machine\start.o %SOURCE_ASM%

echo [2/6] Compiling C Code...
rem C言語をコンパイル
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -c -o program\machine\main.o %SOURCE_C%

echo [3/6] Linking...
rem start.o を一番最初に書くことで、0番地に配置
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext=0x0 -o %TARGET%.elf program\machine\start.o program\machine\main.o

echo [4/6] Disassembling to Assembly...
rem objdumpを使ってELFからアセンブリコードを生成し、保存する
riscv-none-elf-objdump -d %TARGET%.elf > %OUTPUT_ASM%

echo [5/6] Generating Binary...
riscv-none-elf-objcopy -O binary %TARGET%.elf %TARGET%.bin

echo [6/6] Converting to 32-bit Hex for Verilog...
python -c "import sys; d=open(r'%TARGET%.bin','rb').read(); [print(f'{int.from_bytes(d[i:i+4], \"little\"):08x}') for i in range(0, len(d), 4)]" > %TARGET%.hex

echo.
echo [Cleanup] Deleting intermediate files...
if exist program\machine\start.o del program\machine\start.o
if exist program\machine\main.o  del program\machine\main.o
if exist %TARGET%.elf del %TARGET%.elf
if exist %TARGET%.bin del %TARGET%.bin

echo.
echo Done! 
echo Hex file: %TARGET%.hex
echo Assembly dump: %OUTPUT_ASM%
pause
