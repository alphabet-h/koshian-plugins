#!/usr/bin/env bash
# lib/logger.sh
# Usage:
#   logger.sh log <event> <json-detail>
#   logger.sh metric <event> <json-detail>

set -euo pipefail

cache="${TRAP_BOOK_CACHE_DIR:-$HOME/.cache/trap-book}"
mkdir -p "$cache/logs"

cmd="${1:-}"
event="${2:-}"
detail="${3:-}"
[ -z "$detail" ] && detail='{}'
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
day="$(date -u +%Y-%m-%d)"

line="$(jq -c -n --arg ts "$ts" --arg ev "$event" --argjson d "$detail" \
  '{ts: $ts, event: $ev} + $d')"

case "$cmd" in
  log)    echo "$line" >> "$cache/logs/${day}.log" ;;
  metric) echo "$line" >> "$cache/metrics.jsonl" ;;
  *) echo "usage: logger.sh {log|metric} <event> <detail>" >&2; exit 64 ;;
esac

if [ -n "${TRAP_BOOK_DEBUG:-}" ]; then
  echo "[trap-book] $line" >&2
fi
