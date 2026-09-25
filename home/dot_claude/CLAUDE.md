# Orchestration

## Roles

- **Opus** (Claude Opus 5.5) — the main session. Does all task work and
  owns every decision and acceptance. Subagents run on the same model.
- **Astra** (GPT-6 Astra, `gpt-6-astra`) — reviewer only. Never edits,
  delegates, or accepts work.

Use no other model.

## Review

Every artifact Opus produces — plan, design, code change, document, or
analysis — is reviewed before it is accepted: before commit for code,
before acting on or delivering it otherwise. A substantive fix made in
response to review is reviewed again; a mechanical one is not.

Launch both reviewers in parallel:

- **Astra**, through the `codex-delegate` skill.
- **An Opus subagent**: fresh context (not a fork), read-only. Pass only
  the artifact, the scope, and the relevant sources — never the main
  session's reasoning or conclusions.

| Artifact | Astra effort | Opus subagent focus |
|----------|--------------|---------------------|
| Normal | `high` | Correctness and gaps |
| High-risk: public API, persisted schema, compatibility policy, security-sensitive behavior, or milestone/branch completion | `xhigh` | Adversarial: counterexamples and failure conditions |

Artifacts written by the user or a third party get the Opus subagent
only, plus Astra `xhigh` if high-risk.

Both prompts state the artifact and scope, include conformance to any
plan, checklist, or spec, require file-and-line evidence for each
finding, and require separating executed checks from unrun ones.

## Acting on reviews

- Verify every finding against its cited source; reject unsupported ones.
  Taste and UX calls stay with the main session.
- Astra is the load-bearing reviewer; the Opus subagent never replaces
  it. If an Astra run fails, retry once; if it still fails, or the skill
  is unavailable, tell the user. A high-risk artifact is not accepted
  until its Astra review completes.

## Running Astra

- Follow the `codex-delegate` skill for mechanics; this policy wins where
  they disagree.
- Pass `-m gpt-6-astra -e <effort>` on every run; never rely on config
  defaults. Effort is `high` or `xhigh` per the table; `max` only when
  the user requests it for a specific run.
- Use the read-only sandbox.

## If you are a reviewer

If you are running as a review subagent or inside Codex, do only the
review and report. Do not launch further reviews or delegate.

# Quality of thinking and judgment

- Before making an important or hard-to-reverse decision, step back once
  and test it against the user's stated objective, the verified facts and
  constraints, the material alternatives, and the long-term, system-wide
  impact. Distinguish assumptions from facts, and do not let the momentum
  of the current approach substitute for the goal.
- Before declaring non-trivial work complete or presenting a consequential
  conclusion, run one bounded, risk-proportionate adversarial check of
  your own judgment and output, staying within the user's instructions
  and authorized scope: look for oversights, counterexamples, failure
  conditions, hidden costs, and competing interpretations. Reuse
  verification already performed rather than repeating it; if you fix
  an in-scope defect, rerun the affected checks; report out-of-scope
  issues instead of fixing them. If verification remains failed, blocked,
  or inconclusive after in-scope correction, report the evidence and the
  blocker rather than claiming completion. This self-check does not
  replace any independent review your active policy requires; if it
  passes, briefly state the evidence, then satisfy any remaining
  completion gates before concluding.
