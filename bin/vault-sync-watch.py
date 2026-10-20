#!/usr/bin/env python3
"""vault-sync-watch.py — event-driven vault sync (no waiting for cron).

Watches TWO sources and runs bin/vault-sync.sh on change:
  * LOCAL  — a cheap mtime/size signature of the vault (stdlib, no deps).
  * REMOTE — a Dropbox **cursor poll** (files/list_folder/continue on a held
             cursor) using the app + refresh token in secrets/. Reliable, no
             public URL. (Earlier longpoll version kept timing out.)

Debounced (wait for quiet) and rate-limited (min gap) so the ~2-3 min bisync
isn't thrashed. Never drains/swallows a change -> we never miss one; a self-push
costs at most one extra no-op sync, then it settles. The 15-min cron stays as a
backstop; the sync script's flock skips overlapping triggers.

Modes:  (default) run the daemon  |  --selftest: check token+walk, no sync.
"""
import json, os, sys, time, subprocess, threading, urllib.request, urllib.parse

WS       = os.environ.get("JDAK_WORKSPACE", os.path.expanduser("~/.openclaw/workspace"))
VAULT    = os.environ.get("JDAK_VAULT_ROOT", os.path.join(WS, "Vault"))
SYNC     = os.environ.get("WATCH_SYNC", os.path.join(WS, "bin", "vault-sync.sh"))
LOG      = os.environ.get("WATCH_LOG", os.path.join(WS, "logs", "vault-sync-watch.log"))
STATUS   = os.environ.get("WATCH_STATUS", os.path.join(WS, "logs", "vault-sync-watch-state.json"))
DBX_PATH = os.environ.get("JDAK_DROPBOX_PATH", "/Apps/remotely-save/jdak-stack")
APPF     = os.path.join(WS, "secrets", "dropbox-app.json")
TOKF     = os.path.join(WS, "secrets", "dropbox-tokens.json")
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


def dbx_token():
    app = json.load(open(APPF))
    tok = json.load(open(TOKF))
    data = urllib.parse.urlencode({
        "grant_type": "refresh_token",
        "refresh_token": tok["refresh_token"],
        "client_id": app["app_key"],
        "client_secret": app["app_secret"],
    }).encode()
    req = urllib.request.Request("https://api.dropboxapi.com/oauth2/token", data=data,
        headers={"Content-Type": "application/x-www-form-urlencoded"})
    r = json.load(urllib.request.urlopen(req, timeout=25))
    tok["access_token"] = r["access_token"]
    json.dump(tok, open(TOKF, "w"))
    os.chmod(TOKF, 0o600)
    return r["access_token"]


def dbx_api(path, body, token):
    req = urllib.request.Request("https://api.dropboxapi.com/2/" + path,
        data=json.dumps(body).encode(),
        headers={"Authorization": "Bearer " + token, "Content-Type": "application/json"})
    return json.load(urllib.request.urlopen(req, timeout=45))


def latest_cursor(token):
    return dbx_api("files/list_folder/get_latest_cursor",
                   {"path": DBX_PATH, "recursive": True}, token)["cursor"]


# shared state
st = {"dirty": False, "rearm": False, "cursor": None, "remote_seen": 0}


def remote_watch():
    token = dbx_token()
    while True:
        try:
            if st["cursor"] is None or st["rearm"]:
                st["cursor"] = latest_cursor(token)
                st["rearm"] = False
                log("remote watch armed (dropbox cursor @ %s)" % DBX_PATH)
                write_status(remote_armed=st["cursor"][:16])
            r = dbx_api("files/list_folder/continue", {"cursor": st["cursor"]}, token)
            st["cursor"] = r["cursor"]  # always advance
            if r.get("entries"):
                st["dirty"] = True
                st["remote_seen"] += 1
                log("remote change detected (%d entries)" % len(r["entries"]))
                write_status(last_remote_change=time.strftime("%Y-%m-%dT%H:%M:%S%z"),
                             remote_entries=len(r["entries"]))
        except Exception as e:
            log("remote watch error: %r; retry in 30s" % (e,))
            time.sleep(30)
            st["cursor"] = None
            try:
                token = dbx_token()
            except Exception:
                pass
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
        t = dbx_token()
        c = latest_cursor(t)
        print("token: ok | latest cursor: %s | local sig: %s" % (c[:12] + "...", sig()))
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
            before = st["remote_seen"]
            pre_cursor = st["cursor"]
            run_sync("local/remote change")
            dirty = False
            last_sync = time.time()
            last = sig()
            if st["remote_seen"] == before:
                # nothing new arrived during the sync -> our own push; re-arm clean
                st["rearm"] = True
            else:
                dirty = True  # a real change landed mid-sync -> go again


if __name__ == "__main__":
    main()
