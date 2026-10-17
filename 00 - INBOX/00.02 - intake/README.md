---
title: Intake
created: 2026-10-13
updated: 2026-10-13
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema, intake]
---

# 00.02 · Intake

**The owner's single front door.** Instead of separate capture sub-folders, the owner drops **one note
per item** here — an Obsidian template with **checkboxes** that route it. One verb, five handlings.

## How it works

1. Owner creates a note from the **Intake** template (`05 - KITS/05.02 - templates/intake.md`),
   pastes/types/dictates the content, and **checks ONE box**:
   - **Process as a dictation** → the wispr pipeline (Raw/Shaped/Riff → `04.02 - dictations/`).
   - **Run as a command** → the agent does it now; the run is logged to today's **daily note**.
   - **Capture a link** → the link-capture workflow → `04.01 - captures/`.
   - **Create a ticket** → file a ticket in `00 - INBOX/00.03 - tickets/` **and run it** (file, then execute: reverse-prompt → answer in a file → reply on the ticket).
   - **Create a card** → file a ticket **and** a card (`01 - PROJECTS/01.01 - cards/`), linked — **and run the ticket**.
2. The agent reads the checked box, does the work, flips `status: new → done`, and **links the outcome
   into the daily note**.

## Frontmatter

```yaml
type: intake
intake: ""        # dictation | command | link | ticket | card   (agent fills after routing)
status: new       # new | done
```

## Templater (the name is auto-generated)

Intake notes are created via the **Templater** community plugin, with a **Folder Template** mapping
`00 - INBOX/00.02 - intake` → `05 - KITS/05.02 - templates/intake.md`. On creation the template:

- computes the **next index** in this folder, and
- renames the note to **`00.02.NN - <Weekday M-D> capture`** (e.g. `00.02.03 - Wednesday 10-14 capture`).
  (Dash, not slash — `/` is illegal in a filename.)

The **core Templates plugin will not work** — the template uses Templater syntax (`<% %>`) +
`tp.file.rename()`. Setup: *Settings → Templater → Folder Templates*.

> **The auto-name is a placeholder.** On processing, the **sweep renames the note to a descriptive JD
> slug** (`00.02.NN - <topic>`, lower-case-hyphen) derived from the content — so `00.02.03 - Thursday 10-15
> capture` becomes `00.02.03 - voice-file-idea`. Don't fuss over the name at creation; the topic wins.

## Rules

- **One item per note.** Multiple asks → multiple notes.
- The **checked box is the routing key** (like the inbox action sweep).
- Intake is **transient** — consumed when handled. Durable output goes to its numbered home.
- Generic by design — the owner's single manual path is **here** (one note per item).
