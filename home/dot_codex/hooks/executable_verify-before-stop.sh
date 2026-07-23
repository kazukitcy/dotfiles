#!/bin/bash
# Stop hook (Codex): if this turn recorded a mutating tool use, block the
# first stop once and ask for adversarial self-verification. Best-effort
# backstop: fails open (exit 0, empty stdout = allow stop).
set -u
IN=$(cat)
echo "$IN" | jq -es 'length == 1 and (.[0] | type == "object")' >/dev/null 2>&1 || exit 0
SID=$(echo "$IN" | jq -r '.session_id // empty' 2>/dev/null)
TID=$(echo "$IN" | jq -r '.turn_id // empty' 2>/dev/null)
[ -n "$SID" ] && [ -n "$TID" ] || exit 0
# Path-safety guard: IDs must be single path components (defense in depth
# against traversal; Codex IDs are UUIDs, but never rely on that alone).
case "$SID$TID" in */*) exit 0;; esac
M="$HOME/.codex/cache/stop-verify/${SID}-${TID}"
# Loop guard: never re-block a continuation caused by this hook. Consume
# any marker recreated by corrective edits made during the verification
# continuation, so it cannot leak.
if echo "$IN" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  rm -f "$M" 2>/dev/null
  exit 0
fi
[ -f "$M" ] || exit 0
# Block only after successful consumption: an unlink failure fails open
# rather than risking a later duplicate block for the same turn.
rm "$M" 2>/dev/null || exit 0
cat <<'JSON'
{"decision":"block","reason":"Before finishing: this turn used a potentially file-mutating tool. Run one bounded, risk-proportionate adversarial check of the final result against the user's stated objective, staying within the user's instructions and authorized scope: look for oversights, counterexamples, failure conditions, hidden costs, and competing interpretations relevant to the change. Reuse verification already performed rather than repeating it, and run the smallest relevant safe checks not already covered that the user's instructions permit. If you fix an in-scope defect, rerun the affected checks; report out-of-scope issues instead of fixing them. If verification remains failed, blocked, or inconclusive, report the evidence and the blocker rather than claiming completion. This self-check does not replace any independent review your active policy requires; if it passes, briefly state the evidence, then satisfy any remaining completion gates before concluding. Do not restart or expand the task."}
JSON
exit 0
