# tests/helpers/test_helper.bash
# Shared bats utilities. Source from every .bats file.

setup_common() {
  export TRAP_BOOK_ROOT="${BATS_TEST_DIRNAME}/.."
  export TRAP_BOOK_TEST_TMP="$(mktemp -d)"
  export TRAP_BOOK_KB="${TRAP_BOOK_TEST_TMP}/kb"
  export TRAP_BOOK_CACHE="${TRAP_BOOK_TEST_TMP}/cache"
  export TRAP_BOOK_LOG="${TRAP_BOOK_CACHE}/logs/$(date +%Y-%m-%d).log"
  mkdir -p "${TRAP_BOOK_KB}/pitfall" "${TRAP_BOOK_KB}/strategy"
  mkdir -p "${TRAP_BOOK_CACHE}/queue" "${TRAP_BOOK_CACHE}/logs"
  # Point lib scripts at test dirs via env vars (libs read these)
  export TRAP_BOOK_KB_PATH="${TRAP_BOOK_KB}"
  export TRAP_BOOK_CACHE_DIR="${TRAP_BOOK_CACHE}"
  # Mock kb-mcp comes first in PATH
  export PATH="${BATS_TEST_DIRNAME}/helpers:${PATH}"
}

teardown_common() {
  rm -rf "${TRAP_BOOK_TEST_TMP}"
  unset TRAP_BOOK_MOCK_RESULT TRAP_BOOK_MOCK_FAIL
}

assert_file_exists() {
  [ -f "$1" ] || { echo "expected file: $1"; return 1; }
}

assert_file_contains() {
  grep -qF "$2" "$1" || { echo "file $1 missing: $2"; return 1; }
}
