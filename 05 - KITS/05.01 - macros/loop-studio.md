---
title: "Macro — Loop Studio"
created: 2026-10-14
updated: 2026-10-14
type: macro
status: active
authority: authoritative
tags: [macro, schema, loops]
trigger: "Loop Studio"
inputs: [a plain-text brief — what it does · where it looks · what "good" is; optional: cadence, approval, audience]
output: a registered, runnable loop (folder + skill + inbox approval + runs/)
---

# Macro — Loop Studio

**Trigger:** "Loop Studio" · "build a loop" · "new loop <topic>"
**Does:** Turn a plain-text brief into a complete, runnable loop — folder, executor skill, inbox
approval, hyperparameters, `runs/` trail — then register + verify + sync.

**What it is:** you describe a recurring job in plain words — *"every day, find one blog topic"* — and
Loop Studio **scaffolds the whole loop**. Building a loop stops being *"how do I wire this up?"* and
becomes *"where does it go?"*

## Why it's cheap here

The mechanisms already exist in the vault — Loop Studio just **assembles** them:

- **A home** — `06 - LOOPS/NN.MM - <loop>/` holds the *config*; the *artifact* lives on its real shelf.
- **An executor** — a generic skill in `07 - SKILLS/`; the levers live in the loop's `LOOP.md`.
- **Approval** — the inbox (`00 - INBOX/00.01`) with an action block; the **checked box is the approval**.
- **Feedback** — reasons land in `feedback.md`; the inbox sweep bulk-processes them into rules.
- **Resumability** — `runs/<date>/` batons + a `ledger.md`; a timeout is just a re-run.

## Inputs
- The brief: **what · where it looks · what "good" is** (or enough to draft it).
- Optional: cadence · approval on/off · audience.

## Steps
1. Restate the brief as a **driving question** → `01-brief.md`.
2. Design: fetch/where · **value gate** (rubric + threshold) · run shape (batons) · routing · approval ·
   parameters → `02-design.md`.
3. Scaffold `06 - LOOPS/NN.MM - <slug>/`: `LOOP.md` · `prompt.md` · `runs/` · `ledger.md` · `feedback.md`.
4. Add the **generic executor skill** in `07 - SKILLS/` (symlink into the live skills dir) — or point at
   an existing one. Keep it generic; the levers stay in `LOOP.md`.
5. **Wire the inbox**: an `## Your action` block (approve / deny / deny+reason — per `05.07`).
6. Register: `06 - LOOPS/README.md` table + `BALLS.md`.
7. **Verify**: a dry-run that emits a baton without error.
8. Commit + sync + log (`log.md` + the owning ball's `commands.log`).

## Design defaults (lean on these)

- **Approval on by default.** Start with an inbox approve/deny(+reason) gate; remove later if it's noise.
- **File-baton, fresh process.** Verification/critique runs in a *separate* process that sees only the file.
- **Intermediate files live in the vault** — fleeting work in `09 - FLEETING`, durable output in
  `04 - RESOURCES` / `03 - PERMANENT`, drafts in production.
- **Parameters over code.** Tweak the loop's `LOOP.md`, not the skill.
- **`runs/<date>/`** always; one file per phase; **numbered = order**.
- **Route by "where does it belong?"** — not by QBall.

## Output
→ a registered, runnable loop (+ its skill) and its batons: `06 - LOOPS/NN.MM - <loop>/` +
`07 - SKILLS/…` executor + an inbox approval + `runs/`.
