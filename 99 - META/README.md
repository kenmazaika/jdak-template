---
title: Meta
created: 2026-10-12
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# 99 · META

**The central hub for the agent's own meta-files and runtime state.** The source of truth for
the files that are "hooked in" to the vault — agent identity / soul / tool notes / policies —
plus the vault's **state ledgers** (cursors, watch state, seen-lists).

Keeping these in the synced vault makes them viewable and version-controlled instead of buried
inside the agent's install.

## Notes

- Meta started as a kit sub-folder (`05 - KITS/05.02 - meta`) and was promoted to its own
  top-level category on 2026-10-12.
- The base template ships the folder; the state files here are **instance data** — reset them
  on fork.
