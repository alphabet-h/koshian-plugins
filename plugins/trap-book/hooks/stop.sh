#!/usr/bin/env bash
# hooks/stop.sh
# Reads hook input JSON via stdin, scans transcript for resolution signal,
# writes a queue entry if auto-extract enabled.

set -euo pipefail

input="$(cat)"

# ---- Gate: user-disabled ----
[ "${TRAP_BOOK_DISABLE:-}" = "1" ] && exit 0

# ---- Gate: opt-in for v0.1.0 ----
auto="${TRAP_BOOK_AUTO_EXTRACT:-}"
if [ -z "$auto" ]; then
  kb="${TRAP_BOOK_KB_PATH:-$HOME/.claude-trap-book}"
  auto="$(jq -r '.auto_extract // false' "$kb/config.json" 2>/dev/null || echo false)"
fi
[ "$auto" != "1" ] && [ "$auto" != "true" ] && exit 0

# ---- Gate: project opt-out ----
cwd="$(echo "$input" | jq -r '.cwd // empty')"
[ -z "$cwd" ] && cwd="$PWD"
[ -f "$cwd/.trap-book-ignore" ] && exit 0

transcript_path="$(echo "$input" | jq -r '.transcript_path // empty')"
session_id="$(echo "$input" | jq -r '.session_id // "unknown"')"
[ -z "$transcript_path" ] || [ ! -f "$transcript_path" ] && exit 0

# ---- Last user + last assistant (from JSONL) ----
last_user="$(tac "$transcript_path" | jq -r 'select(.role=="user") | .content' 2>/dev/null | head -n1)"
last_asst="$(tac "$transcript_path" | jq -r 'select(.role=="assistant") | .content' 2>/dev/null | head -n1)"

# ---- Gate: [PRIVATE] prefix ----
echo "$last_user" | grep -q '^\[PRIVATE\]' && exit 0

# ---- Gate: negation filter ----
HERE="$(cd "$(dirname "$0")" && pwd)"
LIB="$HERE/../lib"
if bash "$LIB/intent.sh" negated "$last_user"; then
  exit 0
fi

# ---- Signal detection ----
resolve_hit=0
if bash "$LIB/intent.sh" resolve "$last_user" \
   && echo "$last_asst" | grep -qiE '完了|done|fixed|✅|finished|works now'; then
  resolve_hit=1
fi

if [ "$resolve_hit" -eq 0 ] && bash "$LIB/intent.sh" resolve "$last_user"; then
  if echo "$last_asst" | grep -qE '[.!。！]$'; then
    resolve_hit=1
  fi
fi

[ "$resolve_hit" -eq 0 ] && exit 0

# ---- Redact excerpt ----
user_redacted="$(printf '%s' "$last_user" | bash "$LIB/redact.sh" | head -c 2000)"
asst_redacted="$(printf '%s' "$last_asst" | bash "$LIB/redact.sh" | head -c 2000)"

excerpt="$(jq -n \
  --arg u "$user_redacted" \
  --arg a "$asst_redacted" \
  '{excerpt: [{role:"user", content:$u}, {role:"assistant", content:$a}]}')"

# ---- Enqueue ----
bash "$LIB/queue.sh" put "$session_id" "$cwd" "$excerpt"
bash "$LIB/logger.sh" metric extraction_queued "{\"session\":\"$session_id\"}"
exit 0
