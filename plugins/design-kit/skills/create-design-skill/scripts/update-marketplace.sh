#!/bin/bash
# update-marketplace.sh — append a new plugin entry to .claude-plugin/marketplace.json
#
# Default behaviour is **dry-run**: the script prints the entry it would append and exits.
# Pass --yes to actually write the file. This design lets the calling agent (or user)
# preview first and confirm via its own UI (e.g. AskUserQuestion), without relying on
# an interactive `read` prompt that breaks when stdin is not a TTY (e.g. invoked from
# the Claude Code Bash tool).

set -euo pipefail

MARKETPLACE_ROOT=""
PLUGIN_NAME=""
PLUGIN_SOURCE=""
PLUGIN_DESCRIPTION=""
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
  case $1 in
    --marketplace-root) MARKETPLACE_ROOT="$2"; shift 2 ;;
    --plugin-name) PLUGIN_NAME="$2"; shift 2 ;;
    --plugin-source) PLUGIN_SOURCE="$2"; shift 2 ;;
    --plugin-description) PLUGIN_DESCRIPTION="$2"; shift 2 ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

require_arg() {
  local var_name="$1" flag="$2"
  if [ -z "${!var_name}" ]; then
    echo "Error: $flag is required"
    exit 2
  fi
}
require_arg MARKETPLACE_ROOT   --marketplace-root
require_arg PLUGIN_NAME        --plugin-name
require_arg PLUGIN_SOURCE      --plugin-source
require_arg PLUGIN_DESCRIPTION --plugin-description

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

# Show diff preview. Values are passed via env vars (not string-interpolated) to avoid
# breaking the Python literal when a plugin name/description contains quotes or backslashes.
NEW_ENTRY=$(PYTHONIOENCODING=utf-8 PLUGIN_NAME="$PLUGIN_NAME" PLUGIN_SOURCE="$PLUGIN_SOURCE" PLUGIN_DESCRIPTION="$PLUGIN_DESCRIPTION" python -c "
import json, os, sys
entry = {
    'name': os.environ['PLUGIN_NAME'],
    'source': os.environ['PLUGIN_SOURCE'],
    'description': os.environ['PLUGIN_DESCRIPTION'],
}
sys.stdout.buffer.write(json.dumps(entry, indent=2, ensure_ascii=False).encode('utf-8'))
")

echo "About to append the following entry to $MARKETPLACE_FILE:"
echo "---"
echo "$NEW_ENTRY"
echo "---"

if [ "$ASSUME_YES" -eq 0 ]; then
  echo "(dry-run; no changes written. Re-run with --yes to apply.)"
  exit 0
fi

# Append. Read from stdin and write to a tmpfile (avoids passing Windows/Git Bash paths into Python).
# Force UTF-8 encoding on stdio to preserve multibyte characters (e.g., em-dash, CJK) in existing entries.
TMPFILE="$MARKETPLACE_FILE.tmp"
PYTHONIOENCODING=utf-8 PLUGIN_NAME="$PLUGIN_NAME" PLUGIN_SOURCE="$PLUGIN_SOURCE" PLUGIN_DESCRIPTION="$PLUGIN_DESCRIPTION" python -c "
import json, sys, os
data = json.loads(sys.stdin.buffer.read().decode('utf-8'))
data['plugins'].append({
    'name': os.environ['PLUGIN_NAME'],
    'source': os.environ['PLUGIN_SOURCE'],
    'description': os.environ['PLUGIN_DESCRIPTION'],
})
out = json.dumps(data, indent=2, ensure_ascii=False) + '\n'
sys.stdout.buffer.write(out.encode('utf-8'))
" < "$MARKETPLACE_FILE" > "$TMPFILE"

mv "$TMPFILE" "$MARKETPLACE_FILE"

echo "Updated $MARKETPLACE_FILE"
