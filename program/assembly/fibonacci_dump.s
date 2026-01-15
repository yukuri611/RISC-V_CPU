
program\hex\fibonacci.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	40000113          	li	sp,1024
   4:	078000ef          	jal	7c <main>

00000008 <halt>:
   8:	00000063          	beqz	zero,8 <halt>

0000000c <fibbonacci>:
   c:	fe010113          	addi	sp,sp,-32
  10:	00112e23          	sw	ra,28(sp)
  14:	00812c23          	sw	s0,24(sp)
  18:	00912a23          	sw	s1,20(sp)
  1c:	02010413          	addi	s0,sp,32
  20:	fea42623          	sw	a0,-20(s0)
  24:	fec42703          	lw	a4,-20(s0)
  28:	00100793          	li	a5,1
  2c:	00e7c663          	blt	a5,a4,38 <fibbonacci+0x2c>
  30:	fec42783          	lw	a5,-20(s0)
  34:	0300006f          	j	64 <fibbonacci+0x58>
  38:	fec42783          	lw	a5,-20(s0)
  3c:	fff78793          	addi	a5,a5,-1
  40:	00078513          	mv	a0,a5
  44:	fc9ff0ef          	jal	c <fibbonacci>
  48:	00050493          	mv	s1,a0
  4c:	fec42783          	lw	a5,-20(s0)
  50:	ffe78793          	addi	a5,a5,-2
  54:	00078513          	mv	a0,a5
  58:	fb5ff0ef          	jal	c <fibbonacci>
  5c:	00050793          	mv	a5,a0
  60:	00f487b3          	add	a5,s1,a5
  64:	00078513          	mv	a0,a5
  68:	01c12083          	lw	ra,28(sp)
  6c:	01812403          	lw	s0,24(sp)
  70:	01412483          	lw	s1,20(sp)
  74:	02010113          	addi	sp,sp,32
  78:	00008067          	ret

0000007c <main>:
  7c:	fe010113          	addi	sp,sp,-32
  80:	00112e23          	sw	ra,28(sp)
  84:	00812c23          	sw	s0,24(sp)
  88:	02010413          	addi	s0,sp,32
  8c:	00700513          	li	a0,7
  90:	f7dff0ef          	jal	c <fibbonacci>
  94:	fea42623          	sw	a0,-20(s0)
  98:	fec42783          	lw	a5,-20(s0)
  9c:	00078513          	mv	a0,a5
  a0:	01c12083          	lw	ra,28(sp)
  a4:	01812403          	lw	s0,24(sp)
  a8:	02010113          	addi	sp,sp,32
  ac:	00008067          	ret
