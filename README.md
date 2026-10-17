---
title: JDAK — Johnny Decimal Agent Kit
created: 2026-08-29
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# JDAK — Johnny Decimal Agent Kit

**JDAK is an opinionated, agent-growable knowledge base.** It is a
[Johnny Decimal](https://johnnydecimal.com/)-organised Obsidian vault that an LLM agent
(OpenClaw, Hermes, …) can **navigate, file into, and extend** as it works — so every
interaction compounds into something durable instead of dying with the session.

It descends from the "LLM wiki" idea (Karpathy-style): the agent both **reads** and
**writes** its own knowledge base. JDAK is the opinionated packaging — a folder scheme,
a set of rules, and a handful of hooks — that makes that practical for a real workflow.

- **This README** — the concept and the map (read first).
- **`SCHEMA.md`** — the contract: the rules an agent follows before writing *anything*.
- **`TEMPLATE.md`** — how to fork this into your own instance, and what to strip.
- **`INBOX.md`** — the agent → owner handoff board.

## The problems it solves

1. **File spray.** "Save this for later," and durable files get strewn across the
   workspace — unowned, unfindable, forgotten. JDAK gives every durable thing a numbered
   home and a project to belong to (`01 - PROJECTS`).
2. **Session death.** A long thread dies mid-task and you re-explain from scratch. If the
   state, decisions, and receipts already live on disk, resuming is just *reading*
   (`decisions.md` → `BALL.md` → the latest handoff). No bespoke context-management system
   required — the filesystem *is* the memory.
3. **No compounding.** Conversations end and nothing accumulates. The hooks file what the
   agent learns so the base grows with use.
4. **Black-box skills.** An agent's skills live only inside the agent. Vendoring them into
   the synced vault (`07 - SKILLS`) puts them in front of you — readable on your phone,
   diffable in git.
5. **Lost opinion.** Captures pile up as raw links and never become usable. JDAK adds a
   **capture → distill → permanent** path (`00 - INBOX` → `04 - RESOURCES` → `03 - PERMANENT`).
6. **Loop glue is bespoke.** Wiring a new recurring job — its schedule, its approval flow, its
   feedback trail — is usually custom work every time. Here it's a **folder and a few files**: describe
   the loop and the mechanisms already exist (a `runs/` trail, file-**batons**, the **inbox approval**
   flow, a `feedback.md`). Building a loop stops being *"how do I wire this up?"* and becomes
   *"where does it go?"* — see **Loop Studio** (`05 - KITS/05.01 - macros/loop-studio.md`).

## What it does

- **Syncs to your phone.** A filtered two-way sync mirrors the vault to Dropbox (rclone
  `bisync`), where the Obsidian *Remotely Save* plugin picks it up. Your KB — projects,
  notes, skills, daily log — is in your pocket. (See *Sync* below.)
- **Files work as it happens.** Hooks in the agent's workflow route durable files into
  numbered homes: a new job becomes a project folder, a distilled idea becomes a permanent
  note, a handoff goes on the board.
- **Makes interruption cheap.** The project/QBall format means any paused job leaves a
  resumable trail on disk.
- **Is opinionated on purpose.** The value isn't a neutral filing cabinet — it's a *stance*
  about how agent work should be organised so it compounds.

## The map

```
vault/                          ← root holds only key files (see SCHEMA §2)
├── README.md  SCHEMA.md        ← concept + contract
├── TEMPLATE.md                 ← how to fork your own instance
├── INBOX.md  index.md  log.md  ← handoff board · catalog · action log
│
├── 00 - INBOX/                 ← agent → owner handoffs · the owner's Intake (00.02)
├── 01 - PROJECTS/              ← CARDS/ (outcomes) + NN.MM - slug — the QBalls
├── 02 - AREAS/                 ← ongoing responsibilities + the owner's opinion/intent
├── 03 - PERMANENT/             ← distilled, long-lived notes (concepts · entities · …)
├── 04 - RESOURCES/             ← curated external material (references · artifacts · …)
├── 05 - KITS/                  ← the vault's own machinery (scripts · templates · receipts)
├── 06 - LOOPS/                 ← registered loops + their runs
├── 07 - SKILLS/                ← vendored skills & workflow prompts
├── 08 - PRODUCTION/            ← the content pipeline (drafts · working · media)
├── 09 - FLEETING/              ← landing pad (raw/ · concepts/ · demoted notes → promote or archive)
├── 10 - ARCHIVE/               ← superseded / completed / rejected (read-only)
└── 99 - META/                  ← agent identity/config source of truth + state ledgers
```

Two levels: `NN - CATEGORY` (00–09 + 99) → `NN.MM - item` (numbered within the category; renumbered
only by an explicit **compact** / *reorganize the shelves*, so early-phase structure stays clean). Every category has a `README.md` explaining what belongs
there. Full rules — including how the agent *grows* the structure — are in `SCHEMA.md`.

### What each category is for

| # | Category | The question it answers |
|---|---|---|
| `00` | **INBOX** | *What needs attention, and what did we just capture?* — handoffs to the owner + raw capture queue. |
| `01` | **PROJECTS** | *Where is the work in flight?* — every durable intermediate file belongs to a project (QBall format). |
| `02` | **AREAS** | *What do we maintain, and what does the owner actually want?* — ongoing responsibilities + opinion/intent. |
| `03` | **PERMANENT** | *What do we know?* — distilled, long-lived notes; the compounding core. |
| `04` | **RESOURCES** | *What did we pull in from others?* — curated references and distilled sources. |
| `05` | **KITS** | *What machinery do we have?* — scripts, receipts, templates. |
| `06` | **LOOPS** | *What runs on a schedule?* — registered loops + their runs. |
| `07` | **SKILLS** | *What can the agent do?* — vendored, readable, version-controlled skills. |
| `08` | **PRODUCTION** | *What are we making?* — drafts, working notes, and media. |
| `09` | **RAW** | *What did we save verbatim?* — unedited sources. |
| `10` | **ARCHIVE** | *What's done or superseded?* — read-only history. |
| `99` | **META** | *What config/state does the agent run on?* — identity/config + state ledgers. |

## How the agent uses it

- **Before writing:** ask *which number does this belong to?* If none, it goes to
  `00 - INBOX` and is triaged later. Never drop a work product at the root.
- **When producing durable work:** create or adopt a **project**
  (`01 - PROJECTS/NN.MM - slug`) and file everything there. Register it in `BALLS.md`.
- **When pausing:** write a `HANDOFF-*.md` into the project (state, artifacts, exact next
  action, a resume key).
- **When resuming:** `decisions.md` → `BALL.md` → latest `HANDOFF-*.md` → `LINEAGE.md`.
- **When writing into the vault:** follow the **Vault Voice Guide**
  (`03 - PERMANENT/03.02 - guidance/02 - AREAS/02.03 - voice-guide/vault.md`) — short, skimmable, lists over prose,
  no invented detail, and a `provenance:` caveat on external material.
- **When capturing:** drop it in the inbox; the sweep distills it onward.
- **Structural changes** (new category, moving projects, deleting) → ask the owner first.

## How to navigate

- *What work is open?* → `BALLS.md` or scan `01 - PROJECTS/`.
- *What needs the owner?* → `INBOX.md`.
- *Where's the note on X?* → `03 - PERMANENT/` or `index.md`.
- *What did we capture about X?* → `04 - RESOURCES/`, `09 - FLEETING/`.
- *What happened on date D?* → `log.md`.

## Sync & garden

- **Sync:** `bin/vault-sync.sh` runs `rclone bisync` between the vault and
  `Dropbox:Apps/remotely-save/<vault>` on a schedule (cron `*/15`), filtered to docs +
  images + PDFs. Conflicts **never pick a clock winner** — both sides are kept and the agent
  **3-way merges** them against the last-synced base; only a genuine clash is flagged. Point Obsidian
  mobile's *Remotely Save* at the same Dropbox folder.
- **Garden (optional):** a Quartz static site can serve the vault as a browsable garden.

## Base vs instance (forking this)

JDAK ships as a **template**. Everything shareable lives in the *base*; everything
personal lives in the *instance*. See **`TEMPLATE.md`** for the split and the 10-minute
instantiate procedure, and **`05 - KITS/05.08 - install/`** for the full, concrete
install (vault + sync + agent wiring) — that's the file to follow to get this onto your setup.

## Operating rules

- **Git is the archive.** Commit instead of `-v2`/`-final` suffixes.
- **Symlink assets between projects, never copy** — copying forks the source of truth.
- **Frontmatter on every page** (`type` · `kind` · `status` · `authority` · `tags`).
- **Log every action** in `log.md`.
- **Capture freely, process on a schedule** — the inbox is a queue, not a home.

## Layers (the mental model)

- **L0** — this README / `SCHEMA.md` / `INBOX.md` (always read).
- **L1** — project state (`01 - PROJECTS/01.02 - qballs/*/{PROJECT.md,BALL.md,decisions.md,…}`).
- **L2** — the authoritative vault (this repo; git-tracked; indexed for recall).
- **L3** — a compiled wiki (optional; an external index / distilled layer).
- **L4** — gated guidance (`03 - PERMANENT/03.02 - guidance/`) — opinion / voice / taste;
  **not indexed, never auto-injected**.
