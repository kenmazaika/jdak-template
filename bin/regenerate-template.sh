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
# Scoped build (for a focused PR when the vault carries unrelated unshipped drift):
#   SCOPE_PATHS=$'README.md\n05 - KITS/05.04 - install/index.md' bash bin/regenerate-template.sh
#   SCOPE_FILE=runs/2026-10-24/scope.txt bash bin/regenerate-template.sh
#   The build still runs from the vault, then every changed path outside the scope is
#   restored to origin/<branch> (or dropped if new). Result: diff == scope, nothing hand-edited.
#   A trailing "/" in a scope entry authorizes a whole directory.
#   SCOPE_STRICT=1 with an empty scope = drop every change (self-test: expect "no changes").
#
# Safe to re-run: it always rebuilds from the vault, and no-ops if nothing changed.
set -euo pipefail

WS=${JDAK_WORKSPACE:-$HOME/.openclaw/workspace}
V=${JDAK_VAULT_ROOT:-$WS/Vault}
REPO=${TEMPLATE_REPO:-git@github.com:your-org/jdak-template.git}
WORK=${TEMPLATE_WORK:-$WS/tmp/jdak-template}
BRANCH=${TEMPLATE_BRANCH:-main}
PUSH=${PUSH:-1}

# SCOPE_FILE is caller-relative; resolve it before we cd into the template clone.
if [ -n "${SCOPE_FILE:-}" ]; then
  case "$SCOPE_FILE" in
    /*) ;;
    *) SCOPE_FILE="$PWD/$SCOPE_FILE" ;;
  esac
fi

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
cp "$V/README.md" "$V/SCHEMA.md" "$V/TEMPLATE.md" "$V/CONTRIBUTING.md" .
cp "$V/.gitignore" . 2>/dev/null || true
git show "origin/$BRANCH:LICENSE" > LICENSE 2>/dev/null || true
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

# SKILLS — ship only skills that declare `base: true` in SKILL.md frontmatter.
# Numbering is a shelf convention, not a shipping promise: a numbered skill can still be instance-bound.
# The base README is generated from README.base.md so instance skills are never advertised.
if [ -f "$V/07 - SKILLS/README.base.md" ]; then
  cp "$V/07 - SKILLS/README.base.md" "07 - SKILLS/README.md"
else
  cp "$V/07 - SKILLS/README.md" "07 - SKILLS/"
fi
python3 - "$V/07 - SKILLS" "07 - SKILLS" <<'PY'
import pathlib, re, shutil, sys
src, dst = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
shipped = []
for d in sorted(src.iterdir()):
    f = d / "SKILL.md"
    if not d.is_dir() or not f.is_file():
        continue
    head = f.read_text(encoding="utf-8", errors="replace")[:800]
    if re.search(r"^base:\s*true\s*$", head, re.M):
        shutil.copytree(d, dst / d.name, dirs_exist_ok=True)
        shipped.append(d.name)
print("shipped skills:", ", ".join(shipped) or "(none)")
PY

# bin/ — the sync stack (base)
for f in vault-sync.sh vault-paths.sh vault-conflict-merge.py vault-sync-watch.py \
         inbox-action-check.sh inbox-close-request.sh inbox-live-open.sh rclone-vault.filters regenerate-template.sh; do
  [ -f "$WS/bin/$f" ] && cp "$WS/bin/$f" bin/
done
[ -f "$WS/bin/systemd/vault-sync-watch.service" ] && cp "$WS/bin/systemd/vault-sync-watch.service" bin/systemd/

# 5) genericize (base must not name the owner)
python3 - "$WORK" <<'PY'
import pathlib, sys
root = pathlib.Path(sys.argv[1])
REPL = [
    ("JDAK contributors", "JDAK contributors"),
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

# 6b) optional scope filter — keep the generated diff inside the run's declared scope
SCOPE_LIST=()
if [ -n "${SCOPE_FILE:-}" ]; then
  [ -f "$SCOPE_FILE" ] || { echo "scope file not found: $SCOPE_FILE" >&2; exit 1; }
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}; line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue
    case "$line" in \#*) continue;; esac
    SCOPE_LIST+=("${line#./}")
  done < "$SCOPE_FILE"
fi
if [ -n "${SCOPE_PATHS:-}" ]; then
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%$'\r'}; line="${line#"${line%%[![:space:]]*}"}"; line="${line%"${line##*[![:space:]]}"}"
    [ -z "$line" ] && continue
    SCOPE_LIST+=("${line#./}")
  done <<< "$SCOPE_PATHS"
fi

git add -A

if [ "${#SCOPE_LIST[@]}" -gt 0 ] || [ "${SCOPE_STRICT:-0}" = "1" ]; then
  in_scope() {
    local p="$1" s
    for s in ${SCOPE_LIST[@]+"${SCOPE_LIST[@]}"}; do
      [ "$p" = "$s" ] && return 0
      case "$s" in
        */) case "$p" in "$s"*) return 0;; esac;;
      esac
    done
    return 1
  }

  dropped=0; dropped_names=()
  mapfile -t _changed < <(git diff --cached --name-only)
  for p in ${_changed[@]+"${_changed[@]}"}; do
    [ -z "$p" ] && continue
    in_scope "$p" && continue
    if git cat-file -e "origin/$BRANCH:$p" 2>/dev/null; then
      git checkout -q "origin/$BRANCH" -- "$p"
    else
      git rm -q --cached --ignore-unmatch -- "$p" >/dev/null 2>&1 || true
      rm -f -- "$p"
    fi
    dropped_names+=("$p"); dropped=$((dropped + 1))
  done

  echo "==> scope: ${#SCOPE_LIST[@]} authorized path(s); dropped $dropped out-of-scope change(s)"
  for p in ${dropped_names[@]+"${dropped_names[@]}"}; do echo "    - dropped: $p"; done

  mapfile -t _final < <(git diff --cached --name-only)
  for s in ${SCOPE_LIST[@]+"${SCOPE_LIST[@]}"}; do
    case "$s" in */) continue;; esac
    found=0
    for p in ${_final[@]+"${_final[@]}"}; do [ "$p" = "$s" ] && found=1 && break; done
    [ "$found" = "1" ] || echo "==> WARN: scoped path has no change: $s" >&2
  done
fi

# 7) commit + push
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
