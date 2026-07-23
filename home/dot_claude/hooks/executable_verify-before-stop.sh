#!/bin/bash
# Stop hook: if the ending turn used a file-mutating tool, block the first
# stop attempt once and ask for adversarial self-verification. Best-effort
# backstop: fails open (exit 0, empty stdout = allow stop) on any parse
# problem.
set -u
IN=$(cat)

# Framing guard: stdin must be exactly one well-formed JSON object; a
# valid prefix followed by garbage would otherwise still yield a
# transcript_path and could block instead of failing open.
echo "$IN" | jq -es 'length == 1 and (.[0] | type == "object")' \
  >/dev/null 2>&1 || exit 0

# Loop guard: never re-block a continuation caused by this hook.
echo "$IN" | jq -e '.stop_hook_active == true' >/dev/null 2>&1 && exit 0

T=$(echo "$IN" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -n "$T" ] && [ -r "$T" ] || exit 0

# Single pass over the whole transcript (O(1) memory, no tail window).
# Boundary = a real user prompt: non-meta, no tool_result blocks, and text
# that is non-empty after trimming leading whitespace and is not an
# interrupt marker. Mutations count only after a boundary; no recognized
# boundary allows the stop. jq parses the transcript as a stream of JSON
# VALUES (line framing is not significant): a malformed value aborts jq,
# prints nothing, and fails open; valid values concatenated on one
# physical line are processed as their constituent entries — correct,
# since their content is genuine. (.b is redundant in the final
# expression — .m implies .b — kept for readability, not load-bearing.)
MUTATED=$(jq -n '
  def real_text($t):
    ($t | gsub("^\\s+"; "")) as $s
    | (($s | length) > 0)
      and (($s | startswith("[Request interrupted")) | not);
  def is_boundary($e):
    $e.type == "user"
    and (($e.isMeta // false) | not)
    and (
      ((($e.message.content | type) == "string")
       and real_text($e.message.content))
      or
      ((($e.message.content | type) == "array")
       and ([$e.message.content[]?.type] | index("tool_result") | not)
       and ([$e.message.content[]? | select(.type == "text") | .text // ""]
            | join("") | real_text(.)))
    );
  def mutates($e):
    $e.type == "assistant"
    and ([$e.message.content[]? | select(.type == "tool_use") | .name]
         | any(. == "Edit" or . == "Write" or . == "NotebookEdit"));
  reduce inputs as $e ({b: false, m: false};
    if is_boundary($e) then {b: true, m: false}
    elif .b and mutates($e) then .m = true
    else . end)
  | .b and .m
' "$T" 2>/dev/null)
[ "$MUTATED" = "true" ] || exit 0

cat <<'JSON'
{"decision":"block","reason":"Before finishing: this turn used a potentially file-mutating tool. Run one bounded, risk-proportionate adversarial check of the final result against the user's stated objective, staying within the user's instructions and authorized scope: look for oversights, counterexamples, failure conditions, hidden costs, and competing interpretations relevant to the change. Reuse verification already performed rather than repeating it, and run the smallest relevant safe checks not already covered that the user's instructions permit. If you fix an in-scope defect, rerun the affected checks; report out-of-scope issues instead of fixing them. If verification remains failed, blocked, or inconclusive, report the evidence and the blocker rather than claiming completion. This self-check does not replace any independent review your active policy requires; if it passes, briefly state the evidence, then satisfy any remaining completion gates before concluding. Do not restart or expand the task."}
JSON
exit 0
