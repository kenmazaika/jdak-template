---
title: "Kit — Feedback (the corpus + the mining loop)"
created: 2026-10-13
updated: 2026-10-14
type: kit
kind: fact
status: active
authority: authoritative
tags: [kits, feedback, meta]
---

# Kit · Feedback

**What it is:** how the vault handles owner feedback — **capture it consistently, never act on a single
note, and mine the corpus on a schedule.** One model for **every** skill, loop, voice guide, and general
way of working. A rule or skill change only becomes real through this.

## The one rule

> **Feedback is data, not a directive.** Capture every bit; **promote rules only from a batch**, and only
> after the candidate survives a replay against prior decisions. **One note ≠ one rule.**

That's the anti-overcorrection rule earlier work learned: applying one note at a time makes the agent
overfit — it "fixes" something and regresses work that was already approved.

## Capture — the single corpus

- **One file:** `feedback.md` — append-only, newest first, **verbatim**, tagged. The complete record.
- **When:** the owner says **"this is feedback"** (or checks a reject/approve box in the inbox, which the
  sweep logs). The agent appends an entry immediately — **never rewrite the owner's words**.
- **Entry shape:**

  ```
  ### <date> · <target> · <item> · <verdict>
  - **target:** `loop 06.05` | `skill <name>` | `voice` | `general`
  - **item:** [<label>](<path/url>) — the thing the feedback is about
  - **verdict:** accept | reject | tweak | note
  - **feedback:** "<owner's words, verbatim>"
  - **status:** open
  ```

- **Tag it** with the **target** and a **link to the item**, so any pass can segment by source.

## The pipeline (capture → batch → collapse → replay → promote)

1. **Capture** → `feedback.md`, verbatim. Nothing is applied.
2. **Batch** → do **not** collapse on one note. Wait for ≥3 notes or the weekly pass.
3. **Collapse** → mine the batch for the *recurring* signal.
4. **Replay** → test a proposed rule against `examples/` (prior accept/reject decisions); keep it only if
   it would have **improved** the prior calls and **regressed none**.
5. **Promote** → passing rules land in `rules.md` (few + sharp, dated). Every skill/loop reads `rules.md`
   **first**, before its own config.

## The mining loop (weekly — `06 - LOOPS/06.06 - feedback-mining`)

A cron combs the **whole corpus**, weighing **recent feedback higher**, and proposes the **top ≤3** changes
— never a flood. Each proposal carries: the change · the target · the evidence · the expected improvement ·
the **overcorrection risk** (the other direction) · reversibility. The owner **accepts or declines**;
**decline is normal and easy**.

## Rejecting is the default

The bar is **genuine improvement with low risk** — not motion. Expect most proposals to be declined. A
proposal that would **flip a previously accepted decision** is a **regression** unless the owner says otherwise.

## Files

| File | Role |
|---|---|
| `feedback.md` | **The corpus** — append-only, verbatim, tagged. The input. |
| `rules.md` | The live standing rules (collapsed, replayed). Read **first** by every skill/loop run. |
| `rubric.md` | The mining rubric — evidence + improvement + overcorrection risk + reversibility. |
| `examples/` | One file per prior decision + `INDEX.md`. The regression set. |

## Who writes what

- **Owner** → says "this is feedback", or checks an inbox accept/reject box.
- **Agent (any run / session)** → appends the verbatim entry to `feedback.md`.
- **Inbox sweep** → logs the decision + reason into `feedback.md`; adds an `examples/` row.
- **Mining loop (weekly)** → reads all of `feedback.md`, proposes the top 3 → inbox; promotes approved
  changes to `rules.md` (or applies them to their target skill/loop/voice).
