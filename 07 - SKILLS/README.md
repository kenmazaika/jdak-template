---
title: Skills
created: 2026-10-12
updated: 2026-10-19
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema, skills]
---

# 07 · SKILLS

**Vendored, readable skills.** The agent's procedures live here as plain Markdown, so they sync with
the vault, diff in git, and can be read on a phone.

## The `base:` flag — what actually ships

Every `SKILL.md` declares one line:

```yaml
base: true    # generic; ships with the template
base: false   # instance-specific; stays in the fork
```

The build reads that flag. **Numbering is a shelf convention, not a shipping promise** — a numbered
skill can still be instance-bound (it might name a private blog, a local path, or a channel id).
`base: true` is the only thing that puts a skill in the template.

## Base skills (ship with the template)

| # | Skill | What it does |
|---|---|---|
| `07.03` | `loop-studio` | Build a complete, runnable vault loop from a plain-text brief. |
| `07.07` | `checkbox-runner` | Execute checked boxes in a note, one run at a time. |
| `07.08` | `project-boot` | Load a project's state and answer "where are we?" |
| `07.09` | `project-status` | Write the project's status card. |
| `07.10` | `three-phase-pr` | Research → implement → validate + open one focused PR. |
| — | `vault-keeper` | Weekly inbox/capture digest. |
| — | `qball-router` | Route work-product writes to the owning project. |

## Instance skills (do not ship)

Everything else in this folder. Keep them here so the agent can use them; the build skips them.

## Adding a skill

1. Create `<slug>/SKILL.md` (numbered if it belongs on a shelf; unnumbered if it is personal).
2. Put `base: true` in the frontmatter **only** if a different owner could use it unchanged.
3. If it ships, remove owner names, private URLs, local paths, and secrets — or leave `base: false`.
4. Symlink it into the agent's live skills dir; this folder is the source of truth.

## Rules

- **One skill, one job.** The loop holds the parameters; the skill holds the procedure.
- **Vendor, don't copy.** Symlink from the live skills dir back to this folder.
- **`base: false` is normal.** Most skills are personal. The template is not a dump of one person's setup.
