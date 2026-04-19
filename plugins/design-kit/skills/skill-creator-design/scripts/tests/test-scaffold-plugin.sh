#!/bin/bash
# test-scaffold-plugin.sh — verify scaffold-plugin.sh produces correct file structure

set -euo pipefail

SCRIPT="$(dirname "$0")/../scaffold-plugin.sh"
TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

# Invoke the script with required args
bash "$SCRIPT" \
  --output-dir "$TMP/test-plugin" \
  --plugin-name "test-plugin" \
  --description "Test plugin description" \
  --author "test-author"

# Assertions
assert_file() {
  if [ ! -f "$1" ]; then
    echo "FAIL: missing $1"
    exit 1
  fi
}

assert_contains() {
  if ! grep -q "$2" "$1"; then
    echo "FAIL: $1 does not contain '$2'"
    exit 1
  fi
}

assert_file "$TMP/test-plugin/.claude-plugin/plugin.json"
assert_file "$TMP/test-plugin/LICENSE"
assert_file "$TMP/test-plugin/README.md"
assert_file "$TMP/test-plugin/CHANGELOG.md"

assert_contains "$TMP/test-plugin/.claude-plugin/plugin.json" '"name": "test-plugin"'
assert_contains "$TMP/test-plugin/.claude-plugin/plugin.json" '"description": "Test plugin description"'
assert_contains "$TMP/test-plugin/.claude-plugin/plugin.json" '"name": "test-author"'
assert_contains "$TMP/test-plugin/LICENSE" "MIT License"
assert_contains "$TMP/test-plugin/CHANGELOG.md" "## \[0.1.0\]"

# Validate JSON syntax (read via stdin for cross-platform path safety on Windows/Git Bash)
python -c "import json,sys; json.load(sys.stdin)" < "$TMP/test-plugin/.claude-plugin/plugin.json"

echo "PASS: scaffold-plugin.sh creates valid plugin structure"
