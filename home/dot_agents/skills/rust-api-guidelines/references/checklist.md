# Rust API Guidelines Checklist

Use this file for a fast audit pass. Each item includes the guideline ID and the main review question. For rationale and examples, open the matching file from `references/source-map.md`.

## Naming

- `C-CASE`: Do crates, modules, types, traits, enum variants, functions, methods, macros, constants, type parameters, and lifetimes follow Rust casing conventions?
- `C-CONV`: Do ad-hoc conversion methods use `as_`, `to_`, and `into_` consistently with cost and ownership?
- `C-GETTER`: Do getters avoid `get_` unless there is one obvious thing to get, and do mutable or unchecked variants follow standard naming?
- `C-ITER`: Do collection iterator methods use `iter`, `iter_mut`, and `into_iter`?
- `C-ITER-TY`: Do iterator-returning methods return types named `Iter`, `IterMut`, `IntoIter`, `Keys`, `Values`, and similar?
- `C-FEATURE`: Are Cargo feature names specific and free of placeholders like `use-std` when `std` is sufficient?
- `C-WORD-ORDER`: Do related names use consistent word order across error types and other families of types?

## Interoperability

- `C-COMMON-TRAITS`: Do public types eagerly implement applicable standard traits such as `Copy`, `Clone`, `Eq`, `Ord`, `Hash`, `Debug`, `Display`, and `Default`?
- `C-CONV-TRAITS`: Are standard conversions implemented via `From`, `TryFrom`, `AsRef`, and `AsMut`, instead of manual ad-hoc APIs or direct `Into` impls?
- `C-COLLECT`: Do collection-like types implement `FromIterator` and `Extend`?
- `C-SERDE`: Do data structures implement or optionally gate `Serialize` and `Deserialize` when that is useful?
- `C-SEND-SYNC`: Are types `Send` and `Sync` where possible, with tests if raw pointers or unsafe internals make this easy to regress?
- `C-GOOD-ERR`: Do public error types implement `Error`, `Display`, `Debug`, and usually `Send + Sync`, and avoid `()`?
- `C-NUM-FMT`: Do bitwise-oriented numeric types implement `LowerHex`, `UpperHex`, `Octal`, and `Binary` where appropriate?
- `C-RW-VALUE`: Do generic reader/writer APIs take `R: Read` and `W: Write` by value and document that callers can pass `&mut`?

## Macros

- `C-EVOCATIVE`: Does the macro input syntax resemble the Rust syntax it conceptually produces?
- `C-MACRO-ATTR`: Can callers attach attributes, including `cfg` and derives, to generated items?
- `C-ANYWHERE`: Does the item macro work in module scope and function scope?
- `C-MACRO-VIS`: Does the macro support standard visibility syntax like `pub`?
- `C-MACRO-TY`: Do type fragments accept primitives, relative paths, absolute paths, `super::`, and generics?

## Documentation

- `C-CRATE-DOC`: Does the crate have substantial crate-level docs with examples?
- `C-EXAMPLE`: Does each public item have a useful rustdoc example or a direct link to one?
- `C-QUESTION-MARK`: Do examples use `?` instead of `try!` or `unwrap` for fallible code?
- `C-FAILURE`: Do docs include `Errors`, `Panics`, and `Safety` sections when relevant?
- `C-LINK`: Does prose link to referenced items and related types?
- `C-METADATA`: Does `Cargo.toml` include common package metadata such as `authors`, `description`, `license`, `repository`, `keywords`, and `categories`, and are `documentation` / `homepage` set only when they are useful and non-redundant?
- `C-RELNOTES`: Are significant changes documented in release notes, with breaking changes clearly marked, published releases tagged, and the notes discoverable from crate docs or the repository?
- `C-HIDDEN`: Is rustdoc free of unhelpful implementation details, using `#[doc(hidden)]` or restricted visibility where needed?

## Predictability

- `C-SMART-PTR`: Do smart-pointer-like types avoid inherent methods that would be confusing through `Deref`?
- `C-CONV-SPECIFIC`: Do conversions live on the more specific type involved?
- `C-METHOD`: Are operations with a clear receiver implemented as methods rather than free functions?
- `C-NO-OUT`: Do functions return tuples or structs instead of taking out-parameters, except for true in-place mutation use cases?
- `C-OVERLOAD`: Are operator overloads intuitive and semantically close to the built-in operator meaning?
- `C-DEREF`: Is `Deref` limited to genuine smart pointers?
- `C-CTOR`: Are constructors static inherent methods, with `new` as the primary constructor unless the domain strongly suggests `open`, `connect`, `bind`, and similar names?

## Flexibility

- `C-INTERMEDIATE`: Do functions expose useful intermediate results instead of forcing duplicate work?
- `C-CALLER-CONTROL`: Do APIs let the caller decide where cloning or ownership transfer happens?
- `C-GENERIC`: Do function signatures use generics to encode the real requirements instead of over-constraining concrete types?
- `C-OBJECT`: Are traits object-safe when trait-object use is plausible, and are non-object-safe methods isolated with `where Self: Sized` where appropriate?

## Type Safety

- `C-NEWTYPE`: Are distinct meanings encoded as newtypes rather than bare primitives?
- `C-CUSTOM-TYPE`: Do parameters use enums, structs, or tuples instead of ambiguous `bool` or `Option` switches?
- `C-BITFLAG`: Are sets of flags modeled as bitflags rather than enums?
- `C-BUILDER`: Do complex constructors use a builder, preferring non-consuming builders when final construction does not require ownership?

## Dependability

- `C-VALIDATE`: Do functions enforce input validity statically when possible, otherwise dynamically with checked and optionally unchecked forms?
- `C-DTOR-FAIL`: Do destructors avoid fallible teardown?
- `C-DTOR-BLOCK`: Do destructors avoid blocking work or provide an explicit alternative API?

## Debuggability

- `C-DEBUG`: Do all public types implement `Debug` unless there is a strong reason not to?
- `C-DEBUG-NONEMPTY`: Does `Debug` output remain non-empty even for empty values?

## Future Proofing

- `C-SEALED`: Are internally controlled traits sealed and documented as sealed?
- `C-STRUCT-PRIVATE`: Are fields private unless the type is intentionally a passive data bag?
- `C-NEWTYPE-HIDE`: Do newtypes or equivalent wrappers hide implementation details that should stay flexible?
- `C-STRUCT-BOUNDS`: Do generic data structures avoid redundant trait bounds, especially derivable ones?

## Necessities

- `C-STABLE`: Does every public dependency exposed in the public API satisfy the crate's stability story?
- `C-PERMISSIVE`: Do the crate and its dependencies use a licensing setup compatible with intended Rust ecosystem reuse?
