#!/usr/bin/env bash
# tests/helpers/mock_kb-mcp.sh
#
# Two files point to this logic:
#   mock_kb-mcp.sh  — canonical source (edit this)
#   kb-mcp          — PATH-invocable copy (symlink on POSIX, file copy on Windows/MSYS)
# Tests prepend `tests/helpers` to PATH so calls to `kb-mcp` resolve here
# instead of the real binary. Keep both in sync — the setup task (Task 2)
# creates the copy; if the mock logic changes, regenerate with
#   ln -sf mock_kb-mcp.sh tests/helpers/kb-mcp
#   or: cp mock_kb-mcp.sh tests/helpers/kb-mcp
#
# Deterministic kb-mcp substitute for Layer-1 tests.
# Controlled via env:
#   TRAP_BOOK_MOCK_RESULT = path to file whose contents are echoed
#   TRAP_BOOK_MOCK_FAIL   = non-empty → exit 1 with "mock failure"

set -euo pipefail

if [ -n "${TRAP_BOOK_MOCK_FAIL:-}" ]; then
  echo "mock failure" >&2
  exit 1
fi

case "${1:-}" in
  --version) echo "kb-mcp 0.1.0"; exit 0 ;;
  search)
    if [ -n "${TRAP_BOOK_MOCK_RESULT:-}" ] && [ -f "${TRAP_BOOK_MOCK_RESULT}" ]; then
      cat "${TRAP_BOOK_MOCK_RESULT}"
    else
      echo ""
    fi
    exit 0
    ;;
  index|validate|serve)
    exit 0
    ;;
  *)
    echo "mock kb-mcp: unknown command $*" >&2
    exit 2
    ;;
esac
