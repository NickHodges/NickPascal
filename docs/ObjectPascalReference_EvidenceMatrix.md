# Object Pascal Reference Evidence Matrix

This matrix records the current high-risk claims and inconsistencies found during the audit.

## Status Legend

- `verified` - backed by an authoritative source already reviewed
- `internally-corrected` - fixed to remove a repo-internal contradiction
- `needs-external-validation` - cannot yet be stated as settled without additional source or compiler verification
- `deferred-to-phase-6` - relevant to the later Metamorf pass, not the current reference-first phase

| Section | Claim or Issue | Status | Evidence | Action |
| --- | --- | --- | --- | --- |
| `1.4` | Identifier grammar was ASCII-only, while Delphi source accepts Unicode alphabetic and alphanumeric identifier characters | `verified` | Embarcadero DocWiki: `Fundamental Syntactic Elements (Delphi)` -> `Identifiers` | Update lexical wording and Appendix terminal aliases |
| `1.8` | String constants are defined as quoted strings and control strings; mixed quoted/control fragments combine into one character string | `verified` | Embarcadero DocWiki: `Fundamental Syntactic Elements (Delphi)` -> `Character Strings` | Use `CONTROL_STRING` terminology and align prose |
| `1.5` / `A.1` | `on` and `at` are better described as context-restricted reserved words than as context-sensitive reserved words | `verified` | Embarcadero lexical documentation plus current reserved-word table semantics | Use consistent terminology in chapter prose and appendix note |
| `1.6` / `A.2` | `private`, `protected`, `public`, `published`, and `automated` behave directive-like generally but reserved-word-like inside class declarations | `verified` | Embarcadero notes on reserved words vs directives for class declarations | Clarify scope-dependent treatment in chapter and appendix note |
| `1.4.1` / `2.3` | Later chapter grammar still used `IDENT` and `IDENT_LIST` shorthand without chapter-level alias definitions after the lexical rewrite | `internally-corrected` | Repo-internal inconsistency between Chapter 1 lexical productions and later grammar snippets | Define chapter-level aliases and align repeated `UNIT_NAME` production |
| `C.11` | Terminal-symbol note incorrectly referenced Chapter 2 instead of the lexical chapter | `internally-corrected` | Repo-internal inconsistency in `ObjectPascalReference.md` | Correct chapter reference to Chapter 1 |
| `C.11` | Terminal-symbol definitions were incomplete and drifted from Chapter 1 (`IntegerLiteral`, `StringLiteral`) | `internally-corrected` | Chapter 1 vs Appendix C mismatch | Re-anchor Appendix C terminals to Chapter 1 lexical productions |
| `1.7` | Binary `%...` and octal `&...` literal claims need direct Florence-era validation | `needs-external-validation` | Current reference text, review-fix linkage, and Metamorf assumptions exist; reviewed Florence lexical doc is not sufficient proof by itself | Keep open until compiler or newer authoritative evidence is captured |
| `1.4` / `1.7` | `&` escaped-identifier disambiguation versus octal literals needs direct validation for Delphi 13.1 Florence | `needs-external-validation` | Current reference and fix ledger mention it; reviewed official lexical doc confirms `&` for extended identifiers but does not fully settle the interaction with octal literals | Add targeted compiler experiment or stronger source |
| `Review Fix 1` / `1.8` | The fix ledger mentions caret sequences such as `^A`, but current reference text and reviewed official docs only document quoted strings plus control strings (`#nn`, `#$nn`) | `needs-external-validation` | `ObjectPascalReference_ReviewFixes.md`, current reference, Embarcadero `Character Strings` docs | Confirm current Delphi behavior before asserting caret-sequence support in normative prose |
| `A.1` / `A.2` | Reserved-word vs directive classification needs a final reconciliation pass for `on`, `at`, visibility words, and `automated` | `verified` | Embarcadero DocWiki: `Reserved Words` and `Directives` notes | Reconcile appendix wording in current phase |
| `1.8.1` | Multiline-string introduction version is disputed between current repo wording and currently reviewed Embarcadero documentation | `needs-external-validation` | Current reference says Delphi 11; reviewed Florence `Fundamental Syntactic Elements (Delphi)` page says multiline strings were added in RAD Studio 12.0 | Resolve before treating the version tag as settled |
| `Reconciliation` | Local working-copy changes that weakened or contradicted newer `main` content were rolled back to the shared `c000fec` baseline before further review | `internally-corrected` | `main`, `origin/main`, and `upstream/main` all point to `c000fec`; local diff was reconciled against that baseline | Continue future fixes as small, evidence-backed deltas from `c000fec` |
| `Metamorf` | Comment syntax, numeric literal coverage, and token classification must be checked against the revised reference only after the reference-first pass | `deferred-to-phase-6` | Local `.mor` files and Metamorf README | Handle during post-reference Metamorf audit |
