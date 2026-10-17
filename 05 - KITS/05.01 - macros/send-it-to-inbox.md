---
title: "Macro — Send it to inbox"
created: 2026-10-13
updated: 2026-10-13
type: macro
status: active
authority: authoritative
tags: [macro, inbox]
trigger: "send it to inbox"
inputs: ["the recent messages", "the decision", "the artifact"]
output: "00 - INBOX/00.01 - handoffs/<date>-<topic>.md"
---

# Macro — Send it to inbox

**Trigger:** `send it to inbox` (or "send this to inbox", "inbox this").
**Does:** turn the recent conversation — a decision or an artifact — into one clean **inbox handoff**
in the vault, so the owner has everything in Obsidian and can just act there.

## Inputs

- the **recent messages** (the decision + the context)
- the **artifact** it's about (a file / draft / ball) — even if unstated, infer it and link it

## Steps

1. **Read** the recent conversation; identify the **artifact** and the **decision** the owner must make.
2. **Load the playbook:** `05 - KITS/05.09 - inbox-message-playbook.md` — follow it exactly.
3. **Decide the action set (case by case).** Ask: *what are the few things the owner could do here, and
   which are best?* Those become the checkboxes. Don't reuse a fixed set.
4. **Write the handoff** → `00 - INBOX/00.01 - handoffs/<date>-<topic>.md` (from the `handoff` template):
   **Summary · Source (Obsidian link) · Detail · Your action (checkboxes) · Comments ·
   Suggested actions (best takeaways) at the bottom.**
5. **Mirror** one line on the root `INBOX.md` board; link the note into today's **daily note**.
6. **Reply** with the note's vault path (so it's obvious where to click).

## Output

→ `00 - INBOX/00.01 - handoffs/<date>-<topic>.md` + an `INBOX.md` line. Linked into the daily note.

## Worked example

> **Owner:** "send it to inbox" (after a thread about a new publish draft)
>
> → `00 - INBOX/00.01 - handoffs/2026-10-14-publish-<slug>.md`
> **Summary:** ready-to-publish draft *"<title>"* — accept or reject.
> **Source:** [[08 - PRODUCTION/drafts/<slug>/<slug>|the draft]]
> **Your action:** `[ ] ✅ Accept & publish` · `[ ] 🛑 Reject` · `[ ] ✏️ Reject + reason`
> **Suggested actions (best takeaways):** ✅ accept — the lesson clears the new-to-Ken gate; the only
> soft spot is the opening anecdote.

## Notes

- **Everything lives in the vault** — this macro + the playbook. `send it to inbox` needs nothing else.
- For **long-running work**, add a *📋 Convert to ticket* (or *Create a card + ticket*) box to the action set — the sweep moves + runs it in `00.03`.
- The **checked box is the owner's approval**; the inbox sweep (`cf2d5164`) performs it.
- Distinct from the **Intake** (`00.02`): Intake = owner → agent; a handoff = agent → owner.
