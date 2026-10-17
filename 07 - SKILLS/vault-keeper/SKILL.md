---
name: "vault-keeper"
description: "Weekly vault triage: dedupe captures, tag authority/kind, review guidance inbox, refresh BALLS.md, emit ONE digest."
---

# vault-keeper

## When to use
Weekly, once. This replaces unread cron output with a single gated digest.

## Steps
1. **Captures** — find untagged / `status: seed` pages; propose `kind` + `authority` + tags. Do not bulk-edit without a yes.
2. **Dedupe** — flag near-duplicate captures and propose merges.
3. **Guidance inbox** — review `Vault/guidance/inbox/`. For each item show source / date / scope / confidence / review-by and ask: promote, reject, or expire. Nothing is promoted automatically.
4. **Registry freshness** — regenerate or verify `BALLS.md` from ball frontmatter; flag balls stale more than 30 days; fix broken paths.
5. **One digest** — a single one-screen message. Ken approves promotions; unapproved items expire in 30 days.

## Hard rules
- Never bulk-generate research. Never auto-promote to L0 (always-loaded) or L4 (guidance).
- One digest per run. If nothing needs a decision, say so and stop.
- Append every write to `Vault/log.md`.
