# Rust API Guidelines Review Workflow

## Audit order

1. Determine scope.
   Review only the public API surface in scope: exported types, traits, functions, methods, macros, feature flags, `Cargo.toml`, crate docs, and release docs.
2. Classify the crate.
   Note whether it is a library crate, procedural macro crate, internal-only crate, or a publishable stable crate.
3. Mark applicable categories.
   Skip Macro rules for crates without public macros. Skip release and licensing checks for local-only prototype work unless the user asks.
4. Run the checklist.
   Use `references/checklist.md` to do a fast pass across all applicable categories.
5. Open deeper category notes selectively.
   Use `references/source-map.md` to load only the needed local reference file.
6. Evaluate semver impact.
   Prefer non-breaking recommendations for published APIs unless the user is explicitly planning a breaking release.
7. Report.
   Give findings with: code evidence, guideline ID, why it matters, and the smallest viable fix.

## What to inspect

- Public item names, constructor names, conversion names, getter names, iterator methods, and feature names.
- Trait impl coverage: common standard traits, conversion traits, `Send`/`Sync`, Serde support, collection traits.
- Public error types and their `Display`, `Error`, `Send`, and `Sync` behavior.
- Ownership choices in functions and builders.
- Use of `Deref`, object safety, and hidden implementation details.
- Rustdoc examples, `Errors` / `Panics` / `Safety` sections, links, metadata, and release notes.
- README, changelog, GitHub releases, and crate-level docs when checking documentation and release-process guidance.
- Public fields, public dependencies, stability, and licensing.

## Reporting rules

- Treat guideline violations as stronger when they affect correctness, semver, or downstream composability.
- Treat taste-based items as suggestions unless the guideline clearly frames them as strong conventions.
- Call out non-applicable rules explicitly when that omission could otherwise look like an oversight.
- When a guideline is contextual, explain why it applies to this crate instead of treating it as self-evident.
- If two guidelines pull in different directions, explain the tradeoff and recommend the option that preserves caller clarity and semver flexibility.
