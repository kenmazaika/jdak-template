---
title: Skills
created: 2026-10-12
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema, skills]
---

# 07 · SKILLS

**Vendored, readable skills.** The custom skills and workflow prompts the agent uses — copied
(vendored) into the vault so they're not a black box.

## Naming: system vs personal

Two kinds of skill live here, and the **name says which**:

- **System skills** — generic, reusable, worth shipping with the base template. Prefix with a
  **Johnny-Decimal number**: `07.NN - <slug>`. *Numbered = "this ships."*
- **Personal skills** — specific to this instance (a niche workflow, a private voice). **No number** —
  just the plain `<slug>`.

So you can tell at a glance what belongs in the template vs. what stays with you.

## Registry

**System (numbered — ship with the base template):**

| # | Skill | What it does |
|---|---|---|
| `07.01` | [`distribution-scout`](07.01%20-%20distribution-scout/SKILL.md) | Runs the blog-distribution-research loop (scan → candidate → critique → promote). |
| `07.02` | [`wispr-dictation`](07.02%20-%20wispr-dictation/SKILL.md) | Turn a voice dictation into a Raw / Shaped / Riff entry in `04.02 - dictations/`. |
| `07.03` | [`loop-studio`](07.03%20-%20loop-studio/SKILL.md) | Build a complete, runnable vault loop from a plain-text brief (scaffold + executor + approval + batons). |
| `07.04` | [`blog-idea-scout`](07.04%20-%20blog-idea-scout/SKILL.md) | Runs the engineering-blog idea loop (goal → plan → demand → one idea → critique → rubric). |
| `07.05` | [`feedback-miner`](07.05%20-%20feedback-miner/SKILL.md) | Runs the weekly feedback-mining loop (cluster the corpus → ≤3 changes → critique → gate). |
| `07.06` | [`use-case-factory`](07.06%20-%20use-case-factory/SKILL.md) | Turn a concept to demonstrate into reader-legible before/after use cases (3 candidates → scored → recommended). |

**Personal (un-numbered — instance-specific, vendored 2026-10-13):**

| Skill | Runs in | What it does |
|---|---|---|
| [`blog-post-pipeline`](blog-post-pipeline/SKILL.md) | manual | **The Jake process** — chains the content pipeline into the offsite distribution packet. |
| [`media-company`](media-company/SKILL.md) | loop `06.02` | The publish loop's executor (signal-scout → … → editor). |
| [`cold-email-lead-pipeline`](cold-email-lead-pipeline/SKILL.md) | loops `06.04` | The cold-email lead engine. |
| [`cold-email-load-batch`](cold-email-load-batch/SKILL.md) | cron batch-load | Load qualified leads into the Instantly campaign. |
| [`lead-qualification-rubric`](lead-qualification-rubric/SKILL.md) | loops `06.04` | The lead scoring rubric. |
| [`qball-router`](qball-router/SKILL.md) | hooks | Route work-product writes to the owning QBall. |
| [`vault-keeper`](vault-keeper/SKILL.md) | sweep | The weekly inbox/capture digest. |
| [`link-capture`](link-capture/SKILL.md) | intake | Capture a link → Shaped + Riff takeaways. |

## Vendored + symlinked

A vendored skill's folder **here is the source of truth.** The agent's live skills dir holds a
**symlink** to it — edit here, the agent sees the change. (Symlink, never copy: copying forks the
source of truth.)

## Why vendor skills here

- **See them.** The vault syncs to your phone, so you can *read* a skill you're operating by voice.
- **Version them.** Skills sit in source control — diff a tweak, roll it back.
- **Keep them in the loop.** A skill that reads and writes the vault belongs next to the vault it operates on.

## What belongs here

- System skills (numbered) — generic, reusable.
- Personal skills (un-numbered) — instance-specific.
- Workflow prompts (e.g. the dictation-processing prompt).
- Skill pipelines — the multi-phase routines that chain other skills (see `05 - KITS/05.07 - skill-handoffs.md`).

## Notes

- The **base template ships only the numbered (system) skills** — that's what "this ships" means.
- Vendor the *skill*; keep heavy assets with the work they produce, symlinked if shared.
