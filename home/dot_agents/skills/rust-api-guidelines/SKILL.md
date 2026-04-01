---
name: rust-api-guidelines
description: Review, design, document, and refactor public Rust APIs against the Rust API Guidelines. Use when Codex needs to audit a crate or PR, improve naming and conversion APIs, evaluate trait impls and error types, review builders and constructors, check rustdoc and Cargo metadata, assess public macros, or cite guideline IDs like C-GETTER, C-GOOD-ERR, or C-BUILDER.
---

# Rust API Guidelines

## Overview

Use the vendored references in this skill as the working source of truth for public Rust API design and review. Start with a checklist pass, then read only the relevant category notes when you need rationale, examples, or exact guideline wording.

These are guidelines, not a rigid mandate. Some are strong ecosystem conventions, while others are contextual heuristics that depend on crate intent, stability guarantees, and whether the crate is public, internal, experimental, or publishable.

## Workflow

1. Identify the public API surface before judging style.
   Read changed files, public modules, `pub` items, public traits, public macros, `Cargo.toml`, and user-facing docs.
2. Mark applicable categories.
   Skip non-applicable sections explicitly rather than silently ignoring them.
3. Read [references/review-workflow.md](references/review-workflow.md) for the audit sequence.
4. Read [references/checklist.md](references/checklist.md) for the condensed checklist and quick audit prompts.
5. If a point is ambiguous, read the authoritative upstream chapter listed in [references/source-map.md](references/source-map.md).
6. Report findings with guideline IDs and concrete code evidence.

## Applicability

- Apply Naming, Interoperability, Predictability, Flexibility, Type Safety, Dependability, Debuggability, and Future Proofing to most public crates.
- Apply Macros only when the crate exposes public macros.
- Apply Serde guidance only to data structures where serialization is plausibly useful.
- Apply object-safety guidance only when a trait could realistically be used behind `dyn Trait`.
- Apply Necessities, Cargo metadata, release notes, and licensing checks mainly for publishable crates or release/repository tasks.
- Treat stable public API breakage as a harder constraint than local style preference.

## Reporting

- Lead with concrete findings, ordered by severity.
- Cite the guideline ID in every substantive finding, for example `C-GOOD-ERR`.
- Explain why the current API is problematic for callers, not just that it differs from the guideline.
- Distinguish between:
  - breaking API risk
  - correctness or ergonomics issue
  - documentation gap
  - optional improvement
- When proposing a fix, prefer the least disruptive change that still aligns with the guideline.
- When no issue exists, say that the guideline is satisfied or not applicable.

## Review Heuristics

- Prefer guideline-backed evidence over personal taste.
- Treat the guidelines as design pressure, not automatic failure conditions.
- Be careful with rules that depend on crate intent:
  object safety, Serde support, public field visibility, builder choice, and `Deref` are contextual.
- Check semver impact before suggesting changes to existing published APIs.
- For documentation reviews, inspect examples, `Errors` / `Panics` / `Safety` sections, links, crate metadata, and release notes together.
- For API-shape reviews, focus on naming, conversions, ownership, trait impls, error design, constructors, builders, and hidden implementation details.

## Upstream Sources

- Start with the local distilled references in this skill to save context.
- Use [references/checklist.md](references/checklist.md) for the fast pass.
- Use [references/source-map.md](references/source-map.md) to choose the deeper local reference file for the category you are reviewing.
- For finer details, edge cases, or wording that may have been compressed in the vendored summaries, refer to the upstream Rust API Guidelines repository: <https://github.com/rust-lang/api-guidelines>.
- Treat these references as a vendored digest of the Rust API Guidelines so the skill remains usable even if the original checkout is removed.
