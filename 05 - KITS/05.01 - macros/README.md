---
title: Macros
created: 2026-10-13
updated: 2026-10-14
type: schema
kind: fact
status: active
authority: authoritative
tags: [macro]
---

# 05.01 · macros

**A Macro is a short, named, reusable routine the owner writes** — "say X, and the agent does Y."
A mini-skill, authored in the vault, invoked by a phrase.

> The point: a place to say *"hey, do this, then that"* — without spinning up a full agent skill.

## Macro vs Skill

| | Written by | Lives | Is |
|---|---|---|---|
| **Macro** | the **owner** | `05 - KITS/05.01 - macros/<slug>.md` | a few ordered steps + the phrase that triggers it |
| **Skill** | the agent (usually) | `07 - SKILLS/` | a reusable, agent-facing procedure with real logic |

**Promote a macro → a skill** when it grows real logic, inputs, or gets reused across loops.

## The list

| Trigger | Macro | Does |
|---|---|---|
| `send it to inbox` | [`send-it-to-inbox.md`](send-it-to-inbox.md) | Turn the recent messages + decision into a clean inbox handoff (checkboxes + suggested actions). |
| `reorganize the shelves` | [`reorganize-shelves.md`](reorganize-shelves.md) | Sort & renumber the shelves top-down (general-first, contiguous), fix references, re-sync. |
| `Loop Studio` | [`loop-studio.md`](loop-studio.md) | Turn a plain-text brief into a complete, runnable loop (folder · skill · inbox approval · runs/). |
| `execute the ticket` | [`execute-the-ticket.md`](execute-the-ticket.md) | Run a ticket's latest comment (reverse-prompt → execute → write back). |

*(add yours below.)*

## Shape

Create one from `05 - KITS/05.02 - templates/macro.md`:

```yaml
---
title: "Macro — <name>"
type: macro
status: active
trigger: "<the phrase that runs it>"
inputs: [<what it needs>]
output: "<where the result lands>"
---
```

Body: **Trigger · Does (one line) · Inputs · Steps (ordered) · Output → where · Notes.**

## Running one

- The owner says the **trigger** (or `run macro <name>`).
- The agent reads the macro, runs the steps, and **links the output into the daily note**.

## Home

`05 - KITS/05.01 - macros/` — one file per macro; the list above is the shelf.
