#!/bin/bash
# Stop hook (Codex): if mark-mutation.sh recorded a mutation in this turn,
# block the first stop once to request a whole-result review.
# Introduced because agents can finish local steps without revisiting whether
# the assembled result meets the user's goal. Passing tests alone must not
# bypass this review; reuse requires a review of the current result and scope.
# The hook prompts reflection, but cannot certify its quality.
# Best-effort: fails open (exit 0, empty stdout = allow stop).
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
# Shared with mark-mutation.sh: keep this cache namespace stable across
# hook renames so pending review markers remain visible.
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
{"decision":"block","reason":"Before finishing, run one bounded, risk-proportionate adversarial review of the final result as a whole against the user's original objective, later agreements, constraints, and completion criteria. Look for overlooked requirements, inconsistencies between parts, local choices that undermine the overall outcome, unnecessary complexity, counterexamples, failure conditions, hidden downstream costs, and unsupported assumptions. Reconsider credible alternatives or competing interpretations when they could change an important judgment; do not invent alternatives to fill a quota. Reuse existing test results and observations that still apply, but passing individual checks does not substitute for this whole-result review. Reuse a prior whole-result review only if it covers the current final result and current agreed requirements, and its evidence remains valid. Verify conclusion-changing assumptions with the smallest relevant safe checks; ask the user for necessary unresolved information and keep dependent decisions pending. Correct in-scope defects, rerun affected checks, and reassess their impact on the whole result; report out-of-scope issues instead of expanding the task. Give a brief overall verdict supported by evidence, separating observed results from unverified assumptions and remaining limitations. If verification is failed, blocked, or inconclusive, report the evidence and blocker rather than claiming completion. Satisfy any required independent review as well. Do not restart or expand the task."}
JSON
exit 0
