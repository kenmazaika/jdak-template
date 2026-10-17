---
title: Install JDAK
created: 2026-10-11
updated: 2026-10-12
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, install, schema]
---

# Install JDAK

**What you're installing:** an agent-growable Obsidian vault (the JDAK template) **plus** the hooks
that wire it to an agent (OpenClaw, Hermes, …). Two audiences, two tracks: **the human** (Parts A–C)
and **the agent** (Part D). Everything below uses real paths from this stack — copy, adjust, run.

> Convention: `$WS` = the agent workspace (`~/.openclaw/workspace`). `$VAULT` = `$WS/Vault`.

## Prerequisites

- Obsidian (desktop + mobile).
- A Dropbox account (the sync relay).
- `git` + a **private** GitHub repo (for backup).
- `rclone` (`~/.local/bin/rclone`), configured with a `dropbox` remote.
- An agent (OpenClaw) with a workspace and a `skills/` dir.

---

## Part A · The human

1. Install **Obsidian** on desktop and mobile.
2. Install the **Dropbox** app + the mobile Dropbox app; sign in.
3. Create a **private GitHub repo** for the vault (backup + history). Have the URL ready for the agent.
4. Note the **Dropbox app folder** the vault will live in — this stack uses
   `Dropbox:Apps/remotely-save/jdak-stack`.

## Part B · Get the vault in place

```bash
$VAULT=$WS/claw-vault
git clone <your-private-repo-url> "$VAULT"      # or: cp -a the template in, then git init
cd "$VAULT" && git add -A && git commit -m "init" && git push -u origin main
```

## Part C · Sync (vault ↔ Dropbox ↔ Obsidian)

**1. rclone remote** — add a `dropbox` remote:

```bash
rclone config create dropbox dropbox        # follow the OAuth prompt
```

**2. Filter** — `bin/rclone-vault.filters` restricts what syncs (docs + images + PDFs;
excludes `.git/**`, `09 - FLEETING/**`, caches, `*.duckdb`). Copy this stack's file, or start:

```
+ *.md
+ *.txt
+ *.html
+ *.pdf
+ *.png
+ *.jpg
+ *.jpeg
+ *.webp
+ *.csv
- .git/**
- 09 - FLEETING/**
- **/.cache/**
- **
```

**3. Sync script** — this stack's real script is **`bin/vault-sync.sh`** (a two-way `rclone bisync`
with **preserve-both + 3-way agent merge** — *not* newer-wins). Filter: **`bin/rclone-vault.filters`**.
Minimal shape:

```bash
R=~/.local/bin/rclone ; C=~/.config/rclone/rclone.conf
SRC="$VAULT" ; DST="dropbox:Apps/remotely-save/jdak-stack"
$R bisync "$SRC" "$DST" --filter-from "$VAULT/bin/rclone-vault.filters" --config "$C" \
  --conflict-resolve none --conflict-loser num --conflict-suffix sync-conflict \
  --resilient --recover --max-delete 50 --checkers 8 --transfers 8
```

First run needs `--resync` once (rebuilds the baseline). Re-run it any time the baseline looks
wrong. **Kill a stuck rclone by PID** (`pkill -x rclone`) — killing the wrapper can orphan it.

**4. Schedule it** — cron every 15 min:

```
*/15 * * * * $WS/bin/jdak-sync.sh >/dev/null 2>&1
```

**5. Obsidian** — install the community plugins on mobile *and* desktop (below). Now the vault is in
your pocket.

> [!warning] Obsidian mobile setup — required
> Two community plugins, on **mobile and desktop**:
>
> 1. **Remotely Save** — add your **Dropbox** remote and point it at the **same folder**
>    (`Apps/remotely-save/jdak-stack`); **enable Dropbox sync**. This is the remote sync.
> 2. **Templater** — in *Settings → Templater → **Folder Templates***, map the **intake folder**
>    (`00 - INBOX/00.02 - intake`) → the **intake template**
>    (`05 - KITS/05.02 - templates/intake.md`), trigger on new-file creation. This is what auto-names
>    each intake note: **`00.02.NN - <Weekday M-D> capture`**.
>
> The **core Templates plugin will not work** — the intake template uses Templater syntax (`<% %>`)
> and `tp.file.rename()` to set the filename.

## Part D · Wire the agent (the integration points)

**1. Config source of truth → `99 - META`.**
Move the agent's identity/instruction files into the vault so they sync + version:

```
99 - META/
├── AGENTS.md   SOUL.md   IDENTITY.md   USER.md   MEMORY.md   TOOLS.md
└── *-state.json        # runtime ledgers
```

Then **symlink** them back into the agent workspace (so the agent still reads them):

```bash
mv "$WS"/{AGENTS.md,SOUL.md,IDENTITY.md,USER.md,MEMORY.md,TOOLS.md} "$VAULT/99 - META/"
for f in AGENTS.md SOUL.md IDENTITY.md USER.md MEMORY.md TOOLS.md; do
  ln -sfn "$VAULT/99 - META/$f" "$WS/$f"
done
```

**2. MCP servers → `~/.openclaw/openclaw.json`.**
Add each server under `mcp.servers` (API key in `headers`, never in the repo). Example:

```json
{ "mcp": { "servers": {
  "hunter": { "command": "npx", "args": ["-y", "mcp-remote", "https://mcp.hunter.io/sse"],
              "headers": { "X-API-Key": "<your-key>" } }
}}}
```

**3. Secrets → `$WS/secrets/`.** One JSON/key file per service, `chmod 600`. Record a **pointer list**
in `TOOLS.md` (which key is where) — never the values. e.g. `secrets/airtable.key`,
`secrets/apollo.json`.

**4. Skills → vendor + symlink.** The vault is the **source of truth**:

```bash
mkdir -p "$VAULT/07 - SKILLS/my-skill"      # put SKILL.md here
ln -sfn "$VAULT/07 - SKILLS/my-skill" "$WS/skills/my-skill"
```

Edit the vault copy; the symlink picks it up; it syncs to your phone.

**5. Hooks / cron jobs.** Register the recurring jobs with the agent's scheduler (or crontab):
`jdak-sync` (`*/15`), the weekly vault triage, the dictation processor, and any **loop** runners
(`06 - LOOPS/NN.MM - <loop>/LOOP.md` says *what*; the schedule says *when*).

**6. Email (optional).** Wire the sending mailbox via `himalaya`:

```toml
[accounts.<name>]
email = "you@example.com"
# IMAP imap.gmail.com:993 TLS · SMTP smtp.gmail.com:587 start-TLS
# auth.cmd = the app-password helper script
```

Gmail/Workspace needs a 16-char **App Password** (2SV must be on) — the account password won't work.

**7. What to add to `TOOLS.md`.** Keep a running local-notes file: the machine's sync paths, MCP
server names, secret pointers, camera/SSH/TTS specifics, and the voice/sync conventions. (See this
stack's `TOOLS.md` for the shape.)

## Part E · Verify

```bash
cd "$VAULT" && git status                      # clean
$WS/bin/jdak-sync.sh && echo ok                # bisync exit 0
ls -l "$WS/skills/<a-skill>"                   # symlink resolves
```

- Ask the agent to **read** a vault file and **write** a test note.
- Check the note appears on the phone (Obsidian → Remotely Save → sync).

## Related

- `TEMPLATE.md` — base vs instance, and what to strip when forking.
- `SCHEMA.md` — the rules the agent follows.
- `README.md` — the concept and the map.
