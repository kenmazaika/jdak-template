---
title: TEMPLATE — forking JDAK into your own instance
created: 2026-10-12
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# TEMPLATE — forking JDAK into your own instance

JDAK ships in **two layers**, kept deliberately separate so the base stays shareable:

| Layer | What it is | Examples |
|---|---|---|
| **Base (template)** | The structure, rules, and docs — generic and owner-agnostic. | `README.md`, `SCHEMA.md`, every category folder + its `README.md`, the templates, the growth protocol. |
| **Instance** | Your content — your projects, notes, voice, skills, personal files. | your project folders, your `03 - PERMANENT` notes, your voice guide, your vendored skills, your résumé. |

**The rule:** *base* files describe the system and never name the owner; *instance* files
are yours and can say whatever they like. When you fork, you keep the base and replace (or
empty) the instance.

## Base vs instance, by path

| Path | Layer | On fork |
|---|---|---|
| `README.md` · `SCHEMA.md` · `TEMPLATE.md` | base | keep |
| `00 - INBOX/` (README + empty subfolders) | base | keep, empty the board |
| `01 - PROJECTS/` | instance | empty (your projects) |
| `02 - AREAS/02.01–02.03` (projects / goals / voice-guide) | instance | replace |
| `02 - AREAS/02.04 - daily-notes/` | base | keep (empty) |
| `03 - PERMANENT/` | instance | empty (your notes) |
| `04 - RESOURCES/` | instance | empty |
| `05 - KITS/05.03 - scripts/` · `05.02 - templates/` | base | keep |
| `06 - LOOPS/` | base | keep — define *your* loops |
| `07 - SKILLS/` | instance | vendor your own |
| `08 - PRODUCTION/` (drafts · working · media) | instance | empty |
| `09 - FLEETING/` · `10 - ARCHIVE/` | instance | empty |
| `99 - META/` (state ledgers) | instance | reset |
| `INBOX.md` · `index.md` · `log.md` · `BALLS.md` | mixed | reset the content, keep the format |

## Instantiate (10-minute procedure)

1. **Copy the base.** Clone/copy this folder. Delete `.git` and re-`init` for a fresh history.
2. **Name it.** Set the vault name in `bin/vault-sync.sh` (`SRC` / `DST`) and, optionally,
   retitle `README.md`.
3. **Empty the instance.** Clear `01 - PROJECTS/01.02 - qballs/*`, `03 - PERMANENT/*`, `04 - RESOURCES/*`,
   `07 - SKILLS/*`, `08 - PRODUCTION/*`, `09 - FLEETING/*`, `10 - ARCHIVE/*`, and the state files in
   `99 - META/`. Reset `INBOX.md`, `BALLS.md`, `log.md`.
4. **Wire Obsidian.** Point the *Templates* plugin at `05 - KITS/05.02 - templates`; the
   *Daily notes* plugin at `02 - AREAS/02.04 - daily-notes`, with the `daily-note` template.
5. **Wire sync.** Configure an rclone remote + `bin/vault-sync.sh` + a cron (see README
   *Sync*). Point mobile *Remotely Save* at the same Dropbox folder.
6. **Add your first project** (`01 - PROJECTS/01.02 - qballs/01.01 - <slug>/` from `project.md`) and
   register it in `BALLS.md`.

## What NOT to strip

- The category folders themselves — the structure *is* the value.
- `SCHEMA.md` and the growth protocol — that's what keeps it agent-growable.
- The per-category `README.md` files — they're the self-describing map.
- `bin/` (`vault-sync.sh`, `vault-sync-watch.py` + filters) if you want phone sync.
