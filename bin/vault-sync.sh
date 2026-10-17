#!/usr/bin/env bash
# Two-way sync: local Vault  <->  Dropbox:Apps/remotely-save/jdak-stack
#
# CONFLICT POLICY = PRESERVE BOTH, RESOLVED BY FELIX (not by a clock).
#   * bisync runs --conflict-resolve none: it never lets "newer" pick a winner
#     and never discards a version. On a conflict it keeps BOTH as
#     <name>.sync-conflict1 (local) and <name>.sync-conflict2 (remote).
#   * bin/vault-conflict-merge.py then 3-way-merges the two against the last
#     synced base and restores the canonical <name>. Clean merges are silent;
#     anything ambiguous is marker-annotated + escalated (logs/vault-sync-alert.json).
#   * Every run snapshots the vault in git first (version layer under the sync).
#
# Invoked by cron every 15 min. Paths come from bin/vault-paths.sh (single source
# of truth) and stay env-overridable for testing.
set -uo pipefail
export PATH=/home/matthew/.local/bin:/home/matthew/.hermes/node/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# Load the single source of truth for vault paths (edit bin/vault-paths.sh when the vault moves).
[ -r "$SCRIPT_DIR/vault-paths.sh" ] && . "$SCRIPT_DIR/vault-paths.sh"

RCLONE=${RCLONE:-/home/matthew/.local/bin/rclone}
CFG=${CFG:-/home/matthew/.config/rclone/rclone.conf}
WS=${WS:-${JDAK_WORKSPACE:-/home/matthew/.openclaw/workspace}}
SRC=${SRC:-${JDAK_VAULT_ROOT:-$WS/Vault}}
DST=${DST:-${JDAK_DROPBOX_DEST:-dropbox:Apps/remotely-save/jdak-stack}}
FILT=${FILT:-$SCRIPT_DIR/rclone-vault.filters}
LOG=${LOG:-$WS/logs/jdak-bisync.log}
STATE=${STATE:-$WS/logs/vault-sync-state.json}
ALERT=${ALERT:-$WS/logs/vault-sync-alert.json}
REPORT=${REPORT:-$WS/logs/vault-sync-report.json}
STATEDIR=${STATEDIR:-/home/matthew/.local/state/vault-sync}
BACKUP1=${BACKUP1:-$STATEDIR/backup-path1}
REVIEW=${REVIEW:-$STATEDIR/review}
MERGE=${MERGE:-$SCRIPT_DIR/vault-conflict-merge.py}
GIT=${GIT:-/usr/bin/git}
PY=${PY:-/usr/bin/python3}
MAX_DELETE=${MAX_DELETE:-50}
GIT_ID=(-c user.email=felix@openclaw.local -c user.name=Felix)

mkdir -p "$(dirname "$LOG")" "$BACKUP1" "$REVIEW"
log() { echo "===== $(date -Is) $* =====" >> "$LOG"; }
GITC() { "$GIT" -C "$SRC" "$@"; }

alert() { # $1=kind  $2=summary
  "$PY" - "$ALERT" "$1" "$2" <<'PYEOF'
import json, os, sys, time
path, kind, summary = sys.argv[1], sys.argv[2], sys.argv[3]
ev = {"ts": time.strftime("%Y-%m-%dT%H:%M:%S%z"), "kind": kind, "summary": summary}
data = []
if os.path.exists(path):
    try:
        data = json.load(open(path))
    except Exception:
        data = []
data.append(ev)
json.dump(data, open(path, "w"), indent=2)
PYEOF
}

# --- 0. manual pause (used during big vault reorgs so bisync never runs mid-move) ---
if [ -e "$WS/logs/vault-sync.pause" ]; then
  log "sync paused ($WS/logs/vault-sync.pause present) — skipping this run"
  exit 0
fi

log "sync run start (policy=preserve-both)"
mrc=0

# --- 0a. serialize: only ONE vault-sync at a time (a manual run racing the 15-min cron
#         would collide on rclone's bisync lock and fail one of them with rc=1) ---
exec 9>"$WS/logs/vault-sync.runlock"
if ! flock -n 9; then
  log "another vault-sync already holds the run lock — skipping this invocation (exit 0)"
  exit 0
fi

# --- 0b. clear stale bisync locks (a .lck whose owning PID is dead blocks every run) ---
LOCKDIR=${LOCKDIR:-$HOME/.cache/rclone/bisync}
if [ -d "$LOCKDIR" ]; then
  for lk in "$LOCKDIR"/*.lck; do
    [ -e "$lk" ] || continue
    lpid=$("$PY" -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get("PID",""))
except Exception: print("")' "$lk" 2>/dev/null)
    if [ -n "$lpid" ] && ! kill -0 "$lpid" 2>/dev/null; then
      log "removing stale bisync lock $lk (dead pid $lpid)"
      rm -f "$lk"
    fi
  done
fi

# --- 1. version layer: snapshot any uncommitted local changes ---
if [ -d "$SRC/.git" ]; then
  if [ -n "$(GITC status --porcelain)" ]; then
    GITC add -A >/dev/null 2>&1
    GITC "${GIT_ID[@]}" commit -q -m "sync snapshot $(date -Is)" >/dev/null 2>&1
  fi
fi
BASE_REF=""
[ -s "$STATE" ] && BASE_REF=$("$PY" -c 'import sys,json;print(json.load(open(sys.argv[1])).get("last_synced_sha",""))' "$STATE" 2>/dev/null)

# --- 2. bisync (preserve both sides; no clock winner) ---
rc=1
for attempt in 1 2 3 4; do
  "$RCLONE" bisync "$SRC" "$DST" --config "$CFG" --filter-from "$FILT" \
    --conflict-resolve none --conflict-loser num --conflict-suffix sync-conflict \
    --backup-dir1 "$BACKUP1" \
    --resilient --recover --max-delete "$MAX_DELETE" \
    --checkers 8 --transfers 8 --tpslimit 4 --tpslimit-burst 4 \
    --dropbox-batch-mode sync --dropbox-batch-size 100 --dropbox-batch-timeout 10s \
    --log-level INFO --log-file "$LOG"
  rc=$?
  [ "$rc" -eq 0 ] && break
  log "bisync attempt $attempt rc=$rc; retry in $((attempt*15))s"
  sleep $((attempt*15))
done
log "bisync exit $rc"

if [ "$rc" -ne 0 ]; then
  if tail -n 100 "$LOG" | grep -qiE "max-delete|Safety abort"; then
    alert "max-delete-abort" "bisync aborted on the delete cap (>${MAX_DELETE} deletions). Local and Dropbox diverged; nothing was deleted. Inspect logs/jdak-bisync.log."
  else
    alert "bisync-error" "bisync failed after retries (rc=$rc). See logs/jdak-bisync.log."
  fi
fi

# --- 3. smart conflict resolution ---
if find "$SRC" -name '*.sync-conflict[0-9]*' -not -path '*/.git/*' -print -quit 2>/dev/null | grep -q .; then
  log "conflicts detected -> merge worker (base=${BASE_REF:-none})"
  "$PY" "$MERGE" --root "$SRC" --base-ref "$BASE_REF" --suffix sync-conflict \
      --review-dir "$REVIEW" --report "$REPORT" --apply >> "$LOG" 2>&1
  mrc=$?
  log "merge worker exit $mrc"
  # propagate the resolved canonical files back up + drop the conflict copies
  "$RCLONE" bisync "$SRC" "$DST" --config "$CFG" --filter-from "$FILT" \
    --conflict-resolve none --conflict-loser num --conflict-suffix sync-conflict \
    --backup-dir1 "$BACKUP1" --resilient --recover --max-delete "$MAX_DELETE" \
    --checkers 8 --transfers 8 --tpslimit 4 --tpslimit-burst 4 \
    --dropbox-batch-mode sync --dropbox-batch-size 100 --dropbox-batch-timeout 10s \
    --log-level INFO --log-file "$LOG"
  log "post-merge bisync exit $?"
  n=$("$PY" -c 'import sys,json;print(len(json.load(open(sys.argv[1])).get("conflicts",[])))' "$REPORT" 2>/dev/null || echo "?")
  if [ "$mrc" -eq 0 ]; then
    alert "conflict-auto-merged" "Merged ${n} conflicting file(s) automatically (3-way; nothing lost). See logs/vault-sync-report.json."
  else
    alert "conflict-review" "Sync conflict(s) need review: ${n} file(s) (worker rc=$mrc). Merged file(s) may carry git-style markers; raw sides stashed in $REVIEW. See logs/vault-sync-report.json."
  fi
fi

# --- 4. mark the new sync point (merge base for next time) ---
if [ "$rc" -eq 0 ] && [ -d "$SRC/.git" ]; then
  GITC add -A >/dev/null 2>&1
  if [ -n "$(GITC status --porcelain)" ]; then
    GITC "${GIT_ID[@]}" commit -q -m "post-sync $(date -Is)" >/dev/null 2>&1
  fi
  sha=$(GITC rev-parse HEAD 2>/dev/null)
  [ -n "$sha" ] && "$PY" -c 'import json,sys;json.dump({"last_synced_sha":sys.argv[1],"ts":sys.argv[2]},open(sys.argv[3],"w"))' "$sha" "$(date -Is)" "$STATE"
fi

# --- 5. kick the inbox/ticket sweep ON SYNC when owner action is waiting ---
# A ticked box / a convert-to-ticket should run as soon as the change lands, not on the next poll.
SWEEP_ID=${SWEEP_ID:-cf2d5164-58ba-4c6f-a0cf-7aa731066d11}
OC=${OC:-/home/matthew/.local/bin/openclaw}
if [ "$rc" -eq 0 ] && [ -x "$OC" ] && [ -x "$SCRIPT_DIR/inbox-action-check.sh" ] \
   && [ -n "$(bash "$SCRIPT_DIR/inbox-action-check.sh" 2>/dev/null)" ]; then
  running=$("$PY" - "$OC" "$SWEEP_ID" <<'PYEOF'
import json, subprocess, sys, time
oc, jid = sys.argv[1], sys.argv[2]
try:
    out = subprocess.run([oc, "cron", "get", jid], capture_output=True, text=True, timeout=30).stdout
    a, b = out.find("{"), out.rfind("}")
    s = (json.loads(out[a:b+1]) or {}).get("state", {})
    run, last = s.get("runningAtMs") or 0, s.get("lastRunAtMs") or 0
    now = time.time() * 1000
    # skip if a sweep run is in flight OR one started very recently (a forge yields to subagents
    # and closes its run while they still work — only re-kick if the sweep has been quiet a bit)
    active = (run and run > last and now - run < 1800000) or (last and now - last < 300000)
    print("1" if active else "0")
except Exception:
    print("0")
PYEOF
)
  if [ "$running" = "0" ]; then
    log "inbox action pending -> kicking the sweep ($SWEEP_ID)"
    "$OC" cron run "$SWEEP_ID" >>"$LOG" 2>&1 && log "sweep kick enqueued" || log "sweep kick failed"
  else
    log "inbox action pending -> sweep already running; no kick"
  fi
fi

# keep the log bounded
if [ "$(stat -c%s "$LOG" 2>/dev/null || echo 0)" -gt 5242880 ]; then
  tail -n 2000 "$LOG" > "$LOG.tmp" && mv "$LOG.tmp" "$LOG"
fi

[ "$mrc" -eq 10 ] && exit 0   # escalate via alert, not via exit code
exit $rc
