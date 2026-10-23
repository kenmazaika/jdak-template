---
title: Inbox
created: 2026-10-11
updated: 2026-10-17
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# 00 · INBOX

Two jobs — be deliberate about which one an item is:

1. **The agent's handoff surface to the owner** — what the owner must decide, review, or know. The
   *live* board is root [`INBOX.md`](../INBOX.md); the detail notes live in `00.01 - handoffs/`.
2. **The owner's Intake** (`00.02 - intake/`) — the owner's single front door: one note per item, a
   checkbox routes it.

## Sub-folders

| #       | Folder      | Direction                     | For                                                                                                                                                                                                                                                                                                                                                                                   |
| ------- | ----------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `00.01` | `handoffs/` | **agent → owner**             | Dated handoff notes (`YYYY-MM-DD-<topic>.md`; template `05 - KITS/05.02 - templates/handoff.md`) **and decision cards** (`YYYY-MM-DD-decision-<topic>.md`, `type: decision-card`; template `05 - KITS/05.02 - templates/decision-card.md`). Each carries a summary, an **Obsidian link** to the artifact, and an **action block** (checkboxes). Mirrored one line on root `INBOX.md`. |
| `00.02` | `intake/`   | **owner → agent**             | The owner's front door — one note per item; a checkbox routes it (dictation · command · link). See its `README.md`.                                                                                                                                                                                                                                                                   |
| `00.03` | `tickets/`  | **owner → agent, round-trip** | Long-running tickets — one file each, shaped as a **conversation, newest-first**: you write in the ✍️ slot, tick **Execute**, and the sweep reverse-prompts it, runs it, writes the **full answer to a file**, and replies on the ticket with a short chat-style note that links to that file. See its `README.md`.                                                                   |
| `00.04` | `outbox/`   | **done → out**                | Where a **processed** handoff, intake note, or ticket lands — the "left the inbox" tray. Move the note here the moment it's ruled on / actioned. Nothing here is acted on again.                                                                                                                                                                                                      |

## Anatomy of a handoff note

Every `00.01` note is built so the owner can act **without opening anything else**:

- **Summary** — one line: the gist + the ask.
- **Source** — an Obsidian wikilink `[[path/to/artifact|label]]` → click straight into the real file.
- **Detail** — a few bullets of context.
- **`## Your action`** — markdown checkboxes, one outcome per box (chosen **case by case**).
- **`## Comments`** — where the owner types a reason or notes.
- **`## Suggested actions (best takeaways)`** — at the bottom: the agent's case-by-case recommendation.

Frontmatter carries `loop:` (the owning loop, or `—`) and `action: pending | done`.

**How to write one:** follow the **Inbox-message playbook** (`05 - KITS/05.09 - inbox-message-playbook.md`); the **`send it to inbox`** macro composes one from the recent messages.

## Decision cards (`00.01`, `type: decision-card`)

A **decision card** is a handoff whose ask is *"pick which of these"*. Same place (`00.01`), same
sweep, same claim → act → outbox lifecycle — only the **shape** differs: the options *and their
paste-ready payloads* sit inline as checkboxes, so the owner picks without opening anything.

Use one **only** when the decision is a genuine **pick-from-a-set: 2+ discrete options**. A yes/no, a
single recommendation, or an open conversation stays a normal handoff (or a ticket). Doctrine:
[[03 - PERMANENT/03.01 - concepts/inbox-decision-card|The Inbox Decision Card]].

```markdown
## ✅ Options
- [ ] **A. <label>** — <what it does, where it lands>
      Target: [[file]] · `<exact payload>`
- [ ] **Do none of these** — leave as-is; the card closes with no change.

## ▶ Control
- [ ] **Execute** — apply the ticked options, log it, file this card.
```

Frontmatter is **handoff-compatible**: `type: decision-card` · `options_key: <slug>` · `action: pending`
(the sweep's existing detection) · `status: active` (§4 vocabulary — *not* the `open|working` pair the
first draft proposed) · `turn: you` for whose move.

**Rules that make it work.**

- **Tick ≠ fire.** Ticking options records the choice; **Execute** fires the apply — a stray tick during
  review sends nothing.
- **Pre-baked.** Every option carries its own final text/target, so the run *replays* the pick instead of
  re-deriving it.
- **Always an escape hatch.** *Do none of these* is a real outcome, and it is tickable.
- **Bound then terminal.** One decision over a fixed option set. It does not host a back-and-forth —
  that's a ticket.
- **Execute files it.** One run: apply → log → `00.04 - outbox/` → a one-line reply.

| Surface | Direction | Unit | Ends when |
|---|---|---|---|
| Handoff `00.01` | agent → owner | one decision (prose box set) | ruled on |
| **Decision card `00.01`** | **agent → owner** | **one decision + its option set** | **executed** |
| Intake `00.02` | owner → agent | one item, routed by one box | routed |
| Ticket `00.03` | owner → agent | an open conversation, many rounds | closed |

## The action sweep (owner → agent, back) — processes **EVERY** handoff

When the owner checks a box (`- [x]`) and lets the vault sync, the **inbox sweep** acts on it.
It processes **every** `00.01` note — **not only loop-owned ones**:

1. Scan `00.01 - handoffs/*.md` for a note with a checked box (`- [x]`) and `action: pending`.
2. **Read the note** — its `loop:` (if any), the checked box, and the `## Comments`.
   - **Loop-owned** (`loop:` names a loop) → run that loop's matching verb (its `LOOP.md` **Actions**).
   - **Plain handoff** (`loop: —` or missing) → **do what the checked box + comments ask**, generically.
     No loop needed. Route any durable output to its numbered home.
3. Perform it → flip `action: pending` → `done` → log to the owning loop's `ledger.md` (and
   `05 - KITS/05.05 - feedback/feedback.md` for a **reason** — *collect, don't promote to a rule yet*) **and** the day's
   **daily note** → **move the note to `00.04 - outbox/`** → refresh `INBOX.md`.

**Decision cards** ride the same loop with three extra clauses: apply **exactly** the ticked options
(mechanical replay of their payloads, no re-derivation) · *Do none of these* closes the card with no
change, and is honoured as a real decision · a ticked option whose payload no longer applies is **skipped
and named**, never silently approximated.

**Tickets (`00.03`).** A note there with a checked box is a running ticket — **Execute** → reverse-prompt
the message, run it, write the **full answer to a file**, then reply on the ticket in a few sentences that
**link to that file**, clear the ✍️ slot, untick; **Close** → mark done and move it to `00.04 - outbox/`.
Same engine, round-trip shape (conversation, newest-first).

**Convert (`00.01` → `00.03`).** Any handoff can carry a *📋 Convert to ticket* box — checking it moves +
rewrites the note into `00.03 - tickets/` and runs it there.

**After processing, the file leaves the inbox.** A processed handoff, intake note, or closed ticket moves
to
`00.04 - outbox/` — not `10 - ARCHIVE/`. (`10 - ARCHIVE/` is history/old scans; the outbox is the
current "done" tray for things that moved through the inbox.)

**The checked box is the owner's approval** — no second ask. **Nothing is skipped for "no loop"** — if a
handoff has no dispatchable verb, the agent interprets the box + comments and acts.

## The weekly digest (the `vault-keeper` backstop)

1. **Handoffs (`00.01`):** any ruled-on note that's still sitting here → move to `00.03 - outbox/`;
   leave open ones; **refresh `INBOX.md`**.
2. **Intake (`00.02`):** route each unhandled note per its checked box.
3. **Digest:** a short summary to the owner. `00.01` should then hold only *live* handoffs.

## Naming (descriptive, JD-fits)

A note in `00 - INBOX/` is **named for its content**, not its slot.

- **Default names are placeholders.** Intake arrives as `00.02.NN - <Weekday M-D> capture`; the
  **sweep renames it** to a descriptive slug when it processes the note (e.g. `00.02.NN - voice-file-idea`).
- **Tickets / handoffs** → `<YYYY-MM-DD>-<descriptive-slug>` — lower-case-hyphenated, no spaces, no
  `v2`/`final`/`copy` (git is the version history).
- **Decision cards** → `<YYYY-MM-DD>-decision-<descriptive-slug>` — the `decision` token is what makes them
  findable on the shelf and inside the template picker's siblings.
- **Rule of thumb:** if the name would still make sense as a *label on a shelf* — `capture`, `untitled`,
  `note`, a bare date — it's a default; replace it with the topic.
- The rule applies **at creation and at processing** (the sweep fixes a default name it finds).
- See `SCHEMA.md` §3 (naming rules).

## Rules of thumb

- **Agent:** never dump durable content here. A handoff is transient — consumed when the owner rules on it.
- **Owner:** when in doubt, capture now (via Intake), decide later.
- Never file *directly* into a category root; everything enters through here or a clear numbered home.
- One item per file.
