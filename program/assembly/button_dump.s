
program\hex\button.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	40000113          	li	sp,1024
   4:	008000ef          	jal	c <main>

00000008 <halt>:
   8:	00000063          	beqz	zero,8 <halt>

0000000c <main>:
   c:	00000513          	li	a0,0
  10:	00100593          	li	a1,1
  14:	07b00a13          	li	s4,123
  18:	07a00a93          	li	s5,122

0000001c <LOOP>:
  1c:	00b50533          	add	a0,a0,a1
  20:	000a2283          	lw	t0,0(s4)
  24:	fe028ce3          	beqz	t0,1c <LOOP>
  28:	00aaa023          	sw	a0,0(s5)

0000002c <Done>:
  2c:	00000063          	beqz	zero,2c <Done>
