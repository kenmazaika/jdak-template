---
title: "Macro — Reorganize the shelves"
created: 2026-10-14
updated: 2026-10-14
type: macro
status: active
authority: authoritative
tags: [macro, schema]
trigger: "reorganize the shelves"
inputs: [which shelves (default: every maintained shelf)]
output: renumbered shelves + updated references + refreshed index.md
---

# Macro — Reorganize the shelves

**Trigger:** "reorganize the shelves" (alias: "compact the shelves")
**Does:** Reorder + renumber the shelves so a **fresh reader** reads them top-down — general-first,
folders-above-files, **contiguous at every level** — then fix every reference and re-sync.

## Inputs
- Which shelves (default: every **maintained** shelf — see *Exempt*).
- Anything the owner wants left put.

## Steps
1. **Number for a fresh reader, not history.** If a number only makes sense because of what used to be
   there, move it. A newcomer reads the shelf cold.
2. **General-first.** Template/system items take the **low** numbers; instance-specific items sort
   **later**.
3. **Folders above files.** Explorer + `gen-index.py` keep folders first (each ordered by number).
4. **Contiguous — everywhere.** Top level (`00, 01, …` — no missing category number) **and** within a
   shelf (`NN.MM = 01, 02, 03 …`). **Count files and folders together** — a numbered file is an item.
5. **Check the top level first.** List `NN - SHELF`; if a retired shelf left a hole (e.g. an old
   `08 - PRODUCTION`), renumber to close it.
6. **Renumber with `git mv`** — history stays intact.
7. **Fix every reference** — READMEs, `index.md`, `SCHEMA.md`, loops, skills, scripts, filters, symlinks.
8. **Regenerate `index.md`** (`05 - KITS/05.03 - scripts/gen-index.py`).
9. **Commit**; **sync** (`bin/vault-sync.sh`); **log** to `log.md` + the owning ball's `commands.log`.

## Exempt (never renumbered)
`10 - ARCHIVE` (read-only history) · `99 - META` (sentinel) · `01 - PROJECTS` (`01.NN` QBall ids —
referenced vault-wide) · `07 - SKILLS` (numbering *is* the system/personal signal).

## Output
→ renumbered shelves · updated references · refreshed `index.md` · synced.
(Rules live in `05 - KITS/05.08 - compact.md`; this macro is the owner-facing trigger for the same op.)

## Notes
- Same operation as the **`compact`** kit — `05.08` is the spec, this is the phrase you say.
- **A starter kit is the test:** if a newcomer can't read the numbers cold, compact again.
