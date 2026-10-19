---
name: "three-phase-pr"
description: "Run a three-phase development loop that turns project context into one focused pull request: research and specify the idea, implement it on a separate branch, then validate and open the PR. Trigger: 'three-phase PR' / 'run the dev loop' / a loop that cites this skill."
base: true
---

# Three-Phase PR

A generic executor for a development loop whose output is **one pull request**. The loop's `LOOP.md`
supplies the project, the categories to mine, the dedupe sources, and the success criteria; this skill
supplies the procedure.

## The contract

- **One run = one idea = at most one PR.** No bundles.
- **Each phase is a fresh process.** It reads the previous phase's file (the baton), not the chat.
- **Two valid "no" outcomes.** The idea phase may conclude *nothing worth doing*; the validation phase
  may conclude *do not open a PR*. Both are successful runs.
- **Never merge.** The PR is the handoff to the owner.
- **No instance data.** The PR must be useful to any fork of the project, not just this instance.

## Inputs — read from `LOOP.md`

| Input | What it gives you |
|---|---|
| `project` | repo + default branch |
| `context` | what the project is, why it exists |
| `objective` | what a good PR changes |
| `categories` | the allowed kinds of work; pick one per run |
| `dedupe` | open PRs, branches, ledger, prior runs |
| `success` | the gate a PR must clear |
| `runs` | where the batons go |
| `output` | PR target + inbox handoff |

## Phase 1 — Research & specify

**Goal:** turn the loop's abstract context into ONE specific, implementable PR idea.

1. **Load context.** Read `LOOP.md`, the project README/schema/install docs, and the last three run
   ledgers. Know what the project is *supposed* to be before proposing a change.
2. **Dedupe first.** Check:
   - open PRs (`gh pr list --state open`) and the files each one touches;
   - open branches (`git branch -r`) and recent commits;
   - this loop's `ledger.md` + `runs/*/01-idea.md`;
   - the owner's open inbox handoffs.
   If an open PR or branch already covers the idea, **discard it**. If it partially overlaps, narrow
   until the new PR is additive.
3. **Choose a category.** Prefer the one least recently used in `ledger.md`, unless the evidence for
   another is much stronger. State the choice and why.
4. **Explore, then converge.** Within the chosen category, inspect the real artifacts (files, docs,
   scripts, install path). Collect **evidence**: exact paths, line references, broken links, missing
   hooks, failed commands. Do not propose a theme; propose a change.
5. **Write `01-idea.md`.** It must be implementable by a process that has never seen this conversation:
   - title + category
   - the problem, with evidence
   - the proposed change (file by file)
   - acceptance criteria (observable)
   - non-goals / what not to touch
   - risks + rollback
   - validation commands
   - dedupe receipt (what you checked, what you ruled out)
   - success-criteria check (why this clears the loop's gate)

**Stop rule:** if no idea clears the gate, write `01-idea.md` with `verdict: no-op` and the reason. End
the run. Do not implement.

## Phase 2 — Implement

**Goal:** execute `01-idea.md` on a separate branch.

1. Read only the baton + the repo. Do not re-litigate the idea.
2. Branch from the loop's default branch (or the base named in the baton). Use
   `loop/<slug>-<date>`.
3. Implement the baton's file-by-file change. Keep the diff inside the stated scope.
4. Run the baton's validation commands. Fix failures caused by the change.
5. Write `02-implementation.md`: branch, commits, files changed, commands run + output, deviations
   from the baton and why, anything the validator must know.

**Stop rule:** if the change cannot be implemented as specified, stop and write `02-implementation.md`
with `status: blocked` + the exact blocker. Do not improvise a different PR.

## Phase 3 — Validate & open the PR

**Goal:** independently verify the work, then open a clean PR — or refuse.

1. Read `01-idea.md` + `02-implementation.md` + the diff. Do not assume the implementer's claims.
2. **Validate against the acceptance criteria.** Re-run the commands. Check:
   - the diff matches the baton's scope (no unrelated files);
   - docs/tests/scripts still work;
   - no instance data, secrets, personal paths, or owner names;
   - the loop's success criteria all pass.
3. **Decide.** If any criterion fails, write `03-validation.md` with `verdict: no-pr`, the failing
   criterion, and the evidence. Do not open a PR.
4. If it passes, push the branch and open the PR:
   - **Title:** a plain, descriptive summary — what changed, not why it matters.
   - **Body:** 2–4 short paragraphs or bullets: what changed, why, how it was verified. Write like a
     normal engineer, not a launch post. No emoji headers, no "comprehensive", no filler.
   - End with one line: `Created by Felix 👾`.
   - Target the loop's default branch. Never merge.
5. Write `03-validation.md`: verdict, criteria table, commands + results, PR URL.
6. Append a `ledger.md` row: date · category · idea · PR · verdict.

## Rules

- **Evidence over vibes.** Every claim in the idea points at a file, line, command, or PR.
- **Dedupe is a gate, not a step.** If it is already in flight, it is not a new idea.
- **Scope is the contract.** A validator rejects scope creep even when the extra change is good.
- **Fresh eyes.** The implementer never validates their own work; the validator never rewrites it.
- **The PR is the artifact.** Batons are for resumability, not for the owner to read.
