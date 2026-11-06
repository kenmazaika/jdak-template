---
name: "vault-keeper"
description: "Weekly vault triage: dedupe captures, tag authority/kind, review guidance inbox, refresh BALLS.md, emit ONE digest."
base: true
---

# vault-keeper

## When to use
Weekly, once. This replaces unread cron output with a single gated digest.

## Steps
1. **Find the vault** — locate the directory containing `SCHEMA.md`, `00 - INBOX/`, and `01 - PROJECTS/`. If more than one candidate exists, ask which vault to use. Treat it as `<vault-root>` below.
2. **Captures** — find untagged / `status: seed` pages; propose `kind` + `authority` + tags. Do not bulk-edit without a yes.
3. **Dedupe** — flag near-duplicate captures and propose merges.
4. **Guidance review** — if `<vault-root>/03 - PERMANENT/03.02 - guidance/` exists, review its seed or pending pages. For each item show source / date / scope / confidence / review-by and ask: promote, reject, or expire. Nothing is promoted automatically. If the folder is absent, skip this step.
5. **Registry freshness** — regenerate or verify `<vault-root>/BALLS.md` from ball frontmatter; flag balls stale more than 30 days; fix broken paths.
6. **One digest** — a single one-screen message. The owner approves promotions; unapproved items expire in 30 days.

## Hard rules
- Never bulk-generate research. Never auto-promote to L0 (always-loaded) or L4 (guidance).
- One digest per run. If nothing needs a decision, say so and stop.
- Append every write to `<vault-root>/log.md`.
