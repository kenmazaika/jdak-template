#!/usr/bin/env bash
# vault-paths.sh — SINGLE SOURCE OF TRUTH for the JDAK vault location.
#
# The vault folder gets moved around; when it does, change JDAK_VAULT_ROOT
# here (that one line) and everything that sources this file follows:
#   bin/vault-sync.sh, bin/vault-sync-alert-check.sh, bin/inbox-action-check.sh,
#   and the cold-email / inbox crons.
#
# Precedence: everything is ": "${VAR:=default}"" — an already-exported value
# wins, so a single run can be redirected without editing the file:
#   JDAK_VAULT_ROOT=/tmp/other bash bin/vault-sync.sh
#
# This file must live OUTSIDE the vault (here in the workspace bin/) so that
# moving the vault never moves the config that points at it.

# Workspace root (OpenClaw's home for this agent).
: "${JDAK_WORKSPACE:=$HOME/.openclaw/workspace}"
export JDAK_WORKSPACE

# >>> EDIT THIS ONE LINE WHEN THE VAULT MOVES <<<
: "${JDAK_VAULT_ROOT:=$JDAK_WORKSPACE/Vault}"
export JDAK_VAULT_ROOT

# --- derived, stable child paths (nothing below should need editing) ---
export JDAK_PROJECTS_ROOT="${JDAK_PROJECTS_ROOT:-$JDAK_VAULT_ROOT/01 - PROJECTS/01.02 - qballs}"
export JDAK_INBOX_HANDOFFS="${JDAK_INBOX_HANDOFFS:-$JDAK_VAULT_ROOT/00 - INBOX/00.01 - handoffs}"
export JDAK_INBOX_TICKETS="${JDAK_INBOX_TICKETS:-$JDAK_VAULT_ROOT/00 - INBOX/00.03 - tickets}"
export JDAK_INBOX_OUTBOX="${JDAK_INBOX_OUTBOX:-$JDAK_VAULT_ROOT/00 - INBOX/00.04 - outbox}"

# Sync destination (rclone remote + path).
export JDAK_DROPBOX_DEST="${JDAK_DROPBOX_DEST:-dropbox:Apps/remotely-save/jdak-stack}"
