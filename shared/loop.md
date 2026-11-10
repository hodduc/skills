# Review loop

You are the author; the other CLI is the reviewer. A **round** is one reviewer run plus your response to every finding in it. Rounds repeat until the reviewer and you agree, then one clean review runs without history.

## The ledger

Keep `ledger.md` in the scratchpad. After each round, append every finding with your response:

```
## Round 2
2.1 [P1] Upload retried after cancel — src/upload.ts:88
    Reviewer: <one line: what goes wrong, when>
    Response: FIXED in a1b2c3d — cancel now clears the retry timer
2.2 [P2] Empty name accepted — src/form.ts:40
    Response: SKIPPED — names are validated by the API; adding a second check here duplicates it
```

Responses are FIXED (with the commit or a one-line change summary), SKIPPED (with the reason) or ESCALATED (waiting for the user). From round 2 on, pass the ledger as the context file; the reviewer then answers each item RESOLVED, WITHDRAWN or MAINTAINED before reporting new findings.

## Triage each finding

1. **Verify it.** Read the code and reproduce the reasoning. A finding you cannot confirm is SKIPPED with what you checked.
2. **Check that it is realistic.** Fix what users would hit in ordinary use, data and access leaks, and lost work. Skip what needs several unlikely conditions at once, only matters on disk-full or similar infrastructure failure, or contradicts a trade-off the PR or spec already chose.
3. **Size the fix.** A *local* fix stays inside the code the change already touches and adds no new concept. A *design* fix adds a mechanism (state, mode, flag, option, retry, lock, cache, layer), changes an interface, schema or protocol, reaches modules the change did not touch, or reverses a recorded decision.
4. **Pick the smallest response that removes the defect:** reject the input, fail loudly, document the limitation or narrow what is supported, before writing new handling.

Apply local fixes. Design fixes go to the user (next section). A finding labelled "complexity" is a fix like any other: removing code counts.

## When to stop and ask the user

The reviewer will always find another edge case. Stop the loop and ask the user, instead of defending further, when any of these is true:

- A fix you would apply is a design fix.
- Code that an earlier fix in this loop added needs a second correction (patching a patch of a patch), or the same function needs changes in a third round. A first local correction is fine.
- Fixes so far, `git diff --shortstat <loop-start>`, exceed half of the original change, `git diff --shortstat <merge-base> <loop-start>`, not counting tests.
- The reviewer MAINTAINS an item after you answered it twice. That is a disagreement, not a defect to keep patching.

When you ask, give the finding in plain words, why it triggered the stop, and two or three concrete options. One option should keep the design as it is (skip, document or narrow the scope), with what that leaves exposed. Mark the items ESCALATED, finish the other items of the round, and wait for the answer before the next round.

## Ending the loop

- **Agreement:** the reviewer RESOLVES or WITHDRAWS every ledger item and reports no new P0–P2 finding. P3 findings do not block agreement.
- **Cap:** stop after round 5 even without agreement and report where things stand. Do not start a sixth round.
- **Clean review:** after agreement, run the reviewer once more with no ledger, so it sees the change fresh. Triage its findings with the same rules. If you fix a P0 or P1 from it, run one ledger round on those fixes, within the 5-round cap. Do not chain clean reviews; report instead.

## Final report

Tell the user, without making them read round numbers or IDs:

- How it ended: agreement after N rounds, cap reached, or waiting on an escalation, and what the clean review found.
- What was fixed, one line each.
- What was skipped, with the reason.
- Open items: escalations and anything still MAINTAINED, with the options.
- How the fixes were verified (the tests you ran) and whether anything was committed or pushed.
