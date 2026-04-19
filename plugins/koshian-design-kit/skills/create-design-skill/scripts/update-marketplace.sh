#!/bin/bash
# update-marketplace.sh — append a new plugin entry to .claude-plugin/marketplace.json

set -euo pipefail

MARKETPLACE_ROOT=""
PLUGIN_NAME=""
PLUGIN_SOURCE=""
PLUGIN_DESCRIPTION=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --marketplace-root) MARKETPLACE_ROOT="$2"; shift 2 ;;
    --plugin-name) PLUGIN_NAME="$2"; shift 2 ;;
    --plugin-source) PLUGIN_SOURCE="$2"; shift 2 ;;
    --plugin-description) PLUGIN_DESCRIPTION="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

for var in MARKETPLACE_ROOT PLUGIN_NAME PLUGIN_SOURCE PLUGIN_DESCRIPTION; do
  if [ -z "${!var}" ]; then
    echo "Error: --${var,,} is required"
    exit 2
  fi
done

MARKETPLACE_FILE="$MARKETPLACE_ROOT/.claude-plugin/marketplace.json"

if [ ! -f "$MARKETPLACE_FILE" ]; then
  echo "Error: marketplace.json not found at $MARKETPLACE_FILE"
  echo "Hint: ensure --marketplace-root points to the marketplace repo root."
  exit 3
fi

# Check if plugin already registered. Read via stdin for cross-platform path safety (Windows/Git Bash).
if python -c "
import json, sys, os
data = json.load(sys.stdin)
names = [p['name'] for p in data.get('plugins', [])]
sys.exit(0 if os.environ['PLUGIN_NAME'] in names else 1)
" < "$MARKETPLACE_FILE" 2>/dev/null; then
  echo "Plugin '$PLUGIN_NAME' is already registered in marketplace.json. No changes."
  exit 0
fi

# Show diff preview
NEW_ENTRY=$(PLUGIN_NAME="$PLUGIN_NAME" PLUGIN_SOURCE="$PLUGIN_SOURCE" PLUGIN_DESCRIPTION="$PLUGIN_DESCRIPTION" python -c "
import json, os
entry = {
    'name': os.environ['PLUGIN_NAME'],
    'source': os.environ['PLUGIN_SOURCE'],
    'description': os.environ['PLUGIN_DESCRIPTION'],
}
print(json.dumps(entry, indent=2))
")

echo "About to append the following entry to $MARKETPLACE_FILE:"
echo "---"
echo "$NEW_ENTRY"
echo "---"

# Confirm (skip if DRY_RUN_AUTO_CONFIRM env var is set, used by tests)
if [ -z "${DRY_RUN_AUTO_CONFIRM:-}" ]; then
  read -p "Proceed? [y/N] " ANSWER
  if [[ "$ANSWER" != "y" && "$ANSWER" != "Y" ]]; then
    echo "Aborted by user."
    exit 1
  fi
fi

# Append. Read from stdin and write to a tmpfile (avoids passing Windows/Git Bash paths into Python).
TMPFILE="$MARKETPLACE_FILE.tmp"
PLUGIN_NAME="$PLUGIN_NAME" PLUGIN_SOURCE="$PLUGIN_SOURCE" PLUGIN_DESCRIPTION="$PLUGIN_DESCRIPTION" python -c "
import json, sys, os
data = json.load(sys.stdin)
data['plugins'].append({
    'name': os.environ['PLUGIN_NAME'],
    'source': os.environ['PLUGIN_SOURCE'],
    'description': os.environ['PLUGIN_DESCRIPTION'],
})
json.dump(data, sys.stdout, indent=2)
sys.stdout.write('\n')
" < "$MARKETPLACE_FILE" > "$TMPFILE"

mv "$TMPFILE" "$MARKETPLACE_FILE"

echo "Updated $MARKETPLACE_FILE"
