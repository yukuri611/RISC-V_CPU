
program\hex\u_type.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	40000113          	li	sp,1024
   4:	008000ef          	jal	c <main>

00000008 <halt>:
   8:	00000063          	beqz	zero,8 <halt>

0000000c <main>:
   c:	000010b7          	lui	ra,0x1
  10:	00100113          	li	sp,1
  14:	00c11113          	slli	sp,sp,0xc
  18:	00209e63          	bne	ra,sp,34 <FAIL>

0000001c <Label_AUIPC>:
  1c:	00000197          	auipc	gp,0x0
  20:	0040026f          	jal	tp,24 <Label_Next>

00000024 <Label_Next>:
  24:	00418193          	addi	gp,gp,4 # 20 <Label_AUIPC+0x4>
  28:	00419663          	bne	gp,tp,34 <FAIL>
  2c:	00100f13          	li	t5,1

00000030 <loop_pass>:
  30:	00000063          	beqz	zero,30 <loop_pass>

00000034 <FAIL>:
  34:	00000f33          	add	t5,zero,zero

00000038 <loop_fail>:
  38:	00000063          	beqz	zero,38 <loop_fail>
