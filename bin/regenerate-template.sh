#!/usr/bin/env bash
# regenerate-template.sh — rebuild the JDAK **base** template repo from the vault.
#
# The vault is the source of truth; the template repo is a curated BASE (no instance
# content). This script: pulls the repo → wipes it → copies the base file set from the
# vault → genericizes owner names/paths → leak-checks → commits → pushes.
#
#   bash bin/regenerate-template.sh              # regenerate + push
#   PUSH=0 bash bin/regenerate-template.sh       # build + commit locally, do not push
#   TEMPLATE_REPO=git@… TEMPLATE_WORK=/tmp/t bash bin/regenerate-template.sh
#
# Safe to re-run: it always rebuilds from the vault, and no-ops if nothing changed.
set -euo pipefail

WS=${JDAK_WORKSPACE:-$HOME/.openclaw/workspace}
V=${JDAK_VAULT_ROOT:-$WS/Vault}
REPO=${TEMPLATE_REPO:-git@github.com:your-org/jdak-template.git}
WORK=${TEMPLATE_WORK:-$WS/tmp/jdak-template}
BRANCH=${TEMPLATE_BRANCH:-main}
PUSH=${PUSH:-1}

command -v git >/dev/null || { echo "git required"; exit 1; }
[ -d "$V" ] || { echo "vault not found: $V"; exit 1; }

echo "==> template repo: $REPO ($BRANCH)"
echo "==> vault: $V"

# 1) clone or refresh
if [ -d "$WORK/.git" ]; then
  git -C "$WORK" fetch -q origin
  git -C "$WORK" checkout -q "$BRANCH"
  git -C "$WORK" reset -q --hard "origin/$BRANCH"
else
  rm -rf "$WORK"; git clone -q -b "$BRANCH" "$REPO" "$WORK"
fi

cd "$WORK"

# 2) wipe everything except .git
git rm -rq --ignore-unmatch . >/dev/null 2>&1 || true
find . -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} + 2>/dev/null || true

# 3) skeleton
mkdir -p "00 - INBOX/00.01 - handoffs" "00 - INBOX/00.02 - intake" "00 - INBOX/00.03 - tickets" \
         "00 - INBOX/00.04 - outbox" "01 - PROJECTS" "02 - AREAS" "03 - PERMANENT" \
         "04 - RESOURCES" "05 - KITS" "06 - LOOPS" "07 - SKILLS" "08 - PRODUCTION" \
         "09 - FLEETING" "10 - ARCHIVE" "99 - META" bin/systemd

# 4) base files
cp "$V/README.md" "$V/SCHEMA.md" "$V/TEMPLATE.md" .
cp "$V/.gitignore" . 2>/dev/null || true
: > BALLS.md; : > INBOX.md; : > index.md; : > log.md

cp "$V/00 - INBOX/README.md" "00 - INBOX/"
cp "$V/00 - INBOX/00.02 - intake/README.md" "00 - INBOX/00.02 - intake/"
cp "$V/00 - INBOX/00.03 - tickets/README.md" "00 - INBOX/00.03 - tickets/"
: > "00 - INBOX/00.01 - handoffs/.gitkeep"; : > "00 - INBOX/00.04 - outbox/.gitkeep"

for d in "01 - PROJECTS" "02 - AREAS" "03 - PERMANENT" "04 - RESOURCES" "06 - LOOPS" \
         "08 - PRODUCTION" "09 - FLEETING" "10 - ARCHIVE" "99 - META"; do
  cp "$V/$d/README.md" "$d/"
done

# KITS (folders first, then files)
cp "$V/05 - KITS/README.md" "05 - KITS/"
cp -a "$V/05 - KITS/05.01 - macros" "05 - KITS/"
cp -a "$V/05 - KITS/05.02 - templates" "05 - KITS/"
mkdir -p "05 - KITS/05.03 - scripts"
cp "$V/05 - KITS/05.03 - scripts/gen-index.py" "05 - KITS/05.03 - scripts/"
cp -a "$V/05 - KITS/05.04 - install" "05 - KITS/"
mkdir -p "05 - KITS/05.05 - feedback/examples"
cp "$V/05 - KITS/05.05 - feedback/README.md" "$V/05 - KITS/05.05 - feedback/rubric.md" \
   "$V/05 - KITS/05.05 - feedback/rules.md" "05 - KITS/05.05 - feedback/"
: > "05 - KITS/05.05 - feedback/feedback.md"; : > "05 - KITS/05.05 - feedback/examples/.gitkeep"
cp "$V/05 - KITS/05.06 - qball.md" "$V/05 - KITS/05.07 - skill-handoffs.md" \
   "$V/05 - KITS/05.08 - compact.md" "$V/05 - KITS/05.09 - inbox-message-playbook.md" "05 - KITS/"

# SKILLS — the management kit ships; instance skills do not
cp "$V/07 - SKILLS/README.md" "07 - SKILLS/"
for s in "07.03 - loop-studio" "07.07 - checkbox-runner" "07.08 - project-boot" \
         "07.09 - project-status" "vault-keeper" "qball-router"; do
  [ -d "$V/07 - SKILLS/$s" ] && cp -a "$V/07 - SKILLS/$s" "07 - SKILLS/"
done

# bin/ — the sync stack (base)
for f in vault-sync.sh vault-paths.sh vault-conflict-merge.py vault-sync-watch.py \
         inbox-action-check.sh rclone-vault.filters regenerate-template.sh; do
  [ -f "$WS/bin/$f" ] && cp "$WS/bin/$f" bin/
done
[ -f "$WS/bin/systemd/vault-sync-watch.service" ] && cp "$WS/bin/systemd/vault-sync-watch.service" bin/systemd/

# 5) genericize (base must not name the owner)
python3 - "$WORK" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
REPL = [
    ("your-publish-blog", "your-publish-blog"),
    ("your-engineering-blog", "your-engineering-blog"),
    ("your-org", "your-org"),
    ("$HOME", "$HOME"),
    ("the owner's", "the owner's"),
    ("owner-", "owner-"),
    ("new-to-owner", "new-to-owner"),
    ("the owner", "the owner"),
    ("the owner's", "the owner's"),
]
changed = 0
for p in root.rglob("*"):
    if ".git" in p.parts or not p.is_file():
        continue
    if p.suffix not in (".md", ".py", ".sh", ".service", ".filters", ".json", ""):
        continue
    try:
        s = p.read_text()
    except Exception:
        continue
    o = s
    for a, b in REPL:
        s = s.replace(a, b)
    if s != o:
        p.write_text(s); changed += 1
print("genericized files:", changed)
PY

# 6) leak check — base must be owner-agnostic
if grep -rIl -e "your-org" -e "$HOME" -e "\bthe owner\b" . --exclude-dir=.git 2>/dev/null | grep -q .; then
  echo "FAIL: owner-specific references remain:" >&2
  grep -rIl -e "your-org" -e "$HOME" -e "\bthe owner\b" . --exclude-dir=.git >&2
  exit 1
fi

# 7) commit + push
git add -A
if git diff --cached --quiet; then
  echo "==> no changes (template already matches the vault base)"
else
  git commit -q -m "Regenerate JDAK base from vault ($(date +%F))"
  echo "==> committed $(git rev-parse --short HEAD)"
fi

if [ "$PUSH" = "1" ]; then
  git push -q origin "HEAD:$BRANCH"
  echo "==> pushed to $BRANCH: $(git rev-parse --short HEAD)"
else
  echo "==> PUSH=0 — not pushed"
fi

echo "==> files: $(git ls-files | wc -l) · head: $(git rev-parse --short HEAD)"
