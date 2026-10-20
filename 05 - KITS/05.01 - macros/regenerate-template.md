---
title: "Macro — Regenerate the JDAK template"
created: 2026-10-16
updated: 2026-10-16
type: macro
status: active
authority: authoritative
tags: [macro, template, jdak]
trigger: "regenerate the template"
inputs: ["the vault", "the jdak-template repo"]
output: "the regenerated base committed + pushed to jdak-template"
---

# Macro — Regenerate the JDAK template

**Trigger:** `regenerate the template` (or "regenerate jdak template", "update the jdak template").
**Does:** rebuilds the **base** template repo from the vault and pushes it — one deterministic script.

## Inputs

- `JDAK_VAULT_ROOT` — the vault (source of truth).
- `TEMPLATE_REPO` — default `git@github.com:your-org/jdak-template.git`.
- Optional: `TEMPLATE_WORK` (clone dir), `TEMPLATE_BRANCH` (default `main`), `PUSH=0` (build, don't push).

## Steps

1. **Run the script** — `bash bin/regenerate-template.sh`. It:
   1. clones/refreshes the template repo;
   2. wipes it (except `.git`);
   3. copies the **base file set** from the vault (root docs, category READMEs, kits, templates,
      macros, management skills, `bin/` sync stack);
   4. **genericizes** the base (owner names/paths → generic);
   5. **leak-checks** (fails if `the owner` / `your-org` / `$HOME` remain);
   6. commits + pushes.
2. **Verify** — the script prints the new HEAD + file count; `git ls-remote origin main` matches.
3. **Log** one line to `log.md` (date · head · file count).

## Output

→ the `jdak-template` repo, `main` branch.

## Notes

- **Only base files ship.** Instance surfaces (`01 PROJECTS`, `02.01/02.02/02.03`, `03`, `04`, `08`, `09`,
  `10`) keep only their `README.md`. Skills: only the management kit (loop-studio, checkbox-runner,
  project-boot, project-status, vault-keeper, qball-router).
- **Never hand-edit the template repo.** Edit the vault, then regenerate — otherwise the next run
  overwrites you.
- Run with `PUSH=0` first when changing the copy list; inspect, then push.
- The script is the contract; this macro is the trigger. (`bin/regenerate-template.sh`)
