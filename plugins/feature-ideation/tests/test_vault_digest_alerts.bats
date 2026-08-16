#!/usr/bin/env bats
#
# 陳腐化検出・詳細ディレクトリ衛生・外部参照突合・優先度ピック改訂トリガのテスト。

load helpers/test_helper

setup()    { setup_common; }
teardown() { teardown_common; }

# ------------------------------------------------------------ 期限検出 ------

@test "期限: 再評価キューの超過を検出し、経過日数を出す" {
  run digest_in overdue .
  assert_success_output
  assert_contains "$(printf 'overdue\tFI-001\t2026-06-01\t76日超過')"
}

@test "期限: 期日が今日ちょうどなら超過にしない (境界値)" {
  run digest_in overdue .
  assert_success_output
  section_of "ALERT: OVERDUE (再評価キュー)" | grep -q "2026-08-16" && {
    echo "今日の期日を超過扱いにしています"; return 1; }
  assert_contains "$(printf 'due_soon\tFI-002\t2026-08-16\tあと0日')"
}

@test "期限: 未来の期日は DUE SOON にも出さない (8 日以上先)" {
  run digest_in overdue .
  assert_success_output
  section_of "ALERT: DUE SOON (7日以内)" | grep -q "2026-09-30" && {
    echo "8 日以上先の期日を DUE SOON にしています"; return 1; }
  return 0
}

@test "期限: 本文中の絶対日付の期限を拾う" {
  run digest_in overdue .
  assert_success_output
  assert_contains "LOOSE_OVERDUE"
  assert_contains "2026-05-20"
}

@test "期限: チェック済み (- [x]) の行を期限として拾わない" {
  run digest_in overdue .
  assert_success_output
  section_of "ALERT: OVERDUE (本文中の絶対日付)" | grep -q "2026-03-01" && {
    echo "完了済みの日付を期限として誤検出しています"; return 1; }
  return 0
}

@test "期限: 完了語 (確定) を含む行を期限として拾わない" {
  run digest_in overdue .
  assert_success_output
  section_of "ALERT: OVERDUE (本文中の絶対日付)" | grep -q "2026-04-01" && {
    echo "確定済みの日付を期限として誤検出しています"; return 1; }
  return 0
}

# ------------------------------------------------------------ 停滞検出 ------

@test "停滞: last_sweep が閾値を超えたら報告する" {
  run digest_in overdue .
  assert_success_output
  assert_contains "$(printf 'stale_sweep\tlast_sweep=2026-01-05\t223日')"
}

@test "停滞: last_sweep が無ければ未設定として報告する" {
  run digest_in broken .
  assert_success_output
  assert_contains "last_sweep が未設定です"
}

@test "停滞: カテゴリの最終確認が古ければ報告する" {
  run digest_in overdue .
  assert_success_output
  assert_contains "$(printf 'stale_category\t中核品質\t最終確認=2026-01-05')"
}

@test "停滞: 閾値を上げれば何も報告しない" {
  FEATURE_IDEATION_STALE_DAYS=9999 run digest_in overdue .
  assert_success_output
  section_of "ALERT: STALE" | grep -q "stale_category" && {
    echo "閾値が効いていません"; return 1; }
  return 0
}

@test "停滞: 最近棚卸した vault は停滞なし" {
  run digest_in normal .
  assert_success_output
  [ "$(section_of "ALERT: STALE" | grep -c .)" -eq 1 ]
  section_of "ALERT: STALE" | grep -q "(none)"
}

# -------------------------------------------------- 詳細ディレクトリ衛生 ----

@test "衛生: 命名規約に反するファイルを異物として分類する" {
  run digest_in foreign .
  assert_success_output
  assert_contains "$(printf 'FOREIGN\t./docs/feature-ideas/2026-05-16-phase1-plan.md\tplan')"
  assert_contains "$(printf 'FOREIGN\t./docs/feature-ideas/2026-05-17-spec-research.md\tspec')"
}

@test "衛生: 規約に沿った詳細ファイルは異物にしない" {
  run digest_in foreign .
  assert_success_output
  section_of "ALERT: DETAIL DIR" | grep -q "FI-001.md" && {
    echo "正規の詳細ファイルを異物にしています"; return 1; }
  return 0
}

@test "衛生: 1 hop (他の詳細ファイル経由) で参照されていれば孤児にしない" {
  run digest_in foreign .
  assert_success_output
  section_of "ALERT: DETAIL DIR" | grep -q "FI-003-trial" && {
    echo "1 hop 参照されているファイルを孤児にしています"; return 1; }
  return 0
}

@test "衛生: index が指すのに存在しないファイルを報告する" {
  run digest_in foreign .
  assert_success_output
  assert_contains "MISSING_DETAIL"
  assert_contains "feature-ideas/FI-002.md"
}

@test "衛生: 詳細ディレクトリが無くても落ちない" {
  run digest_in broken .
  assert_success_output
  assert_contains "detail_dir: (none)"
}

# ---------------------------------------------------------- 外部参照突合 ----

@test "外部参照: feature-idea 修飾つきの言及を検出する" {
  FEATURE_IDEATION_NO_XREF= run digest_in xref .
  assert_success_output
  assert_contains "$(printf 'XREF\tFI-002')"
  assert_contains "0011-adopt.md"
}

@test "外部参照: 修飾のない素の ID は検出しない" {
  FEATURE_IDEATION_NO_XREF= run digest_in xref .
  assert_success_output
  section_of "ALERT: EXTERNAL MENTION" | grep -q "配列の添字" && {
    echo "修飾なしの ID を誤検出しています"; return 1; }
  return 0
}

@test "外部参照: index に無い ID を dangling として報告する" {
  FEATURE_IDEATION_NO_XREF= run digest_in xref .
  assert_success_output
  assert_contains "$(printf 'DANGLING\tFI-099')"
}

@test "外部参照: NO_XREF=1 で走査を無効化できる" {
  run digest_in xref .
  assert_success_output
  section_of "ALERT: EXTERNAL MENTION" | grep -q "(none)"
}

@test "外部参照: 走査対象ディレクトリが無くても落ちない" {
  FEATURE_IDEATION_NO_XREF= run digest_in normal .
  assert_success_output
  section_of "ALERT: EXTERNAL MENTION" | grep -q "(none)"
}

# ------------------------------------------------------ 優先度ピック改訂 ----

@test "ピック: 台帳にピック外の ID があれば T4 を出す" {
  run digest_in normal .
  assert_success_output
  assert_contains "PICK_TRIGGER	T4"
  assert_contains "FI-004"
}

@test "ピック: ピックが無い vault ではトリガを出さない" {
  run digest_in empty .
  assert_success_output
  section_of "PICK TRIGGER" | grep -q "(none)"
}

# ---------------------------------------------------------------- frozen ---

@test "frozen: 期限切れではなく別枠で報告する" {
  run digest_in normal .
  assert_success_output
  assert_contains "$(printf 'frozen\tFI-003')"
  section_of "ALERT: OVERDUE (再評価キュー)" | grep -q "FI-003" && {
    echo "frozen を期限切れ扱いしています"; return 1; }
  return 0
}

# ------------------------------------------------------------------ 台帳 ---

@test "台帳: 証跡と知見が埋まっていれば警告しない" {
  run digest_in normal .
  assert_success_output
  section_of "ALERT: LEDGER INCOMPLETE" | grep -q "(none)"
}
