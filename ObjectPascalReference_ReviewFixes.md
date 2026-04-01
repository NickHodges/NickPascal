# Object Pascal Language Specification — Review Fixes

**Branch:** [`review-fixes`](https://github.com/omonien/nickpascal/tree/review-fixes) | **Date:** April 2, 2026

---

## All Fixes

### 1. [`ecacf5f`](https://github.com/omonien/nickpascal/commit/ecacf5f) — Correct `STRING_LITERAL` grammar to accept any sequence of string parts

The EBNF for `STRING_LITERAL` only allowed a single quoted segment. In Delphi, a string literal can be a sequence of quoted parts, control characters (`#nn`), and caret sequences (`^A`). The grammar was corrected to accept any combination of these string parts.

---

### 2. [`fdb6209`](https://github.com/omonien/nickpascal/commit/fdb6209) — Remove redundant `_` in `IDENTIFIER` EBNF and add `&` disambiguation rule

The `IDENTIFIER` production listed `_` as a separate alternative even though it was already covered by the character set. Also added the `&` prefix rule that forces the lexer to treat a following reserved word as an identifier.

---

### 3. [`843380b`](https://github.com/omonien/nickpascal/commit/843380b) — Correct `METHOD_HEADER` grammar: class modifier precedes method kind keyword

The EBNF had the `class` keyword in the wrong position. In Delphi, `class` precedes the method kind: `class function Foo` not `function class Foo`.

---

### 4. [`2a0434f`](https://github.com/omonien/nickpascal/commit/2a0434f) — Use `QualifiedIdent` in `ProcHeader`/`FuncHeader` for method implementations in Appendix C.4

Method implementations use qualified names (`TMyClass.DoSomething`), but the EBNF used plain `Ident`. Changed to `QualifiedIdent` to match actual syntax.

---

### 5. [`fbe91bc`](https://github.com/omonien/nickpascal/commit/fbe91bc) — Replace undefined `VALUE_TYPE_CONSTRUCTOR` in §5.1 `FACTOR` and add if-expression disambiguation note

`VALUE_TYPE_CONSTRUCTOR` was used in the `FACTOR` production but never defined anywhere. Replaced with the correct production. Also added a note about disambiguating the `if`-expression (ternary operator) from the `if`-statement.

---

### 6. [`94926f4`](https://github.com/omonien/nickpascal/commit/94926f4) — Demote `WriteLn`/`Write`/`Result`/`Self` from keywords to predefined identifiers

In Delphi, `WriteLn`, `Write`, `Result`, and `Self` are not reserved words — they are predefined (magic) identifiers that can be redeclared. The token definitions were updated accordingly.

---

### 7. [`4a23739`](https://github.com/omonien/nickpascal/commit/4a23739) — Correct `{$T-}` and `{$POINTERMATH}` descriptions in compiler switch table in §17.2

The descriptions for `{$T-}` (typed pointers) and `{$POINTERMATH}` were swapped or inaccurate. Corrected to match the actual compiler behavior.

---

### 8. [`4d8e86a`](https://github.com/omonien/nickpascal/commit/4d8e86a) — Clarify `goto` into/out of `try` blocks as compile-time error in §6.10

The spec said jumping into or out of a `try` block with `goto` was "undefined behavior." In Delphi, this is actually a compile-time error — the compiler rejects it.

---

### 9. [`44bda59`](https://github.com/omonien/nickpascal/commit/44bda59) — Clarify `Round`/`Trunc` validity in constant expression positions in §5.13

`Round` and `Trunc` were listed as valid in constant expressions, but they are not universally accepted by the compiler in all constant contexts (e.g., array bounds). Added a note about the limitations.

---

### 10. [`ba9ad93`](https://github.com/omonien/nickpascal/commit/ba9ad93) — Specify valid positions for inline variable declarations in §4.5.3

The spec said inline vars can appear "at the point of first use" but did not specify where exactly they are permitted (e.g., not inside `repeat..until` condition, not inside `with` designator). Added the precise rules.

---

### 11. [`b3dba37`](https://github.com/omonien/nickpascal/commit/b3dba37) — Add generic angle-bracket disambiguation rule in §11.2

When the parser encounters `Foo<Bar>`, it must decide whether `<` is the start of a generic type parameter list or a relational less-than operator. Added the context-driven disambiguation rule the compiler uses.

---

### 12. [`7dc376c`](https://github.com/omonien/nickpascal/commit/7dc376c) — Add `not in` infix operator rule to grammar

The `not in` compound operator (Delphi 13+) needed its own grammar rule in the metamorf parser. Added `expr.not_in` at precedence 10 (relational level).

---

### 13. [`6b7cec0`](https://github.com/omonien/nickpascal/commit/6b7cec0) — Add `uses SysUtils` to `mathlib.pas` test fixture

The test file used `Exception` without importing `SysUtils`. Added the missing `uses` clause.

---

### 14. [`13c5da8`](https://github.com/omonien/nickpascal/commit/13c5da8) — Document `SetLength` copy-on-write behavior for shared dynamic arrays in §3.6.1

When two dynamic array variables share the same backing store (reference count > 1), calling `SetLength` on one triggers a copy-on-write: the array is duplicated before resizing. This was undocumented.

---

### 15. [`5fe4379`](https://github.com/omonien/nickpascal/commit/5fe4379) — Correct Variant arithmetic conversion priority: numeric types over string in §3.9.1

The spec implied string conversion could take priority in Variant arithmetic. In reality, numeric types always take precedence: `Variant('3') + Variant(4)` yields `7` (Integer), not `'34'` (string).

---

### 16. [`d2443e6`](https://github.com/omonien/nickpascal/commit/d2443e6) — Document for-loop control variable value after `break` in §6.7

After a `break` statement exits a `for` loop, the control variable retains the value it had at the iteration where `break` was executed. This behavior was unspecified.

---

### 17. [`563e8cc`](https://github.com/omonien/nickpascal/commit/563e8cc) — Clarify `inherited` behavior: bare form vs named form in §8.9

Bare `inherited;` (without a method name) silently does nothing if no ancestor method exists. Named `inherited Foo;` is a compile-time error if `Foo` does not exist in any ancestor. This distinction was unclear.

---

### 18. [`842898e`](https://github.com/omonien/nickpascal/commit/842898e) — Document partial-construction requirement for destructors when constructor raises in §8.6

When a constructor raises an exception (called on a class reference), `Destroy` is called automatically on the partially-constructed instance. Destructors must therefore tolerate zero-initialized fields. Added explicit documentation.

---

### 19. [`35944a7`](https://github.com/omonien/nickpascal/commit/35944a7) — Clarify `{$M+}` propagation through inheritance chain for default visibility in §8.3

The `{$M+}` directive (which changes default visibility from `public` to `published`) propagates through the inheritance chain: once a class is compiled with `{$M+}`, all descendants inherit `published` as the default visibility, regardless of their own compiler state.

---

### 20. [`675e1c3`](https://github.com/omonien/nickpascal/commit/675e1c3) — Document hidden result pointer for large-value return types in §18.1.1

When a function returns a large value type (record, string, dynamic array, Variant), the caller allocates space and passes a hidden pointer as an extra parameter. This calling-convention detail was undocumented.

---

### 21. [`1bc8ac3`](https://github.com/omonien/nickpascal/commit/1bc8ac3) — Move `Pi` from math functions table to predefined constants in §19.2/§19.3.7

`Pi` is a predefined constant, not a function. It was incorrectly listed in the math functions table. Moved to the predefined constants section.

---

### 22. [`87d4e35`](https://github.com/omonien/nickpascal/commit/87d4e35) — Clarify bare `raise` outside `except` block as compile-time error in §13.2

A bare `raise;` (without an exception object) is only valid inside an `except` block to re-raise the current exception. Using it elsewhere is a compile-time error, not a runtime error as previously implied.

---

### 23. [`fcb2e21`](https://github.com/omonien/nickpascal/commit/fcb2e21) — Fix triple-quoted multi-line strings version: Delphi 11, not 12 in §1.8.1

Triple-quoted multi-line strings (`'''...'''`) were introduced in Delphi 11 Alexandria, not Delphi 12 Athens as stated. Corrected the version reference.

---

### 24. [`0c02dab`](https://github.com/omonien/nickpascal/commit/0c02dab) — Add `EXPORTS_CLAUSE` to `DECLARATION_SECTION` in §4.1

The `exports` clause was described in §2.2 and Appendix C.2 but was missing from the `DECLARATION_SECTION` production in §4.1. Added for consistency.

---

### 25. [`485105b`](https://github.com/omonien/nickpascal/commit/485105b) — Soften `RawByteString` restriction: inadvisable, not prohibited in §3.5.2

The spec said `RawByteString` "must not" be used as a variable type. In practice, the compiler allows it — it is inadvisable (because the code page is undefined) but not prohibited. Softened the language.

---

### 26. [`6be4baa`](https://github.com/omonien/nickpascal/commit/6be4baa) — Document type inference limitations for generic method calls in §11.4.1

Delphi's type inference for generic method calls is limited: it only infers from direct argument-to-parameter matches, not from return type context or nested expressions. Documented the specific limitations.

---

### 27. [`71fc40b`](https://github.com/omonien/nickpascal/commit/71fc40b) — Use `@label:` prefix for labels in symbol table to avoid conflating with constants

In the metamorf semantics implementation, labels and constants could collide in the symbol table. Added a `@label:` prefix to label entries to ensure distinct namespaces.

---

### 28. [`f7df14e`](https://github.com/omonien/nickpascal/commit/f7df14e) — Dispatch `WriteLn`/`Write` by name in `stmt.ident_stmt` and clean up grammar rules

Refactored the metamorf grammar to dispatch `WriteLn` and `Write` by identifier name rather than by dedicated keyword tokens. Removed the now-unnecessary `self`/`writeln`/`write` grammar rules.

---

### 29. [`de74bf8`](https://github.com/omonien/nickpascal/commit/de74bf8) — Fix directive count: 70+ → 59 in Appendix A.2

The heading claimed "70+" directives but only 59 are listed. Updated the count and its cross-reference in §A.1.

---

### 30. [`638eaf3`](https://github.com/omonien/nickpascal/commit/638eaf3) — Remove implementation-specific W1020 warning code from §8.2.1

A normative language specification should not reference internal compiler warning codes. Replaced "the compiler issues a warning (W1020)" with descriptive language.

---

### 31. [`7ef6122`](https://github.com/omonien/nickpascal/commit/7ef6122) — Add obsolescence note for `absolute INTEGER_LITERAL` form in §4.5.2

The integer-literal form of `absolute` dates from 16-bit real-mode DOS and causes access violations on modern protected-mode platforms. Added a warning that it exists only for backward compatibility.

---

### 32. [`0d39fd0`](https://github.com/omonien/nickpascal/commit/0d39fd0) — Clarify `Pi` type is platform-dependent in §4.3.1 and §19.2

On Win64 `Extended` = `Double`, so `Pi` has only ~15 significant digits rather than the ~19 digits available with 80-bit `Extended` on Win32. Added notes in both the example comment and the predefined constants table.

---

### 33. [`90bff43`](https://github.com/omonien/nickpascal/commit/90bff43) — Clarify `on`/`at` terminology: context-restricted reserved words in §A.1

The phrase "context-sensitive reserved words" is an oxymoron: reserved words are by definition not context-sensitive (unlike directives). Replaced with "context-restricted reserved words" and expanded the explanation of their dual nature.

---

### 34. [`eba2f44`](https://github.com/omonien/nickpascal/commit/eba2f44) — Add editorial note in §8.12 about misplacement in Classes chapter

Operator overloading applies only to records, yet §8.12 lives in Chapter 8 (Classes). Added a visible note directing readers to the canonical treatment in §10.4.

---

### 35. [`918f211`](https://github.com/omonien/nickpascal/commit/918f211) — Add Win64 VMT offsets and symbolic formula in Appendix F.2

The table previously showed Win32 offsets only with a vague note about Win64 being different. Added a Win64 column (offset × 2 since all entries are pointer-sized) and a general formula.

---

### 36. [`86ac60c`](https://github.com/omonien/nickpascal/commit/86ac60c) — Add Delphi 13 vs 13.1 version numbering clarification

Features are tagged inconsistently as "Delphi 13+" and "Delphi 13.1+" throughout the spec. Added a note explaining the relationship: both share the Florence codename, "Delphi 13+" means both releases, "Delphi 13.1+" means Florence-update-only.

---

### 37. [`82f1c38`](https://github.com/omonien/nickpascal/commit/82f1c38) — Add parsing disambiguation rules for `is not` and `not in` operators

Both are two-token compound operators that could be ambiguous with the unary `not` prefix. Added formal parsing rules: `not` after `is` is absorbed into the compound operator; `not in` is only recognized in infix position after a complete left-hand expression.

---

### 38. [`1de8e36`](https://github.com/omonien/nickpascal/commit/1de8e36) — Document `with`-statement and inline variable scope interaction in §6.14

Inline variable declarations inside a `with`-block interact with the `with`-scope injection in non-obvious ways. Added a note explaining shadowing behavior in both directions.

---

### 39. [`33dbad7`](https://github.com/omonien/nickpascal/commit/33dbad7) — Expand property specifier inheritance rules in §8.10.1

The spec said specifiers are "inherited" but did not detail which specifiers carry forward during partial re-declaration. Added explicit rules for `read`, `write`, `default`, `stored`, `index`, visibility, and type.

---

### 40. [`7865a9f`](https://github.com/omonien/nickpascal/commit/7865a9f) — Add missing EBNF productions and terminal definitions in Appendix C

Defines `ClassVarSection`, `OperatorDecl`, `ClassConstructorDecl`, and `ClassDestructorDecl` which were referenced but never defined. Adds new §C.11 with formal definitions for all terminal symbols used in the grammar: `Ident`, `Number`, `IntegerLiteral`, `RealLiteral`, `StringLiteral`, `StringConst`, `BoolConst`, `GUID`, and `AsmInstruction`.

---

### 41. [`653f142`](https://github.com/omonien/nickpascal/commit/653f142) — Document class constructors and class destructors in new §8.7.1

These were referenced in the EBNF (§8.1) but completely undocumented. Added syntax, execution timing, rules about no-explicit-calls, no-inheritance, use cases, and exception safety behavior.

---

### 42. [`e7b3f0e`](https://github.com/omonien/nickpascal/commit/e7b3f0e) — Document `TMonitor` hidden monitor field in §8.17

Every `TObject` instance has a hidden pointer-sized field for built-in lock support via `System.TMonitor`. This was completely unmentioned in the spec despite being a significant runtime feature since Delphi 2009.

---

### 43. [`325c374`](https://github.com/omonien/nickpascal/commit/325c374) — Add `{$ZEROBASEDSTRINGS}` deprecation guidance in §17.2

RTL functions remain 1-based regardless of this directive, making it a source of subtle off-by-one bugs. The mobile compilers it was designed for have been retired. Added recommendation against use.

---

### 44. [`74b443c`](https://github.com/omonien/nickpascal/commit/74b443c) — Explain `packed set` syntax and semantics in §3.6.3

The `packed` modifier is accepted before `set of` but has no effect since Delphi sets are already bit vectors. Added explanation noting this differs from `packed record`/`packed array` where `packed` does change layout.

---

### 45. [`219fa8d`](https://github.com/omonien/nickpascal/commit/219fa8d) — Add `CompilerVersion`/`VERxxx` history table in §17.4.1

The spec only mentioned `VER370` and `VER360` in passing. Added a complete mapping from Delphi 7 (`15.0`/`VER150`) through Delphi 13.1 Florence (`37.1`/`VER371`) with `CompilerVersion` float values and `VERxxx` symbols.

---

### 46. [`33d7c37`](https://github.com/omonien/nickpascal/commit/33d7c37) — Document `Assigned()` behavior with method references

`Assigned()` was listed for pointer/object/proc but method references (which are interface-backed) were unmentioned. Added method reference support to both the §5.14 summary and §19.3.5 table.

---

### 47. [`a2ad55b`](https://github.com/omonien/nickpascal/commit/a2ad55b) — Fix codenames: Delphi 13 is Florence not Athens, add repo reference

Athens is Delphi 12's codename. Both Delphi 13.0 and 13.1 are Florence. Corrected the version note and `CompilerVersion` table. Added reference to [omonien/Delphi-Version-Information](https://github.com/omonien/Delphi-Version-Information) for the comprehensive version mapping.

---

### 48. [`7830891`](https://github.com/omonien/nickpascal/commit/7830891) — State `TArray<T>` open array compatibility explicitly in §3.6.1

The existing note was minimal. Expanded to clearly confirm that `TArray<T>` is fully compatible with open array parameters and that this is the primary mechanism for passing generic collection contents to non-generic routines.

---

### 49. [`99df34a`](https://github.com/omonien/nickpascal/commit/99df34a) — Expand `Supports()` documentation with all overloads and examples in §9.9

Only two of four overloads were shown, and no usage examples were provided. Added the two-argument overloads (test-only, no `out` param) and the common query-and-use pattern.
