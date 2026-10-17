---
title: Tickets
created: 2026-10-15
updated: 2026-10-16
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema, inbox, tickets]
---

# 00.03 · Tickets

**A durable back-and-forth between the owner and the agent, in a file.** A **Ticket** is one file in this
folder — the baton you hand the agent. It stays alive across many rounds, and reads like a conversation:
**you write at the top, the agent replies right below your message.**

> Think: *"here's what I want — go, then talk to me."* You write your message, tick **Execute**, let the
> vault sync; the agent reverse-prompts it, runs it, **writes the full answer to a file**, and replies on
> the ticket in a few sentences that **link to that file**. You reply with the next message. Repeat until
> you close it.

## What a ticket is (vs everything else)

| Folder | Direction | Shape | Lifespan |
|---|---|---|---|
| Handoff (`00.01`) | agent → owner | one decision, one screen | one rule-on, then out |
| Intake (`00.02`) | owner → agent | one item, routed by a box | one routing |
| **Ticket (`00.03`)** | **owner → agent, round-trip** | **a conversation, newest-first** | **many rounds, until closed** |
| Outbox (`00.04`) | done → out | processed notes | terminal |

## The ticket file

```yaml
---
title: "Ticket — <title>"
type: ticket
status: open            # open (your turn) | working (my turn) | blocked (needs you to unblock) | done
turn: you               # you | agent | —
backing: "[[09 - FLEETING/09.07 - tickets/<slug>]]"
prompt_log: "[[09 - FLEETING/09.07 - tickets/<slug>/PROMPTS]]"
runs: 0
created: YYYY-MM-DD
updated: YYYY-MM-DD
authority: authoritative
tags: [ticket]
---
```

Body, top → bottom:

1. **▸ Status** — the one place to see *where it stands*: **Where it stands:** (1–2 plain sentences, the
   gist of what's done + what's pending) then a compact line — `status:` · **whose turn** · run N · updated.
   Rewritten after every run. This is what answers *"what state is this in?"* in one glance.
2. **▶ Control** — the boxes:
   - `- [ ] Execute the ticket` — take my **message** and run it. *(Ticking it is the trigger.)*
   - `- [ ] Close the ticket` — stop, mark done, move this ticket to `00.04 - outbox/`.
   - *(A ticket may carry extra boxes for its own gates — e.g. kagi's "Open the PR — say I approve".)*
3. **💬 Thread** — the conversation, **newest first**:
   - A **`### ✍️ Your message`** slot at the very top — where you type the next ask (a messy wall of text
     / dictation is fine). The agent clears it after each run, so a fresh slot always waits.
   - Below it, each finished round, newest first: **`### 🧑 You — <date>`** (your message, quoted) then
     **`### 🤖 Felix — <date>`** (a short, chat-style reply).
4. **🗒 Background** — seeded context that isn't part of the back-and-forth (where the ticket came from,
   source links).

Start one from [[05 - KITS/05.02 - templates/ticket]].

## How the agent replies (the point of the revamp)

The agent's reply is **a normal chat reply** — a few sentences, first person, the gist and what it means —
**not** a rigid run-block. Two rules shape it:

- **Default: the answer goes in a FILE.** The substantive answer, the artifact, the write-up — that lands
  in a file (the run's answer file under `…/<slug>/outputs/`, or its durable numbered home). The ticket
  reply is the *gist + a link*. Only answer inline when the answer genuinely *is* one screen and no file is
  warranted.
- **Link out, don't cram.** Every file the reply touches is an **Obsidian wikilink** —
  `[[08 - PRODUCTION/drafts/x/draft|draft]]` — never a bare backticked path. Code ticks are only for field
  names, statuses, commands, and literal tokens. A good reply reads like a chat message and ends with
  `→ **Full answer:** [[<file>|<what it is>]]`.
- **Link the thing, not just the commentary.** When a reply cites a **critique, verdict, or other
  derivative**, always link the **primary output it is about** too — the draft, the PR, the skill — so you can
  open the artifact *and* its review, not just the review. Same in the **▸ Status** line: if it names a thing,
  link it.

## How a run works (the baton)

1. You write your **message** in the ✍️ slot, tick **Execute**, sync.
2. The **inbox sweep** (`cf2d5164` — the processing engine) sees the tick and runs the ticket:
   1. **Claims it** (untick Execute) — before any work.
   2. Ensures the **backing folder** — `09 - FLEETING/09.07 - tickets/<slug>/` (`prompts/` + `outputs/` + `work/`).
   3. Reads your **message**, **reverse-prompts** the *most effective OpenClaw prompt* to achieve it →
      `…/<slug>/prompts/run-<N>.md` (indexed in `…/PROMPTS.md`).
   4. **Executes** it, writing the **full answer to a file** (`…/outputs/run-<N>-answer.md`, or its durable home).
   5. **Replies on the ticket**: moves your message down as a `### 🧑 You` turn and adds a `### 🤖 Felix`
      turn right below it — a short chat-style reply with Obsidian links; refreshes **▸ Status**; bumps
      `runs` / `updated`; clears the ✍️ slot.
3. You read the reply, write your next message. Repeat until **Close**.

## Rules

- **Name it descriptively.** A ticket file is `<YYYY-MM-DD>-<topic-slug>` — lower-case-hyphenated. If it
  was filed with a default/generic name (`untitled`, `capture`, a bare date), the sweep **renames it** to
  the content slug when it runs. (See `00 - INBOX/README` → *Naming*.)
- **One ticket = one thread of work.** A new, unrelated ask → a new ticket.
- **A ticket can be seeded from a handoff** — tick *📋 Convert to ticket* on any `00.01` note and it moves
  + rewrites here, then runs.
- **The message wins.** The agent acts on the ✍️ slot, not the whole file — and **clears it after each run**.
- **The answer lives in a file; the ticket holds the conversation.** Heavy artifacts go in the backing
  folder (or their durable home) and are linked.
- **The structured prompt is always linked** (`prompt_log`) so you can see *what the agent decided to do*.
- **Close → outbox.** A closed ticket moves to `00.04 - outbox/`; nothing is acted on again.
- **Never** file durable output directly here — a ticket is transient machinery; its backing folder holds
  the artifacts.
- **Links, not paths.** Reference every vault file/folder as an **Obsidian link**.

## Wiring (Obsidian)

- Optional: set a **Templater Folder Template** [[00 - INBOX/00.03 - tickets]] → [[05 - KITS/05.02 - templates/ticket]]
  so a new note lands pre-filled.
- Trigger phrase: **`execute the ticket`** (macro [[05 - KITS/05.01 - macros/execute-the-ticket]]).
