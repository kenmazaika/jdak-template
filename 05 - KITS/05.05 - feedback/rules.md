# rules — the live standing rules

The **collapsed, replayed** rules every skill and loop must honour. Short, imperative, testable. Each
carries its date and the batch it came from. Keep this list **few and sharp**.

**Read this first** on every skill/loop run — before the loop's own config. Promoted only after replaying
against `examples/` with no regressions (see `README.md`).

---

### R0 · Don't promote a rule from a single note
_2026-10-13 · process rule._
- One rejection is data, not a policy. Collapse only a batch (≥3 notes, or the weekly pass).

### R1 · Feedback is global — one corpus
_2026-10-14 · process rule._
- Every skill, loop, voice guide, and general note uses ONE corpus: `05 - KITS/05.05 - feedback/feedback.md`.
- Tag each entry with its **target** + a **link to the item**.

### R2 · The mining pass proposes at most 3 changes
_2026-10-14 · process rule._
- The weekly mining loop (`06 - LOOPS/06.06 - feedback-mining`) proposes the **top ≤3** corpus-backed
  changes; the owner accepts or declines. Never a flood; **decline is normal**.

### R3 · An accepted-decision flip is a regression
_2026-10-14 · process rule._
- A rule that would flip a previously accepted decision is a **regression** unless the owner says it's intended.

### R4 · Escalate on the second failure, not the first
_2026-10-19 · cron/watch rule (accepted from `06.06` P1)._
- A loop fixes its own error **in-run, up to 3 attempts**; a dead probe is not a dead run.
- The failure watcher files a handoff only at **≥2 consecutive errors**, a **disabled** job, or a
  **deterministic** error (auth · model · missing config/script) — those escalate immediately.
- A single failure is **logged, never routed**: it lands in `logs/cron-failure-scan.json`
  (`observed`) plus one digest line, and stays out of the inbox.
- Escalating is a route, not a fix: the handoff still names one concrete change.

<!-- add rules below -->

### R5 · Setup guides use the how-to register
_2026-10-26 · voice rule (accepted from `06.06` P1 — **trial**, review after the next setup guide)._
- Headline **names the thing**, never the sell. The `description`/subtitle may sell; the opening paragraph may
  say why it matters.
- Problem + concept in the **first half**, numbered steps in the **bottom half**. No clickbait framing.
- Scope: `your-engineering-blog` setup guides only. Everything else keeps its own mode.

### R6 · Don't re-propose a spent shape
_2026-10-26 · loop rule (accepted from `06.06` P2)._
- `06.05 - blog-idea` will not propose **the "add lines to your prompt / write an artifact first" device** as
  *the change* — nor a benchmark for benchmarks' sake, nor a new per-run ceremony.
- Return condition: the device comes back once a **non-device** idea ships.

### R7 · Lede first — no TL;DR block, anywhere
_2026-10-26 · voice rule (finishes the 2026-10-14 accept; `06.06` P3)._
- No TL;DR / summary block on any surface. Open on the **lede** and put the payload inside the first screen.
- `description` = the one-line promise, lede = the concrete scene; if one restates the other, reject.
