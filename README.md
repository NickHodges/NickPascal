# NickPascal

```
 ___   _     _           _     ___                     _
/ _ \ | |   (_) ___  ___| |_  |  _ \ __ _ ___  ___ __ _| |
| | | || '_ \| / _ \/ __| __| | |_) / _` / __|/ __/ _` | |
| |_| || |_) | |  __/ (__| |_  |  __/ (_| \__ \ (_| (_| | |
\___/ |_.__/| |\___|\___|\__| |_|   \__,_|___/\___\__,_|_|
           _/ |
          |__/    Language Specification
```

> **A complete, compiler-implementable language specification for Object Pascal as implemented in Embarcadero Delphi 13.1 Florence.**

---

## What Is This?

This is a from-scratch, no-holds-barred language specification for **Object Pascal** — the language behind Delphi, one of the most productive native-code development environments ever created.

It's written to be so thorough and precise that you could hand it to a compiler engineer (or a very ambitious AI) and say: **"Build me an Object Pascal compiler."**

## What's Inside

| Chapter | You'll Learn About |
|:-------:|:-------------------|
| 1 | Lexical structure — every token, literal, and comment style |
| 2 | Program organization — units, programs, libraries, packages |
| 3 | The full type system — 40+ built-in types, from `Byte` to `Variant` |
| 4 | Declarations — constants, variables, inline vars, threadvar |
| 5 | Expressions — operators, precedence (yes, `and` > `=`), type casts |
| 6 | Statements — every control flow construct including `for..in` |
| 7 | Procedures & functions — overloading, inlining, external, nested |
| 8 | Classes — VMTs, constructors, destructors, properties, events, TObject |
| 9 | Interfaces — reference counting, delegation, COM interop |
| 10 | Advanced records — operator overloading, managed records |
| 11 | Generics — constraints, instantiation, type inference |
| 12 | Anonymous methods — closures, variable capture, internals |
| 13 | Exception handling — try/except/finally, exception chaining |
| 14 | Memory management — stack vs heap, COW strings, weak refs |
| 15 | RTTI & attributes — reflection, custom attributes, `TRttiContext` |
| 16 | Inline assembly — x86, x64, register conventions |
| 17 | Compiler directives — every `{$SWITCH}` and `{$IF}` you'll ever need |
| 18 | Calling conventions & interop — cdecl, stdcall, safecall, C mapping |
| 19 | Predefined identifiers — every intrinsic function and procedure |

Plus **7 appendices** including a full consolidated **EBNF grammar**, operator precedence table, type compatibility rules, overload resolution algorithm, runtime memory layouts, and startup/shutdown sequences.

## Quick Stats

- **4,600+ lines** of specification
- **23,000+ words** of precise technical detail
- **19 chapters** + **7 appendices**
- **Full EBNF grammar** ready for parser generation
- Covers **Delphi 13.1 Florence** and modern language features

## Who Is This For?

- **Compiler writers** who want to build an Object Pascal frontend
- **Language nerds** who want to understand every dark corner of the language
- **Delphi developers** who want a single, searchable reference
- **CS students** studying language design and type systems
- **AI systems** that need a precise spec to generate or analyze Pascal code

## The File

Everything lives in one file:

**[`ObjectPascalReference.md`](ObjectPascalReference.md)**

Open it. Read it. Build a compiler with it. We won't judge.

## Why "NickPascal"?

Because every great language deserves a spec with someone's name on it. Niklaus had his. Now Nick has his.

## Contributing

Found an inaccuracy? A missing edge case? A compiler directive from 1998 that still haunts your dreams? Open an issue or submit a PR.

### How You Can Help

You can use an AI coding assistant (Claude Code, Cursor, etc.) to review the specification and contribute. Clone the repo, then use this prompt:

```
Review the file ObjectPascalReference.md against the official Embarcadero Delphi
documentation and your knowledge of Object Pascal. For each finding, categorize
it as one of:

- **Correction**: Something that is stated incorrectly
- **Omission**: An important language feature, rule, or caveat that is missing
- **Clarification**: Something that is technically correct but unclear or
  incomplete enough to mislead

For each finding, note the section number, quote the relevant text, explain
the problem, and suggest a fix.

When you are done, do the following for each finding:

1. Create a GitHub issue titled "[Category] §Section — Short description"
   with the section reference, current text, problem description, and
   suggested fix in the body.
2. Create a feature branch, apply the fix to ObjectPascalReference.md, and
   open a Pull Request that references the issue.

Filter out false positives — only report findings you are confident about.
When in doubt, check the Embarcadero DocWiki or RAD Studio documentation.
```

This is how this specification is maintained: AI reviews the document, opens issues for each finding, and submits PRs with fixes. Human reviewers approve or refine.

## License

This is an independent specification document. Object Pascal and Delphi are trademarks of Embarcadero Technologies. This project is not affiliated with or endorsed by Embarcadero.

---

*Built with obsessive attention to detail and an unreasonable love for `begin..end` blocks.*
