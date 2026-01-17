.globl main
main:
    # ==========================
    # LUI Test
    # ==========================
    lui x1, 1
    addi x2, x0, 1
    slli x2, x2, 12
    bne x1, x2, FAIL


    # ==========================
    # AUIPC Test
    # ==========================
Label_AUIPC:
    auipc x3, 0         # x3 = Address of Label_AUIPC
    
    # 次の命令のアドレスを取得 (JALは PC+4 をrdに保存する)
    jal x4, Label_Next

Label_Next:
    addi x3, x3, 8
    
    # x3 と x4 が違ったら FAIL へ
    bne x3, x4, FAIL


    # ==========================
    # SUCCESS (成功)
    # ==========================
    addi x30, x0, 1     # x30 = 1 (成功フラグ)
loop_pass:
    beq x0, x0, loop_pass


    # ==========================
    # FAIL (失敗)
    # ==========================
FAIL:
    add x30, x0, x0     # x30 = 0 (失敗フラグ)
loop_fail:
    beq x0, x0, loop_fail
