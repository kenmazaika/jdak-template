---
title: Templates
created: 2026-10-11
updated: 2026-10-11
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# 05.05 · Templates

Reusable scaffolding for JDAK pages. **Obsidian wiring** (Settings →):

- **Templates** (core plugin) → *Template folder location* = `05 - KITS/05.02 - templates`.
- **Daily notes** (core plugin) → *New file location* = `02 - AREAS/02.04 - daily-notes`,
  *Template file* = `05 - KITS/05.02 - templates/daily-note.md`,
  *Date format* = `YYYY-MM-DD`.

Agent: when you create a page of a known type, start from the matching template so
frontmatter stays consistent (this is what keeps the vault agent-growable).

| Template | Use for |
|---|---|
| `daily-note.md` | The daily log (`02.04`) |
| `handoff.md` | An agent → owner handoff (`00.01`) |
| `ticket.md` | A long-running ticket (`00.03`) |
| `capture.md` | A raw capture (routes via Intake / `04.01 - captures`) |
| `permanent-note.md` | A distilled note (`03 - PERMANENT/03.03–03.06`) |
| `project.md` | A new project's `PROJECT.md` (`01 - PROJECTS/NN.MM`) |
