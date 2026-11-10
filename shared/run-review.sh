#!/usr/bin/env bash
# Read-only review of the change in <dir> against <base> by another agent CLI; the findings go to <out>.
# usage: run-review.sh <codex|claude> <dir> <base> <out.md> [context-file]
# env:   CODEX_CMD / CLAUDE_CMD  reviewer command (default: codex / claude); may carry env assignments and flags
#        REVIEW_EFFORT           reviewer reasoning effort (low, medium, high, xhigh, ...)
set -u
if (( $# < 4 )); then
  echo "usage: run-review.sh <codex|claude> <dir> <base> <out.md> [context-file]" >&2
  exit 2
fi
reviewer=$1 dir=$2 base=$3 out=$4 context=${5:-}
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
abspath() { echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"; }
out=$(abspath "$out")
log=${out%.md}.log
[[ -n $context ]] && context=$(abspath "$context")

cd "$dir" || exit 1
mb=$(git merge-base "$base" HEAD) || { echo "no merge base between $base and HEAD in $dir" >&2; exit 1; }

template=$(<"$here/reviewer-prompt.md")
prompt=${template//\{\{BASE\}\}/$mb}
[[ -n $context ]] && prompt+=$'\n\n# Context\n\n'$(<"$context")

effort=${REVIEW_EFFORT:-}
case $reviewer in
  codex)
    args=(exec -s read-only --ephemeral -o "$out")
    [[ -n $effort ]] && args+=(-c "model_reasoning_effort=\"$effort\"")
    eval "${CODEX_CMD:-codex} $(printf '%q ' "${args[@]}") -" <<<"$prompt" >"$log" 2>&1
    ;;
  claude)
    git_ro=("Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)" "Bash(git status:*)" "Bash(git blame:*)" "Bash(git grep:*)")
    args=(-p --no-session-persistence --permission-mode dontAsk --output-format text
          --tools Read Grep Glob Bash --allowedTools Read Grep Glob "${git_ro[@]}")
    [[ -n $effort ]] && args+=(--effort "$effort")
    eval "${CLAUDE_CMD:-claude} $(printf '%q ' "${args[@]}")" <<<"$prompt" >"$out" 2>"$log"
    ;;
  *)
    echo "unknown reviewer: $reviewer (codex or claude)" >&2
    exit 2
    ;;
esac
code=$?
if (( code != 0 )) || [[ ! -s $out ]]; then
  echo "$reviewer failed (exit $code, output $out): see the tail of $log" >&2
  exit 1
fi
echo "review → $out"
