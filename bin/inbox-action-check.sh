#!/usr/bin/env bash
# inbox-action-check.sh — emit the inbox items that need the sweep's attention.
# Fires the "Vault inbox action sweep" cron when non-empty.
#
# Surfaces (one line each, tab-separated "kind<TAB>path"):
#   - 00.01 handoffs: `action: pending` + a checked box       -> do the action
#   - 00.02 intake:   `status: new`      + a checked box       -> route it
#   - 00.03 tickets:  a checked box, unless a run is actively holding it
#   - ticket-syncgap: the UPSTREAM copy has a tick the local copy does not
#   - SYNC-STALE:     the upstream inbox could not be read (blind, not clean)
#
# TICKET CONTRACT (2026-10-17) — the box is the durable signal, status is the claim:
#   * A checked `Execute` stays CHECKED while a run works. If the run dies, the item
#     is still emitted next tick — a tick can no longer be lost by a claim.
#   * `status: working` + a fresh file = a live run → skip.
#   * `status: working` + a stale file (> TICKET_CLAIM_TTL, default 1800s) = an
#     abandoned claim → emit, even if the box was unticked.
#   * `status: done` is never emitted.
#
# REMOTE AWARENESS (2026-10-18) — the local vault is the LAST hop of
# Obsidian → Remotely Save → Dropbox → bisync → local. A break in that chain used
# to look identical to "nothing ticked". Now the upstream copy is read directly
# (bin/inbox-remote-state.sh) and:
#   * a tick that exists upstream but not locally emits `ticket-syncgap`
#     (the sweep pulls the upstream file down before doing anything else);
#   * an unreadable/stale upstream snapshot emits `SYNC-STALE` instead of silence.
#
# TICK RECEIPT (2026-10-18) — state/inbox-tick-receipt.json records, per file, the
# checkbox hash and when each state was first/last observed. "Did my tick arrive?"
# becomes a lookup instead of an investigation.
set -uo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[ -r "$SCRIPT_DIR/vault-paths.sh" ] && . "$SCRIPT_DIR/vault-paths.sh"
V="${JDAK_VAULT_ROOT:-$HOME/.openclaw/workspace/Vault}"
WS="${JDAK_WORKSPACE:-$HOME/.openclaw/workspace}"
H="${JDAK_INBOX_HANDOFFS:-$V/00 - INBOX/00.01 - handoffs}"
I="$V/00 - INBOX/00.02 - intake"
T="$V/00 - INBOX/00.03 - tickets"
O="$V/00 - INBOX/00.04 - outbox"
CLAIM_TTL="${TICKET_CLAIM_TTL:-1800}"
REMOTE_STATE="${INBOX_REMOTE_STATE:-$WS/state/inbox-remote.json}"
REMOTE_STALE="${INBOX_REMOTE_STALE_SECS:-2700}"
RECEIPT="${INBOX_TICK_RECEIPT:-$WS/state/inbox-tick-receipt.json}"
SKIP_REMOTE="${INBOX_SKIP_REMOTE:-0}"
NOW=$(date +%s)
shopt -s nullglob

# ---- upstream snapshot (best effort, bounded) ------------------------------
# Remote awareness is optional: a base/instance that does not ship the upstream
# reader (e.g. the generic template) must not report SYNC-STALE just because no
# Dropbox/rclone integration exists. Only gate on it when the reader is present
# or an upstream remote is configured explicitly.
remote_enabled=0
if [ "$SKIP_REMOTE" != "1" ] && [ -x "$SCRIPT_DIR/inbox-remote-state.sh" ]; then
  remote_enabled=1
  INBOX_REMOTE_STATE="$REMOTE_STATE" "$SCRIPT_DIR/inbox-remote-state.sh" >/dev/null 2>&1 || true
fi
[ -n "${INBOX_REMOTE:-}" ] && remote_enabled=1

remote_ok=0
remote_ts=0
if [ -r "$REMOTE_STATE" ]; then
  read -r remote_ts remote_ok < <(python3 - "$REMOTE_STATE" <<'PY' 2>/dev/null || echo "0 0"
import json,sys
d=json.load(open(sys.argv[1]))
print(int(d.get("ts",0)), 1 if d.get("ok") else 0)
PY
)
fi

emit() { printf '%s\t%s\n' "$1" "$2"; }

# A move raced the sync: if the processed copy is already in the outbox, the
# checked source is stale and must never be re-emitted.
has_outbox_twin() { [ -f "$O/$(basename "$1")" ]; }

# SELF-HEAL: delete the phantom copies themselves (twin done -> work is finished).
# Deterministic, no model call; runs on every check/gate tick. Without this the
# has_outbox_twin guard suppresses the item forever and the stale note sits in
# the inbox looking unprocessed. Skip in the trigger-eval hot path only if asked.
if [ -x "$SCRIPT_DIR/inbox-twin-cleanup.sh" ] && [ "${INBOX_TWIN_CLEANUP:-1}" != "0" ]; then
  bash "$SCRIPT_DIR/inbox-twin-cleanup.sh" >/dev/null 2>&1 || true
fi

# ---- 1) handoffs: action pending + a checked box ---------------------------
for f in "$H"/*.md; do
  [ -f "$f" ] || continue
  has_outbox_twin "$f" && continue

  # SELF-CLOSE: a ticked "Mark as read" is a DISMISS, not an action. Handled here so a
  # handoff without `action: pending` still closes instead of sitting in the inbox.
  if [ -x "$SCRIPT_DIR/inbox-close-request.sh" ] && [ "${INBOX_AUTOCLOSE:-1}" != "0" ]; then
    bash "$SCRIPT_DIR/inbox-close-request.sh" "$f" >/dev/null 2>&1 && continue
  fi

  grep -q '^action: pending' "$f" 2>/dev/null || continue
  grep -qE '^- \[[xX]\]' "$f" 2>/dev/null && emit handoff "$f"
done

# ---- 2) intake: status new + a checked box --------------------------------
for f in "$I"/*.md; do
  [ -f "$f" ] || continue
  has_outbox_twin "$f" && continue

  if [ -x "$SCRIPT_DIR/inbox-close-request.sh" ] && [ "${INBOX_AUTOCLOSE:-1}" != "0" ]; then
    bash "$SCRIPT_DIR/inbox-close-request.sh" "$f" >/dev/null 2>&1 && continue
  fi

  grep -qE '^status: new' "$f" 2>/dev/null || continue
  grep -qE '^- \[[xX]\]' "$f" 2>/dev/null && emit intake "$f"
done

# ---- 3) tickets: checked box, unless a live run holds it ------------------
for f in "$T"/*.md; do
  [ -f "$f" ] || continue
  has_outbox_twin "$f" && continue
  st=$(grep -m1 '^status:' "$f" 2>/dev/null | sed 's/^status:[[:space:]]*//; s/[[:space:]]*$//')
  [ "$st" = "done" ] && continue

  # SELF-CLOSE: a ticked box under a close-intent heading means "move to outbox".
  # Deterministic, no model call (bin/inbox-close-request.sh). Handled tickets are
  # moved local+upstream here and never emitted, so they cost nothing.
  if [ -x "$SCRIPT_DIR/inbox-close-request.sh" ] && [ "${INBOX_AUTOCLOSE:-1}" != "0" ]; then
    bash "$SCRIPT_DIR/inbox-close-request.sh" "$f" >/dev/null 2>&1 && continue
  fi
  mtime=$(stat -c %Y "$f" 2>/dev/null || echo 0)
  age=$(( NOW - mtime ))

  # LIVE TICKET (mode: live) — the chat owns it. The sweep stands down while the file is
  # warm; if the conversation goes quiet past LIVE_TTL (default 6h) the sweep takes it
  # back, so a live ticket cannot be lost by walking away.
  mode=$(grep -m1 '^mode:' "$f" 2>/dev/null | sed 's/^mode:[[:space:]]*//; s/[[:space:]]*$//')
  if [ "$mode" = "live" ] && [ "$age" -lt "${LIVE_TTL:-21600}" ]; then continue; fi
  checked=0
  grep -qE '^- \[[xX]\]' "$f" 2>/dev/null && checked=1

  if [ "$st" = "working" ]; then
    [ "$checked" -eq 1 ] && [ "$age" -lt "$CLAIM_TTL" ] && continue
    [ "$checked" -eq 0 ] && [ "$age" -lt "$CLAIM_TTL" ] && continue
    emit ticket "$f"
    continue
  fi

  [ "$checked" -eq 1 ] && emit ticket "$f"
done

# ---- 4) upstream ticks the local vault does not have ----------------------
if [ "$remote_ok" = "1" ] && [ -r "$REMOTE_STATE" ]; then
  python3 - "$REMOTE_STATE" "$V" "$T" "$H" "$I" <<'PY' 2>/dev/null
import json,re,sys,os
state,root,T,H,I = sys.argv[1:6]
d=json.load(open(state))
for rel,meta in (d.get("files") or {}).items():
    if not meta.get("checked"): continue
    if not rel.startswith("00 - INBOX/00.03 - tickets/"): continue
    local=os.path.join(root,rel)
    if not os.path.exists(local): continue
    if os.path.exists(os.path.join(root,"00 - INBOX/00.04 - outbox",os.path.basename(local))): continue
    try: raw=open(local,encoding="utf-8",errors="replace").read()
    except OSError: continue
    local_checked=bool(re.search(r"^\s*[-*]\s*\[[xX]\]",raw,re.M))
    if not local_checked:
        print(f"ticket-syncgap\t{local}")
PY
fi

# ---- 5) silence must mean "checked", not "couldn't check" -----------------
if [ "$remote_enabled" = "1" ] && { [ "$remote_ok" != "1" ] || [ $(( NOW - remote_ts )) -gt "$REMOTE_STALE" ]; }; then
  age=$(( NOW - remote_ts ))
  msg="upstream inbox snapshot ${age}s old"
  [ "$remote_ok" = "1" ] || msg="upstream inbox unreadable"
  emit SYNC-STALE "$msg"
fi

# ---- receipt ledger -------------------------------------------------------
python3 - "$V" "$RECEIPT" "$NOW" <<'PY' 2>/dev/null || true
import json,re,sys,os,hashlib
root,receipt,now = sys.argv[1], sys.argv[2], int(sys.argv[3])
dirs=["00 - INBOX/00.01 - handoffs","00 - INBOX/00.02 - intake","00 - INBOX/00.03 - tickets"]
try: prev=json.load(open(receipt))
except Exception: prev={}
cur={}
for d in dirs:
    p=os.path.join(root,d)
    if not os.path.isdir(p): continue
    for name in sorted(os.listdir(p)):
        if not name.endswith(".md"): continue
        rel=f"{d}/{name}"
        try: raw=open(os.path.join(p,name),encoding="utf-8",errors="replace").read()
        except OSError: continue
        boxes="\n".join(l for l in raw.splitlines() if re.match(r"^\s*[-*]\s*\[[ xX]\]",l))
        h=hashlib.sha256(boxes.encode()).hexdigest()[:16]
        checked=1 if re.search(r"^\s*[-*]\s*\[[xX]\]",raw,re.M) else 0
        old=prev.get(rel) or {}
        cur[rel]={"checked":checked,"hash":h,
                  "first_seen":old.get("first_seen",now) if old.get("hash")==h else now,
                  "last_seen":now,
                  "state_since":old.get("state_since",now) if old.get("checked")==checked else now}
json.dump(cur,open(receipt,"w"),indent=1,sort_keys=True)
PY

exit 0
