.text
.global _start

_start:
    addi x1, x0, 5
    addi x2, x1, 1
    sw x1, 2(x0)
    lw x2, 2(x0)
    addi x3, x2, 10
    sw x3, 3(x0)
