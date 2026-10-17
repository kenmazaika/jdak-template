---
title: "Macro — Execute the ticket"
created: 2026-10-15
updated: 2026-10-16
type: macro
status: active
authority: authoritative
tags: [macro, inbox, tickets]
trigger: "execute the ticket"
inputs: ["the ticket (00.03)", "my message"]
output: "the full answer in a file + a chat-style reply on the ticket"
---

# Macro — Execute the ticket

**Trigger:** `execute the ticket` (or "run the ticket", "execute ticket <slug>", "work the ticket").
**Does:** run a ticket's **message** end-to-end — reverse-prompt → execute (**answer in a file**) → reply on
the ticket **like a chat reply** — exactly as the inbox sweep does.

## Steps

1. **Find the ticket** — the named one, else the open ticket whose `### ✍️ Your message` slot holds text
   (`Vault/00 - INBOX/00.03 - tickets/*.md`).
2. **Claim it** — set `status: working`, `turn: agent`. (Before any work — never re-fire.)
3. **Read the message** (the `### ✍️ Your message` slot) + the ticket's `backing:` / `prompt_log:`.
4. **Ensure the backing folder** — `09 - FLEETING/09.07 - tickets/<slug>/` (+ `prompts/` · `outputs/` · `work/`).
5. **Reverse-prompt** — write the *most effective OpenClaw prompt* to achieve the ask, given the project +
   the knowledge base; save `prompts/run-<N>.md`; append a row to `PROMPTS.md`.
6. **Execute** that prompt. **Write the full answer to a file** — `…/<slug>/outputs/run-<N>-answer.md`, or
   its durable numbered home (`08`/`04`/`03`) when it's a real deliverable. *(Answer inline only when the
   answer genuinely is one screen and no file is warranted.)*
7. **Reply on the ticket**: move the ✍️ slot text down into a new round at the top of **💬 Thread** —
   `### 🧑 You — <date>` (the message, quoted) then `### 🤖 Felix — <date>` (a **short chat-style reply**: a
   few sentences, the gist + what's next, **Obsidian links** `[[path|label]]` to the files — never bare
   backticked paths; end with `→ **Full answer:** [[<file>|<what it is>]]`).
8. **Refresh ▸ Status** (`Where it stands:` + the `status · turn · run N · updated` line); **clear the ✍️
   slot** back to an empty `>`; **untick Execute**; bump `runs` / `updated`; set `turn: you` (or `status:
   done` if the thread is finished).
9. **Reply** with the one-line outcome + the ticket path.

## Output

→ updated `00.03 - tickets/<slug>.md` + `09 - FLEETING/09.07 - tickets/<slug>/`.

## Notes

- Same flow as the sweep; the macro is the **manual** path (tick the box + sync = the **automatic** path).
- **The answer goes in a file; the ticket holds the conversation.** Don't cram the write-up into the ticket.
- **Close** = tick **Close** on the ticket (or say "close the ticket") → move to `00.04 - outbox/`.
