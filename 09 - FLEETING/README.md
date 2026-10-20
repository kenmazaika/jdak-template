---
title: Fleeting
created: 2026-10-13
updated: 2026-10-13
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# 09 · FLEETING

**The landing pad.** Stuff that doesn't fit cleanly anywhere yet — **pre-production**. It came from
somewhere (a capture, the Intake, a demoted note), but hasn't earned `03 - PERMANENT` or
`04 - RESOURCES`, and isn't stale enough for `10 - ARCHIVE`.

## What lives here

| # | Folder | Holds |
|---|---|---|
| `09.01` | `raw/` | **Immutable** sources — `articles/` · `assets/` · `session-turns/` · `content/`. Read, never edit. |
| `09.02` | `concepts/` | Fleeting ideas — started, not yet promoted. |
| `09.03` | `entities/` | *(demoted out of `03 - PERMANENT` 2026-10-13.)* |
| `09.04` | `comparisons/` | *(demoted 2026-10-13.)* |
| `09.05` | `questions/` | *(demoted 2026-10-13.)* |
| `09.06` | `production/` | **Production** — `drafts/` · `working/` · `media-company/`. The in-flight outputs. |
| `09.07` | `tickets/` | **Ticket backing folders** — machinery for `00.03` tickets (`prompts/` · `outputs/` · `work/`). |

## The pipeline

```
Intake (00) → FLEETING (09) → [09.06 production] → Permanent (03)  or  Archive (10)
```

- Fleeting → **production (`09.06`)** when it becomes an actual output (a draft, a build).
- Production → **Permanent (`03`)** when distilled + durable; → **Archive (`10`)** when stale.

## Rules

- **Transient by design** — Fleeting should stay small; items promote or get swept.
- **A sweep clears it** — *not wired yet* (deliberate: no auto-clear; the owner wants a manual/opt-in
  sweep). When built: each item → promote (→ `03`/`04`/`09.06`) or archive (→ `10`).
- The raw trees (`articles/` · `assets/` · `session-turns/` · `content/`) are **immutable** — never edit.
- A demoted `03` item lands here, not in Archive — *declassified*, not dead.
- Keep it **shallow** (≤2 levels) — that's why the raw trees sit at the top of this shelf.

> **Slot note:** `08` retired when Production moved here. The shelf order is now … `07 SKILLS` ·
> `09 FLEETING` · `10 ARCHIVE`.
