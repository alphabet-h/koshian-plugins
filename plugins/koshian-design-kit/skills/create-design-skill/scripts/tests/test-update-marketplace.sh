#!/bin/bash
# test-update-marketplace.sh — verify update-marketplace.sh appends correctly

set -euo pipefail

SCRIPT="$(dirname "$0")/../update-marketplace.sh"
TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

# Setup: fake marketplace.json
mkdir -p "$TMP/.claude-plugin"
cat > "$TMP/.claude-plugin/marketplace.json" <<'EOF'
{
  "name": "test-marketplace",
  "owner": {"name": "tester"},
  "metadata": {"description": "Test"},
  "plugins": [
    {
      "name": "existing-plugin",
      "source": "./plugins/existing-plugin",
      "description": "Existing"
    }
  ]
}
EOF

# Invoke (auto-confirm via env var to bypass interactive prompt)
DRY_RUN_AUTO_CONFIRM=1 bash "$SCRIPT" \
  --marketplace-root "$TMP" \
  --plugin-name "new-plugin" \
  --plugin-source "./plugins/new-plugin" \
  --plugin-description "New plugin description"

# Assertions
assert_contains() {
  if ! grep -q "$2" "$1"; then
    echo "FAIL: $1 does not contain '$2'"
    cat "$1"
    exit 1
  fi
}

assert_contains "$TMP/.claude-plugin/marketplace.json" '"name": "new-plugin"'
assert_contains "$TMP/.claude-plugin/marketplace.json" '"name": "existing-plugin"'

# Validate JSON syntax (read via stdin for cross-platform path safety on Windows/Git Bash)
python -c "import json,sys; data = json.load(sys.stdin); assert len(data['plugins']) == 2" < "$TMP/.claude-plugin/marketplace.json"

echo "PASS: update-marketplace.sh appends new plugin entry"
