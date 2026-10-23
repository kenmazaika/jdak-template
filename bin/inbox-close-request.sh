#!/usr/bin/env bash
# inbox-close-request.sh — a ticket that asks to be closed, closes itself.
#
# WHY: the owner adds a close-intent section to a ticket (e.g. "## Close") with a checkbox. Ticking
# that box means "I'm done with this — move it to the outbox." That should not cost a
# model run, and it should not wait for a sweep to interpret prose. It is a mechanical
# move: local -> 00.04 outbox, plus the upstream delete so Obsidian doesn't re-upload it.
#
# RULE (deterministic, no model call)
#   Close when a CHECKED box sits under a heading that means "close" — or when the
#   checked box's own text says it. Matching is case-insensitive over:
#     close · outbox · archive · done · mark as read
#   The heading list is overridable: INBOX_CLOSE_HEADINGS='close|outbox|archive'
#   (a value set to `0` disables the whole feature).
#
# USAGE:  bash bin/inbox-close-request.sh "<absolute path in 00.01 | 00.02 | 00.03>"
# EXIT:   0 = closed (moved + upstream deleted) · 1 = nothing to do / refused
#
# A "Mark as read" tick is a DISMISS, not an action: it closes the note even when the
# note carries no `action: pending` (that missing gate is why handoff dismissals used
# to sit in the inbox forever).
#
# SAFETY
#   * Only touches 00.01 handoffs, 00.02 intake, 00.03 tickets. Never the outbox.
#   * Never overwrites an existing outbox twin.
#   * Skips files touched within INBOX_CLOSE_GRACE seconds (default 60) so an in-flight
#     Obsidian upload is not fought mid-write.
#   * Logs one line per action to logs/inbox-close-request.log; DRY=1 previews.
set -uo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[ -r "$SCRIPT_DIR/vault-paths.sh" ] && . "$SCRIPT_DIR/vault-paths.sh"

V="${JDAK_VAULT_ROOT:-$HOME/.openclaw/workspace/Vault}"
WS="${JDAK_WORKSPACE:-$HOME/.openclaw/workspace}"
H="$V/00 - INBOX/00.01 - handoffs"
I="$V/00 - INBOX/00.02 - intake"
T="$V/00 - INBOX/00.03 - tickets"
O="$V/00 - INBOX/00.04 - outbox"
LOG="$WS/logs/inbox-close-request.log"
GRACE="${INBOX_CLOSE_GRACE:-60}"
PATTERN="${INBOX_CLOSE_HEADINGS:-close|outbox|archive|done|mark[ _-]*as[ _-]*read}"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true
log() { printf '%s %s\n' "$(date -Is)" "$*" >> "$LOG"; }

[ "$PATTERN" = "0" ] && exit 1
f="${1:-}"
[ -f "$f" ] || exit 1
src_dir=""
case "$f" in
  "$H"/*.md) src_dir="00 - INBOX/00.01 - handoffs" ;;
  "$I"/*.md) src_dir="00 - INBOX/00.02 - intake" ;;
  "$T"/*.md) src_dir="00 - INBOX/00.03 - tickets" ;;
  *) log "REFUSED (not an inbox source): $f"; exit 1 ;;
esac

mtime=$(stat -c %Y "$f" 2>/dev/null || echo 0)
[ $(( $(date +%s) - mtime )) -lt "$GRACE" ] && exit 1

# Detection: does a checked box live under a close-intent heading (or say it itself)?
python3 - "$f" "$PATTERN" <<'PY'
import re,sys
path,pat = sys.argv[1], sys.argv[2]
raw = open(path, encoding="utf-8", errors="replace").read().splitlines()
rx = re.compile(pat, re.I)
heading = ""
heading_hits = False
for line in raw:
    m = re.match(r"^\s{0,3}(#{1,6})\s*(.+?)\s*$", line)
    if m:
        heading = m.group(2)
        heading_hits = bool(rx.search(heading))
        continue
    b = re.match(r"^\s*[-*]\s*\[([ xX])\]\s*(.*)$", line)
    if not b:
        continue
    if b.group(1).lower() != "x":
        continue
    if heading_hits or rx.search(b.group(2)):
        sys.exit(0)
sys.exit(1)
PY
[ $? -eq 0 ] || exit 1

base=$(basename "$f")
dest="$O/$base"
[ -e "$dest" ] && { log "skip (outbox twin exists): $base"; exit 1; }

if [ "${DRY:-0}" = "1" ]; then
  log "DRY would close: $base"
  exit 0
fi

# Mark terminal in place, then move.
python3 - "$f" <<'PY'
import re,sys,datetime
p=sys.argv[1]
s=open(p,encoding="utf-8",errors="replace").read()
today=datetime.date.today().isoformat()
if re.search(r"^status:", s, re.M):
    s=re.sub(r"^status:.*$", "status: done", s, count=1, flags=re.M)
elif s.startswith("---\n"):
    s=s.replace("---\n","---\nstatus: done\n",1)
# handoffs carry `action:` — mark it terminal too so twin-cleanup recognises it
if re.search(r"^action:.*$", s, re.M):
    s=re.sub(r"^action:.*$", "action: done", s, count=1, flags=re.M)
if re.search(r"^updated:", s, re.M):
    s=re.sub(r"^updated:.*$", f"updated: {today}", s, count=1, flags=re.M)
open(p,"w",encoding="utf-8").write(s)
PY

mkdir -p "$O"
if command -v trash >/dev/null 2>&1; then :; fi
mv -f "$f" "$dest" || { log "FAILED move: $base"; exit 1; }
log "closed: $base"

# Close the upstream hop too, or Obsidian re-uploads the original and it comes back.
src_rel="$src_dir/$base"
[ -x "$SCRIPT_DIR/inbox-remote-close.sh" ] && bash "$SCRIPT_DIR/inbox-remote-close.sh" "$src_rel" >/dev/null 2>&1 || true
exit 0
