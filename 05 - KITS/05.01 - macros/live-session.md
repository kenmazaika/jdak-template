---
title: "Macro — Live session (take a ticket live)"
created: 2026-10-22
updated: 2026-10-22
type: macro
status: active
authority: authoritative
tags: [macro, inbox, tickets, live]
trigger: "take ticket <name> live"
inputs: ["the ticket (00.03)", "the conversation"]
output: "the ticket card + numbered artifacts, updated in the same turn as each message"
---

# Macro — Live session

**Trigger:** `take ticket <name> live` · `go live on <ticket>` · `let's work the <X> ticket here`.
**Does:** moves one ticket out of the file queue and into the conversation for the length of a working
session. I act on every message in the same turn and rewrite the card each turn, so the ticket stays the
record of the session instead of a mailbox.

## The prompt (paste-able)

> Take ticket `<slug>` live. From now until I say close: treat every message I send as the ticket's next
> instruction, do the work in that turn, write the artifact to a numbered file, and update the ticket card
> (Status, Control, Thread, run counter) plus the ball **before** you reply. No ✍️ slot, no `Execute` tick,
> no waiting on the sync hop. If a message is genuinely ambiguous, ask one question instead of guessing.
> When I say close, write the live-session recap and put the ticket back in the queue.

## Steps

### Open (once)

1. **Find the ticket** — the named one, else the most recently updated open ticket in `00.03`.
2. **Read the why before the what** — `decisions.md` → `BALL.md` → latest `HANDOFF-*.md` → the ticket. If
   state can't be determined, ask one question; never guess.
3. **Claim it** — `mode: live`, `live_since: <iso>`, `status: working`, `turn: agent`, bump `runs` and
   `updated`. Leave any ticked box alone: it is still the durable signal if the process dies.
4. **Confirm in one line** — "Ticket live: <name>. You talk, I write." Nothing else.

### Each turn (repeat)

5. **Take the instruction.** Read the message as the ticket's next instruction. A dictation is processed as a
   dictation. Two plausible readings → ask **one** question and stop.
6. **Do the work.** Produce the artifact as a **new** numbered file in the ball's `drafts/` (or its named
   durable home). Never overwrite a prior version — versions are the record.
7. **Write the card in the same turn, before replying:**
   - 💬 Thread — move the message into a round: `### 🧑 You — <date>` (verbatim or compressed), then
     `### 🤖 Felix — <date> · live · <what changed>` (2–4 sentences: what changed, why).
   - ▸ Status — `Where it stands:` rewritten to the new truth + the `status · turn · runs · updated` line.
   - ▶ Control — tick what got done, leave open what didn't, add a box when a new decision surfaces.
8. **Log the change** — `LINEAGE.md` (prompt/model/command per version), `commands.log` (append-only), and one
   line in `Vault/log.md`. A version that isn't logged doesn't exist.
9. **Feedback is captured, not obeyed.** A judgement in the message ("cheesy", "cut to the chase") goes into
   `05 - KITS/05.05 - feedback/feedback.md` **verbatim**, and is acted on. One note ≠ a rule.
10. **Reply short.** One or two sentences: what changed, what's next. The card carries the detail.

### Close

11. **Recognise the close** — "close it", "park it", or a ticked close-intent box.
12. **Write the recap** at the bottom of the ticket: *what live mode was · machinery touched · decisions in
    order · artifacts produced · **what did NOT happen** · next action on pickup.* The "did not happen" list
    is mandatory — it is what stops the next session assuming staging, deploy, or verification occurred.
13. **Put it back** — `mode: queue`, `live_ended: <iso>`, `turn: you`, recap written. If the work is
    finished: tick close → `bin/inbox-close-request.sh` moves it to `00.04` and deletes the upstream copy.

## Invariants

- **The card never lags the conversation.** If I replied, the file already says it.
- **No ✍️ slot while live.** Chat is the message channel.
- **The sweep stands down.** `bin/inbox-action-check.sh` skips `mode: live` for `LIVE_TTL` (6h) after the
  last write; past the TTL the ticket returns to the queue on its own — a live ticket can't be abandoned
  into silence.
- **Artifacts are files; references are Obsidian links.** Chat is the channel, never the storage.
- **One gate per run.** Never re-deliver a gate that was already answered.
- **Ambiguity costs one question; guessing costs a version.**

## Failure modes

| Symptom | Cause | Action |
|---|---|---|
| Ticket re-fires mid-conversation | `mode: live` missing, or TTL expired | reset `live_since`; check the frontmatter survived the sync hop |
| Chat went quiet and the sweep took it | TTL passed | expected; resume from the card, re-open live |
| Run died mid-turn | crash | `status: working` + the ticked box are the durable claim; the sweep re-emits it |
| Two tickets plausible | ambiguity | ask one question; never pick silently |

## Output

→ updated `00.03 - tickets/<slug>.md`; numbered artifacts in the ball; one line in each log.
