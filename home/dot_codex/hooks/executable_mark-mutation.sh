#!/bin/bash
# PostToolUse hook (Codex): record that this turn invoked a potentially
# file-mutating tool; review-before-stop.sh consumes the marker.
# Best-effort: fails open (exit 0, empty stdout).
set -u
IN=$(cat)
# Framing guard: stdin must be exactly one well-formed JSON object.
echo "$IN" | jq -es 'length == 1 and (.[0] | type == "object")' >/dev/null 2>&1 || exit 0
SID=$(echo "$IN" | jq -r '.session_id // empty' 2>/dev/null)
TID=$(echo "$IN" | jq -r '.turn_id // empty' 2>/dev/null)
[ -n "$SID" ] && [ -n "$TID" ] || exit 0
# Path-safety guard: IDs must be single path components (defense in depth
# against traversal; Codex IDs are UUIDs, but never rely on that alone).
case "$SID$TID" in */*) exit 0;; esac
D="$HOME/.codex/cache/stop-verify"
mkdir -p "$D" 2>/dev/null || exit 0
# Prune stale markers (e.g. turns whose Stop never consumed them).
find "$D" -maxdepth 1 -type f -mtime +30 -delete 2>/dev/null
touch "$D/${SID}-${TID}" 2>/dev/null
exit 0
