# 初期化
addi x1, x0, 10
addi x2, x0, 10
addi x3, x0, 0

# テスト本番
# x1 == x2 なので、label_match へジャンプするはず
beq x1, x2, label_match 

# --- ここはスキップされるべきゾーン ---
addi x3, x0, 0xFF   # もし x3 が 0xBAD (2989) になったら失敗
# ------------------------------------

# ジャンプ先
label_match:
addi x3, x0, 1       # 成功！ x3 に 1 が入ればOK
addi x4, x0, 2       # 続きの処理

# 終了用無限ループ
end:
beq x0, x0, end
