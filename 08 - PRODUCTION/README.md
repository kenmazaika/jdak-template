---
title: Production
created: 2026-10-14
updated: 2026-10-14
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# 08 · PRODUCTION

**Where work is made.** Drafts, working notes, and media — the artifacts in progress, before they ship
or archive.

## Sub-folders

| Folder | For |
|---|---|
| `drafts/` | post/asset drafts by slug (`<slug>/`) — the core artifacts a loop produces |
| `working/` | in-progress working notes + `working/archive/` (shipped/consumed drafts) |
| `media-company/` | the content pipeline (campaigns · platforms · roles · engine) — symlinked from `~/wiki` |

## Rules

- **The draft is the artifact.** A content loop (`06.02 - publish-blog`) configures here; this shelf holds
  the work.
- **Route by "where it belongs":** drafts → `08.xx`; a *note* → `03 - PERMANENT`; a *resource* →
  `04 - RESOURCES`; raw → `09 - FLEETING/09.01 - raw`.
- **Frontmatter on every page** (SCHEMA §4). Follow the **Vault Voice Guide**.
- Shipped/rejected work leaves for `10 - ARCHIVE`.

*(Restored to the top level 2026-10-14 — it had been nested under `09 - FLEETING/09.06`, leaving the
top-level `08` slot empty.)*
