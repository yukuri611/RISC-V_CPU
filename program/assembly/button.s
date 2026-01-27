.globl main
main:
addi x10, x0, 0
addi x11, x0, 1
addi x20, x0, 123
addi x21, x0, 122

LOOP:
add  x10, x10, x11
lw   x5, 0(x20)
beq  x5, x0, LOOP
sw   x10, 0(x21)

Done:
beq  x0, x0, Done
