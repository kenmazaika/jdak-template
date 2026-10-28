---
title: "Decision — <topic>"
created: {{date:YYYY-MM-DD}}
updated: {{date:YYYY-MM-DD}}
type: decision-card
kind: fact
status: active
authority: authoritative
tags: [decision]
loop: <06.NN - loop-name | —>
item: <slug-or-id>
options_key: <slug>
action: pending
turn: you
---

# Decision — <topic> ({{date:YYYY-MM-DD}})

**Summary:** <one line — the decision, and what fires when you tick **Execute**.>
**Source:** [[<vault-relative path to the artifact>|<short label>]]  ← the evidence, if you want depth
**Loop:** <06.NN - loop-name> · **Item:** <slug-or-id>

## ✅ Options
_Tick the ones you want — one or several. Ticking records the **choice**; **Execute** applies it. Each
option carries its own paste-ready payload, so applying it is replay, not a re-derivation._

- [ ] **A. <label>** — <one line: what it does, where it lands>
      Target: [[<file it changes>|<label>]] · `<exact text / command / payload, inline>`
- [ ] **B. <label>** — <one line>
      Target: [[<file it changes>|<label>]] · `<exact text / command / payload, inline>`
- [ ] **C. <label>** — <one line>
      Target: [[<file it changes>|<label>]] · `<exact text / command / payload, inline>`
- [ ] **Do none of these** — leave everything as-is; the card closes with no change.
- [ ] **✏️ Something else** — none of the above. Write it under this line, then tick this box.
      → <your instruction, in your words; I execute it as written>

> The **✏️ Something else** box is **never optional** — every option set carries it, including a two-way
> Approve/Reject. A fixed menu is a guess about what you might want; this box is how you say the guess was
> wrong. Ticking it means the free text **is** the instruction (if it's ambiguous, I ask once instead of
> guessing).

## ▶ Control
- [ ] **Execute** — apply the ticked options, log it, then file this card to `00.04 - outbox/`.

## 🗒 Background
<!-- Context only — not the decision. 2–4 bullets: the feedback/sources that produced these options. -->
-

## Suggested actions (best takeaways)
<!-- agent: the recommended pick + why, one line each. The owner can take it or overrule it. -->
-
