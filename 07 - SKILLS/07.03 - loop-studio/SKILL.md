---
name: "loop-studio"
description: "Build a complete, runnable vault loop from a plain-text brief — scaffold the 06-LOOPS folder, a generic executor skill, the inbox approval flow, hyperparameters, and the runs/ baton trail. Trigger: 'Loop Studio' / 'build a loop' / 'new loop <topic>'."
---

# Loop Studio

The **generic executor** that turns a plain-language brief — *"every day, find one blog topic"* — into a
working loop. Doctrine: `05 - KITS/05.01 - macros/loop-studio.md`. The phrase is the macro
`05 - KITS/05.01 - macros/loop-studio.md`.

## When to use

- Ken says **"Loop Studio"**, "build a loop", "new loop <topic>", or describes a recurring job to wire.

## What it assembles (the mechanisms already exist)

- **A home** — `06 - LOOPS/NN.MM - <slug>/` (config): `LOOP.md` · `prompt.md` · `runs/` · `ledger.md` · `feedback.md`.
- **The artifact's real shelf** — where durable output *belongs* (`04 - RESOURCES` · `03 - PERMANENT` · production).
- **An executor** — a generic skill in `07 - SKILLS/`; hyperparameters stay in `LOOP.md`.
- **Approval** — an inbox action block (`00 - INBOX/00.01`); the **checked box is the approval**.
- **Feedback** — reasons → `feedback.md`, bulk-processed by the **inbox sweep** into standing rules.
- **Resumability** — `runs/<date>/` batons + a `ledger.md`; a timeout is just a re-run.

## Inputs (a brief)

1. **What** — the job in one sentence (the *driving question*).
2. **Where** — sources (web · reddit/x · the vault · a repo).
3. **What "good" is** — the rubric / value gate, and where output goes.

Optional: cadence · approval on/off · audience. Ask **only** if a key input is missing; otherwise draft it.

## Steps (each writes a baton; hand the next step to a fresh process)

1. **`01-brief.md`** — restate the brief + the driving question.
2. **`02-design.md`** — fetch/where · **value gate** (rubric + threshold) · run shape (batons) · routing · approval · parameters.
3. **`03-scaffold.md`** — create the loop folder: `LOOP.md` · `prompt.md` · `runs/` · `ledger.md` · `feedback.md`.
4. **`04-skill.md`** — add the **generic** executor skill in `07 - SKILLS/` (symlink into the live skills dir) or point at an existing one.
5. **`05-wire.md`** — the inbox `## Your action` block (approve / deny / deny+reason — per `05.10`) + registry rows (`06 - LOOPS/README.md`, `BALLS.md`).
6. **`06-verify.md`** — a dry-run that emits a baton without erroring.
7. Commit + sync + log.

## Rules

- **Approval on by default** — inbox approve/deny(+reason); drop it later if it's noise.
- **Fresh process for critique** — the designer never grades its own work.
- **Intermediate files in the vault** — in the shelf where they belong.
- **Parameters over code** — tweak `LOOP.md`, not the skill.
- **Route by "where does it belong?"** — a loop isn't QBall-constrained; durable output goes to its real shelf.
- **One node per file**; numbered = order; a baton carries everything the next step needs.
