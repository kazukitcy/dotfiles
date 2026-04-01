# Rust API Guidelines Source Map

This skill is self-contained. Load these local references when you need deeper rationale than the checklist provides.

## Core index

- `references/checklist.md`: Condensed checklist with all guideline IDs and review questions.
- `references/review-workflow.md`: Audit order, applicability rules, and reporting expectations.

## Deeper references by category

- `references/naming-and-interoperability.md`
  Covers `C-CASE`, `C-CONV`, `C-GETTER`, `C-ITER`, `C-ITER-TY`, `C-FEATURE`, `C-WORD-ORDER`, `C-COMMON-TRAITS`, `C-CONV-TRAITS`, `C-COLLECT`, `C-SERDE`, `C-SEND-SYNC`, `C-GOOD-ERR`, `C-NUM-FMT`, `C-RW-VALUE`.
- `references/macros-and-documentation.md`
  Covers `C-EVOCATIVE`, `C-MACRO-ATTR`, `C-ANYWHERE`, `C-MACRO-VIS`, `C-MACRO-TY`, `C-CRATE-DOC`, `C-EXAMPLE`, `C-QUESTION-MARK`, `C-FAILURE`, `C-LINK`, `C-METADATA`, `C-RELNOTES`, `C-HIDDEN`.
- `references/api-design.md`
  Covers `C-SMART-PTR`, `C-CONV-SPECIFIC`, `C-METHOD`, `C-NO-OUT`, `C-OVERLOAD`, `C-DEREF`, `C-CTOR`, `C-INTERMEDIATE`, `C-CALLER-CONTROL`, `C-GENERIC`, `C-OBJECT`, `C-NEWTYPE`, `C-CUSTOM-TYPE`, `C-BITFLAG`, `C-BUILDER`.
- `references/stability-and-reliability.md`
  Covers `C-VALIDATE`, `C-DTOR-FAIL`, `C-DTOR-BLOCK`, `C-DEBUG`, `C-DEBUG-NONEMPTY`, `C-SEALED`, `C-STRUCT-PRIVATE`, `C-NEWTYPE-HIDE`, `C-STRUCT-BOUNDS`, `C-STABLE`, `C-PERMISSIVE`.

## Practical selection hints

- Open `naming-and-interoperability.md` when reviewing naming, trait impls, error types, conversions, collections, or Serde support.
- Open `macros-and-documentation.md` when reviewing rustdoc, examples, `Cargo.toml`, README, release process files, or public macros.
- Open `api-design.md` when redesigning constructors, builders, ownership, trait objects, and parameter types.
- Open `stability-and-reliability.md` when reviewing validation, destructors, `Debug`, semver flexibility, public fields, or licensing.

## Upstream checklist quirk

- The vendored upstream checklist still mentions `C-HTML-ROOT`, but this checkout does not contain a corresponding documentation chapter or active guideline text for it.
- Do not treat `C-HTML-ROOT` as a separate audit category unless the user explicitly asks about hosted rustdoc configuration.
