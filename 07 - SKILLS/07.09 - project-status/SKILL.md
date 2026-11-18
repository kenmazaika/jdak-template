---
name: "project-status"
description: "Answer what work is left from files: locate the vault, read its BALLS.md plus each PROJECT.md, and emit an evidence-linked digest."
base: true
---

# project-status

## When to use
"What's left?", "where are my projects?", "status across everything".

## Steps
1. Set `<vault>` to the directory that contains `BALLS.md`. It may be the current repository root or
   a `Vault/` child of the workspace. If more than one candidate exists, ask which vault to use.
2. Read `<vault>/BALLS.md` → the registry (name · path · status · last touched · next).
3. For the requested project(s) — or all active ones — read each `<vault>/<project-path>/PROJECT.md`.
4. Emit a digest grouped by status: active → blocked → awaiting-approval → complete.
5. Every line carries a path (evidence). Nothing inferred from chat.
6. End with the top 3 next actions across all projects, and any ball stale more than 30 days.

## Rules
- Read-only. Never modify state.
- One screen max for a single project; one paragraph per project for the full sweep.
- If a project has no `<vault>/<project-path>/PROJECT.md`, say so and point at its
  `<vault>/<project-path>/BALL.md`.
