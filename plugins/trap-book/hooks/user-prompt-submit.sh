#!/usr/bin/env bash
# hooks/user-prompt-submit.sh
# 1. consume any .queue/*.json matching cwd → emit extraction directive
# 2. detect inject intent → kb-mcp search → emit additionalContext

set -euo pipefail

input="$(cat)"

[ "${TRAP_BOOK_DISABLE:-}" = "1" ] && exit 0

prompt="$(echo "$input" | jq -r '.prompt // empty')"
cwd="$(echo "$input" | jq -r '.cwd // empty')"
[ -z "$cwd" ] && cwd="$PWD"

[ -f "$cwd/.trap-book-ignore" ] && exit 0

HERE="$(cd "$(dirname "$0")" && pwd)"
LIB="$HERE/../lib"

context=""

# ---- (1) Queue consumption (regardless of prompt length) ----
queued="$(cd "$cwd" 2>/dev/null && bash "$LIB/queue.sh" take 2>/dev/null || true)"
if [ -n "$queued" ]; then
  last_take_file="${TRAP_BOOK_CACHE_DIR:-$HOME/.cache/trap-book}/queue/.last_take"
  lock="$(cat "$last_take_file" 2>/dev/null || true)"
  directive="[trap-book] 直前セッションで解決シグナルが検出されました。以下の excerpt を Agent(subagent_type=\"trap-extractor\", model=\"haiku\") に prompt として渡し、pitfall/strategy があれば抽出してください。該当なしなら Agent を呼ばずスキップして構いません。

<transcript-excerpt>
$queued
</transcript-excerpt>"
  context+="$directive"$'\n\n'
  [ -n "$lock" ] && bash "$LIB/queue.sh" finalize "$lock"
  bash "$LIB/logger.sh" metric extraction_dispatched '{}' 2>/dev/null || true
fi

# ---- (2) Length gate + Injection ----
# Per design §5.6, length gate lives here (not in intent.sh)
if [ "${#prompt}" -ge 10 ]; then
  if bash "$LIB/intent.sh" inject "$prompt" 2>/dev/null; then
    search_out="$(bash "$LIB/kb-search.sh" "$prompt" 2>/dev/null || true)"
    if [ -n "$search_out" ]; then
      context+="## 過去の関連 trap (trap-book)

$search_out

[注: status: auto_extracted は未レビュー。参考程度に扱ってください。]"$'\n'
      bash "$LIB/logger.sh" metric injection_hit '{}' 2>/dev/null || true
    fi
  fi
fi

# ---- Emit ----
if [ -n "$context" ]; then
  jq -n --arg ctx "$context" \
    '{hookSpecificOutput: {hookEventName: "UserPromptSubmit", additionalContext: $ctx}}'
fi
exit 0
