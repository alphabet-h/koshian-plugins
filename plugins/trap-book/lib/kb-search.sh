#!/usr/bin/env bash
# lib/kb-search.sh
# Thin wrapper around `kb-mcp search` with:
#   - silent bypass when kb-mcp not in PATH
#   - 2s timeout to protect UserPromptSubmit latency
#   - 60s sha256-keyed cache

set -euo pipefail

query="${1:-}"
[ -z "$query" ] && exit 0

cache_dir="${TRAP_BOOK_CACHE_DIR:-$HOME/.cache/trap-book}/search-cache"
mkdir -p "$cache_dir"

command -v kb-mcp >/dev/null 2>&1 || exit 0

key="$(printf '%s' "$query" | sha256sum | cut -c1-16)"
cache_file="$cache_dir/$key"

if [ -f "$cache_file" ]; then
  age=$(( $(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file") ))
  if [ "$age" -lt 60 ]; then
    cat "$cache_file"
    exit 0
  fi
fi

kb_path="${TRAP_BOOK_KB_PATH:-$HOME/.claude-trap-book}"

# Run with timeout; on failure or empty output, emit nothing silently
result="$(timeout 2s kb-mcp search "$query" --kb-path "$kb_path" --format text --limit 3 2>/dev/null || true)"
if [ -n "$result" ]; then
  printf '%s' "$result" > "$cache_file"
  printf '%s' "$result"
fi
