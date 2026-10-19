---
name: "checkbox-runner"
description: "Two guarantees for any checkbox-triggered agent runner: claim the box on pickup; never orphan a spawned subagent."
base: true
---

# Checkbox runner — claim on pickup, never orphan

## When to use
Any runner that reacts to a **checkbox flip** (or a status change) in a file — vault inbox handoffs, intake notes, tickets, task lists — especially when it triggers off file-sync or a schedule. Use it whenever **one ticked box should cause exactly one agent run**.

## The failure it prevents
Two failure modes, both observed in the same vault runner (2026-10-15):

1. **Re-fire loop.** The runner reads a checked box, does the work, and clears the box only at the **end**. The box stays "pending" for the whole run, so every sync and every scheduled tick re-fires the same item — a no-op re-spawn loop. Observed: a ticket re-ran six times in ~30 min, spawning fresh critics each pass.
2. **Orphaned subagent.** The runner spawns a fresh subagent (a critic, a researcher), then `sessions_yield`s-and-ends while it is still running → the subagent is orphaned and its result is never written back.

## The two guarantees
- **G1 — Claim on pickup.** The instant you take an item, clear its triggering box / flip its status so it is no longer "pending" — **before any work**. Claiming is what makes a run exclusive.
- **G2 — No orphans.** If the work spawns subagents, finish them **inside the run**: spawn, then stay and await each result (poll `subagents` / `sessions_history`), write the outputs, then stop. Never yield-and-end with a subagent pending. If a result genuinely can't be obtained, write an **honest block** naming what stalled.

## Steps
1. Scan for items whose box is **checked** AND whose status is still **pending** (a small trigger script that prints one line per item).
2. For each item: **claim it first** — untick the box / flip status to `working` (G1).
3. Do the work. If you spawn subagents, **await them in-run** (G2).
4. Write the result back to the item (and its ledger/receipt); finish it (move to outbox / mark done).
5. If the work can't complete, leave an **honest block** — never a silent stop.

## Anti-patterns
- Clearing the box only at the end → re-fire loop.
- `sessions_yield`-and-end with a subagent still running → orphan.
- Logging "waiting for verdicts" and ending the run with nothing written back.

## Notes
- The two guarantees compose: **G1 makes the run exclusive; G2 makes it complete.** Neither alone is enough.
- Applies to **every** checkbox surface — don't special-case one folder.
- Pairs with, but is not the same as, a "done contract" (write the finish line first): G1/G2 are about the *runner's* mechanics; the done contract is about the *work's* exit condition.

## Provenance
Learned fixing the JDAK vault inbox sweep (`00 - INBOX/00.01-00.03`) on 2026-10-15: a ticket re-ran six times, spawning fresh critics each pass and never writing them back. Fix = G1 + G2, applied to all three surfaces (handoffs · intake · tickets).
