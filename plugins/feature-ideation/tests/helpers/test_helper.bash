# tests/helpers/test_helper.bash — feature-ideation の bats 共通ヘルパ

setup_common() {
  export FID_ROOT="${BATS_TEST_DIRNAME}/.."
  export FID_FIXTURES="${BATS_TEST_DIRNAME}/fixtures/vaults"
  # 時間を止める。これが無いと fixture の期限を毎年書き換えることになる。
  export FEATURE_IDEATION_TODAY="2026-08-16"
  # 既定では外部参照の走査を切る。xref のテストだけ明示的に有効化する。
  export FEATURE_IDEATION_NO_XREF=1
  unset FEATURE_IDEATION_VAULT
  unset FEATURE_IDEATION_STALE_DAYS
  unset FEATURE_IDEATION_MAX_ROWS
  unset FEATURE_IDEATION_XREF_PATHS
}

teardown_common() {
  [ -n "${FID_TMP:-}" ] && [ -d "$FID_TMP" ] && rm -rf "$FID_TMP"
  return 0
}

# fixture ディレクトリで digest を実行する
digest_in() {
  local fixture="$1"; shift
  ( cd "$FID_FIXTURES/$fixture" && bash "$FID_ROOT/lib/vault-digest.sh" "$@" )
}

# fixture を tmp にコピーしてから実行する (git 経路や書き換えを伴うテスト用)
copy_fixture() {
  FID_TMP="$(mktemp -d)"
  cp -R "$FID_FIXTURES/$1/." "$FID_TMP/"
  export FID_TMP
}

assert_success_output() {
  [ "$status" -eq 0 ] || { echo "expected exit 0, got $status"; echo "$output"; return 1; }
}

assert_contains() {
  echo "$output" | grep -qF -- "$1" || { echo "missing: $1"; echo "--- output ---"; echo "$output"; return 1; }
}

assert_not_contains() {
  if echo "$output" | grep -qF -- "$1"; then
    echo "unexpected: $1"; echo "--- output ---"; echo "$output"; return 1
  fi
  return 0
}

# セクション名を渡すと、その直後から次のセクションまでの本文を返す
section_of() {
  echo "$output" | awk -v s="-- $1 --" '$0==s{f=1;next} /^-- /{f=0} f'
}
