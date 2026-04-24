#!/usr/bin/env bash
# lib/queue.sh
#
# Queue directory layout:
#   ${TRAP_BOOK_CACHE_DIR}/queue/<session>-<ts>.json       (pending)
#   ${TRAP_BOOK_CACHE_DIR}/queue/<session>-<ts>.json.lock  (in-flight)
#   ${TRAP_BOOK_CACHE_DIR}/queue/.broken/                  (quarantine)
#
# Usage:
#   queue.sh put <session_id> <project_root> <json-payload>
#   queue.sh take     → prints JSON of first cwd-matching item; renames to .lock
#                       exit 0 on hit, 1 if none
#                       writes lock path to $qdir/.last_take
#   queue.sh finalize <lock-path>   → rm the .lock file

set -euo pipefail

qdir="${TRAP_BOOK_CACHE_DIR:-$HOME/.cache/trap-book}/queue"
broken="$qdir/.broken"
mkdir -p "$qdir" "$broken"

cmd="${1:-}"
shift || true

case "$cmd" in
  put)
    sess="$1"; proj="$2"; payload="$3"
    ts="$(date -u +%Y%m%dT%H%M%SZ)"
    file="$qdir/${sess}-${ts}.json"
    jq -n \
      --arg session_id "$sess" \
      --arg project_root "$proj" \
      --arg created_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      --argjson payload "$payload" \
      '$payload + {session_id: $session_id, project_root: $project_root, created_at: $created_at}' \
      > "$file"
    ;;
  take)
    cwd="$(pwd)"
    found=""
    # Only pick up pending (*.json), not already-locked (*.json.lock)
    for f in $(ls -1tr "$qdir"/*.json 2>/dev/null | grep -v '\.lock$' || true); do
      if ! jq -e . "$f" >/dev/null 2>&1; then
        mv "$f" "$broken/$(basename "$f")"
        continue
      fi
      proj="$(jq -r '.project_root // empty' "$f")"
      if [ "$proj" = "$cwd" ] || [ "$proj" = "*" ] || [ -z "$proj" ]; then
        lock="${f}.lock"
        if mv "$f" "$lock" 2>/dev/null; then
          cat "$lock"
          echo "$lock" > "$qdir/.last_take"
          found=1
          break
        fi
      fi
    done
    [ -n "$found" ] || exit 1
    ;;
  finalize)
    lock="$1"
    rm -f "$lock"
    rm -f "$qdir/.last_take"
    ;;
  *)
    echo "usage: queue.sh {put|take|finalize} ..." >&2
    exit 64
    ;;
esac
