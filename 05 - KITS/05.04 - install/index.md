---
title: Install JDAK
created: 2026-10-11
updated: 2026-10-28
type: schema
kind: fact
status: active
authority: authoritative
tags: [meta, install, schema]
---

# Install JDAK

**What you're installing:** an agent-growable Obsidian vault (the JDAK template) **plus** the hooks that
wire it to an agent (OpenClaw, Hermes, …). Two audiences: **the human** (A–C) and **the agent** (D).

> `$WS` = the agent workspace (`~/.openclaw/workspace`). `$VAULT` = `$WS/Vault`. **The vault is the source
> of truth** — the agent's own instruction files, skills, and state live *inside* it (see D1).

## Prerequisites

- **Obsidian** (desktop + mobile).
- **Dropbox** (the sync relay) — desktop + mobile apps.
- `git` + the **GitHub CLI** (`gh`, signed in) — it creates your private repo from the template in Part B.
- `rclone` (`~/.local/bin/rclone`) with a `dropbox` remote.
- **Python 3** (stdlib only — no pip packages needed).
- An agent (OpenClaw) with a workspace and a `skills/` dir.

---

## Part A · The human

1. Install **Obsidian** on desktop and mobile.
2. Install the **Dropbox** app (desktop + mobile); sign in.
3. Have the **GitHub CLI** (`gh`) installed and signed in (`gh auth login`) — it creates the private
   repository for you in Part B, so you do not make one by hand.
4. Note the **Dropbox app folder** the vault lives in — this stack uses
   `Dropbox:Apps/remotely-save/jdak-stack`.

## Part B · Get the vault in place — the template *is* the installer

One command does acquisition: it creates **your own private repo** from the template and clones it, with
`origin` already pointing at your repository.

```bash
export WS="$HOME/.openclaw/workspace"
export VAULT="$WS/Vault"
mkdir -p "$WS" && cd "$WS"

gh repo create my-jdak --template your-org/jdak-template --private --clone
mv my-jdak "$VAULT"
cd "$VAULT"
git status                                                   # clean, one commit
```

GitHub's template flow gives this a property a plain `clone` does not: the new repository starts with **one
independent commit** — the template's files and folder structure, without JDAK's development history. That
is the separation this stack wants: **acquisition** is the `gh` command above, **machine setup** is the
check-first bootstrap in Parts C–D, which runs from files you can now read and rerun.

**Fallbacks** (no `gh`, or you prefer the browser):

- **Use this template** on the repo page → creates *your* private repo with the single-commit history, then
  `git clone git@github.com:<you>/<your-repo>.git "$VAULT"`. Nothing else to fix up.
- **Plain clone** of the template — you inherit JDAK's history, so re-point the remotes:
  ```bash
  git clone https://github.com/your-org/jdak-template.git "$VAULT"
  cd "$VAULT"
  git remote rename origin template
  git remote add origin git@github.com:<you>/<your-vault>.git
  git push -u origin main
  ```

Never `curl | bash` an installer for this. The acquisition step is a supported GitHub command, and every
setup script it leads to is a file in the repo you now own.

## Part C · Sync (vault ↔ Dropbox ↔ Obsidian) — the real scripts

**This is the post-clone bootstrap.** Every step below is a plain, rerunnable command — copy, install,
verify — with nothing hidden behind a remote installer. Re-run any of it any time; it reports what it could
not configure instead of failing silently.

The sync is **four scripts + one unit**, all vendored in `bin/`:

| File | Job |
|---|---|
| `bin/vault-paths.sh` | **Single source of truth** for paths (`JDAK_VAULT_ROOT`). Edit one line when the vault moves. |
| `bin/rclone-vault.filters` | What syncs (md/txt/html/pdf/images/csv; excludes `.git`, `09 - FLEETING`, caches). |
| `bin/vault-sync.sh` | Two-way `rclone bisync`, **preserve-both + 3-way agent merge** (never newer-wins). Git snapshot first. |
| `bin/vault-conflict-merge.py` | 3-way merge on conflict; escalates ambiguity to `logs/vault-sync-alert.json`. |
| `bin/vault-sync-watch.py` | **Event-driven watcher**: local mtime scan + Dropbox cursor poll → fires the sync on change. |
| `bin/systemd/vault-sync-watch.service` | systemd **user** unit that keeps the watcher running (survives logout with Linger). |

**1. rclone remote:**
```bash
rclone config create dropbox dropbox        # follow the OAuth prompt
```

**2. Install the sync runtime** — copy every runtime dependency into the workspace before invoking it:

```bash
mkdir -p "$WS/bin" "$HOME/.config/systemd/user"
install -m 0755 "$VAULT/bin/vault-sync.sh" "$VAULT/bin/vault-conflict-merge.py" \
  "$VAULT/bin/vault-sync-watch.py" "$WS/bin/"
install -m 0644 "$VAULT/bin/vault-paths.sh" "$VAULT/bin/rclone-vault.filters" "$WS/bin/"
install -m 0644 "$VAULT/bin/systemd/vault-sync-watch.service" "$HOME/.config/systemd/user/"

bash -n "$WS/bin/vault-sync.sh" "$WS/bin/vault-paths.sh"
python3 -m py_compile "$WS/bin/vault-conflict-merge.py" "$WS/bin/vault-sync-watch.py"
systemd-analyze --user verify "$HOME/.config/systemd/user/vault-sync-watch.service"
```

Set `JDAK_VAULT_ROOT` in `~/.openclaw/.env` if the vault is not at `$WS/Vault`.

**3. First sync + baseline:**
```bash
$WS/bin/vault-sync.sh            # first run may need: rclone bisync … --resync (once)
```

**4. Schedule (backstop) + event-driven watcher:**
```bash
# backstop: every 15 min
*/15 * * * * $WS/bin/vault-sync.sh >/dev/null 2>&1

# event-driven (recommended): user systemd unit installed in step 2
systemctl --user daemon-reload && systemctl --user enable --now vault-sync-watch.service
loginctl enable-linger "$USER"     # keep it running after logout
```
The watcher syncs **within seconds** of a change in either direction; the cron stays as a safety net.
Tune: `WATCH_DEBOUNCE` (20s), `WATCH_MIN_INTERVAL` (120s), `WATCH_POLL` (5s), `WATCH_REMOTE_POLL` (30s).
Log: `$WS/logs/vault-sync-watch.log`. Kill a stuck rclone by PID (`pkill -x rclone`).

**5. Obsidian — two community plugins (mobile *and* desktop):**

> [!warning] Required
> **Remotely Save** — add your **Dropbox** remote, point it at the **same folder**
> (`Apps/remotely-save/jdak-stack`), enable Dropbox sync. *This is the Obsidian ↔ Dropbox hop; its
> auto-save interval is the end-to-end latency for your edits.*
>
> **Templater** — *Settings → Templater → **Folder Templates***: map
> **`00 - INBOX/00.02 - intake`** → **`05 - KITS/05.02 - templates/intake.md`**, trigger **on new file
> creation**. This auto-numbers each intake (`00.02.NN - <Weekday M-D> capture`; the sweep renames it
> descriptively). The **core Templates plugin will not work** — the template uses `<% %>` +
> `tp.file.rename()`.

## Part D · Wire the agent

### D1 · Vendor the system files in `99 - META`

The vault is the **source of truth**, so the agent's instruction files live in **`99 - META/`** and are
**symlinked** back into the workspace:

```
99 - META/
├── AGENTS.md  SOUL.md  IDENTITY.md  USER.md  MEMORY.md  TOOLS.md
└── *-state.json        # runtime ledgers
```

```bash
mkdir -p "$VAULT/99 - META"
mv "$WS"/{AGENTS.md,SOUL.md,IDENTITY.md,USER.md,MEMORY.md,TOOLS.md} "$VAULT/99 - META/" 2>/dev/null || true
for f in AGENTS.md SOUL.md IDENTITY.md USER.md MEMORY.md TOOLS.md; do
  ln -sfn "Vault/99 - META/$f" "$WS/$f"
done
```
Edit the vault copy; the symlink picks it up; it syncs to your phone. *(Already done in this instance.)*

### D2 · `TOOLS.md` — your local cheat sheet

`99 - META/TOOLS.md` is where **environment specifics** go (never in skills). Build it as you wire
things up:

1. **Sync** — the vault path, the Dropbox remote/path, the watcher service name, where the logs are.
2. **Secrets pointers** — one line per service: *which file* holds its key (`secrets/airtable.key`), never
   the value.
3. **MCP servers** — the names registered in `openclaw.json`.
4. **Skills** — which are symlinked, and from where.
5. **Machine specifics** — SSH hosts, device names, TTS voice, browser/CDP notes.
6. **Conventions** — voice/sync rules you want the agent to remember.

> Rule of thumb: **if it's "how this machine is set up", it's `TOOLS.md`; if it's "how to do the task,
> it's a skill.**

### D3 · MCP servers → `~/.openclaw/openclaw.json`

Add each under `mcp.servers` (key in `headers`, never in the repo):

```json
{ "mcp": { "servers": {
  "hunter": { "command": "npx", "args": ["-y", "mcp-remote", "https://mcp.hunter.io/sse"],
              "headers": { "X-API-Key": "<your-key>" } }
}}}
```

### D4 · Secrets → `$WS/secrets/`

One JSON/key file per service, `chmod 600`. Record a **pointer list** in `TOOLS.md` — never the values.

### D5 · Skills → vendor + symlink

The vault ships its generic management kit as skills marked `base: true`. Numbering organizes the
shelf; it does not decide what ships. Skills marked `base: false` stay in the instance.

```bash
mkdir -p "$WS/skills"
while IFS= read -r -d '' skill_file; do
  skill_dir=${skill_file%/SKILL.md}
  skill_name=${skill_dir##*/}
  skill_name=${skill_name#* - }       # strip an optional Johnny Decimal prefix
  ln -sfn "$skill_dir" "$WS/skills/$skill_name"
done < <(grep -rlZx --include=SKILL.md 'base: true' "$VAULT/07 - SKILLS")

find "$WS/skills" -mindepth 1 -maxdepth 1 -type l -printf '%f -> %l\n' | sort
```

### D6 · Loops + schedulers

Register the recurring jobs with the agent's scheduler (or crontab): the sync backstop, the weekly vault
triage, the dictation processor, and each **loop** (`06 - LOOPS/NN.MM - <loop>/LOOP.md` says *what*; the
schedule says *when*).

### D7 · Email (optional)

Wire the sending mailbox via `himalaya`. Gmail/Workspace needs a 16-char **App Password** (2SV must be on)
— the account password won't work.

## Part E · Verify

```bash
cd "$VAULT" && git status                     # clean
$WS/bin/vault-sync.sh && echo ok              # bisync exit 0
systemctl --user is-active vault-sync-watch   # active
test -L "$WS/skills/checkbox-runner" && test -e "$WS/skills/checkbox-runner/SKILL.md"
```

- Ask the agent to **read** a vault file and **write** a test note.
- Check the note appears on your phone (Obsidian → Remotely Save → sync).
- Edit a note on the phone; confirm it lands in the vault within ~a minute.

## Template vs instance

This repo **is** the template. When forking: strip the owner's instance content (projects, dictations,
drafts, `99 - META` personal state), keep the schema + kits + scripts + skills. See `TEMPLATE.md`.

## Related

- `README.md` — the concept + map + **Getting started**.
- `SCHEMA.md` — the rules the agent follows.
- `TEMPLATE.md` — base vs instance, and what to strip.
