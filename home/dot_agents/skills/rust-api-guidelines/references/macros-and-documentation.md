# Macros and Documentation

## Macros

### `C-EVOCATIVE`

- Macro input syntax should look like the Rust syntax it conceptually expands into.
- Prefer familiar keywords and punctuation over clever custom DSLs.
- If a macro declares a struct, using `struct` in the input usually improves readability.

### `C-MACRO-ATTR`

- Public item macros should allow attributes on generated items.
- This matters for derives, `cfg`, lint controls, and documentation attributes.
- Macros that generate multiple items should not trap callers into all-or-nothing attribute placement.

### `C-ANYWHERE`

- Item macros should work anywhere ordinary items are allowed, including module scope and function scope.
- Add tests for both contexts.
- Macros that rely on brittle module-relative paths often fail this rule.

### `C-MACRO-VIS`

- Support standard Rust visibility syntax, with private-by-default behavior and `pub` when requested.
- Avoid inventing alternate visibility switches.

### `C-MACRO-TY`

- If a macro takes a type fragment, support relative paths, absolute paths, `super::`, primitives, and generic types.
- Fragile pattern matching around types usually shows up as surprising compile failures for otherwise valid Rust syntax.

## Documentation

### `C-CRATE-DOC`

- Crate-level docs should explain what the crate is for and include runnable examples.
- Users often read the crate root first, so this is the right place for the mental model and main entry points.

### `C-EXAMPLE`

- Public items should have examples or a clear link to a single canonical example.
- A good example shows why the API is useful, not just how to call a method mechanically.
- Apply this rule with judgment for trivial items.

### `C-QUESTION-MARK`

- Fallible docs examples should use `?` rather than `try!` or `unwrap`.
- Users frequently paste examples directly into code; docs should model good error handling.

### `C-FAILURE`

- Document `Errors` for fallible APIs.
- Document `Panics` when the API can panic in realistic usage.
- Document `Safety` for every `unsafe fn`, including all invariants the caller must maintain.
- Trait methods need these sections too when their contract allows errors or panics.

### `C-LINK`

- Link referenced types, traits, methods, and related modules in prose.
- Rustdoc becomes much more usable when docs are navigable rather than plain text.

### `C-METADATA`

- `Cargo.toml` should usually include `authors`, `description`, `license`, `repository`, `keywords`, and `categories`.
- `documentation` is only necessary when docs do not live on docs.rs.
- `homepage` should point to a real project site, not repeat `repository` or `documentation`.

### `C-RELNOTES`

- Significant releases should have release notes or changelog entries.
- Mark breaking changes clearly.
- Published releases should correspond to tags in version control.
- Keep the release notes discoverable from crate-level docs and/or the repository.
- This matters less for throwaway internal crates and much more for public ecosystem crates.

### `C-HIDDEN`

- Keep rustdoc focused on what callers need, not every implementation detail.
- Hide conversion impls and helpers that users cannot meaningfully name or use directly.
- Restricted visibility like `pub(crate)` often improves docs and future refactoring freedom.
