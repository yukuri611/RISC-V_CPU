
program\hex\sum_show_led.elf:     file format elf32-littleriscv


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
  20:	fef42223          	sw	a5,-28(s0)
  24:	fe042623          	sw	zero,-20(s0)
  28:	00100793          	li	a5,1
  2c:	fef42423          	sw	a5,-24(s0)
  30:	0200006f          	j	50 <main+0x44>
  34:	fec42703          	lw	a4,-20(s0)
  38:	fe842783          	lw	a5,-24(s0)
  3c:	00f707b3          	add	a5,a4,a5
  40:	fef42623          	sw	a5,-20(s0)
  44:	fe842783          	lw	a5,-24(s0)
  48:	00178793          	addi	a5,a5,1
  4c:	fef42423          	sw	a5,-24(s0)
  50:	fe842703          	lw	a4,-24(s0)
  54:	00a00793          	li	a5,10
  58:	fce7dee3          	bge	a5,a4,34 <main+0x28>
  5c:	fe442783          	lw	a5,-28(s0)
  60:	fec42703          	lw	a4,-20(s0)
  64:	00e7a023          	sw	a4,0(a5)
  68:	00000793          	li	a5,0
  6c:	00078513          	mv	a0,a5
  70:	01c12083          	lw	ra,28(sp)
  74:	01812403          	lw	s0,24(sp)
  78:	02010113          	addi	sp,sp,32
  7c:	00008067          	ret
