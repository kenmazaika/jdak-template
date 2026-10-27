---
name: "qball-router"
description: "Route the first file-write in a thread to the right QBall: search existing balls, attach if relevant, else create one."
base: true
---

# qball-router

## When to use
- The first time a **work-product** file (CSV, draft, research note, receipt, data) is about to be
  created, written, or edited in a session, when no QBall is attached to the conversation.
- **Before every later work-product write** (re-validation — see below).
- When the user asks "which ball does this go in?".

Set **`<vault>`** to the directory that contains `BALLS.md`. It may be the current repository root or
a `Vault/` child of the workspace. If more than one candidate exists, ask which vault to use.

## Steps

### 1. Search for a relevant existing ball
- Read `<vault>/BALLS.md` — one line per project with status + next action.
- Keyword-search every ball recursively below the projects shelf (paths and numbering may differ by vault):
  ```bash
  find "<vault>/01 - PROJECTS" -type f -name BALL.md -print0 \
    | xargs -0 grep -ilE '<keyword1>|<keyword2>'
  ```

### 2. Rank candidates — recency + status first
- Prefer `status: active` balls touched recently. A keyword match on a **stale** ball is a trap.
- Treat `complete` / `archived` balls as **read-only reference** — never write new work into them.
- Flag any candidate whose `updated` is older than 30 days (or with no `updated`) as suspect.
- Rank: same project/offer/campaign/channel > same topic > same audience, then by recency.

### 3. Decide
- **One strong match → adopt it.**
  1. Read the ball's `PROJECT.md`, then `decisions.md` (why), then `BALL.md` (state).
  2. Write the file **inside** that ball (`receipts/` proof, `drafts/` output, `research/` findings).
  3. Update `BALL.md` `next_action`, `PROJECT.md` `## Next`, append a dated line to `<vault>/log.md`.
- **No match → create a ball.** Use the shared parent of existing QBall directories. If the vault has
  no QBall yet, use `<vault>/01 - PROJECTS/01.02 - qballs/<slug>/`, the template default:
  ```
  BALL.md        # frontmatter: name, type: qball, status: active, owner, created, last_thrown, next_action
                 # + "One-screen read", "Open decisions (need the owner)", "How to resume"
  decisions.md   # the WHY — read first
  LINEAGE.md     # prompts/models/commands per version
  receipts/      # proof of what ran
  prompts/       # the briefs
  commands.log   # append-only
  ```
  Add a row to `BALLS.md`, then write the file inside the new ball.
- **Two plausible candidates → ask ONE question** before writing. Never guess.

### 4. Re-validate (the periodic check)
- **Before every later work-product write**, re-confirm the attached ball still matches the work.
- If the topic/project has drifted → re-run the search and switch balls. If it's genuinely new work → split
  into a new ball. Never keep writing into a ball that no longer fits.
- **A new thread is a fresh routing.** Sessions are separate: a main-channel session and a thread session
  do not share an attached ball. Do not inherit a stale ball from the parent channel — re-run the search.
  If it's a continuation, the search lands on the same ball; say so and continue.

### 5. Report
Say in one line which ball you attached to or created (and, on a re-check, that it's unchanged or switched).
Never silently start a new ball when a live one could fit, and never leave a work product at the workspace root.

## Hard rules
- **Symlink assets, never copy** — copying forks the source of truth.
- **Log every change in all four files** (BALL, decisions, LINEAGE, commands.log) — not just the work.
- **Scope:** work products only. Not `memory/` notes, config, or skills. Scratch files go in `tmp/`.
- If the registry looks stale or a ball root has a `.pre-consolidation-archive-*` dir, flag it — don't
  create a duplicate ball to work around a registry problem.
