---
title: Loops
created: 2026-10-12
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema, loops]
---

# 06 · LOOPS

**Where loops are configured.** A **loop** is a recurring, parameterised job. The executing **skill**
stays generic; the loop holds the **hyperparameters** — the levers you tweak.

## The three pieces (per loop)

1. **The loop** — `06 - LOOPS/NN.MM - <loop>/LOOP.md`. *What* it looks for, the parameters, the
   cadence, and the rubric for **"is the output worth it?"**
2. **The skill** — `07 - SKILLS/<skill>/SKILL.md`. The generic **executor**. Vendored in the vault
   and **symlinked** into the agent's live skills dir, so **the vault is the source of truth**.
3. **The runs** — `06 - LOOPS/NN.MM - <loop>/runs/<date>/`. What each run actually produced.

## Shape

```
06 - LOOPS/
└── NN.MM - <loop>/
    ├── LOOP.md        # what it does · where to look · parameters · rubric · routing
    └── runs/
        └── YYYY-MM-DD/  # the run's artifacts (interim batons + the final output)
```

## How a run works

1. **Fetch** — the skill reads `LOOP.md` for the parameters, then looks where it says.
2. **Baton handoff** — write interim output to a **file**, then hand off to a **fresh process** with
   no shared prompt context. The new process gets the *file*, not the reasons — so it can critique
   or take a different angle. (No Kanban needed: the file *is* the baton.)
3. **Dedupe + value gate** — before writing anything, check the rubric. No value → write **nothing**
   (or one line: "investigated X — not worth it").
4. **Route** — a worthwhile result lands where `LOOP.md` says. (For distribution research: a new
   channel → `04 - RESOURCES/04.07 - distribution/`.)
5. **Inbox (optional)** — if the result clears the rubric, the loop posts an `00 - INBOX` message.

## Inbox actions (owner → agent, back)

A loop that posts an inbox handoff can attach an **`## Your action`** block — markdown checkboxes, one
outcome per box. The owner checks **one** box (and may add notes under `## Comments`) and lets the vault
sync. An **inbox sweep** then performs the checked action:

1. Scan `00 - INBOX/00.01 - handoffs/*.md` for a file with a checked box (`- [x]`) and `action: pending`.
2. Read its `loop:` frontmatter → dispatch to that loop's **Actions** table (defined in its `LOOP.md`).
3. Perform it (accept → promote/publish; reject → archive; reason → the loop's `feedback.md`).
4. Flip `action: done`, write a `ledger.md` row, append a line to today's **daily note**
   (`Loop runs` / `Inbox processed`), and move the handoff out of `00.01` (to `10 - ARCHIVE`).

The **action set is per loop** — publish has accept / reject / reject+reason; a research loop might have
promote / skip. Define the verbs in the loop's `LOOP.md`; the mechanism (scan → dispatch → log → archive)
is generic. The **checked box is the owner's approval** — the sweep acts on it without asking again.

## Rules

- **Separate skills from parameters.** Tweak the loop, not the skill.
- **Every run leaves an artifact** in `runs/<date>/` — so you can diff it over time.
- **Don't write noise.** "Ran today, nothing new" is not an output.
- **Baton = a file.** Hand off to a fresh process instead of one long context — cleaner critique.
- Loops are usually cron-driven; the loop says *what*, the schedule says *when*.
- Anything written into the vault follows the **Vault Voice Guide**.

## The registry

| Loop | What it does | Cadence | Outputs to |
|---|---|---|---|
| `06.01 - distribution-research` | Scout new places to distribute the blog; promote one new channel | daily | `04.07 - distribution/` + inbox |
| `06.02 - publish-blog` | Produce ONE new `publish.kenmazaika.com` post that teaches Ken something new; dedupe while a draft is pending; log accept/reject + reason | daily | `08 - PRODUCTION/drafts/` (**the draft**) + inbox |
| `06.03 - research-engine` | Review the goals → frame **one** high-leverage question + hypothesis → research it | weekly / manual | `06.03/questions/` + a durable `03 - PERMANENT` page |
| `06.04 - cold-email` | Source → enrich → Airtable → Instantly: the lead engine (declares the cold-email crons) | continuous | `01.35` + Airtable/Instantly |
| `06.05 - blog-idea` | Queue **ONE** new engineering-blog idea (topic + angle + why) via SEO + agent-traffic + trend research; rubric-gated | daily | `04.08 - blog-content/idea-backlog.md` + inbox |
| `06.06 - feedback-mining` | Batch the feedback corpus → propose the top ≤3 rule changes (collect, never auto-promote) | weekly | `05 - KITS/05.09 - feedback/` (+ `rules.md`) |
| `06.07 - forge-draft` | Turn a **locked** idea (from `06.05`) into a forged draft against a **written 5-check rubric** — idea gate → deterministic forge (fresh adversarial critic → bounded revise → honest block) → verdict gate | on-request (ticket / cron) | `08 - PRODUCTION/drafts/` (the draft) + `06.07/runs/` |

**Building a new loop?** Use **Loop Studio** (`05 - KITS/05.01 - macros/loop-studio.md` · macro `05 - KITS/05.01 - macros/loop-studio.md`) — it scaffolds a loop from a plain-text brief.

### Loops whose core output lives in production

Some loops *produce* a production artifact rather than a note. `06.02 - publish-blog` is the first: the
loop config lives here, but the **draft post is the artifact** and lives in `08 - PRODUCTION/drafts/`.
The inbox only carries the nudge. This keeps "configuration" (here) separate from "the work" (production).
