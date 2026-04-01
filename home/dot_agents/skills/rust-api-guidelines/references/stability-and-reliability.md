# Stability and Reliability

## Dependability

### `C-VALIDATE`

- Prefer static validation through the type system when possible.
- Fall back to dynamic checks when the property is not practical to encode in types.
- If performance-sensitive callers may need to skip checks, provide explicit unchecked variants such as `_unchecked` or a `raw` module.

### `C-DTOR-FAIL`

- Destructors must not fail.
- If teardown can fail, provide an explicit method like `close` that reports errors, and let `Drop` ignore or log failures.

### `C-DTOR-BLOCK`

- Destructors should avoid blocking operations.
- If cleanup may block, expose an explicit non-`Drop` path so callers can control when it happens.

## Debuggability

### `C-DEBUG`

- Public types should almost always implement `Debug`.
- Exceptions should be rare and justified.

### `C-DEBUG-NONEMPTY`

- `Debug` output should never be empty, even for conceptually empty values.
- Empty debug output makes diagnostics harder to trust and harder to read.

## Future Proofing

### `C-SEALED`

- Seal traits that are not meant for downstream implementation.
- This preserves freedom to add methods later without breaking downstream crates.
- Document that the trait is sealed so users do not waste time trying to implement it.

### `C-STRUCT-PRIVATE`

- Public fields are a strong representation commitment.
- Use private fields plus methods unless the type is intentionally passive data.

### `C-NEWTYPE-HIDE`

- Use newtypes or similar wrappers to hide complex concrete return types and internal representation choices.
- This preserves refactoring freedom and often simplifies signatures.

### `C-STRUCT-BOUNDS`

- Avoid trait bounds on generic data structures when the bounds are derivable or otherwise unnecessary.
- Redundant bounds reduce future flexibility and can turn harmless trait derivations into breaking changes.
- Exceptions mainly exist for associated types, `?Sized`, and bounds required by `Drop`.

## Necessities

### `C-STABLE`

- A stable crate cannot expose unstable public dependencies in its public API.
- Public dependency leakage can happen through argument types, return types, trait impls, and conversions.

### `C-PERMISSIVE`

- Publishable ecosystem crates should use a permissive license setup compatible with normal Rust reuse.
- `MIT OR Apache-2.0` is the common baseline, though other permissive choices can also be workable.
- Dependency licenses matter too because they can restrict downstream distribution.
