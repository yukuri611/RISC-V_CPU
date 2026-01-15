.section .text
.global _start

_start:
    # 1. スタックポインタ(sp)の初期化
    addi sp, x0, 1024

    # 2. main関数へジャンプ
    jal ra, main

halt:
    beq x0, x0, halt
