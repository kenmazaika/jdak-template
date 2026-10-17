---
title: Resources
created: 2026-10-12
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, schema, resources]
---

# 04 · RESOURCES

**Material pulled in from outside, filed by the *job it serves*.** Two ideas do the work:

1. **Domain shelves** — one per job-to-be-done, each topped by a rubric-scored `INDEX.md`.
2. **A resource is a folder** — `source.md` (the raw material) + `shaped.md` (a skimmable, **raw-only** distill of the post's actual point — no invention).

(Redesigned 2026-10-12 — proposals in `04.03 - proposals/`.)

## The four layers

```
capture / run  →  SOURCE (immutable)  →  WORKING (compound)  →  USABLE (shelf)  →  DISTILLED
```

| Layer | Home | Mutability | Syncs? |
|---|---|---|---|
| **Source** | `04.01 - captures/` (explicit) · `09 - FLEETING/…` (raw dumps) | immutable | **captures: yes** · raw: no |
| **Working** | `06 - LOOPS/runs/<date - topic>/` | scratch — compounds per run | yes |
| **Usable** | `04 - RESOURCES/04.0N - <domain>/` + `INDEX.md` | living | yes |
| **Distilled** | `03 - PERMANENT/03.01 concepts` | living | yes |

**Compounding happens by *writing back*** — a research run isn't "done" until it merged its
findings into a shelf `INDEX.md` (or a concept page).

## A resource = a folder

Every filed resource is a directory holding two files:

```
04.0N - <shelf>/<slug>/
  source.md     # the raw material:
                #   explicit capture -> the FULL raw output (and a link back to 04.01)
                #   implicit         -> the relevant snippets only
  shaped.md     # a skimmable bullet list distilling the post's ACTUAL point — short sentences,
                #   invents nothing, raw info only. Frontmatter keeps serves:/why:/signal:/review_by:.
```

So the raw is never lost, and the actual point is always one skimmable file away. (`source.md` is
the reference for the details; `shaped.md` is what you read first, on a phone, to get the point.) (Explicit captures are also
stored, immutably, in `04.01 - captures/` — the shelf resource inlines the same raw so the
resource is self-contained on a phone.)

## The shelves

| # | Folder | The job it serves |
|---|---|---|
| `04.01` | `captures/` | **Store of explicit captures** — raw outputs + `INDEX` by destination |
| `04.02` | `dictations/` | The raw voice layer (immutable; balls **symlink** in; synced) |
| `04.03` | `proposals/` | Recommendations produced *for* the owner |
| `04.04` | `reviews/` | Structured reviews / evaluations |
| `04.05` | `artifacts/` | Reusable non-link files (renders, kits, datasets) — *(system)* |
| `04.06` | `cold-email/` | Fill the lead funnel with outbound → `serves: [[MARKETING - Cold Email]]` |
| `04.07` | `distribution/` | Get read — where the audience comes from |
| `04.08` | `blog-content/` | Produce posts that rank + convert |
| `04.09` | `workshop-funnel/` | Sell the $97 workshop seat |
| `04.10` | `agent-tooling/` | Run + extend the agent stack |

Each **domain shelf** (04.06–04.10): `INDEX.md` (scored shortlist) + one folder per resource.

## The "why it matters" key

Every resource declares **which job it serves** (frontmatter on `shaped.md`) — this is what makes the shelf usable:

```yaml
serves: "[[MARKETING - Cold Email]]"   # the job / area / question / project it informs
why: "Gong's −44% is the number behind Decision 6 (no booking call)."   # one line
signal: 11                             # the rubric score (below)
review_by: 2027-04-12                  # decay clock
source_file: "source.md"               # the sibling raw file
```

## The rubric — SIGNAL (0–15)

Score 0–3 on each axis; sum. **S**erves a live thing · **I**mmediately actionable · **G**rounded
(evidence) · **N**ovel · **A**ges well.

- **12–15 → DISTILL** to a `03 - PERMANENT` page (and link it from the shelf index).
- **8–11 → SHELVE** as a distilled reference here.
- **4–7 → HOLD** as a raw capture in `04.01 - captures/` (or `09 - FLEETING`).
- **≤3 → ARCHIVE.**

Decay: `fact` lives forever (provenance required) · `opinion` `review_by` ≈ +6mo · **platform
mechanics** (X/Reddit/SEO/API) ≈ +3mo. The shelf `INDEX.md` flags anything past `review_by`.

## Voice & provenance

- **Voice:** every generated artifact follows the **Vault Voice Guide**
  (`03 - PERMANENT/03.02 - guidance/02 - AREAS/02.03 - voice-guide/vault.md`) — short, skimmable, lists not prose,
  bold key terms, no fluff.
- **Provenance caveat:** resources summarize *other people's* material and are **not verified**.
  Each resource carries `provenance: third-party` (or `owner`), and the `shaped.md` opens with one
  line — `> Source: … — summarized capture of their claims; not independently verified.` State it
  once; don't write “the author claims” on every bullet.

## Rules

- **Raw is immutable.** Captures in `04.01` are never edited; distillation creates a *new* page.
- **`shaped.md` invents nothing.** It's a bulleted distill of the raw's actual points, in short
  sentences — no synthesis, no opinion, no detail that isn't in the source. (If it's not in
  `source.md`, it doesn't go in `shaped.md`.)
- **Explicit vs implicit.** Explicit capture → full raw output in `source.md`. Implicit (a link
  you referenced but didn't capture) → relevant snippets only; say so in the frontmatter.
- **Never invent a shelf for one file** — park it in a domain shelf nearest-fit, or `04.05 - artifacts`.
- **Dictations are immutable**, and balls **symlink** them (never copy).
- A resource is `kind: opinion` unless verifiable fact — attribute it and date it.
- To file a new capture: digest it into a domain shelf as `<slug>/{source.md, shaped.md}` and add
  a row to that shelf's `INDEX.md` (+ its line in `04.01 - captures/INDEX.md`).
