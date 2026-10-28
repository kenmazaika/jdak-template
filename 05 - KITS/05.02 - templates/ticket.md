---
title: "Ticket — <title>"
type: ticket
status: open            # open (your turn) | working (my turn) | blocked (needs you to unblock) | done
turn: you               # you | agent | —
backing: ""
prompt_log: ""
runs: 0
created: 2026-10-15
updated: 2026-10-15
authority: authoritative
tags: [ticket]
---

# Ticket — <title>

<!-- A ticket is a CONVERSATION you and Felix have in a file. You write at the top (the ✍️ slot),
     tick Execute, and sync — Felix runs it and replies right below your message, newest-first.
     Its replies read like a chat reply, but they link out to FILES instead of cramming the answer in here. -->

## ▸ Status
**Where it stands:** <1–2 plain sentences — what's done so far and what's pending, in words you'd say out loud. Rewritten after every run.>

`status: open` · **your turn** · run 0 · updated <date>

## ▶ Control
- [ ] **Execute the ticket** — run my next message: answer in a file, then reply here.
- [ ] **Close the ticket** — done; move it to `00.04 - outbox/`.
- [ ] **✏️ Something else** — neither run nor close: I say what I want in the ✍️ slot below, and that is the instruction.

> The ✍️ slot **is** the free-form box (a ticket is a conversation, not a menu). Any option set a reply
> offers still ends with `✏️ Something else` — see `05 - KITS/05.09 - inbox-message-playbook.md`.

## 💬 Thread
_Newest message on top. Type your next message in the ✍️ slot; Felix replies right below it._
_Each reply is a few sentences — the gist — plus a link to the file that holds the full answer._

### ✍️ Your message
>

<!-- ===== above: your pending message · below: newest-first history ===== -->

### 🧑 You — <date>
> <your message>

### 🤖 Felix — <date>
<a few sentences, chat-style — the gist, what it means, what's next.>
→ **Full answer:** [[<path to the file with the detail>|<what it is>]]

## 🗒 Background
<!-- Seeded context that isn't part of the back-and-forth: where the ticket came from, source links. -->
-
