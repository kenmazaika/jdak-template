<%*
// Intake — generate the filename from the Johnny-Decimal address + the day.
// Result: "00.02.03 - Wednesday 10-14 capture"  (incrementing index within this folder).
// Runs via a Templater FOLDER TEMPLATE mapped to 00 - INBOX/00.02 - intake.
const folder = "00 - INBOX/00.02 - intake";
const dir = app.vault.getAbstractFileByPath(folder);
const nums = (dir?.children ?? [])
  .map(f => (f.name.match(/^00\.02\.(\d+)\b/) || [])[1])
  .filter(Boolean)
  .map(Number);
const next = String((nums.length ? Math.max(...nums) : 0) + 1).padStart(2, "0");
const stamp = tp.date.now("dddd M-D");        // e.g. Wednesday 10-14  (no '/': illegal in filenames)
const name = `00.02.${next} - ${stamp} capture`;
await tp.file.rename(name);
-%>
---
title: "<% name %>"
created: <% tp.date.now("YYYY-MM-DD") %>
updated: <% tp.date.now("YYYY-MM-DD") %>
type: intake
kind: idea
status: new
intake: ""
authority: authoritative
tags: [intake]
---

# <% name %>

<!-- Paste, type, or dictate below. Then check ONE box. -->

> <the dictation / the command / the link>

## How should I handle this?
- [ ] **Process as a dictation** — Raw / Shaped / Riff → `04 - RESOURCES/04.02 - dictations/`.
- [ ] **Run as a command** — do it now; log the run to today's daily note.
- [ ] **Capture a link** — the link-capture workflow → `04 - RESOURCES/04.01 - captures/`.
- [ ] **Create a ticket** — file a ticket in `00 - INBOX/00.03 - tickets/` **and run it** (the sweep files it, then executes it: reverse-prompt → answer in a file → reply on the ticket).
- [ ] **Create a card** — file a ticket **and** a card (`01 - PROJECTS/01.01 - cards/`), linked — **and run the ticket**.

## Notes
<!-- optional: constraints, where the output should go, deadline -->
