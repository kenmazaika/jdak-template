#!/usr/bin/env python3
"""vault-sync-watch.py — event-driven vault sync (no waiting for cron).

Watches TWO sources and runs bin/vault-sync.sh on change:
  * LOCAL  — a cheap mtime/size signature of the vault (stdlib, no deps).
  * REMOTE — a stable recursive listing through the same rclone remote used by
             the sync job. No second set of Dropbox credentials is required.

Debounced (wait for quiet) and rate-limited (min gap) so the ~2-3 min bisync
isn't thrashed. Never drains/swallows a change -> we never miss one; a self-push
costs at most one extra no-op sync, then it settles. The 15-min cron stays as a
backstop; the sync script's flock skips overlapping triggers.

Modes:  (default) run the daemon  |  --selftest: check remote+walk, no sync.
"""
import hashlib, json, os, sys, time, subprocess, threading

WS       = os.environ.get("JDAK_WORKSPACE", os.path.expanduser("~/.openclaw/workspace"))
VAULT    = os.environ.get("JDAK_VAULT_ROOT", os.path.join(WS, "Vault"))
SYNC     = os.environ.get("WATCH_SYNC", os.path.join(WS, "bin", "vault-sync.sh"))
LOG      = os.environ.get("WATCH_LOG", os.path.join(WS, "logs", "vault-sync-watch.log"))
STATUS   = os.environ.get("WATCH_STATUS", os.path.join(WS, "logs", "vault-sync-watch-state.json"))
REMOTE   = os.environ.get("JDAK_DROPBOX_DEST", "dropbox:Apps/remotely-save/jdak-stack")
RCLONE   = os.environ.get("RCLONE", os.path.expanduser("~/.local/bin/rclone"))
RCLONE_CONFIG = os.environ.get("RCLONE_CONFIG", os.path.expanduser("~/.config/rclone/rclone.conf"))
DEBOUNCE     = int(os.environ.get("WATCH_DEBOUNCE", "20"))       # quiet seconds before firing
MIN_INTERVAL = int(os.environ.get("WATCH_MIN_INTERVAL", "120"))  # min seconds between syncs
POLL         = int(os.environ.get("WATCH_POLL", "5"))            # local scan cadence
REMOTE_POLL  = int(os.environ.get("WATCH_REMOTE_POLL", "30"))    # dropbox poll cadence


def log(m):
    line = "%s %s" % (time.strftime("%Y-%m-%dT%H:%M:%S%z"), m)
    print(line, flush=True)
    try:
        os.makedirs(os.path.dirname(LOG), exist_ok=True)
        with open(LOG, "a") as f:
            f.write(line + "\n")
    except Exception:
        pass


def write_status(**kw):
    try:
        d = {}
        if os.path.exists(STATUS):
            try:
                d = json.load(open(STATUS))
            except Exception:
                d = {}
        d.update(kw)
        d["updated"] = time.strftime("%Y-%m-%dT%H:%M:%S%z")
        json.dump(d, open(STATUS, "w"), indent=2)
    except Exception:
        pass


def remote_sig():
    cmd = [RCLONE, "lsf", REMOTE, "--recursive", "--files-only", "--format", "pst"]
    if RCLONE_CONFIG:
        cmd += ["--config", RCLONE_CONFIG]
    result = subprocess.run(cmd, check=True, capture_output=True, timeout=120)
    return hashlib.sha256(result.stdout).hexdigest(), len(result.stdout.splitlines())


# shared state
st = {"dirty": False, "remote_seen": 0}


def remote_watch():
    last = None
    while True:
        try:
            current, count = remote_sig()
            if last is None:
                log("remote watch armed (rclone listing @ %s; %d files)" % (REMOTE, count))
                write_status(remote_armed=current[:16], remote_files=count)
            elif current != last:
                st["dirty"] = True
                st["remote_seen"] += 1
                log("remote change detected (rclone listing changed; %d files)" % count)
                write_status(last_remote_change=time.strftime("%Y-%m-%dT%H:%M:%S%z"),
                             remote_files=count)
            last = current
        except Exception as e:
            log("remote watch error: %r; retry in %ds" % (e, REMOTE_POLL))
        time.sleep(REMOTE_POLL)


def sig():
    n = 0; mx = 0.0; sz = 0
    for root, dirs, files in os.walk(VAULT):
        if ".git" in dirs:
            dirs.remove(".git")
        for fn in files:
            try:
                s = os.stat(os.path.join(root, fn))
            except OSError:
                continue
            n += 1; sz += s.st_size
            if s.st_mtime > mx:
                mx = s.st_mtime
    return (n, round(mx, 3), sz)


def run_sync(reason):
    log("trigger sync (%s)" % reason)
    write_status(last_sync_start=time.strftime("%Y-%m-%dT%H:%M:%S%z"), last_sync_reason=reason)
    try:
        subprocess.run(["bash", SYNC], check=False, timeout=1800)
        log("sync finished")
        write_status(last_sync_end=time.strftime("%Y-%m-%dT%H:%M:%S%z"))
    except Exception as e:
        log("sync run error: %r" % (e,))


def main():
    if "--selftest" in sys.argv:
        remote, count = remote_sig()
        print("remote listing: ok (%d files, %s...) | local sig: %s"
              % (count, remote[:12], sig()))
        return
    log("vault-sync-watch starting: VAULT=%s DEBOUNCE=%ds MIN_INTERVAL=%ds POLL=%ds REMOTE_POLL=%ds"
        % (VAULT, DEBOUNCE, MIN_INTERVAL, POLL, REMOTE_POLL))
    write_status(started=time.strftime("%Y-%m-%dT%H:%M:%S%z"))
    threading.Thread(target=remote_watch, daemon=True).start()
    last = sig(); last_sync = 0.0; dirty = False; last_change = 0.0
    seen = st["remote_seen"]
    while True:
        time.sleep(POLL)
        now = time.time()
        cur = sig()
        if cur != last:
            last = cur; dirty = True; last_change = now
            log("local change detected")
            write_status(last_local_change=time.strftime("%Y-%m-%dT%H:%M:%S%z"))
        if st["dirty"]:
            st["dirty"] = False; dirty = True; last_change = now
        if dirty and (now - last_change) >= DEBOUNCE and (now - last_sync) >= MIN_INTERVAL:
            run_sync("local/remote change")
            dirty = False
            last_sync = time.time()
            last = sig()


if __name__ == "__main__":
    main()
