# Review Checklist

Use this file when a PR needs a deeper audit than a quick diff scan.

## Context Pass

- Confirm the problem statement from the PR title, body, linked issue, and commit messages.
- Identify the base branch and what changed relative to it.
- Note whether the PR changes runtime code, tests only, docs only, build tooling, or generated artifacts.
- Flag hidden scope changes early: config edits, dependency bumps, generated code, schema migrations, feature flags, or renamed files.

## Core Questions

- Does the implementation actually satisfy the stated change?
- Can this break existing callers, stored data, wire formats, CLI behavior, or APIs?
- Does it introduce a new failure path, race, timeout, retry loop, or permission boundary?
- Are errors handled at the correct layer with enough context?
- Are tests proving the new behavior and protecting the regression path?

## High-Risk Change Types

### Data and Migrations

- Check forward and rollback safety.
- Look for destructive migrations, backfill assumptions, nullability changes, or missing defaults.
- Verify reads and writes remain compatible during partial rollout.

### API and Contract Changes

- Check request and response shapes, status codes, field names, enum values, and default behavior.
- Verify backward compatibility for existing clients and stored payloads.
- Treat silent contract changes as defects unless explicitly versioned.

### Auth and Security

- Check authorization boundaries, tenant scoping, secret handling, redirects, token validation, and input sanitization.
- Verify new code does not bypass existing guards or logging.

### Concurrency and State

- Look for race conditions, stale caches, missing invalidation, duplicate work, and non-atomic multi-step updates.
- Verify idempotency for retried or repeated operations.

### Performance and Operations

- Check hot paths, query counts, indexing assumptions, memory growth, batching, retries, and timeout behavior.
- Look for config or infra changes that alter deploy, rollback, observability, or alerting behavior.

## Test Review

- Make sure tests would fail without the change.
- Check the negative path, boundary cases, and representative input shapes.
- Verify renamed behavior did not leave stale assertions that still pass.
- Call out untested migrations, concurrency changes, and fallback behavior.

## Reporting Prompts

- "This changes X, but Y still assumes the old behavior, which can fail when ..."
- "The happy path is covered, but the regression path for ... is untested."
- "This update is safe only if ..., but the PR does not enforce or document that assumption."
- "The implementation matches the PR description, but it leaves a rollout or compatibility risk around ..."
