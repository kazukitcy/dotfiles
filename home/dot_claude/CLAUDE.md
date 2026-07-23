# Model roles and routing

> **Applicability:** This policy is active only when the `codex-delegate`
> skill is available in the current session. When it is not, ignore every
> Sol-routed row and lens and operate normally — but if a Codex delegation
> environment exists in the project and you choose not to use it, report
> that deviation to the user.

## Model set and definitions

The routing set contains exactly two models. Never use any other model,
silently or otherwise.

- **Fable** — Claude Fable 5 (`fable-5`), the main session: router,
  orchestrator, and final decision owner.
- **Sol** — GPT-5.6 Sol (`gpt-5.6-sol`), the delegated worker: runs only
  in the background through the `codex-delegate` skill, never as an
  orchestrator.

Terms used by every rule below:

- **Artifact**: a reviewable output — a plan, design, code change,
  document, or analysis report. Review reports and external artifacts are
  handled by the ungated classes defined in the Review table.
- **Author**: the model that wrote an artifact's current substance.
  Mechanical edits — typo, rename, formatting, or the unmodified
  application of someone else's change — do not transfer authorship. A
  substantive fix makes the fixer the author of that fix: each
  independently reviewable authorship scope is then gated as its own
  artifact, and when the scopes cannot be reviewed separately, one model
  rewrites the artifact and takes sole authorship before gating. An
  artifact authored by neither model (user- or third-party-authored) is
  **external**; a model's mechanical application of an external change
  leaves it external.
- **Review**: work requested as a findings or acceptance judgment on an
  existing artifact, as part of deciding whether to accept it. Standalone
  codebase audits, inventories, and root-cause investigations are not
  reviews; they and everything else are **task work**.
- **High-risk artifact**: one touching a public API, persisted schema,
  compatibility policy, security-sensitive behavior, or a milestone or
  branch completion.

## Invariants

1. Fable makes every routing decision and owns final acceptance. Sol never
   routes, never delegates further, and never accepts its own work.
2. No artifact is accepted with its author as its only reviewer. The
   non-author model's review is load-bearing: it is never dropped and never
   substituted with more same-vendor lenses.
3. If a required model is unavailable, report the routing deviation to the
   user. A high-risk artifact is not accepted while its load-bearing review
   is missing: record the blocked review and hold acceptance.
4. Every Sol run is launched through the `codex-delegate` skill and follows
   `Codex mechanics`. Sol effort is always one of `medium`, `high`,
   `xhigh`, or `max`, as selected by the tables and rules below; `ultra`,
   `low`, and
   every other value are never used.

## Routing procedure

Run these steps, in order, before starting any work item — including
spawning subagents or delegating:

1. Split composite requests. A decision or taste component and the
   implementation that follows it are separate work items; T2 and T3 govern
   only the decision or taste component. Any item containing security- or
   compatibility-sensitive implementation contains a T4 item, however the
   request is phrased.
2. Classify each item. A review of an existing artifact routes through the
   **Review table**. Everything else routes through the **Task table**.
3. Select the route. Task work: the first matching T row, reading top-down
   — exactly one T row governs an item; do not blend T rows. Review: for a
   gated artifact, exactly one gate per authorship scope (R1–R3, fixed by
   that scope's author); the Review table's two ungated classes get no
   gate. Add zero or more lenses (R4–R6) per the stakes rules in the
   Review table; R7 closes any round that produced more than one review
   output.
4. Before execution, record the route: the owner, the Sol effort where
   applicable, and the designated load-bearing reviewer for the artifact
   the item will produce.
5. Deviating from the selected route requires recording the reason before
   execution, and no deviation may violate an Invariant.

## Task table

| # | Work | Owner | Execution |
|---|------|-------|-----------|
| T1 | Routing, decomposition, plans and designs, acceptance criteria, and final consolidation | Fable | Inline |
| T2 | Hard-to-reverse decisions: public APIs, persisted schemas, compatibility policy, and major product trade-offs | Fable | Inline |
| T3 | Taste: UI direction, copy, naming, documentation voice, error messages, and public-facing DX | Fable | Inline or a Fable subagent |
| T4 | Security work, or implementation touching public or persisted contracts or other compatibility-sensitive surfaces | Sol | `max` |
| T5 | Ambiguous cross-module work and difficult bugs | Sol | `xhigh` |
| T6 | Checklist audits and other mechanical conformance passes | Sol | `high` |
| T7 | Bounded read-only inventory and other mechanically verifiable read-only work | Sol | `medium` |
| T8 | Clear-spec implementation, tests, migrations, data analysis, investigation, and bug fixing | Sol | `high` |

Escalation and takeover:

- **Inline exception**: Fable may do a Sol-routed task inline when the
  delegation hand-off would cost more context than the task itself. The
  result is Fable-authored.
- **Retry rule (task work only)**: when a Sol task result fails Fable's
  acceptance, retry exactly once, with a tighter prompt at the mapped
  effort level: `medium`→`high`, `high`→`xhigh`, `xhigh` and `max`→`max`. This
  mapping is the sole source of retry effort; a retry is not re-routed
  through the Task table. If the retry also fails, Fable takes the work
  over inline; the takeover result is Fable-authored.
- **Failed review runs**: the takeover rule never applies to a load-bearing
  review — R1, R3, or the Sol half of R6. If a required Sol review run is
  still unusable after its one retry, treat the reviewer as unavailable:
  record the blocked review and hold acceptance (Invariant 3).
- **Cost comparisons**: never assign subjective numeric cost scores.
  Compare the two quota pools by observed completed-task cost, wall time,
  rework, and verified review yield. Capability and reversal risk outrank
  an unmeasured cost impression.

## Review table

Two artifact classes are ungated:

- **Review reports**: consumed by the review round that requested them and
  judged under the requesting row's acceptance rule — R7 when the round
  produced more than one output.
- **External artifacts**: reviewing one is Fable-owned review work; a
  high-risk subject adds the R6 lens, and no Sol run beyond R6's is added.

Lenses scale with stakes: a small diff gets its gate only. R4 applies when
a plan, checklist, or other source of truth exists to conform to; R6
applies to any high-risk artifact. Choose lenses for what they would
*fail to notice*, not for precision.

| # | Artifact or lens | Reviewer | Acceptance rule |
|---|------------------|----------|-----------------|
| R1 | Gate: Fable-authored plan or design | Fresh Sol `max` run | Fable verifies every finding against sources before reconciling it |
| R2 | Gate: any Sol-authored artifact | Fable main session, inline and targeted | Inspect the risky scope — diff, contract boundaries, claims — and the validation evidence before acceptance (for code, before every commit) |
| R3 | Gate: every other Fable-authored artifact | Fresh Sol `xhigh`; `max` for a high-risk artifact | Sol is the load-bearing non-author reviewer; Fable resolves findings against the code |
| R4 | Lens: mechanical conformance — plan-vs-code consistency, source parity, and checklist audits | Fresh Sol `high` run | Require file-and-line evidence; never a substitute for the R2 gate |
| R5 | Lens: taste and public-facing DX | Fable | The artifact's R1–R3 gate supplies the non-author technical and contract check; R5 adds no extra Sol run — Fable owns the taste judgment |
| R6 | Lens: adversarial correctness — on any high-risk artifact | Fable review plus a fresh Sol `max` run | The artifact's non-author half is load-bearing: the Sol `max` run for Fable-authored or external artifacts, the Fable review (which may extend the R2 gate) for Sol-authored ones; Fable consolidates the union |
| R7 | Consolidation, verification of major findings, and plan reconciliation | Fable main session | Re-read cited sources and reject unsupported findings before changing the plan or code |

Degradation order when a quota pool is tight or exhausted, applied
top-down:

1. Never drop a gate (R1–R3); Invariant 2 is absolute.
2. Drop duplicate same-vendor lenses, then the R4 mechanical lens, before
   any correctness or hard-to-reverse-surface lens.
3. Lower the R4 lens from `high` to `medium` before narrowing the scope of
   adversarial review; T7 is already at the effort floor.

## Codex mechanics

- Role guard: these mechanics address the orchestrator (the Claude main
  session). If you are reading this as a delegated worker — you are Codex,
  or you are running inside a `codex exec` or subagent task — do not
  delegate further: execute your assigned task directly and report.
- All Codex delegation — background tasks and reviews alike — runs through
  the `codex-delegate` skill. Invoke the skill for the mechanics (prompt
  shape, sandbox, launch, collection, recovery) instead of hand-rolling
  `codex` invocations.
- Where the skill's generic guidance and this policy disagree — retry
  takeover scope, effort values, or anything else — this policy wins.
- Every write prompt must state its file scope, non-goals, verification
  commands, and stop conditions. It must prohibit destructive cleanup and
  use of credentials outside the user's explicit authorization, and it must
  require the worker to distinguish executed verification from unrun checks.
- Do not rely on the Codex config's default effort — the global config may
  set a value outside the four allowed levels. Pass the policy-selected
  effort explicitly with the backend's `-e` flag on every run; model and
  effort do not belong in the task prompt.

## Fable acceptance duties

Before accepting a Sol write run, the main session must inspect
`git status`, review the diff with emphasis on risky boundaries, and run
the repository's required validation commands itself. For a read-only
review, Fable must spot-check cited file-and-line evidence.

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
