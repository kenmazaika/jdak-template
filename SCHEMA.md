---
title: JDAK Schema
created: 2026-08-29
updated: 2026-10-17
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema]
---

# JDAK Schema

**JDAK = the Johnny Decimal Agent Kit.** This vault is a Johnny-Decimal-organised
knowledge base + content-production system that an LLM agent can *navigate, file into,
and grow* without breaking its own conventions. This file is the contract.

- **Humans:** read `README.md` first, then this.
- **Agents:** read this before writing *anything* into the vault.

If you are an agent and a task needs a folder, a number, or a new page, the rules below
tell you exactly how to do it — and when you must instead ask the owner.

---

## 0. Base vs instance (read this first)

JDAK is a **template**: a shareable *base* (structure, rules, docs) that an owner fills with
their own *instance* (projects, notes, voice, skills). **Base files describe the system and
never name the owner; instance files are the owner's.** Each category carries a `README.md`
saying what belongs there, and `TEMPLATE.md` documents the split and how to fork. Where a
rule below touches instance content, keep it generic here and put specifics in the instance.

---

## 1. The numbering (Johnny Decimal)

Two levels, both zero-padded:

```
NN - CATEGORY           (top-level bucket, NN = 00…09)
  NN.MM - item          (a project, an area, a topic shelf, a working folder)
```

- **Categories** are the top-level buckets `00`–`10` plus `99`. They are **stable**: a
  category is never renumbered and never reused for something else. New categories are rare
  (see §7). *(The set was renumbered 2026-10-12 — see §11.)*
- **Items** are `NN.MM`, where `NN` is the parent category and `MM` is the next free
  number in that category. Items **within a category** are numbered independently
  (`01.01`, `01.02`, … / `04.01`, `04.02`, …).
- **Never renumber** an existing item. Numbers are permanent addresses; the *name*
  after the dash may change, the number may not.
- A folder/file whose name is **not** `NN`/`NN.MM` is an "undisciplined" node — allowed
  only inside a category as loose content, and should be folded in on the next pass.
- Keep the file/folder name **after** `NN.MM - ` lower-case-hyphenated (see §3).

### The map (current)

| # | Category | Holds |
|---|---|---|
| `00` | **INBOX** | The agent → owner handoff board + the owner's capture queue. Swept on a schedule. |
| `01` | **PROJECTS** | Work in flight. One folder per project = the **QBall** format. |
| `02` | **AREAS** | Ongoing responsibilities + the owner's opinion/intent (voice, goals) + `02.04 - daily-notes`. |
| `03` | **PERMANENT** | Long-lived distilled notes: concepts, entities, comparisons, questions, guidance (+ personal artifacts like a résumé). |
| `04` | **RESOURCES** | Captures, dictations, proposals, reviews + **domain shelves** (each resource = a folder: `source.md` + `analysis.md`). |
| `05` | **KITS** | The vault's own machinery — scripts, receipts, templates. |
| `06` | **LOOPS** | Registered loops + their runs (each loop's hyperparameters live here). |
| `07` | **SKILLS** | Vendored skills & workflow prompts — readable + version-controlled. |
| `08` | **PRODUCTION** | The content pipeline: drafts, working notes, and media (`08 - PRODUCTION/media-company`). |
| `09` | **RAW** | Immutable source material (articles, papers, transcripts, captures). |
| `10` | **ARCHIVE** | Superseded / completed / rejected material. Read-only reference. |
| `99` | **META** | Source of truth for agent meta-files (identity/config) + runtime state ledgers. |

Every category also carries its own `README.md` with the full contract for that shelf.

Root keeps only a **few key files** (this is deliberate — see §2).

---

## 2. Root key files

The vault root holds *only* orientation + contract files:

- `README.md` — what JDAK is + how to navigate
- `SCHEMA.md` — this file (the rules + growth protocol)
- `TEMPLATE.md` — base vs instance + how to fork your own
- `INBOX.md` — the agent → owner handoff board + inbox contract
- `index.md` — generated catalog (`05 - KITS/05.03 - scripts/gen-index.py`)
- `log.md` — append-only action log

Everything else lives under a numbered category. Do **not** drop work products at the root.

---

## 3. Naming rules

- Categories/items: `NN - Name` / `NN.MM - name` (two spaces around the dash, capital in
  category names, lower-case-hyphen in item names).
- Files inside: `lower-case-hyphenated.md`. No spaces. No `v2`/`final`/`copy` suffixes —
  **git is the version history** (see §8).
- Dates in filenames only when the date *is* the identity (`2026-10-11-digest.md`).
- Wikilinks `[[...]]` between pages; provenance `^[09 - FLEETING/…]` markers on synthesized claims.

---

## 4. Frontmatter

Every markdown page starts with:

```yaml
---
title: Page Title
created: YYYY-MM-DD
updated: YYYY-MM-DD        # bump on every edit
type: entity | concept | comparison | question | goal | area | reference | artifact
      | project | capture | schema | log | index | decision-card
kind: fact | opinion | idea
status: seed | active | complete | archived
authority: authoritative | guidance      # default authoritative
tags: [from §6]
sources: [09 - FLEETING/…]                     # where claims came from
confidence: high | medium | low
serves: "[[Area / Project / Question]]"  # (resources) the job/decision it informs — see 04/README
signal: 8                                 # (resources) SIGNAL rubric score, 0–15
review_by: YYYY-MM-DD                     # (resources) decay clock (opinion ~6mo, platform ~3mo)
source_file: source.md                    # (resources) sibling raw file inside the resource folder
provenance: third-party | owner           # (resources) whose claim it is — third-party = unverified
---
```

### `kind` — the fact/opinion/idea axis (retention + trust)

- **fact** — verifiable, sourced. Keep forever; provenance matters.
- **opinion** — someone's take. Keep with attribution + date; decays (~6 months).
- **idea** — hypothesis/seed. Cheap to regenerate; **expires in 30 days** unless attached
  to a live project/goal/question.

### `status` — controlled vocabulary (4 values only)

`seed` (inbox/untrusted) · `active` (attached to live work) · `complete` (done/published)
· `archived` (superseded/expired).

### `authority` — the retrieve/gate axis (added 2026-09-14)

- **authoritative** (default) — facts, intent, project state, evidenced synthesis.
  Safe to auto-retrieve/index. `extraPaths` indexing applies here.
- **guidance** — voice rules, taste, strategy heuristics, "best plan" calls. L4.
  Lives under `03 - PERMANENT/03.02 - guidance/`, is **excluded from the recall index**,
  and is **never auto-injected**. Carries `source`, `date`, `scope`, `confidence`, `review-by`.

---

## 5. The project format (formerly the QBall)

A **project** is `01 - PROJECTS/NN.MM - slug/`. It is the QBall convention, formalised:

```
01 - PROJECTS/NN.MM - slug/
├── PROJECT.md      # the contract: objective · state · next · open decisions (start here)
├── BALL.md         # the QBall state file (one-screen read, spine, receipts)
├── decisions.md    # WHY — read first for any resume
├── LINEAGE.md      # exact prompts/models/commands per version
├── commands.log    # append-only command trail
├── prompts/  receipts/  campaign/  dictations/  assets/   (as needed)
└── HANDOFF-*.md    # pause/resume handoff (with a 6-digit resume key)
```

Rules: **symlink assets between project folders — never copy** (copying forks the source
of truth). Log every change in `BALL.md` + `commands.log`, not only in the work.
**Resume order:** `decisions.md` → `BALL.md` → latest `HANDOFF-*.md` → `LINEAGE.md`.

---

## 6. Tag taxonomy

Add a tag here *first*, then use it. Groups: Engineering Management (`em`, `hiring`,
`promotion`, …) · Career (`career-growth`, `job-search`, …) · AI Tools (`hermes`, `claw`,
`ai-agent`, `automation`, `skill`, …) · Content & Growth (`writing`, `blog`, `seo`,
`distribution`, `newsletter`, …) · Industry (`ai-trends`, `agent-safety`, `benchmark`, …)
· Personal Goals (`goals`, `career-target`, `business`, …) · Meta (`wiki`, `schema`, `archive`).

---

## 7. Growth protocol — how the LLM extends the system

> This is the part that makes JDAK *agent-growable*. Follow it exactly. When two rules
> conflict, prefer the rule that keeps **addresses stable** and **root clean**.

**(a) Filing something new (the 90% case).**
Put it in the existing item that fits. If it's a new project → next free `01.MM`.
If it's a new capture/reference → land the raw in `04 - RESOURCES/04.01 - captures/`, then digest it into a domain shelf as a folder `<slug>/{source.md, analysis.md}` (see `04 - RESOURCES/README.md`).
If it's a new distilled note → `03 - PERMANENT/03.01 - concepts/`. **Never** invent a
top-level folder for one file.

**(b) New item (`NN.MM`) inside an existing category.**
Allowed freely when there's no good existing home. Take the **next free MM** in that
category (01, 02, …), never reuse a retired number, never renumber siblings. Name it
`NN.MM - lowercase-slug`. Record it in the registry (`BALLS.md` for projects; `index.md`
regenerates itself via `05 - KITS/05.03 - scripts/gen-index.py`).

**(c) New *category* (`00`–`09`).**
Rare, and **requires the owner's explicit yes**. A category is justified only when a whole
class of material has no home among the ten and won't fit as an item. The ten slots are
effectively full (`00`–`09` all allocated), so the default answer is **no — use an item**.

**(d) Splitting / promoting.**
When an item outgrows its shelf (e.g. a shelf hits ~200 lines or ~50 files), split it
into sub-items `NN.MM.1`… or promote a new item and move the files with `git mv`.
Log the split in `log.md`.

**(e) Retirement.**
Don't delete numbers. Move the content to `10 - ARCHIVE/…`, set `status: archived`, and
leave a one-line tombstone in the category's README if it had one.

**(f) Every structural change is logged.**
Append to `log.md`: date · what moved · why. Update `index.md` via
`05 - KITS/05.03 - scripts/gen-index.py`. Bump `updated:` on any page you touch.

**(g) Ask, don't guess, when:** a change is structural (new category, moving >1 project),
irreversible (deleting anything not obviously transient), or when **two items both fit**.

---

## 8. Lifecycles (the triage model)

### Inbox (`00 - INBOX/`) — the agent → owner handoff surface + capture queue
1. **Agent → owner:** post handoffs in `00.01 - handoffs/` and keep the live board `INBOX.md`
   current — what the owner must **decide / review / know** (template `05 - KITS/05.02 - templates/handoff.md`).
   A handoff whose ask is *"pick which of these"* ships as a **decision card** instead — same folder, same
   sweep, `type: decision-card` (template `05 - KITS/05.02 - templates/decision-card.md`).
2. **Owner → agent:** the owner's front door is `00.02 - intake/` — one note per item; a
   checkbox routes it (dictation · command · link · ticket · card).
3. **Tickets (`00.03 - tickets/`):** long-running, round-trip work — one file each, shaped as a
   **conversation, newest-first**: write your message in the ✍️ slot, tick **Execute**, and the sweep
   reverse-prompts it, runs it, writes the **full answer to a file**, and replies on the ticket in a few
   sentences that **link to that file** (see `00 - INBOX/00.03 - tickets/README.md`).
4. **Processed → out:** the moment the agent finishes a handoff, an intake note, **or** closes a ticket,
   the file moves to `00.04 - outbox/` — the "left the inbox" tray. Nothing there is acted on again.
5. Sweep: the **action sweep** processes **every** checked handoff (loop-owned or not) and files the
   note in `00.04 - outbox/`; the weekly pass clears handoffs the owner has ruled on and refreshes the
   board. Afterward `00.01` holds only live handoffs; `00.02` holds only unhandled intake notes.

**Decision cards** (`00.01`, `type: decision-card`) are the fourth surface: an agent → owner item carrying
**one decision plus its option set**, each option pre-baked with its exact payload, plus a tickable
*Do none of these* and an **Execute**. Tick options = record the choice; tick **Execute** = fire the apply,
which replays the ticked payloads, logs, and files the card to `00.04`. Frontmatter stays inside the
vocabularies above (`status: active`, `turn:`, `action: pending|done`) so it needs no new detection — the
sweep already reads `action: pending` + a checked box. Emit one **only** for a genuine pick-from-a-set
(2+ discrete options); everything else stays a handoff or a ticket. Doctrine:
[[03 - PERMANENT/03.01 - concepts/inbox-decision-card|The Inbox Decision Card]].

### Ideas — expire unless attached
`seed` ideas get a 30-day clock. Unattached seeds are archived by the monthly sweep. An
idea survives only by attaching to a `goal`, `question`, or active project.

### Opinions — decay (~6 months). Facts — live forever (provenance required).

### Projects — current + archive
Only current state + the final artifact live in the active tree; older versions live in
git history. On ship: `status: complete`, log it, and (optionally) move heavy intermediates
to `10 - ARCHIVE`.

---

## 9. Page thresholds

Create a page when an entity/concept appears in 2+ sources OR is central to one source.
Add to an existing page when a source covers something already there. Don't create pages
for passing mentions. Split a page past ~200 lines. Archive fully-superseded pages.

---

## 10. Update policy

When new info conflicts: prefer the newer source; if genuinely contradictory, record both
with dates/sources and set `contradictions: [page]` in frontmatter; flag it in the weekly
triage digest. Bump `updated:` on every edit.

---

## 11. History

- **2026-08-29** — ported from the Hermes wiki (`$HOME/wiki`); 4-layer model,
  `kind` axis, controlled `status`.
- **2026-09-14** — added `authority` (retrieve/gate); guidance gated under `03.07`; ball
  root consolidated to `Vault/balls/`.
- **2026-10-11** — **JDAK restructure**: Johnny-Decimal top level, QBall → project
  format under `01 - PROJECTS/NN.MM - slug`, inbox reframed as the agent → owner handoff
  surface, daily notes (`02.04`) + templates (`05 - KITS/05.05`) added, growth protocol added,
  root reduced to key files. Categories reconciled to the owner's Obsidian scheme
  (`05 - KITS`, `06 - SKILLS`, `99 - ARCHIVE`); an earlier agent pass's `05 - META` /
  `06 - ARCHIVE` folded into `05 - KITS/05.0x` and `99 - ARCHIVE`.
- **2026-10-12** — **category renumber** (owner's scheme): `06 SKILLS`→`07 - SKILLS`,
  `07 PRODUCTION`→`08 - PRODUCTION`, `99 ARCHIVE`→`10 - ARCHIVE`; new `06 - LOOPS` (promoted
  from `05 - KITS/05.01 - loop-engine`) and `99 - META` (from `05 - KITS/05.02 - meta`);
  `08 - MEDIA` folded into `08 - PRODUCTION/media-company`; `09 RAW` kept. Dropbox
  mirror baseline rebuilt to match.
- **2026-10-12 (later)** — **Resources redesign**: filed by *job* into domain shelves
  (`04.05 cold-email` … `04.09 agent-tooling`) + `04.02 - dictations`; added the `serves:` /
  `why:` / `signal:` / `review_by:` key and the **SIGNAL** rubric (see
  `04 - RESOURCES/README.md`); dictations moved out of `09 - FLEETING` (so they sync) with balls
  symlinking in; `04.02 - artifacts` split (owner-authored posts →
  `08 - PRODUCTION/drafts/legacy-artifacts/`, résumé + reddit twins archived).
  Proposal: `04.03 - proposals/resources-handling-2026-10-12.md`.
- **2026-10-12 (later still)** — **Resources v2** (owner's ask): `04.01` is now the **explicit-capture
  store** (raw outputs moved out of `09 - FLEETING/captures`, so they sync; `INDEX.md` organised by a link
  to each destination); **dictations moved to `04.02`** (front of the shelf); `04.02 - artifacts`
  → `04.05 - artifacts`; and **every shelf resource became a folder** — `source.md` (full raw output
  for explicit captures, relevant snippets for implicit) + `analysis.md`. `source_file:` added to §4.
- **2026-10-12 (v3 — shaped)** — replaced the per-resource `analysis.md` with a **`shaped.md`**: a
  skimmable **bullet list** distilling the post's *actual* point in short sentences — **raw info
  only, no invention, no synthesis** (the analysis read as wrong). Resource = `source.md` (raw) +
  `shaped.md`; `serves:`/`why:`/`signal:`/`review_by:` carried onto `shaped.md`.
- **2026-10-17** — **decision cards** adopted as a fourth inbox surface (owner-approved, from the
  voice-guide ticket): an agent → owner item in `00.01` with the option set *and* its paste-ready payloads
  inline, a tickable *Do none of these*, and an **Execute**. `type: decision-card` added to §4; the four
  surfaces are now handoff · **decision card** · intake · ticket. Kept inside the existing vocabularies
  (`status: active` — not the draft's `open|working`) and the existing sweep detection (`action: pending`),
  so no new code and no new folder. Template + base docs ship on the next `regenerate the template`.

---

## 12. Writing into the vault (voice + provenance)

Two rules govern every generated artifact:

- **Voice → the Vault Voice Guide** (`03 - PERMANENT/03.02 - guidance/02 - AREAS/02.03 - voice-guide/vault.md`).
  Short, skimmable, **lists not prose**, bold key terms, ≤ ~20-word sentences, no fluff, no
  invented detail. Two modes: **verbatim** (a capture → reproduce as-is) vs **shaped** (summarize →
  compress, invent nothing).
- **Provenance → the global caveat.** External material is *someone else's claim, unverified*. Tag
  it `provenance: third-party` (or `owner`) and state it **once** — don't sprinkle “the author
  claims”. The `shaped.md` opens with one line: `> Source: … — summarized capture of their claims;
  not independently verified.`
