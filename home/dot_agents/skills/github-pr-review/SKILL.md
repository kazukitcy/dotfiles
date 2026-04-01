---
name: github-pr-review
description: Review GitHub pull requests for correctness, regressions, security, performance, API and schema compatibility, and test gaps. Use when Codex needs to inspect a GitHub PR, compare a branch against its base, read changed files or commits, assess merge risk, or produce actionable review findings with file and line references.
---

# GitHub PR Review

## Overview

Use this skill to review pull requests, not to implement them. Build context from the PR metadata and the actual diff, then report only concrete, actionable findings that matter for merge decisions.

## Workflow

1. Build the review context first.
   Collect the PR title, body, base branch, head branch, linked issues, changed files, commits, test results, and CI status when available.
2. Prefer GitHub-native context when tooling is available.
   Use `gh pr view` and `gh pr diff` or equivalent GitHub tooling to inspect metadata, review state, and the full patch. If that is unavailable, review the local checkout against the target base with `git diff` and `git log`.
3. Read the diff by risk, not by file order.
   Start with migrations, auth, permissions, data writes, parsing, concurrency, caching, API boundaries, infra changes, and test updates.
4. Verify the claimed behavior.
   Compare the PR description with the actual code paths, config changes, and tests. Treat mismatches as a review signal.
5. Read [references/review-checklist.md](references/review-checklist.md) for the detailed checklist and review prompts.
6. Report findings with evidence.
   Include file and line references when possible. Explain the failure mode, impact, and triggering scenario, not just the stylistic difference.

## Review Heuristics

- Prioritize correctness, regressions, security, data loss, compatibility, operational risk, and missing tests.
- Treat user-visible behavior changes, schema changes, and interface changes as high-risk until verified.
- Be skeptical of changes that silently alter defaults, validation, retries, timeouts, permissions, or serialization.
- Review tests as part of the feature, not as an afterthought. Missing or misleading tests are review findings when they hide risk.
- Ignore nits unless they materially affect readability, maintainability, or bug risk.
- Do not invent issues from hypothetical style preferences. Every finding should tie to a concrete code path or realistic execution scenario.

## Reporting

- Lead with findings, ordered by severity.
- For each finding, state:
  - what is wrong
  - why it matters
  - when it breaks or regresses
  - the supporting file and line reference
- Distinguish clearly between:
  - blocking defect or regression
  - significant risk or missing coverage
  - non-blocking suggestion
- If no findings are discovered, say so explicitly and mention residual risks or testing gaps.
- Keep the final summary brief. The findings are the main deliverable.
