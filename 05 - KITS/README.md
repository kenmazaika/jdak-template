---
title: Kits
created: 2026-10-12
updated: 2026-10-14
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# 05 · KITS

**The vault's own machinery.** A kit is the connective tissue between skills — the reusable
routine that chains moves together. If a *skill* is one move, a *kit* is the pattern that runs
moves in sequence (e.g. a skill that ends by emitting a handoff "ready for the next skill").
Kits are deliberately *more verbose* than skills — they carry the structure, not just the action.

## What lives here

| # | Folder | Holds |
|---|---|---|
| `05.01` | `macros/` | **Macros:** the owner's phrase → routine surface — the list + one file per macro (see `05.01 - macros/README.md`). |
| `05.02` | `templates/` | Page scaffolding (daily-note, handoff, project, area, capture, macro, …). |
| `05.03` | `scripts/` | The vault's own tooling (`gen-index.py`, sync helpers). |
| `05.04` | [`qball.md`](05.04%20-%20qball.md) | **Kit — QBall:** the resumable-work bundle (6 layers, symlink rule, handoff/resume, ship-it signal). |
| `05.05` | [`skill-handoffs.md`](05.05%20-%20skill-handoffs.md) | **Kit — Skill pipelines & handoffs:** chaining skills into a multi-phase pipeline with the file as the baton. |
| `05.06` | [`compact.md`](05.06%20-%20compact.md) | **Kit — Compact:** the one-word sort/renumber op (general-first · folders-above-files). |
| `05.07` | [`inbox-message-playbook.md`](05.07%20-%20inbox-message-playbook.md) | **Kit — Inbox-message playbook:** how to write an agent→owner handoff (scan, decide, checkboxes). |
| `05.08` | `install/` | Install kit — vault, sync, and the agent integration points. |

> **Loops** and **meta** have their own top-level categories: `06 - LOOPS` (registered loops + runs) and
> `99 - META` (agent identity/config + state ledgers).
>
> **2026-10-14 renumber:** macros folded into a single numbered folder (`05.01 - macros/` — the list + the
> definitions); `templates/` moved up to `05.02`; two stale docs (`capture-policy`, `dictation-capture`)
> retired to `10 - ARCHIVE/`. The shelf is contiguous `05.01`–`05.08`.

## Notes

- **Macro vs kit:** a *macro* (`05.01`) is owner-facing and short — a phrase → a few steps. A *kit* doc
  (e.g. `05.04 - qball`) is the longer doctrine. Both are "a named routine"; **promote a macro to a skill**
  when it grows real logic, inputs, or gets reused across loops.
- Scripts here are the *vault's* tooling, not general-purpose code.
- Kit **docs** stay generic (base); any state is instance data.
