
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
  1c:	fe042623          	sw	zero,-20(s0)
  20:	00100793          	li	a5,1
  24:	fef42423          	sw	a5,-24(s0)
  28:	0200006f          	j	48 <main+0x3c>
  2c:	fec42703          	lw	a4,-20(s0)
  30:	fe842783          	lw	a5,-24(s0)
  34:	00f707b3          	add	a5,a4,a5
  38:	fef42623          	sw	a5,-20(s0)
  3c:	fe842783          	lw	a5,-24(s0)
  40:	00178793          	addi	a5,a5,1
  44:	fef42423          	sw	a5,-24(s0)
  48:	fe842703          	lw	a4,-24(s0)
  4c:	00500793          	li	a5,5
  50:	fce7dee3          	bge	a5,a4,2c <main+0x20>
  54:	07a00793          	li	a5,122
  58:	fef42223          	sw	a5,-28(s0)
  5c:	fe442783          	lw	a5,-28(s0)
  60:	fec42703          	lw	a4,-20(s0)
  64:	00e7a023          	sw	a4,0(a5)
  68:	0000006f          	j	68 <main+0x5c>
