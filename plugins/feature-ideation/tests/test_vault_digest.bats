#!/usr/bin/env bats
#
# vault-digest.sh の契約とパースのテスト。
# 実行: cd plugins/feature-ideation && bats tests/

load helpers/test_helper

setup()    { setup_common; }
teardown() { teardown_common; }

# ---------------------------------------------------------------- 契約 ------
# このスクリプトはコンテキスト注入から呼ばれる。非 0 で終了すると
# スキル起動ごと abort するため、どの入力でも exit 0 を返さなければならない。

@test "契約: 全 fixture で exit 0 かつ END DIGEST で終わる" {
  for f in normal empty no-vault overdue broken foreign crlf xref legacy; do
    run digest_in "$f" .
    [ "$status" -eq 0 ] || { echo "fixture=$f exit=$status"; return 1; }
    echo "$output" | tail -1 | grep -qF '=== END DIGEST ===' \
      || { echo "fixture=$f: END DIGEST がありません"; echo "$output"; return 1; }
  done
}

@test "契約: vault が無くても exit 0 で案内を出す" {
  run digest_in no-vault .
  assert_success_output
  assert_contains "digest_status: no-vault"
  assert_contains "hint:"
}

@test "契約: 存在しないパスを渡しても自動検出にフォールバックする" {
  run digest_in normal --vault /nonexistent/nope.md
  assert_success_output
  assert_contains "vault: ./docs/feature-ideas.md"
}

@test "契約: 置換されなかったリテラル引数を無視する" {
  run digest_in normal '$ARGUMENTS'
  assert_success_output
  assert_contains "vault: ./docs/feature-ideas.md"
}

@test "契約: 壊れたテーブルでも digest 全体を出す" {
  run digest_in broken .
  assert_success_output
  assert_contains "=== END DIGEST ==="
  assert_contains "列数が 4 でヘッダの 7 と一致しません"
}

@test "契約: 出力にバックタックを含まない" {
  run digest_in normal .
  assert_success_output
  assert_not_contains '`'
}

@test "契約: git 管理外でも mtime にフォールバックする" {
  run digest_in normal .
  assert_success_output
  assert_contains "vault_last_change:"
}

# ---------------------------------------------------------------- パース ----

@test "パース: カテゴリ別・状態別の件数が実数と一致する" {
  run digest_in normal .
  assert_success_output
  assert_contains "open_total: 4"
  assert_contains "ledger_done: 1"
  assert_contains "ledger_declined: 1"
  assert_contains "$(printf 'by_cat\t検索精度の強化\t2')"
  assert_contains "$(printf 'by_status\tprobing\t1')"
}

@test "パース: 凡例や棲み分けの表をカテゴリとして数えない" {
  run digest_in normal .
  assert_success_output
  # 凡例表は ID 列を持たないので拾われない。open_total がちょうど 4 であることで担保する
  assert_contains "open_total: 4"
}

@test "パース: 空の vault は open_total 0" {
  run digest_in empty .
  assert_success_output
  assert_contains "open_total: 0"
}

@test "パース: 旧形式の ID しか無い vault は 0 件ではなく理由を報告する" {
  run digest_in legacy .
  assert_success_output
  assert_contains "legacy_rows: 2"
  assert_contains "移行が必要です"
}

@test "パース: 区切り行のない表は読まない" {
  run digest_in broken .
  assert_success_output
  assert_not_contains "FI-009"
}

@test "パース: CRLF でも LF と同じ結果になる" {
  run bash -c "
    cd '$FID_FIXTURES/normal' && bash '$FID_ROOT/lib/vault-digest.sh' . | grep -v vault_last_change > '$BATS_TMPDIR/lf.txt'
    cd '$FID_FIXTURES/crlf'   && bash '$FID_ROOT/lib/vault-digest.sh' . | grep -v vault_last_change > '$BATS_TMPDIR/crlf.txt'
    diff '$BATS_TMPDIR/lf.txt' '$BATS_TMPDIR/crlf.txt'
  "
  [ "$status" -eq 0 ] || { echo "$output"; return 1; }
}

@test "パース: 詳細ファイルへのリンクだけを昇格済みとして数える" {
  run digest_in normal .
  assert_success_output
  # FI-003 の備考にある known-issues.md や FI-006 の plans/*.md は昇格リンクではない
  assert_contains "detail_promoted: 1"
}

# ------------------------------------------------------------ 表記の規律 ----

@test "規律: 語彙外の状態を警告する" {
  run digest_in broken .
  assert_success_output
  assert_contains 'FI-003: 状態 "vault" は正規語彙'
}

@test "規律: index に残った done を警告する" {
  run digest_in broken .
  assert_success_output
  assert_contains "FI-002: done は index に残さず台帳へ移してください"
}

@test "規律: 取り消し線の墓標行を警告する" {
  run digest_in broken .
  assert_success_output
  assert_contains "FI-004: 取り消し線の墓標行です"
}

@test "規律: 昇格条件のない ⚠️ を警告する" {
  run digest_in broken .
  assert_success_output
  assert_contains "FI-005: 制約が ⚠️ ですが備考に昇格条件がありません"
}
