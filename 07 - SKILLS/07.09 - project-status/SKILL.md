---
name: "project-status"
description: "Answer what work is left from files: read BALLS.md plus each PROJECT.md, emit an evidence-linked digest."
base: true
---

# project-status

## When to use
"What's left?", "where are my projects?", "status across everything".

## Steps
1. Read `BALLS.md` → the registry (name · path · status · last touched · next).
2. For the requested project(s) — or all active ones — read `PROJECT.md`.
3. Emit a digest grouped by status: active → blocked → awaiting-approval → complete.
4. Every line carries a path (evidence). Nothing inferred from chat.
5. End with the top 3 next actions across all projects, and any ball stale more than 30 days.

## Rules
- Read-only. Never modify state.
- One screen max for a single project; one paragraph per project for the full sweep.
- If a project has no `PROJECT.md`, say so and point at its `BALL.md`.
