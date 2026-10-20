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
