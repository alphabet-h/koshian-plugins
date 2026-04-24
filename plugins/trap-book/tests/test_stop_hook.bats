#!/usr/bin/env bats
load helpers/test_helper

setup() {
  setup_common
  export TRAP_BOOK_AUTO_EXTRACT=1
}
teardown() { teardown_common; }

_run_hook() {
  local transcript="$1"
  local cwd_arg="${2:-${TRAP_BOOK_TEST_TMP}}"
  local payload
  payload=$(jq -n \
    --arg sid "sess-test" \
    --arg tp "$transcript" \
    --arg cwd "$cwd_arg" \
    '{session_id:$sid, transcript_path:$tp, cwd:$cwd}')
  echo "$payload" | bash "${TRAP_BOOK_ROOT}/hooks/stop.sh"
}

@test "stop hook: silent exit when auto-extract disabled" {
  unset TRAP_BOOK_AUTO_EXTRACT
  run _run_hook "${BATS_TEST_DIRNAME}/fixtures/transcripts/resolve.jsonl"
  [ "$status" -eq 0 ]
  [ -z "$(ls "${TRAP_BOOK_CACHE}/queue/"*.json 2>/dev/null)" ]
}

@test "stop hook: silent exit with TRAP_BOOK_DISABLE" {
  export TRAP_BOOK_DISABLE=1
  run _run_hook "${BATS_TEST_DIRNAME}/fixtures/transcripts/resolve.jsonl"
  [ "$status" -eq 0 ]
  [ -z "$(ls "${TRAP_BOOK_CACHE}/queue/"*.json 2>/dev/null)" ]
}

@test "stop hook: resolution signal writes queue file" {
  run _run_hook "${BATS_TEST_DIRNAME}/fixtures/transcripts/resolve.jsonl"
  [ "$status" -eq 0 ]
  local f
  f="$(ls "${TRAP_BOOK_CACHE}/queue/"sess-test-*.json | head -1)"
  [ -f "$f" ]
  jq -e '.excerpt | length == 2' "$f"
  jq -e '.project_root' "$f"
}

@test "stop hook: no resolution signal → no queue" {
  run _run_hook "${BATS_TEST_DIRNAME}/fixtures/transcripts/ongoing.jsonl"
  [ "$status" -eq 0 ]
  [ -z "$(ls "${TRAP_BOOK_CACHE}/queue/"*.json 2>/dev/null)" ]
}

@test "stop hook: negation filter cancels queue write" {
  run _run_hook "${BATS_TEST_DIRNAME}/fixtures/transcripts/negated.jsonl"
  [ "$status" -eq 0 ]
  [ -z "$(ls "${TRAP_BOOK_CACHE}/queue/"*.json 2>/dev/null)" ]
}

@test "stop hook: excerpt is redacted" {
  local tp="${TRAP_BOOK_TEST_TMP}/secret.jsonl"
  cat > "$tp" <<EOF
{"role":"user","content":"api_key=sk-top-secret finally works"}
{"role":"assistant","content":"✅ 完了"}
EOF
  run _run_hook "$tp"
  local f
  f="$(ls "${TRAP_BOOK_CACHE}/queue/"sess-test-*.json | head -1)"
  ! grep -q "sk-top-secret" "$f"
  grep -q "REDACTED" "$f"
}

@test "stop hook: .trap-book-ignore in cwd skips" {
  touch "${TRAP_BOOK_TEST_TMP}/.trap-book-ignore"
  run _run_hook "${BATS_TEST_DIRNAME}/fixtures/transcripts/resolve.jsonl" "${TRAP_BOOK_TEST_TMP}"
  [ -z "$(ls "${TRAP_BOOK_CACHE}/queue/"*.json 2>/dev/null)" ]
}

@test "stop hook: [PRIVATE] in last user msg skips" {
  local tp="${TRAP_BOOK_TEST_TMP}/private.jsonl"
  cat > "$tp" <<EOF
{"role":"user","content":"axum で Rc"}
{"role":"assistant","content":"Arc<T> に変えて"}
{"role":"user","content":"[PRIVATE] 動いた"}
{"role":"assistant","content":"完了"}
EOF
  run _run_hook "$tp"
  [ -z "$(ls "${TRAP_BOOK_CACHE}/queue/"*.json 2>/dev/null)" ]
}
