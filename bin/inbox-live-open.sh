#!/usr/bin/env bash
# inbox-live-open.sh — take a ticket live (mode: live) deterministically.
#
#   bash bin/inbox-live-open.sh "<ticket name or path>"
#
# Sets, in the frontmatter only: mode: live · live_since · status: working · turn: agent
# · updated · runs+1 (and clears live_ended). Leaves every ticked box alone — a tick is
# the durable claim if the run dies. Idempotent: re-running refreshes live_since.
set -euo pipefail

T=${1:?usage: inbox-live-open.sh "<ticket name or path>"}
V=${JDAK_VAULT_ROOT:-$HOME/.openclaw/workspace/Vault}
DIR="$V/00 - INBOX/00.03 - tickets"

if [ -f "$T" ]; then
  F=$T
elif [ -f "$DIR/$T" ]; then
  F="$DIR/$T"
elif [ -f "$DIR/$T.md" ]; then
  F="$DIR/$T.md"
else
  F=$(ls -t "$DIR"/*"$T"*.md 2>/dev/null | grep -v '/README' | head -1 || true)
fi

[ -n "${F:-}" ] && [ -f "$F" ] || { echo "ticket not found: $T" >&2; exit 1; }
[ "$(basename "$F")" = "README.md" ] && { echo "refusing to take README live" >&2; exit 1; }

NOW=$(date +%Y-%m-%dT%H:%M:%S%:z)
TODAY=$(date +%F)

python3 - "$F" "$NOW" "$TODAY" <<'PY'
import re, sys, pathlib

path, now, today = sys.argv[1], sys.argv[2], sys.argv[3]
p = pathlib.Path(path)
s = p.read_text(encoding="utf-8")
m = re.match(r"---\n(.*?)\n---\n", s, re.S)
if not m:
    sys.exit(f"no frontmatter: {path}")
fm, body = m.group(1), s[m.end():]

if re.search(r"^status:\s*(done|closed)\s*$", fm, re.M):
    sys.exit(f"ticket is closed: {path}")
if re.search(r"^mode:\s*live\s*$", fm, re.M):
    print("already live — refreshing live_since")

def set_field(text, key, value):
    line = f"{key}: {value}"
    if re.search(rf"^{key}:.*$", text, re.M):
        return re.sub(rf"^{key}:.*$", lambda _: line, text, count=1, flags=re.M)
    return text.rstrip("\n") + "\n" + line

for k, v in (("mode", "live"), ("live_since", now), ("status", "working"),
             ("turn", "agent"), ("updated", today)):
    fm = set_field(fm, k, v)

fm = re.sub(r"^live_ended:.*\n?", "", fm, flags=re.M)

r = re.search(r"^runs:\s*(\d+)\s*$", fm, re.M)
fm = set_field(fm, "runs", (int(r.group(1)) + 1) if r else 1)

p.write_text(f"---\n{fm}\n---\n{body}", encoding="utf-8")
print(f"live: {p.name} · runs={re.search(r'^runs:.*$', fm, re.M).group(0).split(': ')[1]} · {now}")
PY
