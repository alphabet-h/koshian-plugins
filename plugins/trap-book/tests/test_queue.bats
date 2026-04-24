#!/usr/bin/env bats

load helpers/test_helper

setup() { setup_common; }
teardown() { teardown_common; }

@test "queue put: writes file with session_id + ts in filename" {
  run bash "${TRAP_BOOK_ROOT}/lib/queue.sh" put \
    "sess-xyz" "/tmp/proj" '{"excerpt":[]}'
  [ "$status" -eq 0 ]
  local f
  f="$(ls "${TRAP_BOOK_CACHE}/queue"/sess-xyz-*.json 2>/dev/null | head -1)"
  assert_file_exists "$f"
}

@test "queue take: atomic mv to .lock; returns content" {
  cp "${BATS_TEST_DIRNAME}/fixtures/queue/valid.json" "${TRAP_BOOK_CACHE}/queue/sess-abc-20260424T100000Z.json"
  mkdir -p /tmp/proj 2>/dev/null || true
  cd /tmp/proj
  run bash "${TRAP_BOOK_ROOT}/lib/queue.sh" take
  [ "$status" -eq 0 ]
  echo "$output" | jq -e '.excerpt[0].role == "user"' >/dev/null
  [ -f "${TRAP_BOOK_CACHE}/queue/sess-abc-20260424T100000Z.json.lock" ]
  [ ! -f "${TRAP_BOOK_CACHE}/queue/sess-abc-20260424T100000Z.json" ]
}

@test "queue take: cwd mismatch skips the file" {
  cp "${BATS_TEST_DIRNAME}/fixtures/queue/valid.json" "${TRAP_BOOK_CACHE}/queue/sess-abc-20260424T100000Z.json"
  # valid.json has project_root /tmp/proj; current cwd is TEST_TMP (different)
  cd "${TRAP_BOOK_TEST_TMP}"
  run bash "${TRAP_BOOK_ROOT}/lib/queue.sh" take
  [ "$status" -eq 1 ]
  [ -f "${TRAP_BOOK_CACHE}/queue/sess-abc-20260424T100000Z.json" ]
}

@test "queue finalize: deletes the lock file" {
  cp "${BATS_TEST_DIRNAME}/fixtures/queue/valid.json" "${TRAP_BOOK_CACHE}/queue/sess-abc.json.lock"
  run bash "${TRAP_BOOK_ROOT}/lib/queue.sh" finalize "${TRAP_BOOK_CACHE}/queue/sess-abc.json.lock"
  [ "$status" -eq 0 ]
  [ ! -f "${TRAP_BOOK_CACHE}/queue/sess-abc.json.lock" ]
}

@test "queue quarantine: invalid JSON moved to .broken/" {
  cp "${BATS_TEST_DIRNAME}/fixtures/queue/broken.json" "${TRAP_BOOK_CACHE}/queue/sess-bad-20260424.json"
  cd "${TRAP_BOOK_TEST_TMP}"
  run bash "${TRAP_BOOK_ROOT}/lib/queue.sh" take
  [ "$status" -eq 1 ]
  [ -f "${TRAP_BOOK_CACHE}/queue/.broken/sess-bad-20260424.json" ]
}

@test "queue: lock collision returns empty (lock files are NOT re-taken)" {
  cp "${BATS_TEST_DIRNAME}/fixtures/queue/valid.json" "${TRAP_BOOK_CACHE}/queue/sess-abc.json"
  mv "${TRAP_BOOK_CACHE}/queue/sess-abc.json" "${TRAP_BOOK_CACHE}/queue/sess-abc.json.lock"
  cd "${TRAP_BOOK_TEST_TMP}"
  run bash "${TRAP_BOOK_ROOT}/lib/queue.sh" take
  [ "$status" -eq 1 ]
}
