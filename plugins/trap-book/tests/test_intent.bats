#!/usr/bin/env bats

load helpers/test_helper

setup() { setup_common; }
teardown() { teardown_common; }

@test "intent: inject fixtures" {
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    run bash "${TRAP_BOOK_ROOT}/lib/intent.sh" inject "$line"
    [ "$status" -eq 0 ] || { echo "FAIL positive: $line"; return 1; }
  done < "${BATS_TEST_DIRNAME}/fixtures/intent/positive.txt"
}

@test "intent: negative fixtures do NOT trigger inject" {
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    run bash "${TRAP_BOOK_ROOT}/lib/intent.sh" inject "$line"
    [ "$status" -eq 1 ] || { echo "FAIL negative (should not match): $line"; return 1; }
  done < "${BATS_TEST_DIRNAME}/fixtures/intent/negative.txt"
}

@test "intent: resolution fixtures trigger resolve" {
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    run bash "${TRAP_BOOK_ROOT}/lib/intent.sh" resolve "$line"
    [ "$status" -eq 0 ] || { echo "FAIL resolve: $line"; return 1; }
  done < "${BATS_TEST_DIRNAME}/fixtures/intent/resolution.txt"
}

@test "intent: negation filter cancels resolution" {
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    run bash "${TRAP_BOOK_ROOT}/lib/intent.sh" negated "$line"
    [ "$status" -eq 0 ] || { echo "FAIL negation: $line"; return 1; }
  done < "${BATS_TEST_DIRNAME}/fixtures/intent/negation.txt"
}

@test "intent: short input skips all checks" {
  run bash "${TRAP_BOOK_ROOT}/lib/intent.sh" inject "short"
  [ "$status" -eq 2 ]
}
