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

assert_contains() {
  if ! grep -q "$2" "$1"; then
    echo "FAIL: $1 does not contain '$2'"
    cat "$1"
    exit 1
  fi
}

# 1. Dry-run (no flag) must NOT modify the file.
BEFORE_DRY="$(cat "$TMP/.claude-plugin/marketplace.json")"
bash "$SCRIPT" \
  --marketplace-root "$TMP" \
  --plugin-name "dry-run-plugin" \
  --plugin-source "./plugins/dry-run-plugin" \
  --plugin-description "Should not be appended" > /dev/null
AFTER_DRY="$(cat "$TMP/.claude-plugin/marketplace.json")"
if [ "$BEFORE_DRY" != "$AFTER_DRY" ]; then
  echo "FAIL: dry-run mode modified the file"
  exit 1
fi

# 2. With --yes the entry must be appended.
bash "$SCRIPT" --yes \
  --marketplace-root "$TMP" \
  --plugin-name "new-plugin" \
  --plugin-source "./plugins/new-plugin" \
  --plugin-description "New plugin description"

assert_contains "$TMP/.claude-plugin/marketplace.json" '"name": "new-plugin"'
assert_contains "$TMP/.claude-plugin/marketplace.json" '"name": "existing-plugin"'

# 3. Validate JSON syntax (read via stdin for cross-platform path safety on Windows/Git Bash).
python -c "import json,sys; data = json.load(sys.stdin); assert len(data['plugins']) == 2" < "$TMP/.claude-plugin/marketplace.json"

echo "PASS: update-marketplace.sh dry-run + --yes behaviour"
