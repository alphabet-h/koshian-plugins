#!/usr/bin/env bats

load helpers/test_helper

setup() { setup_common; }
teardown() { teardown_common; }

@test "redact is idempotent on already-redacted text" {
  local input="hello [REDACTED:aws_access_key] world"
  run bash "${TRAP_BOOK_ROOT}/lib/redact.sh" <<<"$input"
  [ "$status" -eq 0 ]
  [ "$output" = "$input" ]
}

@test "redact passes through clean text unchanged" {
  local input="just a normal sentence"
  run bash "${TRAP_BOOK_ROOT}/lib/redact.sh" <<<"$input"
  [ "$status" -eq 0 ]
  [ "$output" = "$input" ]
}

@test "redact fixture: aws" {
  run bash "${TRAP_BOOK_ROOT}/lib/redact.sh" < "${BATS_TEST_DIRNAME}/fixtures/redact/input-aws.txt"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cat "${BATS_TEST_DIRNAME}/fixtures/redact/expected-aws.txt")" ]
}

@test "redact fixture: jwt" {
  run bash "${TRAP_BOOK_ROOT}/lib/redact.sh" < "${BATS_TEST_DIRNAME}/fixtures/redact/input-jwt.txt"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cat "${BATS_TEST_DIRNAME}/fixtures/redact/expected-jwt.txt")" ]
}

@test "redact fixture: ssh" {
  run bash "${TRAP_BOOK_ROOT}/lib/redact.sh" < "${BATS_TEST_DIRNAME}/fixtures/redact/input-ssh.txt"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cat "${BATS_TEST_DIRNAME}/fixtures/redact/expected-ssh.txt")" ]
}

@test "redact fixture: mixed" {
  run bash "${TRAP_BOOK_ROOT}/lib/redact.sh" < "${BATS_TEST_DIRNAME}/fixtures/redact/input-mixed.txt"
  [ "$status" -eq 0 ]
  [ "$output" = "$(cat "${BATS_TEST_DIRNAME}/fixtures/redact/expected-mixed.txt")" ]
}
