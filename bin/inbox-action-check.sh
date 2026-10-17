#!/usr/bin/env bash
# inbox-action-check.sh — emit the inbox items that need the sweep's attention.
# Fires the "Vault inbox action sweep" cron when non-empty.
# Covers three surfaces (one line each, tab-separated "kind<TAB>path"):
#   - 00.01 handoffs: `action: pending` + a checked box       -> do the action
#   - 00.02 intake:   `status: new`      + a checked box       -> route it
#   - 00.03 tickets:  any checked box (Execute / Close)        -> run / close the ticket
# Prints nothing (exit 0) when there is nothing to do.
set -uo pipefail
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[ -r "$SCRIPT_DIR/vault-paths.sh" ] && . "$SCRIPT_DIR/vault-paths.sh"
V="${JDAK_VAULT_ROOT:-$HOME/.openclaw/workspace/Vault}"
H="${JDAK_INBOX_HANDOFFS:-$V/00 - INBOX/00.01 - handoffs}"
I="$V/00 - INBOX/00.02 - intake"
T="$V/00 - INBOX/00.03 - tickets"
shopt -s nullglob

# 1) handoffs: action pending + a checked box
for f in "$H"/*.md; do
  [ -f "$f" ] || continue
  grep -q '^action: pending' "$f" 2>/dev/null || continue
  grep -qE '^- \[[xX]\]' "$f" 2>/dev/null && printf 'handoff\t%s\n' "$f"
done

# 2) intake: status new + a checked box
for f in "$I"/*.md; do
  [ -f "$f" ] || continue
  grep -qE '^status: new' "$f" 2>/dev/null || continue
  grep -qE '^- \[[xX]\]' "$f" 2>/dev/null && printf 'intake\t%s\n' "$f"
done

# 3) tickets: any checked box (Execute or Close)
for f in "$T"/*.md; do
  [ -f "$f" ] || continue
  grep -qE '^- \[[xX]\]' "$f" 2>/dev/null && printf 'ticket\t%s\n' "$f"
done

exit 0
