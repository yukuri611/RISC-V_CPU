
program\hex\led.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	40000113          	li	sp,1024
   4:	008000ef          	jal	c <main>

00000008 <halt>:
   8:	00000063          	beqz	zero,8 <halt>

0000000c <main>:
   c:	fe010113          	addi	sp,sp,-32
  10:	00112e23          	sw	ra,28(sp)
  14:	00812c23          	sw	s0,24(sp)
  18:	02010413          	addi	s0,sp,32
  1c:	07a00793          	li	a5,122
  20:	fef42423          	sw	a5,-24(s0)
  24:	fe042623          	sw	zero,-20(s0)
  28:	fec42783          	lw	a5,-20(s0)
  2c:	00178793          	addi	a5,a5,1
  30:	fef42623          	sw	a5,-20(s0)
  34:	fec42783          	lw	a5,-20(s0)
  38:	fff7c713          	not	a4,a5
  3c:	fe842783          	lw	a5,-24(s0)
  40:	00e7a023          	sw	a4,0(a5)
  44:	fe5ff06f          	j	28 <main+0x1c>
