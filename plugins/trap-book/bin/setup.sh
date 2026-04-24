#!/usr/bin/env bash
# bin/setup.sh — one-shot init for trap-book.

set -euo pipefail

KB="${TRAP_BOOK_KB_PATH:-$HOME/.claude-trap-book}"
CACHE="${TRAP_BOOK_CACHE_DIR:-$HOME/.cache/trap-book}"

# 1. Directories with restrictive perms
mkdir -p -m 700 "$KB/pitfall" "$KB/strategy"
mkdir -p -m 700 "$CACHE/queue" "$CACHE/logs" "$CACHE/search-cache"
chmod 700 "$KB" "$CACHE"

# 2. Schema
cp "${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}/schema/kb-mcp-schema.toml" "$KB/"

# 3. config.json (only if absent, preserve user edits)
if [ ! -f "$KB/config.json" ]; then
  cat > "$KB/config.json" <<'EOF'
{
  "dedup_threshold": 0.85,
  "ttl_days_pitfall": 180,
  "ttl_days_strategy": 180,
  "auto_extract": false,
  "ignore_paths": []
}
EOF
fi

# 4. kb-mcp presence + version
if ! command -v kb-mcp >/dev/null 2>&1; then
  echo "ERROR: kb-mcp not found in PATH." >&2
  echo "Install: https://github.com/alphabet-h/kb-mcp" >&2
  exit 1
fi

KB_VER="$(kb-mcp --version 2>&1 | awk '{print $NF}')"
MIN="0.1.0"
if [ "$(printf '%s\n%s\n' "$MIN" "$KB_VER" | sort -V | head -1)" != "$MIN" ]; then
  echo "ERROR: kb-mcp v${MIN}+ required, found ${KB_VER}" >&2
  exit 1
fi

# 5. Initial index
echo "Indexing ~/.claude-trap-book (this takes a few seconds on first run)..."
kb-mcp index --kb-path "$KB" --model bge-m3 >/dev/null

# 6. Print .mcp.json snippet
cat <<EOF

Setup complete. Add this to your .mcp.json (merge with existing entries):

  "trap-book": {
    "command": "kb-mcp",
    "args": ["serve", "--kb-path", "${KB}", "--model", "bge-m3"],
    "type": "stdio"
  }

Next steps:
  - Restart Claude Code so it picks up the new MCP server.
  - Run a trial: /trap-save after fixing something non-trivial.
  - To enable auto-extraction later: export TRAP_BOOK_AUTO_EXTRACT=1
EOF
