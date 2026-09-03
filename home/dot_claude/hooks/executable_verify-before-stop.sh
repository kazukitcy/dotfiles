#!/bin/bash
# Stop hook: after a real user prompt, block the first stop attempt once when
# the ending turn either (a) used a file-mutating tool, or (b) produced a
# substantial final message (analysis or recommendations) — each with its own
# verification instruction. Best-effort backstop: fails open (exit 0, empty
# stdout = allow stop) on any parse problem.
set -u
ANALYSIS_MIN_CHARS=1000
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
# interrupt marker. After a boundary we track two things: whether a
# file-mutating tool ran (.m), and the longest assistant text emitted (.t —
# max, not last, because the final transcript entry can be a tool-use-only
# or thinking-only message with no text). No recognized boundary allows
# the stop. jq parses the transcript as a stream of JSON VALUES; a
# malformed value aborts jq, prints nothing, and fails open.
VERDICT=$(jq -rn --argjson min "$ANALYSIS_MIN_CHARS" '
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
  def text_len($e):
    ($e.message.content // []) as $c
    | if ($c | type) == "array"
      then ([$c[]? | select(.type == "text") | .text // ""] | join("") | length)
      elif ($c | type) == "string" then ($c | length)
      else 0 end;
  reduce inputs as $e ({b: false, m: false, t: 0};
    if is_boundary($e) then {b: true, m: false, t: 0}
    elif .b and $e.type == "assistant" then
      (if mutates($e) then .m = true else . end)
      | .t = ([.t, text_len($e)] | max)
    else . end)
  | if .b and .m then "mutate"
    elif .b and .t >= $min then "analyze"
    else "none" end
' "$T" 2>/dev/null)

case "$VERDICT" in
mutate)
  cat <<'JSON'
{"decision":"block","reason":"Before finishing: this turn used a potentially file-mutating tool. Run one bounded, risk-proportionate adversarial check of the final result against the user's stated objective, staying within the user's instructions and authorized scope: look for oversights, counterexamples, failure conditions, hidden costs, and competing interpretations relevant to the change. Reuse verification already performed rather than repeating it, and run the smallest relevant safe checks not already covered that the user's instructions permit. If you fix an in-scope defect, rerun the affected checks; report out-of-scope issues instead of fixing them. If verification remains failed, blocked, or inconclusive, report the evidence and the blocker rather than claiming completion. This self-check does not replace any independent review your active policy requires; if it passes, briefly state the evidence, then satisfy any remaining completion gates before concluding. Do not restart or expand the task."}
JSON
  ;;
analyze)
  cat <<'JSON'
{"decision":"block","reason":"Before finishing: this turn presented substantial analysis or recommendations. Run one bounded adversarial pass over its claims: separate facts actually observed in this session (command output, file contents, fetched sources) from assumptions and recollections; for any assumption that changes the conclusion or a recommended action, verify it now with the cheapest direct check available (actual remote refs, actual file state, actual documentation) or explicitly mark it unverified in a brief follow-up; look for counterexamples and competing interpretations of the question. Reuse verification already performed rather than repeating it. If everything material was already verified, state that evidence in one or two sentences and finish. If the turn was purely conversational, simply finish. Do not restart or expand the task."}
JSON
  ;;
esac
exit 0
