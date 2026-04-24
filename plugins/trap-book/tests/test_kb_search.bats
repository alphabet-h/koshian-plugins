#!/usr/bin/env bats

load helpers/test_helper

setup() { setup_common; }
teardown() { teardown_common; }

@test "kb-search: when kb-mcp absent, exits 0 silently" {
  PATH="/usr/bin:/bin" run bash "${TRAP_BOOK_ROOT}/lib/kb-search.sh" "query"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "kb-search: delegates to kb-mcp and echoes result" {
  export TRAP_BOOK_MOCK_RESULT="${BATS_TEST_DIRNAME}/fixtures/search-result.txt"
  run bash "${TRAP_BOOK_ROOT}/lib/kb-search.sh" "axum rc send"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "axum-state-rc.md"
}

@test "kb-search: second call within 60s uses cache" {
  export TRAP_BOOK_MOCK_RESULT="${BATS_TEST_DIRNAME}/fixtures/search-result.txt"
  bash "${TRAP_BOOK_ROOT}/lib/kb-search.sh" "axum rc send"
  # Change mock to empty — cache should still return original
  export TRAP_BOOK_MOCK_RESULT=""
  run bash "${TRAP_BOOK_ROOT}/lib/kb-search.sh" "axum rc send"
  [ "$status" -eq 0 ]
  echo "$output" | grep -q "axum-state-rc.md"
}

@test "kb-search: mock failure degrades silently" {
  export TRAP_BOOK_MOCK_FAIL=1
  run bash "${TRAP_BOOK_ROOT}/lib/kb-search.sh" "anything"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
