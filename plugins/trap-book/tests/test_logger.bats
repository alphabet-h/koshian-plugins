#!/usr/bin/env bats

load helpers/test_helper

setup() { setup_common; }
teardown() { teardown_common; }

@test "logger: writes JSON lines to daily log" {
  run bash "${TRAP_BOOK_ROOT}/lib/logger.sh" log injection_hit '{"trap":"pitfall/a.md"}'
  [ "$status" -eq 0 ]
  local logf="${TRAP_BOOK_CACHE}/logs/$(date -u +%Y-%m-%d).log"
  assert_file_exists "$logf"
  jq -e '.event == "injection_hit"' "$logf" >/dev/null
}

@test "logger: metrics.jsonl appends one line per call" {
  bash "${TRAP_BOOK_ROOT}/lib/logger.sh" metric injection_hit '{}'
  bash "${TRAP_BOOK_ROOT}/lib/logger.sh" metric extraction_queued '{}'
  local mf="${TRAP_BOOK_CACHE}/metrics.jsonl"
  [ "$(wc -l <"$mf")" -eq 2 ]
}
