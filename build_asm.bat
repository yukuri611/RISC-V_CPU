@echo off
set FILE_NAME=u_type
set TARGET=program\hex\%FILE_NAME%
rem メインのアセンブリソース
set SOURCE_MAIN=program\assembly\%FILE_NAME%.s
rem スタートアップコード（共通）
set SOURCE_START=program\assembly\start.s
rem ダンプファイルの出力先
set OUTPUT_ASM=program\assembly\%FILE_NAME%_dump.s

echo [1/6] Compiling Startup Code...
rem start.s をコンパイル
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -c -o program\machine\start.o %SOURCE_START%

echo [2/6] Compiling Main Assembly Code...
rem メインのアセンブリファイルをコンパイル
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -c -o program\machine\main.o %SOURCE_MAIN%

echo [3/6] Linking...
rem start.o を先頭にしてリンク（0番地に配置するため）
riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext=0x0 -o %TARGET%.elf program\machine\start.o program\machine\main.o

echo [4/6] Disassembling to Assembly...
rem 確認用にダンプを出力
riscv-none-elf-objdump -d %TARGET%.elf > %OUTPUT_ASM%

echo [5/6] Generating Binary...
riscv-none-elf-objcopy -O binary %TARGET%.elf %TARGET%.bin

echo [6/6] Converting to 32-bit Hex for Verilog...
rem Verilogのreadmemhで読み込める形式に変換
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
