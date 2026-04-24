#!/usr/bin/env bats
load helpers/test_helper

setup() { setup_common; }
teardown() { teardown_common; }

_run_hook() {
  local prompt="$1"
  local cwd="${2:-${TRAP_BOOK_TEST_TMP}}"
  mkdir -p "$cwd"
  jq -n --arg p "$prompt" --arg c "$cwd" \
    '{prompt:$p, cwd:$c, session_id:"sess-x", transcript_path:""}' \
    | bash "${TRAP_BOOK_ROOT}/hooks/user-prompt-submit.sh"
}

@test "UPS hook: TRAP_BOOK_DISABLE skips" {
  export TRAP_BOOK_DISABLE=1
  run _run_hook "実装してください"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "UPS hook: short prompt skipped" {
  run _run_hook "short"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "UPS hook: inject intent calls kb-search and emits additionalContext" {
  export TRAP_BOOK_MOCK_RESULT="${BATS_TEST_DIRNAME}/fixtures/search-result.txt"
  run _run_hook "この機能を実装してほしい"
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.hookSpecificOutput.additionalContext' >/dev/null
  echo "$output" | grep -q "axum-state-rc"
}

@test "UPS hook: non-intent prompt emits nothing" {
  run _run_hook "そうですか、ありがとう。じゃあ次の話ですが…"
  [ "$status" -eq 0 ]
  [ -z "$(echo "$output" | jq -r '.hookSpecificOutput.additionalContext // ""' 2>/dev/null)" ]
}

@test "UPS hook: consumes queue and emits extraction directive" {
  cp "${BATS_TEST_DIRNAME}/fixtures/queue/valid.json" "${TRAP_BOOK_CACHE}/queue/sess-abc-ts.json"
  run _run_hook "次どうする？" "/tmp/proj"
  [ "$status" -eq 0 ]
  echo "$output" | jq -r '.hookSpecificOutput.additionalContext' | grep -q "trap-extractor"
  [ -z "$(ls "${TRAP_BOOK_CACHE}/queue/"*.lock 2>/dev/null)" ]
}

@test "UPS hook: .trap-book-ignore skips all" {
  touch "${TRAP_BOOK_TEST_TMP}/.trap-book-ignore"
  run _run_hook "実装してください"
  [ -z "$output" ]
}
