# Naming and Interoperability

## Naming

### `C-CASE`

- Use `UpperCamelCase` for types and traits.
- Use `snake_case` for functions, methods, modules, variables, and macros.
- Use `SCREAMING_SNAKE_CASE` for constants and statics.
- Use concise type parameter and lifetime names such as `T` and `'a`.
- Treat acronyms as normal words: `Uuid`, `Stdin`, `is_xid_start`.
- Avoid crate names with `-rs` or `-rust`.

### `C-CONV`

- Use `as_` for free borrowed-to-borrowed views.
- Use `to_` for conversions with meaningful runtime work or allocation.
- Use `into_` for owned-to-owned extraction or conversion where ownership is consumed.
- Use `into_inner()` for wrappers that expose the wrapped value.
- Keep `mut` in the position implied by the return type, for example `as_mut_slice`.

### `C-GETTER`

- Do not prefix ordinary getters with `get_`.
- Use `foo()` and `foo_mut()` for accessors.
- Reserve bare `get` when there is one obvious thing to get, especially indexed or validated access.
- If checked access exists, consider `get_unchecked` variants where performance and invariants justify it.

### `C-ITER` and `C-ITER-TY`

- Homogeneous collection APIs should expose `iter`, `iter_mut`, and `into_iter`.
- Iterator-returning methods should return types named after those methods, such as `Iter`, `IterMut`, `IntoIter`, `Keys`, and `Values`.
- Skip this convention when the abstraction is not really a plain collection, for example `str::chars`.

### `C-FEATURE`

- Prefer direct feature names like `std`, `serde`, and `simd`.
- Avoid placeholders or wrapper words like `use-std`, `serde-support`, or `enable-x`.
- Feature names become user-facing API surface, so optimize for clarity and stability.

### `C-WORD-ORDER`

- Keep family names consistent.
- Error families often use patterns like `ParseIntError`, `RecvTimeoutError`, and `StripPrefixError`.
- Inconsistency here hurts discoverability and makes APIs feel improvised.

## Interoperability

### `C-COMMON-TRAITS`

- Implement applicable standard traits eagerly on public types because downstream crates cannot add them later due to orphan rules.
- High-value traits are `Copy`, `Clone`, `Eq`, `PartialEq`, `Ord`, `PartialOrd`, `Hash`, `Debug`, `Display`, and `Default`.
- It is normal for a type to expose both `Default` and `new` when a no-argument constructor is sensible.

### `C-CONV-TRAITS`

- Implement `From`, `TryFrom`, `AsRef`, and `AsMut` when they fit.
- Do not write direct `Into` or `TryInto` impls; the blanket impls already derive them from `From` and `TryFrom`.
- Prefer standard traits over custom conversion functions when the conversion is general-purpose and unsurprising.

### `C-COLLECT`

- Collection-like types should implement `FromIterator` and `Extend`.
- This enables idiomatic use with `collect`, `partition`, `unzip`, and extension from iterators.

### `C-SERDE`

- Data structures should usually support `Serialize` and `Deserialize`.
- If Serde is otherwise unnecessary, gate it behind a feature literally named `serde`.
- This rule is about user value, not blanket derivation. Marker or phantom-like types often do not need serialization.

### `C-SEND-SYNC`

- Public types should be `Send` and `Sync` wherever the implementation allows it.
- Types using raw pointers, interior mutability, or unsafe code deserve explicit tests to prevent accidental regressions.
- Missing `Send` or `Sync` reduces composability with threads, executors, and common error-handling patterns.

### `C-GOOD-ERR`

- Public error types should implement `std::error::Error`, `Display`, and `Debug`.
- They should usually be `Send + Sync`, especially if they might cross thread boundaries or be wrapped in `io::Error`.
- Exposed error trait objects are usually most useful as `dyn Error + Send + Sync + 'static`.
- Never use `()` as a public error type.
- Keep `Display` messages concise, lowercase, and without trailing punctuation.
- Prefer meaningful unit structs over uninformative placeholder errors.

### `C-NUM-FMT`

- Bit-oriented numeric types should implement `LowerHex`, `UpperHex`, `Octal`, and `Binary`.
- This is especially relevant for bitflags and masks.
- Ordinary quantity wrappers often do not need these formatters.

### `C-RW-VALUE`

- Generic reader and writer functions should take `R: Read` and `W: Write` by value.
- Callers can still pass `&mut reader` or `&mut writer` because the standard library implements `Read` and `Write` for mutable references.
- Mention this in docs because newer Rust users often get stuck on the ownership model here.
