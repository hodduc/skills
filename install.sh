#!/usr/bin/env bash
# Link the skills in this repo into Claude Code's and Codex's skill directories.
set -eu
repo=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

link() {
  local src=$1 dest=$2/$(basename "$1")
  mkdir -p "$2"
  if [[ -e $dest && ! -L $dest ]]; then
    echo "skip $dest: exists and is not a symlink; move it away first" >&2
    return
  fi
  ln -sfn "$src" "$dest"
  echo "$dest -> $src"
}

for s in "$repo"/claude/*/; do link "${s%/}" "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"; done
for s in "$repo"/codex/*/; do link "${s%/}" "${CODEX_HOME:-$HOME/.codex}/skills"; done
