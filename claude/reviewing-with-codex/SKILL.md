---
name: reviewing-with-codex
description: Use when the user asks to have Codex (the OpenAI Codex CLI) review the current diff, a branch, a pull request or a stack of pull requests, and then fix what it finds
---

# Reviewing with Codex

## Overview

Codex reviews the change read-only; you are the author. You triage its findings, fix the ones worth fixing, and send the rest back with reasons, round after round, until Codex and you agree. Then a clean review runs without history. **REQUIRED:** read `loop.md` in this directory before the first round; it sets the rounds, the ledger, when to stop and ask the user, and the 5-round cap.

## Arguments

`/reviewing-with-codex [effort] [target] [--report-only]`, shaped like `/code-review`. Natural-language requests map onto the same parts.

| Part | Meaning |
|---|---|
| `effort` | `low`, `medium`, `high` or `xhigh`: Codex's reasoning effort, passed as `REVIEW_EFFORT`. Omitted: Codex's configured default. |
| target omitted | the current branch with uncommitted work, against the default branch (`origin/HEAD`) |
| PR number or URL | that PR; base and head from `gh pr view <pr> --json baseRefName,headRefName` |
| branch name | that branch against the default branch |
| several PRs | a stack: each PR's base is the PR below it |
| paths | the default target, with "focus on these paths" in the context file |
| `--report-only` | one round and the report; no edits, no clean review |

Run `git fetch` first and give bases as `origin/<base>`; local branches may be stale.

## Running Codex

```sh
<skill-dir>/run-review.sh codex <dir> origin/<base> <out.md> [context-file]
```

`<skill-dir>` is the base directory shown when this skill loads. The script runs `codex exec -s read-only --ephemeral` with `reviewer-prompt.md`, so Codex sees committed, uncommitted and untracked changes against the merge base.

- **Command:** the script runs `codex` unless `CODEX_CMD` is set. If the environment or your instructions name a different Codex command for this machine (a profile, a `CODEX_HOME`), pass it as `CODEX_CMD="<command>"`. Shell aliases do not exist in your non-interactive shell.
- **Context file:** a few lines on what the change is for and the spec or convention docs to read; from round 2 on, the ledger too. Keep it, the output and the ledger in the session scratchpad.
- **Background:** one background Bash call per run; a run takes 5–30 minutes and you are notified when it ends. Read only `<out.md>`. Read the tail of the `.log` next to it only if the script reports a failure.
- **Where:** run on the current checkout when the target is checked out there, and do not edit it while Codex runs. For a PR or branch that is not checked out, or a stack, use one worktree per PR in `.claude/worktrees/codex-<pr>`: `git worktree add --detach <path> origin/<head>` for the first round, `git checkout <head>` there before you fix. Different worktrees can run in parallel.

## Fixing

- Fix directly for one branch. For a stack, give one subagent per PR a brief with the findings, the decided fixes and the tests to add; fix bottom-up, merge each fixed branch into the next one up, and fix a finding about lower-PR code in that lower PR. No rebase and no force push on open PRs.
- Run the repo's tests (its AGENTS.md or CLAUDE.md names them) before the next round.
- If the target started with a clean tree, commit each round's fixes locally with the repo's commit convention. If it started with uncommitted work, leave the fixes uncommitted.
- Push and watch CI only if the user asked for pushes or PRs.
- Remove the review worktrees (`git worktree remove`) when done.

## Reporting

At the end, call `ReportFindings` once with every distinct finding from all rounds and the clean review, most severe first: `verdict` CONFIRMED when you verified it, PLAUSIBLE when you could not; `outcome` fixed, skipped or no_change_needed (leave `outcome` out with `--report-only`). Then write the rest of the final report from `loop.md` in text: how the loop ended, skip reasons, open items with options, verification, commits. Do not repeat the findings themselves.

## Common Mistakes

- Running the alias `codex` or a profile alias directly from Bash: aliases are missing there. Use `run-review.sh`, with `CODEX_CMD` when needed.
- Using `codex review --base`: it rejects a custom prompt, so there are no priorities or conditions.
- Fixing every finding, or adding handling for each new edge case instead of stopping at the triggers in `loop.md`.
- Starting a sixth round, or chaining clean reviews.
- Reading the run log instead of the output file.
