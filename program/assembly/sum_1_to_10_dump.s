
program\hex\sum_1_to_10.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	40000113          	li	sp,1024
   4:	068000ef          	jal	6c <main>

00000008 <halt>:
   8:	00000063          	beqz	zero,8 <halt>

0000000c <calc_sum>:
   c:	fe010113          	addi	sp,sp,-32
  10:	00112e23          	sw	ra,28(sp)
  14:	00812c23          	sw	s0,24(sp)
  18:	02010413          	addi	s0,sp,32
  1c:	fe042623          	sw	zero,-20(s0)
  20:	00100793          	li	a5,1
  24:	fef42423          	sw	a5,-24(s0)
  28:	0200006f          	j	48 <calc_sum+0x3c>
  2c:	fec42703          	lw	a4,-20(s0)
  30:	fe842783          	lw	a5,-24(s0)
  34:	00f707b3          	add	a5,a4,a5
  38:	fef42623          	sw	a5,-20(s0)
  3c:	fe842783          	lw	a5,-24(s0)
  40:	00178793          	addi	a5,a5,1
  44:	fef42423          	sw	a5,-24(s0)
  48:	fe842703          	lw	a4,-24(s0)
  4c:	00a00793          	li	a5,10
  50:	fce7dee3          	bge	a5,a4,2c <calc_sum+0x20>
  54:	fec42783          	lw	a5,-20(s0)
  58:	00078513          	mv	a0,a5
  5c:	01c12083          	lw	ra,28(sp)
  60:	01812403          	lw	s0,24(sp)
  64:	02010113          	addi	sp,sp,32
  68:	00008067          	ret

0000006c <main>:
  6c:	fe010113          	addi	sp,sp,-32
  70:	00112e23          	sw	ra,28(sp)
  74:	00812c23          	sw	s0,24(sp)
  78:	02010413          	addi	s0,sp,32
  7c:	f91ff0ef          	jal	c <calc_sum>
  80:	fea42623          	sw	a0,-20(s0)
  84:	00000793          	li	a5,0
  88:	00078513          	mv	a0,a5
  8c:	01c12083          	lw	ra,28(sp)
  90:	01812403          	lw	s0,24(sp)
  94:	02010113          	addi	sp,sp,32
  98:	00008067          	ret
