#!/usr/bin/env bash
# harness-kit Stop hook reminder.
#
# Emits a reminder only when:
#   (1) this Stop is NOT already caused by a previous Stop hook (prevents loops), and
#   (2) the current project has been harness-initialized
#       (features.json or claude-progress.txt exists at the project root).
# Otherwise exits silently so that empty / unrelated projects are not disrupted.

set -euo pipefail

input="$(cat)"

if printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

cwd="$(printf '%s' "$input" \
  | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -n1)"
if [ -z "${cwd:-}" ]; then
  cwd="${PWD:-.}"
fi

if [ ! -f "$cwd/features.json" ] && [ ! -f "$cwd/claude-progress.txt" ]; then
  exit 0
fi

cat <<'JSON'
{
  "decision": "block",
  "reason": "作業を終える前に確認してください。(1) features.json に今回の作業に関連する機能があれば status を更新する。(2) claude-progress.txt に作業内容を追記する。(3) evaluator エージェントによる品質チェックが未実施なら提案する。該当する更新が無い場合、または今回がユーザーへの質問回答のみで成果物の変更を伴わない場合は、何もせずそのまま停止してよい。"
}
JSON
