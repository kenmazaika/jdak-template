---
title: Projects
created: 2026-10-12
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# 01 · PROJECTS

**Where work in flight lives.** Every durable intermediate file an agent produces belongs
to a *project* — a numbered folder in the **QBall** format. This is the cure for *file
spray*: instead of strewing files across the workspace, the agent drops them into the
project they belong to, and both of you can always find them again.

## Two shelves: `01.02 - qballs/` + `CARDS/`

- **`01.02 - qballs/`** — the **QBalls**: contained, throwable buckets of work (the format below). Each ball is
  its own sub-folder, `01.02 - qballs/NN.MM - slug/`.
- **`CARDS/`** — the **portfolio of outcomes**, one card per outcome tracked to completion (see
  `CARDS/README.md`). Bigger than any single ball.

## What a project is

`01 - PROJECTS/01.02 - qballs/NN.MM - slug/` — the QBall convention, formalised:

```
NN.MM - slug/
├── PROJECT.md      # the contract: objective · state · next · open decisions (start here)
├── BALL.md         # one-screen state read (the spine)
├── decisions.md    # WHY — read first on any resume
├── LINEAGE.md      # exact prompts/models/commands per version
├── commands.log    # append-only command trail
├── prompts/  receipts/  campaign/  dictations/  assets/   (as needed)
└── HANDOFF-*.md    # pause/resume handoff (+ a 6-digit resume key)
```

## Why it matters

- **Interruption is cheap.** Pause any job and the *state* is already on disk; resuming is
  just reading `decisions.md` → `BALL.md` → the latest handoff. No bespoke context-management
  system needed.
- **Nothing is orphaned.** A file without a project is a file you'll forget. If durable work
  has no home, make a project.
- **One source of truth.** Symlink shared assets between projects — never copy.

## Conventions

- Register every project (one line) in `BALLS.md`.
- New QBall → next free `01.MM` inside `01.02 - qballs/`; **never renumber** a retired number.
- Set `status: complete` on ship; optionally move heavy intermediates to `10 - ARCHIVE`.
- Resume order: `decisions.md` → `BALL.md` → latest `HANDOFF-*.md` → `LINEAGE.md`.

## Does NOT belong here

- Raw sources → `09 - FLEETING`; distilled notes → `03 - PERMANENT`; reusable output →
  `04 - RESOURCES`.
- Throwaway scratch — use a temp dir, not a project.
