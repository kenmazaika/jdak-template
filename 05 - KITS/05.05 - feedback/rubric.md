---
title: "Feedback — mining rubric"
created: 2026-10-14
updated: 2026-10-14
type: schema
kind: fact
status: active
authority: authoritative
tags: [feedback, rubric, meta]
---

# Feedback-mining rubric

A proposed change must clear this **before** it reaches the owner. Score each axis 0–2 (max 10);
**ship only ≥ 7**, and **drop any proposal with a `0` on axis 2 or 3**.

| # | Axis | 0 | 1 | 2 |
|---|---|---|---|---|
| 1 | **Evidence** | one note | ≥3 notes / a pattern | strong, recurring, and recent |
| 2 | **Improvement** | cosmetic / noise | real but small | clearly better for the goal |
| 3 | **Overcorrection risk** | likely to overfit or flip an accepted call | some risk | low — narrow and reversible |
| 4 | **Reversibility** | hard to undo | awkward | one-line change, easy to revert |
| 5 | **Regression-safe** | would regress a prior accept | unclear | replays clean on `examples/` |

## Rules of thumb

- **Recency-weighted** — recent feedback counts more, but a *repeated* old theme can win.
- **Few and sharp.** At most **3** proposals per pass. Never a flood.
- **Decline is the default.** The bar is genuine improvement, not motion.
- **Both sides.** Every proposal names the **counter-risk** (where it could go too far) and the
  **sweet spot** — so we don't swing to the opposite extreme.
- **A proposal that flips an accepted decision is a regression** unless the owner says otherwise.
