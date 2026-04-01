# API Design

## Predictability

### `C-SMART-PTR`

- Smart pointers should avoid inherent methods that can be confused with methods on the pointee through `Deref`.
- Prefer associated functions like `Box::into_raw(boxed)` over methods like `boxed.into_raw()`.

### `C-CONV-SPECIFIC`

- Put conversion APIs on the more specific type.
- This keeps generic or lower-level types from accumulating endless ad-hoc helpers and makes method chaining natural.

### `C-METHOD`

- If an operation has an obvious receiver, prefer a method over a free function.
- Methods improve discoverability, leverage autoborrowing, and better communicate ownership.

### `C-NO-OUT`

- Return tuples or structs instead of using out-parameters, unless the API is intentionally mutating caller-owned storage such as buffers.
- Out-parameters make signatures harder to read and are rarely needed for performance in Rust.

### `C-OVERLOAD`

- Operator overloads should match user expectations for the operator's semantics.
- Avoid clever overloads that are legal but surprising.

### `C-DEREF`

- Restrict `Deref` and `DerefMut` to genuine smart pointers.
- `Deref` affects method resolution and implicit coercions, so misuse leaks surprising behavior throughout the API.

### `C-CTOR`

- Constructors should be static inherent methods.
- Use `new` for the primary constructor unless the domain strongly suggests names like `open`, `connect`, or `bind`.
- Use `from_` constructors when extra parameters or unsafe preconditions make `From` unsuitable.
- If there are many construction options, prefer a builder.
- When a type exposes both `new` and `Default`, they should have the same behavior.

## Flexibility

### `C-INTERMEDIATE`

- If an API computes useful extra information along the way, consider returning it.
- Good APIs save callers from repeating expensive work or secondary lookups.

### `C-CALLER-CONTROL`

- Let the caller decide when to clone and when to transfer ownership.
- If the function needs ownership, take ownership directly.
- If it does not, borrow directly.
- Do not hide a clone inside the callee unless that is an intentional semantic choice.

### `C-GENERIC`

- Use generics to encode the real requirements of a function instead of pinning callers to specific container types.
- This usually improves reuse, inference, and performance, but excessive generic verbosity can hurt readability.
- Only generalize as far as the real contract justifies.

### `C-OBJECT`

- If a trait may be used behind `dyn Trait`, design for object safety early.
- Generic methods and methods returning `Self` are not object-safe unless isolated with `where Self: Sized`.
- Use this rule only when trait object use is plausible, not for every trait.

## Type Safety

### `C-NEWTYPE`

- Use newtypes to encode semantic distinctions such as units, identifiers, or validated wrappers.
- This moves mistakes from runtime into compile-time.

### `C-CUSTOM-TYPE`

- Replace ambiguous `bool` or `Option` parameters with enums, structs, tuple structs, or dedicated marker types.
- Richer types clarify meaning today and leave room for future expansion.

### `C-BITFLAG`

- Use bitflags for sets of combinable flags.
- Use enums when exactly one option should be chosen.

### `C-BUILDER`

- Introduce a builder when construction requires many inputs, optional configuration, compound data, or multiple flavors.
- Builder constructors should take only required inputs.
- Configuration methods should support chaining.
- Prefer non-consuming builders when final construction only needs shared or mutable access.
- Use consuming builders when final construction must take ownership of builder state.
