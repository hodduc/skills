---
name: reviewing-with-claude
description: Use when the user asks to have Claude (the Claude Code CLI) review the current diff, a branch, a pull request or a stack of pull requests, and then fix what it finds
---

# Reviewing with Claude

## Overview

Claude Code reviews the change read-only; you are the author. You triage its findings, fix the ones worth fixing, and send the rest back with reasons, round after round, until Claude and you agree. Then a clean review runs without history. **REQUIRED:** read `loop.md` in this directory before the first round; it sets the rounds, the ledger, when to stop and ask the user, and the 5-round cap.

## Arguments

`$reviewing-with-claude [effort] [target] [--report-only]`. Natural-language requests map onto the same parts.

| Part | Meaning |
|---|---|
| `effort` | `low`, `medium`, `high`, `xhigh` or `max`: Claude's effort, passed as `REVIEW_EFFORT`. Omitted: Claude's configured default. |
| target omitted | the current branch with uncommitted work, against the default branch (`origin/HEAD`) |
| PR number or URL | that PR; base and head from `gh pr view <pr> --json baseRefName,headRefName` |
| branch name | that branch against the default branch |
| several PRs | a stack: each PR's base is the PR below it |
| paths | the default target, with "focus on these paths" in the context file |
| `--report-only` | one round and the report; no edits, no clean review |

Run `git fetch` first and give bases as `origin/<base>`; local branches may be stale.

## Running Claude

```sh
<skill-dir>/run-review.sh claude <dir> origin/<base> <out.md> [context-file]
```

`<skill-dir>` is the directory holding this SKILL.md. The script runs `claude -p` with `reviewer-prompt.md`, limited to Read, Grep, Glob and read-only git commands, so Claude sees committed, uncommitted and untracked changes against the merge base and cannot edit anything.

- **Command:** the script runs `claude` unless `CLAUDE_CMD` is set. If the environment or your instructions name a different Claude command for this machine (a config directory, a wrapper), pass it as `CLAUDE_CMD="<command>"`. Shell aliases do not exist in your non-interactive shell.
- **Sandbox:** Claude needs network access and writes its own state outside the workspace. Request escalated permissions for the run instead of letting the sandbox fail it.
- **Context file:** a few lines on what the change is for and the spec or convention docs to read; from round 2 on, the ledger too. Keep it, the output and the ledger in a temporary directory outside the repo.
- **Long run:** a run takes 5–30 minutes. Start it as a long-running command and keep polling until it exits; do not kill it on a timeout. Read only `<out.md>`. Read the tail of the `.log` next to it only if the script reports a failure.
- **Where:** run on the current checkout when the target is checked out there, and do not edit it while Claude runs. For a PR or branch that is not checked out, or a stack, use one detached worktree per PR outside the checkout (`git worktree add --detach <path> origin/<head>`), and `git checkout <head>` there before you fix.

## Fixing

- For a stack, fix bottom-up: fix a finding about lower-PR code in that lower PR, then merge each fixed branch into the next one up. No rebase and no force push on open PRs.
- Run the repo's tests (its AGENTS.md names them) before the next round.
- If the target started with a clean tree, commit each round's fixes locally with the repo's commit convention. If it started with uncommitted work, leave the fixes uncommitted.
- Push and watch CI only if the user asked for pushes or PRs.
- Remove the review worktrees (`git worktree remove`) when done.

## Reporting

End with the final report from `loop.md`. List the findings from all rounds and the clean review once each, most severe first, as `[P1] title — file:line — fixed / skipped: <reason> / open`. Then how the loop ended, open items with options, verification and commits.

## Common Mistakes

- Running `claude` through a shell alias: aliases are missing in your shell. Use `run-review.sh`, with `CLAUDE_CMD` when needed.
- Letting the sandbox block the run, or killing it before it exits.
- Fixing every finding, or adding handling for each new edge case instead of stopping at the triggers in `loop.md`.
- Starting a sixth round, or chaining clean reviews.
- Reading the run log instead of the output file.
