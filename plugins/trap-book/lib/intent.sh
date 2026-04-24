#!/usr/bin/env bash
# lib/intent.sh
#
# Usage:
#   intent.sh inject   "<prompt>"   → exit 0 if inject-intent hit
#   intent.sh resolve  "<text>"     → exit 0 if resolution signal hit
#   intent.sh negated  "<text>"     → exit 0 if negation filter hit (cancel resolve)
#
# Exit codes: 0 = match, 1 = no match
# (No length gating here. Short-input skip happens at the hook layer.)

set -euo pipefail

kind="${1:-}"
text="${2:-}"

case "$kind" in
  inject)
    echo "$text" | grep -qiE '実装|作成して|書いて|直して|修正|デバッグ|\b(implement|fix|debug|build|modify)\b|write (the|a) code'
    ;;
  resolve)
    echo "$text" | grep -qiE '動いた|できた|解決|完璧|完了|\b(OK|perfect|works|fixed|it works)\b|ありがとう'
    ;;
  negated)
    echo "$text" | grep -qiE 'まだ動|解決して|うまくいか|できない|\b(does.?n.t work|still failing|not fixed)\b'
    ;;
  *)
    echo "usage: intent.sh {inject|resolve|negated} <text>" >&2
    exit 64
    ;;
esac
