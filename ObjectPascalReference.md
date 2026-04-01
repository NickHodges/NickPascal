# Object Pascal Language Specification

## As Implemented in Embarcadero Delphi (Version 13.1 Florence)

### Version 1.1 — March 2026

---

## Document Conventions

### EBNF Notation

This specification uses Extended Backus-Naur Form (EBNF) to describe the syntax.

| Notation   | Meaning                                |
|------------|----------------------------------------|
| `=`        | Definition                             |
| `;`        | End of production rule                 |
| `\|`       | Alternation (choice)                   |
| `( )`      | Grouping                               |
| `[ ]`      | Optional (zero or one)                 |
| `{ }`      | Repetition (zero or more)              |
| `' '`      | Terminal string (literal)              |
| `" "`      | Terminal string (alternate delimiters) |
| `-`        | Exception (set difference)             |

### Terminology

- **shall** — mandatory requirement for a conforming implementation
- **should** — recommended but not mandatory
- **may** — optional behavior
- **undefined behavior** — the specification imposes no requirements
- **implementation-defined** — behavior defined by each implementation and documented

Keywords appear in **`bold monospace`** and are shown in lowercase. The language is **case-insensitive**: `Begin`, `BEGIN`, and `begin` are identical tokens.

---

## Table of Contents

1. [Lexical Structure](#chapter-1-lexical-structure)
2. [Program Organization](#chapter-2-program-organization)
3. [Types](#chapter-3-types)
4. [Declarations](#chapter-4-declarations)
5. [Expressions](#chapter-5-expressions)
6. [Statements](#chapter-6-statements)
7. [Procedures and Functions](#chapter-7-procedures-and-functions)
8. [Classes](#chapter-8-classes)
9. [Interfaces](#chapter-9-interfaces)
10. [Advanced Records](#chapter-10-advanced-records)
11. [Generics](#chapter-11-generics)
12. [Anonymous Methods and Method References](#chapter-12-anonymous-methods-and-method-references)
13. [Exception Handling](#chapter-13-exception-handling)
14. [Memory Management and Object Lifecycle](#chapter-14-memory-management-and-object-lifecycle)
15. [Runtime Type Information (RTTI) and Attributes](#chapter-15-runtime-type-information-rtti-and-attributes)
16. [Inline Assembly](#chapter-16-inline-assembly)
17. [Compiler Directives](#chapter-17-compiler-directives)
18. [Calling Conventions and Interoperability](#chapter-18-calling-conventions-and-interoperability)
19. [Predefined Identifiers and Intrinsic Routines](#chapter-19-predefined-identifiers-and-intrinsic-routines)

Appendices:
- [A. Complete Reserved Words and Directives](#appendix-a-complete-reserved-words-and-directives)
- [B. Operator Precedence Table](#appendix-b-operator-precedence-table)
- [C. Consolidated EBNF Grammar](#appendix-c-consolidated-ebnf-grammar)
- [D. Type Compatibility and Assignment Compatibility Rules](#appendix-d-type-compatibility-and-assignment-compatibility-rules)
- [E. Name Resolution and Overload Resolution Rules](#appendix-e-name-resolution-and-overload-resolution-rules)
- [F. Runtime Memory Layout](#appendix-f-runtime-memory-layout)
- [G. Program Startup and Shutdown Sequence](#appendix-g-program-startup-and-shutdown-sequence)

---

## Chapter 1: Lexical Structure

### 1.1 Source Text Encoding

A conforming implementation shall accept source files encoded in:

- UTF-8 (with or without BOM)
- UTF-16 LE (with BOM)
- Windows-1252 (CP1252) / ISO 8859-1 (legacy)

When a UTF-8 BOM (`EF BB BF`) or UTF-16 BOM (`FF FE`) is present, the implementation shall use the indicated encoding. In the absence of a BOM, the implementation shall assume a default encoding (implementation-defined; typically UTF-8 or the system ANSI code page).

String literals and comments may contain any Unicode code point permitted by the source encoding. Identifiers are restricted as specified in [§1.4](#14-identifiers).

### 1.2 Line Structure

Source text is divided into lines. A line terminator is one of:

- U+000D U+000A (CR LF) — Windows convention
- U+000A (LF)
- U+000D (CR)

Line numbers are used in error messages and `{$LINE}` directives. The first line of a source file is line 1.

### 1.3 Lexical Elements Overview

The lexical analysis phase (tokenization) converts source text into a sequence of tokens. The categories of tokens are:

1. **Reserved words** (keywords)
2. **Identifiers**
3. **Directive words** (context-sensitive identifiers)
4. **Numeric literals**
5. **String literals**
6. **Operators and delimiters**
7. **Comments**
8. **Compiler directives**

White space (spaces U+0020, horizontal tabs U+0009, and line terminators) serves to separate tokens and is otherwise ignored, except within string literals.

### 1.4 Identifiers

```
IDENTIFIER = LETTER { LETTER | DIGIT } ;
LETTER     = 'A'..'Z' | 'a'..'z' | '_' ;
DIGIT      = '0'..'9' ;
```

Rules:

1. Identifiers are **case-insensitive**. `MyVar`, `myvar`, and `MYVAR` all refer to the same entity.
2. Identifiers may begin with a letter or underscore, followed by zero or more letters, digits, or underscores.
3. The **significant length** of an identifier is 255 characters. Characters beyond position 255 are ignored for purposes of identity comparison.
4. An identifier that matches a **reserved word** ([§1.5](#15-reserved-words)) cannot be used as a user-defined identifier unless prefixed with `&` (the escaped identifier prefix). The `&` is not part of the identifier name; `&begin` refers to an identifier named `begin`.
5. Identifiers matching **directive words** ([§1.6](#16-directive-words)) may be used as user-defined identifiers, but this is discouraged.
6. **Lexer disambiguation for `&`**: When the lexer encounters `&`, it inspects the immediately following character. If the next character is a letter or `_`, the `&` is an escaped identifier prefix and the rest is scanned as an identifier (rule 4 above). If the next character is an octal digit (`0`–`7`), the `&` begins an `OCTAL_LITERAL` ([§1.7.1](#171-integer-literals)). No other character may follow `&`.

#### 1.4.1 Qualified Identifiers

```
QUALIFIED_IDENT = [ UNIT_NAME '.' ] IDENT ;
UNIT_NAME       = IDENT { '.' IDENT } ;
```

A qualified identifier uses dot notation to resolve ambiguity. `System.SysUtils.StrToInt` refers to the identifier `StrToInt` declared in unit `System.SysUtils`.

### 1.5 Reserved Words

Reserved words have fixed meaning in the language and cannot be used as identifiers (except via the `&` prefix). The complete list:

```
and          array        as           asm
at           begin        case         class
const        constructor  destructor   dispinterface
div          do           downto       else
end          except       exports      file
finalization finally      for          function
goto         if           implementation in
inherited    initialization interface
is           label        library      mod
nil          not          object       of
on           or           packed       procedure
program      property     raise        record
repeat       resourcestring set        shl
shr          string       then         threadvar
to           try          type         unit
until        uses         var          while
with         xor
```

Notes:
- `operator` and `out` are directive/contextual keywords ([§1.6](#16-directive-words)) — they have special meaning only in operator overloading declarations and parameter modifiers respectively, and may be used as identifiers elsewhere.
- `on` and `at` are context-sensitive reserved words: `on` has special meaning only inside `except` handler syntax; `at` only in `raise` statements. They cannot be used as identifiers without the `&` prefix.

### 1.6 Directive Words

Directive words are context-sensitive: they have special meaning in specific syntactic contexts but may be used as identifiers elsewhere. A conforming implementation shall recognize the following directives:

```
absolute        abstract        align           assembler
automated       cdecl           contains        default
delayed         deprecated      dispid          dynamic
experimental    export          external        far
final           forward         helper          implements
index           inline          local           message         name            near
nodefault       noreturn        operator        out
overload        override        package         pascal
platform        private         protected       public
published       read            readonly        reference
register        reintroduce     requires        resident
safecall        sealed          static          stdcall
stored          strict          unmanaged       unsafe
varargs         virtual         winapi          write
writeonly
```

Notes:
- Visibility specifiers (`private`, `protected`, `public`, `published`) are directives, not reserved words -- they can be used as identifiers outside class/record declarations, though this is strongly discouraged.
- `operator` and `out` appear here (not in [§1.5](#15-reserved-words)) because they are context-sensitive directives: `operator` is only meaningful in `class operator` declarations; `out` only as a parameter modifier.
- `message` is a directive used to declare Windows message-handler methods ([§8.8.7](#887-message-handler-methods)).
- `read` and `write` are property specifier directives ([§8.10](#810-properties)).

### 1.7 Numeric Literals

#### 1.7.1 Integer Literals

```
INTEGER_LITERAL  = DECIMAL_LITERAL | HEX_LITERAL | OCTAL_LITERAL | BINARY_LITERAL ;
DECIMAL_LITERAL  = DIGIT { DIGIT } ;
HEX_LITERAL      = '$' HEX_DIGIT { HEX_DIGIT } ;
OCTAL_LITERAL    = '&' OCTAL_DIGIT { OCTAL_DIGIT } ;
BINARY_LITERAL   = '%' BIN_DIGIT { BIN_DIGIT } ;
HEX_DIGIT        = '0'..'9' | 'A'..'F' | 'a'..'f' ;
OCTAL_DIGIT      = '0'..'7' ;
BIN_DIGIT        = '0' | '1' ;
```

The type of an integer literal is the smallest of the following types that can represent the value: `Integer` (32-bit signed), `Cardinal` (32-bit unsigned), `Int64` (64-bit signed), `UInt64` (64-bit unsigned). If the value exceeds `UInt64` range, a compile-time error shall be issued.

Underscores may be used as digit separators within numeric literals (Delphi 11+): `1_000_000`, `$FF_FF`, `%1111_0000`. Underscores shall not appear at the beginning or end of the digit sequence, and consecutive underscores are not permitted.

#### 1.7.2 Floating-Point Literals

```
FLOAT_LITERAL    = DIGIT_SEQ '.' DIGIT_SEQ [ EXPONENT ]
                 | DIGIT_SEQ EXPONENT ;
DIGIT_SEQ        = DIGIT { ['_'] DIGIT } ;
EXPONENT         = ('E' | 'e') [ '+' | '-' ] DIGIT_SEQ ;
```

Floating-point literals are of type `Extended` (80-bit on Win32, 64-bit/`Double` on Win64 and other 64-bit platforms). If the literal has no decimal point and no exponent, it is an integer literal, not floating-point.

### 1.8 String Literals

```
STRING_LITERAL   = STRING_PART { STRING_PART } ;
STRING_PART      = QUOTED_STRING | CHAR_LITERAL ;

QUOTED_STRING    = "'" { STRING_CHAR | "''" } "'" ;
STRING_CHAR      = (* any character except "'" and line terminators *) ;
CHAR_LITERAL     = '#' ( DECIMAL_LITERAL | HEX_LITERAL ) ;
```

Rules:

1. A single-quoted string `'Hello'` represents a string of characters.
2. Within a quoted string, two consecutive apostrophes `''` represent a single apostrophe character -- they are an escape sequence, **not** two empty strings being concatenated.
3. A `#` prefix followed by a decimal or hex integer specifies a character by its ordinal value. `#65` is the character `A`. `#$41` is also `A`.
4. A char literal may appear adjacent to a quoted string to form a single string constant: `'Hello'#13#10'World'` yields a string containing `Hello`, a CR/LF, and `World`. Two adjacent quoted strings separated by whitespace (`'Hello' 'World'`) are **not** concatenated -- use the `+` operator for explicit string concatenation: `'Hello' + 'World'`.
5. A string literal of length 1 is compatible with both `Char` and `string` types.
6. A string literal of length 0 (`''`) represents the empty string.
7. String literals are **not** null-terminated in their Pascal representation, but the runtime ensures a null terminator is present for interoperability with C APIs.

#### 1.8.1 Multi-Line String Literals

As of Delphi 12, multi-line string literals are supported using the triple-quoted syntax:

```
MULTILINE_STRING = "'''" { ANY_CHAR } "'''" ;
```

Rules:

1. Everything between the opening `'''` and closing `'''` is part of the string, including line breaks.
2. The opening `'''` must be followed by a line terminator; the content begins on the next line.
3. The closing `'''` must appear on its own line, preceded only by optional whitespace.
4. The leading whitespace of the closing `'''` line determines the *indentation prefix*. This prefix is stripped from each content line.
5. The resulting string uses the platform's native line ending.

### 1.9 Comments

```
COMMENT = LINE_COMMENT | BLOCK_COMMENT_BRACE | BLOCK_COMMENT_PAREN ;
LINE_COMMENT         = '//' { ANY_CHAR_EXCEPT_NEWLINE } LINE_TERMINATOR ;
BLOCK_COMMENT_BRACE  = '{' { ANY_CHAR_EXCEPT_CLOSE_BRACE } '}' ;
BLOCK_COMMENT_PAREN  = '(*' { ANY_CHAR_EXCEPT_STAR_PAREN } '*)' ;
```

Rules:

1. Comments are treated as white space (they separate tokens but produce no tokens themselves).
2. Comments do **not** nest. `{ { } }` — the first `}` ends the comment.
3. However, different comment styles **do not** interact: `{ (* } *)` — the `{` opens a brace comment; the `(*` inside it is just comment text; the `}` ends the brace comment; the `*)` is then a syntax error (or stray tokens). Conversely, `(* { *) }` — the `(*` opens a paren-star comment; the `{` is comment text; the `*)` ends the comment; the `}` is stray.
4. A `{` or `(*` that is immediately followed by `$` introduces a **compiler directive** ([§17](#chapter-17-compiler-directives)), not an ordinary comment.

### 1.10 Operators and Delimiters

#### 1.10.1 Single-Character Tokens

| Token | Name                  |
|-------|-----------------------|
| `+`   | Plus                  |
| `-`   | Minus                 |
| `*`   | Asterisk / Multiply   |
| `/`   | Slash / Real division |
| `=`   | Equals                |
| `<`   | Less than             |
| `>`   | Greater than          |
| `(`   | Left parenthesis      |
| `)`   | Right parenthesis     |
| `[`   | Left bracket          |
| `]`   | Right bracket         |
| `.`   | Dot                   |
| `,`   | Comma                 |
| `;`   | Semicolon             |
| `:`   | Colon                 |
| `^`   | Caret / Dereference   |
| `@`   | At sign / Address-of  |
| `#`   | Hash / Character literal prefix |
| `$`   | Dollar / Hex prefix   |
| `&`   | Ampersand / Escaped identifier prefix |

#### 1.10.2 Multi-Character Tokens

| Token  | Name                        |
|--------|-----------------------------|
| `:=`   | Assignment                  |
| `<>`   | Not equal                   |
| `<=`   | Less than or equal          |
| `>=`   | Greater than or equal       |
| `..`   | Range (subrange)            |
| `(.`   | Alternative for `[`         |
| `.)`   | Alternative for `]`         |
| `<<`   | Left shift (overloaded ops) |
| `>>`   | Right shift (overloaded ops)|

#### 1.10.3 Keyword Operators

The following reserved words function as operators:

| Keyword   | Operation                     |
|-----------|-------------------------------|
| `and`     | Bitwise/logical AND           |
| `or`      | Bitwise/logical OR            |
| `xor`     | Bitwise/logical XOR           |
| `not`     | Bitwise/logical NOT           |
| `div`     | Integer division              |
| `mod`     | Integer modulus               |
| `shl`     | Shift left                    |
| `shr`     | Shift right                   |
| `in`      | Set membership                |
| `is`      | Type test                     |
| `as`      | Type cast (checked)           |

### 1.11 Tokens — Maximal Munch Rule

When multiple token interpretations are possible, the lexer shall use the **maximal munch** rule: the longest possible sequence of characters that forms a valid token is consumed. For example, `>=` is one token (greater-than-or-equal), not `>` followed by `=`.

### 1.12 Implicit Semicolons and Statement Separation

Object Pascal uses **explicit semicolons** as statement separators (not terminators). A semicolon separates two statements; it does not terminate a single statement. Consequently:

- A semicolon before **`end`**, **`else`**, **`except`**, **`finally`**, or **`until`** is optional (it separates from an empty statement).
- A missing semicolon between two statements is a compile-time error.

---

## Chapter 2: Program Organization

### 2.1 Compilation Units

Object Pascal source code is organized into **compilation units**. There are three kinds:

1. **Program** — the main executable entry point.
2. **Unit** — a module containing declarations that can be used by other units or programs.
3. **Package** — a collection of units compiled into a shared library (BPL).

Additionally, a **Library** is a variant of a program that produces a dynamically linked library (DLL/SO) instead of an executable.

### 2.2 Programs

```
PROGRAM = PROGRAM_HEAD ';' [ USES_CLAUSE ]
          BLOCK '.' ;

PROGRAM_HEAD = 'program' IDENT [ '(' IDENT_LIST ')' ] ;
```

The optional `( IDENT_LIST )` after the program name is accepted for backward compatibility with ISO Pascal (file parameters) but is ignored by the compiler.

The **`block`** in a program constitutes the main body:

```
BLOCK = { DECLARATION_SECTION } COMPOUND_STATEMENT ;

DECLARATION_SECTION = CONST_SECTION
                    | TYPE_SECTION
                    | VAR_SECTION
                    | THREADVAR_SECTION
                    | LABEL_SECTION
                    | PROCEDURE_DECLARATION
                    | FUNCTION_DECLARATION
                    | EXPORTS_CLAUSE ;

COMPOUND_STATEMENT = 'begin' STMT_LIST 'end' ;
STMT_LIST          = [ STATEMENT { ';' STATEMENT } ] ;
```

The compound statement between `begin` and `end` is the program's entry point. Execution begins there after all unit initialization sections have executed.

### 2.3 Units

```
UNIT = UNIT_HEAD ';'
       INTERFACE_SECTION
       IMPLEMENTATION_SECTION
       [ INITIALIZATION_SECTION ]
       [ FINALIZATION_SECTION ]
       'end' '.' ;

UNIT_HEAD = 'unit' UNIT_NAME [ PORTABILITY_DIRECTIVE ] ;

UNIT_NAME = IDENT { '.' IDENT } ;
```

A unit name may contain dots, forming a **dotted unit name** (e.g., `System.SysUtils`). The dots are part of the unit name, not scope resolution operators. By convention the source file name matches the unit name with a `.pas` extension (e.g., `System.SysUtils.pas`), but this is not a language requirement: the `in` clause of a `uses` statement may redirect the compiler to any file: `uses MyUnit in 'SomeOtherFile.pas';`.

#### 2.3.1 Interface Section

```
INTERFACE_SECTION = 'interface'
                    [ USES_CLAUSE ]
                    { INTERFACE_DECL } ;

INTERFACE_DECL = CONST_SECTION
               | TYPE_SECTION
               | VAR_SECTION
               | THREADVAR_SECTION
               | PROCEDURE_HEADER ';' [ DIRECTIVE_LIST ';' ]
               | FUNCTION_HEADER ';' [ DIRECTIVE_LIST ';' ] ;
```

The interface section declares all entities that are **publicly visible** to other units. Procedure and function declarations in the interface section provide only the **header** (signature); the implementation (body) is in the implementation section.

#### 2.3.2 Implementation Section

```
IMPLEMENTATION_SECTION = 'implementation'
                         [ USES_CLAUSE ]
                         { DECLARATION_SECTION } ;
```

The implementation section contains:

1. The **bodies** of all procedures and functions declared in the interface section.
2. Additional **private** declarations (types, constants, variables, procedures, functions) that are not visible outside the unit.
3. An optional `uses` clause that imports units needed only in the implementation.

#### 2.3.3 Initialization and Finalization Sections

```
INITIALIZATION_SECTION = 'initialization' STMT_LIST ;
FINALIZATION_SECTION   = 'finalization' STMT_LIST ;
```

Alternatively, the initialization section may use the older syntax:

```
INITIALIZATION_SECTION = 'begin' STMT_LIST ;
```

(In this form, there can be no finalization section.)

**Execution order:**

1. **Initialization sections** execute in **dependency order**: if unit A uses unit B, then B's initialization executes before A's. Among units used in the same `uses` clause, initialization proceeds left to right.
2. **Finalization sections** execute in **reverse** dependency order when the program terminates.
3. A unit's initialization section executes at most once, even if the unit is used by multiple units.

#### 2.3.4 Circular Unit References

Two units may reference each other under the following constraint:

- At most one of the two circular `uses` references may appear in an **interface** section. The other must be in the **implementation** section.
- If both references are in interface sections, a compile-time error shall be issued.

### 2.4 The Uses Clause

```
USES_CLAUSE = 'uses' USES_ENTRY { ',' USES_ENTRY } ';' ;
USES_ENTRY  = UNIT_NAME [ 'in' STRING_LITERAL ] ;
```

The `in` clause specifies the source file path for the unit, used when the file name does not match the unit name or when the file is in a non-standard location. The path is relative to the file containing the `uses` clause.

**Scope rules for `uses`:**

1. Identifiers from a used unit are brought into scope as if qualified by the unit name.
2. Unqualified access is permitted if the identifier is unambiguous.
3. If two or more used units declare the same identifier, the **last** unit in the `uses` clause takes precedence for unqualified references. Other declarations can be accessed via qualification.
4. The interface `uses` clause is visible to both the interface and implementation sections. The implementation `uses` clause is visible only to the implementation section.

### 2.5 Libraries

```
LIBRARY = 'library' IDENT ';'
          [ USES_CLAUSE ]
          BLOCK '.' ;
```

A library compiles to a dynamic-link library (DLL on Windows, .so on Linux, .dylib on macOS). The block's compound statement (`begin..end`) serves as the DLL entry point (called on `DLL_PROCESS_ATTACH`).

### 2.6 Packages

```
PACKAGE = 'package' IDENT ';'
          [ REQUIRES_CLAUSE ]
          [ CONTAINS_CLAUSE ]
          'end' '.' ;

REQUIRES_CLAUSE = 'requires' IDENT_LIST ';' ;
CONTAINS_CLAUSE = 'contains' USES_ENTRY { ',' USES_ENTRY } ';' ;
```

Packages are groups of units compiled into a single BPL (Borland Package Library). Packages support:

- **`requires`** — declares dependencies on other packages.
- **`contains`** — lists units included in this package. A unit may appear in only one package.

### 2.7 Exports Clause

```
EXPORTS_CLAUSE = 'exports' EXPORTS_ENTRY { ',' EXPORTS_ENTRY } ';' ;

EXPORTS_ENTRY = IDENT [ '(' FORMAL_PARAMS ')' ]
                [ 'name' STRING_LITERAL ]
                [ 'index' INTEGER_LITERAL ]
                [ 'resident' ] ;
```

The `exports` clause makes procedures and functions available for dynamic linking. It is meaningful in **library** (.dll/.so) and **package** (.bpl) files. Programs technically accept the syntax but do not produce importable exports in normal use; the clause is not meaningful there.

- **`name`** — specifies the exported name (may differ from the Pascal identifier).
- **`index`** — specifies a numeric ordinal for the export (Windows only).
- **`resident`** — keeps the export name in memory for faster lookup (legacy, largely ignored).

### 2.8 Namespaces and Scope

#### 2.8.1 Scope Levels

Object Pascal has the following scope levels, from innermost to outermost:

1. **Block scope** — local variables in a `begin..end` block (including nested procedure/function scopes).
2. **Record/class scope** — members of a record or class.
3. **Unit scope (implementation)** — declarations in the implementation section.
4. **Unit scope (interface)** — declarations in the interface section.
5. **Used unit scopes** — declarations imported via `uses` clauses.
6. **Predefined scope** — built-in identifiers (`Integer`, `WriteLn`, `True`, etc.).

Name lookup proceeds from innermost to outermost scope. The first match is used. An inner declaration **shadows** an outer declaration of the same name.

#### 2.8.2 The `with` Statement and Scope

The `with` statement ([§6.14](#614-the-with-statement)) temporarily adds record/class member scopes to the current scope chain, creating potential for ambiguity. See [§6.14](#614-the-with-statement) for details.

#### 2.8.3 Unit Namespace Resolution

When a dotted unit name like `System.SysUtils` is used, the compiler attempts to match the longest possible prefix as a unit name. Given `System.SysUtils.StrToInt`:

1. Is `System.SysUtils.StrToInt` a known unit? No.
2. Is `System.SysUtils` a known unit containing `StrToInt`? Yes → resolved.

---

## Chapter 3: Types

### 3.1 Type System Overview

Object Pascal is a **statically typed**, **strongly typed** language. Every variable, constant, and expression has a type determined at compile time. Types are organized in a hierarchy:

```
Type
├── Simple Types
│   ├── Ordinal Types
│   │   ├── Integer Types
│   │   ├── Character Types
│   │   ├── Boolean Types
│   │   ├── Enumerated Types
│   │   └── Subrange Types
│   └── Real (Floating-Point) Types
├── String Types
│   ├── ShortString
│   ├── AnsiString
│   ├── UnicodeString (default "string")
│   ├── WideString
│   └── RawByteString
├── Structured Types
│   ├── Array Types
│   │   ├── Static Arrays
│   │   └── Dynamic Arrays
│   ├── Record Types
│   ├── Set Types
│   └── File Types
├── Pointer Types
├── Procedural Types
│   ├── Procedure/Function Pointers
│   ├── Method Pointers
│   └── Anonymous Method Types (method references)
├── Variant Types
├── Class Types
├── Class-Reference Types (Metaclasses)
├── Interface Types
└── Generic Types (Parameterized Types)
```

### 3.2 Type Identity and Compatibility

#### 3.2.1 Type Identity (Structural vs. Nominal)

Object Pascal uses **nominal typing**: two types are identical if and only if they refer to the same type declaration, or one is defined as equal to the other.

```pascal
type
  T1 = Integer;    // T1 is identical to Integer (type alias)
  T2 = Integer;    // T2 is identical to Integer (and to T1)
  T3 = type Integer; // T3 is a DISTINCT type (not identical to Integer)
```

The **`type`** keyword before a type name in a type declaration creates a **distinct type** that is assignment-compatible but not identical. Distinct types have their own RTTI.

#### 3.2.2 Assignment Compatibility

A value of type `S` is assignment-compatible with type `T` if any of the following is true:

1. `S` and `T` are identical types.
2. `S` is a subrange of `T`, or `T` is a subrange of `S`, or both are subranges of the same base type.
3. `S` and `T` are both ordinal types and the value of `S` is in the range of `T`.
4. `S` and `T` are both real types.
5. `S` is an integer type and `T` is a real type.
6. `S` and `T` are both string types.
7. `S` is a string type and `T` is `Char`, or vice versa (with length constraints).
8. `S` and `T` are compatible set types.
9. `S` is a descendant of `T`'s class type (widening), or `T` is an interface implemented by `S`.
10. `S` is `nil` and `T` is a pointer, class, class-reference, interface, procedural, or dynamic-array type.
11. `S` is a procedural type compatible with `T` (matching parameter lists and calling convention).
12. `S` is `Variant` and `T` is a type for which variant conversion is defined, or vice versa.

See [Appendix D](#appendix-d-type-compatibility-and-assignment-compatibility-rules) for the complete, formal rules.

### 3.3 Ordinal Types

Ordinal types are types whose values form a countable, ordered sequence. Every value has an **ordinal number** (an integer).

The following intrinsic functions operate on all ordinal types:

| Function    | Description                            |
|-------------|----------------------------------------|
| `Ord(X)`    | Ordinal number of `X`                  |
| `Pred(X)`   | Predecessor of `X`                     |
| `Succ(X)`   | Successor of `X`                       |
| `High(T)`   | Highest value of type `T`              |
| `Low(T)`    | Lowest value of type `T`               |

#### 3.3.1 Integer Types

| Type       | Size (bytes) | Range                                    | Signed |
|------------|-------------|------------------------------------------|--------|
| `ShortInt` | 1           | -128 .. 127                              | Yes    |
| `SmallInt` | 2           | -32768 .. 32767                          | Yes    |
| `Integer`  | 4           | -2147483648 .. 2147483647                | Yes    |
| `LongInt`  | 4           | same as `Integer`                        | Yes    |
| `Int64`    | 8           | -2^63 .. 2^63-1                          | Yes    |
| `Byte`     | 1           | 0 .. 255                                 | No     |
| `Word`     | 2           | 0 .. 65535                               | No     |
| `Cardinal` | 4           | 0 .. 4294967295                          | No     |
| `LongWord` | 4           | same as `Cardinal`                       | No     |
| `UInt64`   | 8           | 0 .. 2^64-1                              | No     |
| `NativeInt`| platform    | Signed, pointer-sized (4 or 8 bytes)     | Yes    |
| `NativeUInt`| platform   | Unsigned, pointer-sized                  | No     |

`Integer` is always 32 bits regardless of platform (unlike C). `NativeInt` and `NativeUInt` are pointer-sized and vary by target.

#### 3.3.2 Character Types

| Type       | Size (bytes) | Description                       |
|------------|-------------|-----------------------------------|
| `AnsiChar` | 1           | 8-bit character (byte)            |
| `WideChar` | 2           | 16-bit Unicode character (UTF-16) |
| `Char`     | 2           | Alias for `WideChar`              |

`Char` is always `WideChar` in modern Delphi. The ordinal value of a character is its Unicode code point (for `WideChar`) or byte value (for `AnsiChar`).

#### 3.3.3 Boolean Types

| Type        | Size (bytes) | Description                    |
|-------------|-------------|--------------------------------|
| `Boolean`   | 1           | `False` = 0, `True` = 1       |
| `ByteBool`  | 1           | `False` = 0, `True` = nonzero |
| `WordBool`  | 2           | `False` = 0, `True` = nonzero |
| `LongBool`  | 4           | `False` = 0, `True` = nonzero |

For `Boolean`, the only valid values are 0 (`False`) and 1 (`True`), and `not True` yields `False`. For `ByteBool`, `WordBool`, and `LongBool`, any nonzero value is `True`, but `not` performs a **bitwise complement**, not a logical negation. This means `not ByteBool(1)` yields `ByteBool($FE)`, which is still `True` (nonzero). Only when the `True` value has all bits set (e.g., `ByteBool($FF)`, i.e., `-1`) does `not` produce `False` (0). In COM interop, `VARIANT_BOOL` (`WordBool`) uses `-1` for `True` specifically so that `not True = False` holds. These wider boolean types exist for COM/Windows API interoperability.

#### 3.3.4 Enumerated Types

```
ENUM_TYPE = '(' ENUM_ELEMENT { ',' ENUM_ELEMENT } ')' ;
ENUM_ELEMENT = IDENT [ '=' CONST_EXPR ] ;
```

Example:
```pascal
type
  TColor = (clRed, clGreen, clBlue);
  TSuit = (Hearts = 1, Diamonds, Clubs, Spades);  // 1, 2, 3, 4
```

Rules:

1. By default, the first element has ordinal value 0, and each subsequent element has a value one greater than its predecessor.
2. An explicit `= CONST_EXPR` assigns a specific ordinal value. Subsequent elements without explicit values continue incrementing from the specified value.
3. Values need not be contiguous, but each must be greater than the previous. Duplicate values are not permitted.
4. The element identifiers are declared in the scope enclosing the type declaration (not scoped to the type).
5. **Scoped enumerations** (Delphi 2009+): When `{$SCOPEDENUMS ON}` is active, enumeration elements are scoped to their type and must be qualified: `TColor.clRed`. Without this directive, both `clRed` and `TColor.clRed` are valid.
6. The underlying storage size is chosen to accommodate all values: 1 byte if max ≤ 255, 2 bytes if max ≤ 65535, 4 bytes otherwise. The `{$Z}` directive can override minimum storage size.

#### 3.3.5 Subrange Types

```
SUBRANGE_TYPE = CONST_EXPR '..' CONST_EXPR ;
```

Example:
```pascal
type
  TMonth = 1..12;
  TUpperCase = 'A'..'Z';
```

Rules:

1. Both bounds must be constant expressions of the same ordinal type.
2. The lower bound must be less than or equal to the upper bound.
3. The base type of the subrange is the host type of the bounds.
4. Range checking (`{$R+}`) generates runtime checks for subrange assignments.

### 3.4 Real (Floating-Point) Types

| Type        | Size (bytes) | Significant digits | Range (approximate)        |
|-------------|-------------|--------------------|-----------------------------|
| `Single`    | 4           | 7-8                | 1.5e-45 .. 3.4e+38         |
| `Double`    | 8           | 15-16              | 5.0e-324 .. 1.7e+308       |
| `Extended`  | 10 (Win32)  | 19-20              | 3.4e-4932 .. 1.1e+4932     |
|             | 8 (Win64)   | 15-16              | same as `Double`            |
| `Comp`      | 8           | 19-20              | -2^63+1 .. 2^63-1 (integral)|
| `Currency`  | 8           | 19-20              | -922337203685477.5808 ..    |
|             |             |                    | 922337203685477.5807        |
| `Real`      | 8           | 15-16              | same as `Double`            |
| `Real48`    | 6           | 11-12              | 2.9e-39 .. 1.7e+38         |

Notes:

1. `Extended` is 80-bit on Win32 (x87) but maps to `Double` (64-bit) on Win64 and other 64-bit platforms where the x87 80-bit format is not natively supported.
2. `Currency` is a fixed-point type stored as a 64-bit integer with an implicit divisor of 10,000. It is the preferred type for monetary calculations.
3. `Comp` is deprecated. Use `Int64` instead.
4. `Real48` is the old Turbo Pascal 6-byte real format. It is retained for backward compatibility only.
5. `Real` is an alias for `Double`.

### 3.5 String Types

#### 3.5.1 UnicodeString (Default String Type)

`UnicodeString` is the default type for `string` (when `{$H+}` is active, which is the default). It is a **reference-counted**, **copy-on-write**, dynamically allocated string of `WideChar` elements (UTF-16 encoding).

Memory layout:

```
[CodePage: Word][ElemSize: Word][RefCount: Integer][Length: Integer][Char data...][#0#0]
```

- **CodePage** — 1200 for UTF-16.
- **ElemSize** — 2 (bytes per element).
- **RefCount** — reference count for COW semantics. -1 indicates a string constant (never freed).
- **Length** — number of `Char` elements (not bytes, not code points).
- The data is followed by a null `WideChar` for C interoperability.

Indexing is **1-based** by default. `S[1]` is the first character. (With `{$ZEROBASEDSTRINGS ON}`, indexing is 0-based.)

Assignment creates a new reference (increments ref count). Modification triggers copy-on-write if ref count > 1.

#### 3.5.2 AnsiString

`AnsiString` is a reference-counted string of `AnsiChar` elements. It carries a **code page** attribute:

```pascal
type
  UTF8String = AnsiString(65001);
  RawByteString = AnsiString($FFFF);
```

The code page is part of the type's identity at compile time. The runtime performs automatic code page conversion when assigning between `AnsiString` types with different code pages, and when converting to/from `UnicodeString`.

`RawByteString` (code page $FFFF) is a special "no conversion" type: it accepts any `AnsiString` without triggering code page conversion. It should only be used for parameters, never for variables.

#### 3.5.3 ShortString

```
SHORT_STRING_TYPE = 'string' '[' CONST_EXPR ']' ;
```

`ShortString` is a fixed-capacity string stored on the stack (or inline in a record). The maximum length is 255 characters. It is **not** reference counted.

Memory layout:

```
[Length: Byte][Char data: array[1..MaxLen] of AnsiChar]
```

`ShortString` with no length specifier has a maximum length of 255. `string[N]` declares a short string of maximum length `N` (1 ≤ N ≤ 255).

When `{$H-}` is active, `string` without a length specifier means `ShortString` (compatibility mode).

#### 3.5.4 WideString

`WideString` is a UTF-16 string type that uses COM BSTR allocation (`SysAllocStringLen`/`SysFreeString`). It is **not** reference counted (each assignment makes a deep copy). It exists primarily for COM interoperability on Windows.

#### 3.5.5 String Operators and Operations

| Operation | Description |
|-----------|-------------|
| `+`       | Concatenation |
| `=`, `<>`, `<`, `>`, `<=`, `>=` | Lexicographic comparison |
| `S[I]`    | Character access (1-based by default) |
| `Length(S)` | Number of characters |
| `SetLength(S, N)` | Resize string |

### 3.6 Structured Types

#### 3.6.1 Array Types

##### Static Arrays

```
STATIC_ARRAY_TYPE = 'array' '[' INDEX_TYPE { ',' INDEX_TYPE } ']' 'of' BASE_TYPE ;
INDEX_TYPE = ORDINAL_TYPE | SUBRANGE_TYPE ;
```

Example:
```pascal
type
  TMatrix = array[1..10, 1..10] of Double;
  TFlags  = array[Boolean] of string;
```

Static arrays are allocated inline (on the stack for locals, in the data segment for globals, inline in records/classes). Their size is fixed at compile time.

A multi-dimensional array `array[T1, T2] of X` is equivalent to `array[T1] of array[T2] of X`.

##### Dynamic Arrays

```
DYNAMIC_ARRAY_TYPE = 'array' 'of' BASE_TYPE ;
```

Dynamic arrays are **reference-counted**, heap-allocated. They are **0-based** (the first element is index 0). Unlike strings, dynamic arrays do **not** use copy-on-write; assigning one dynamic array variable to another shares the same data.

Memory layout:

```
[RefCount: Integer][Length: NativeInt][Element data...]
```

Operations:

| Operation | Description |
|-----------|-------------|
| `SetLength(A, N)` | Allocate/resize to N elements |
| `Length(A)` | Number of elements |
| `Low(A)` | Always 0 |
| `High(A)` | `Length(A) - 1` (-1 if empty) |
| `A + B` | Array concatenation (Delphi XE7+) |
| `Copy(A, I, N)` | Shallow copy of N elements starting at I |
| `Insert(Elem, A, I)` | Insert element at position I |
| `Delete(A, I, N)` | Delete N elements starting at I |
| `A := [1,2,3]` | Dynamic array constructor (Delphi XE7+) |

Dynamic arrays support **reference semantics**: assigning one dynamic array variable to another copies the reference (both point to the same data). Use `Copy` for a shallow value copy.

##### Open Array Parameters

An **open array parameter** accepts any array (static or dynamic) of a given element type:

```pascal
procedure Process(const Arr: array of Integer);
```

Within the procedure, `Low(Arr)` is always 0 and `High(Arr)` is `Length - 1`. Open arrays are passed as two hidden values: a pointer to the data and the high bound (not the length). The open array parameter is always effectively zero-indexed inside the called routine regardless of the source array's index range.

**Passing rules:**
- A static array `A: array[5..10] of Integer` may be passed to an open array parameter directly.
- A dynamic array `D: TArray<Integer>` may also be passed directly.
- A typed constant array is acceptable.

**Temporary array creation.** An array literal (bracket construct) may be passed directly at the call site:

```pascal
Process([1, 2, 3, 4]);   // compiler creates a temporary array on the stack
```

The temporary is created on the stack and lives for the duration of the call.

**`const` optimization.** Marking an open array parameter `const` allows the compiler to pass a pointer to static data without copying. For large arrays this avoids stack allocation. Use `const` whenever the callee does not need to modify the elements.

##### Array of Const

```pascal
procedure Format(const Args: array of const);
```

`array of const` is an open array of `TVarRec` records. Each element can hold a value of any type. This is the mechanism underlying `Format`, `WriteLn`, etc. Arguments of any type may be passed; the compiler automatically wraps each argument in the appropriate `TVarRec` variant.

#### 3.6.2 Record Types

```
RECORD_TYPE = 'record'
              { FIELD_SECTION }
              [ VARIANT_PART ]
              'end' [ 'align' CONST_EXPR ] ;

FIELD_SECTION = [ VISIBILITY ] FIELD_LIST ';'
              | METHOD_DECLARATION
              | PROPERTY_DECLARATION
              | CONST_SECTION
              | TYPE_SECTION
              | CLASS_VAR_SECTION
              | OPERATOR_DECLARATION ;

FIELD_LIST = IDENT_LIST ':' TYPE ;

VARIANT_PART = 'case' [ IDENT ':' ] ORDINAL_TYPE 'of'
               VARIANT { ';' VARIANT } [ ';' ] ;
VARIANT = CONST_EXPR_LIST ':' '(' FIELD_LIST { ';' FIELD_LIST } ')' ;
```

Records are **value types**. Assignment copies all fields. Records may contain:

- Fields (including variant parts for overlapping storage)
- Methods (instance and class/static)
- Properties
- Operators (overloaded)
- Nested type and constant declarations
- Class variables (`class var`)
- Constructors (but no destructors — records have no finalizer other than `Finalize` for managed fields)

Records **cannot** inherit from other records and do not support polymorphism. See [Chapter 10](#chapter-10-advanced-records) for advanced record features.

##### Variant Parts

Variant parts provide **overlapping storage** (like C unions). All variants share the same memory. The tag field (if named) occupies real storage; variants overlap after it.

```pascal
type
  TValue = record
    case Kind: Integer of
      0: (AsInteger: Integer);
      1: (AsDouble: Double);
      2: (AsChar: array[0..7] of Char);
  end;
```

The total size of the record is the size of the fixed fields plus the size of the **largest** variant.

##### Per-Record Alignment (`align`)

The optional `align` clause after `end` specifies the minimum alignment for the record type:

```pascal
type
  TAligned = record
    X: Byte;
    Y: Integer;
  end align 16;
```

The alignment value must be a constant expression evaluating to 1, 2, 4, 8, or 16. This controls both field alignment within the record and the alignment of the record type itself when allocated. The `align` clause has no effect on `packed` records.

When no `align` clause is specified, the compiler directive `{$ALIGN}` (or `{$A}`) controls field alignment (default is `{$A8}`).

#### 3.6.3 Set Types

```
SET_TYPE = 'set' 'of' ORDINAL_TYPE ;
```

The base ordinal type must have at most 256 values (ordinal range 0..255).

Storage: a bit vector of ⌈(High - Low + 1) / 8⌉ bytes. Bit `N` is set if value `N` is in the set.

Set constructors:

```pascal
var S: set of Byte;
S := [1, 3, 5..10, 20];
S := [];          // empty set
```

Set operators:

| Operator | Operation       |
|----------|-----------------|
| `+`      | Union           |
| `-`      | Difference      |
| `*`      | Intersection    |
| `=`      | Equality        |
| `<>`     | Inequality      |
| `<=`     | Subset          |
| `>=`     | Superset        |
| `in`     | Membership test |
| `Include(S, E)` | Add element (intrinsic procedure) |
| `Exclude(S, E)` | Remove element (intrinsic procedure) |

#### 3.6.4 File Types

```
FILE_TYPE = 'file' 'of' TYPE
          | 'file' ;
```

- **`file of T`** — typed file. `T` must not contain managed types (strings, dynamic arrays, interfaces, variants).
- **`file`** (untyped) — raw byte-level I/O.
- **`TextFile`** / **`Text`** — predefined type for line-oriented text I/O.

File variables shall not be assigned (copied). They must be passed by reference.

#### 3.6.5 File I/O Operations

File I/O follows a consistent protocol: associate a file variable with a filename, open it, perform reads/writes, and close it.

**Text files (`TextFile`):**

```pascal
var
  F: TextFile;
begin
  AssignFile(F, 'output.txt');
  Rewrite(F);             // create/truncate for writing
  WriteLn(F, 'Hello');    // write line
  CloseFile(F);

  AssignFile(F, 'output.txt');
  Reset(F);               // open for reading
  while not Eof(F) do
  begin
    var Line: string;
    ReadLn(F, Line);
  end;
  CloseFile(F);

  AssignFile(F, 'output.txt');
  Append(F);              // open for appending (text files only)
  WriteLn(F, 'Appended');
  CloseFile(F);
end;
```

**Typed files (`file of T`):**

```pascal
var
  F: file of TMyRecord;
  Rec: TMyRecord;
begin
  AssignFile(F, 'data.bin');
  Rewrite(F);
  Write(F, Rec);          // write one record
  CloseFile(F);

  Reset(F);
  while not Eof(F) do
    Read(F, Rec);          // read one record
  Seek(F, 0);             // reposition to beginning
  FilePos(F);             // current record index
  FileSize(F);            // total records
  CloseFile(F);
end;
```

**Untyped files (`file`):**

Untyped files use `BlockRead` and `BlockWrite` for raw byte-level I/O. `Reset` and `Rewrite` accept an optional record-size parameter (default 128):

```pascal
var
  F: file;
  Buf: array[0..4095] of Byte;
  BytesRead: Integer;
begin
  AssignFile(F, 'data.bin');
  Reset(F, 1);            // open with record size = 1 byte
  BlockRead(F, Buf, SizeOf(Buf), BytesRead);
  CloseFile(F);
end;
```

**I/O error handling:**

By default, I/O errors raise `EInOutError`. The `{$I-}` directive disables automatic checking; errors are then retrieved via `IOResult`:

```pascal
{$I-}
AssignFile(F, 'maybe.txt');
Reset(F);
if IOResult <> 0 then
  // file does not exist or cannot be opened
{$I+}
```

Each call to `IOResult` clears the stored error code. Calling any I/O routine while a pending `IOResult` has not been checked produces undefined behavior.

**Standard file variables:** `Input` and `Output` are predefined `TextFile` variables bound to stdin and stdout. `Write` and `WriteLn` without a file parameter write to `Output`; `Read` and `ReadLn` read from `Input`.

### 3.7 Pointer Types

```
POINTER_TYPE = '^' TYPE_IDENT ;
```

Example:
```pascal
type
  PInteger = ^Integer;
  PNode    = ^TNode;
```

Rules:

1. `Pointer` is the generic untyped pointer (like `void*` in C). It is compatible with all pointer types.
2. `nil` is the null pointer constant, compatible with all pointer, class, interface, procedural, and dynamic-array types.
3. The `^` operator dereferences a pointer: `P^` yields the value pointed to by `P`.
4. The `@` operator takes the address of a variable: `@X` yields a pointer to `X`.
5. Pointer arithmetic is supported when `{$POINTERMATH ON}` is active:
   - `P + N` advances the pointer by `N * SizeOf(T)` bytes.
   - `P - N` moves the pointer back.
   - `P - Q` yields the number of elements between two pointers of the same type.
   - Array indexing `P[N]` is equivalent to `(P + N)^`.
6. Forward declarations: a pointer type may reference a type not yet declared in the same `type` block. The forward reference is resolved at the end of the `type` block.

### 3.8 Procedural Types

```
PROC_TYPE   = PROCEDURE_TYPE | FUNCTION_TYPE | METHOD_TYPE_PROC | METHOD_TYPE_FUNC ;

PROCEDURE_TYPE   = 'procedure' [ FORMAL_PARAMS ] [ ';' CALLING_CONV ] ;
FUNCTION_TYPE    = 'function' [ FORMAL_PARAMS ] ':' RETURN_TYPE [ ';' CALLING_CONV ] ;
METHOD_TYPE_PROC = 'procedure' [ FORMAL_PARAMS ] 'of' 'object' [ ';' CALLING_CONV ] ;
METHOD_TYPE_FUNC = 'function' [ FORMAL_PARAMS ] ':' RETURN_TYPE 'of' 'object' [ ';' CALLING_CONV ] ;
```

Three categories:

1. **Procedure/function pointers** — point to standalone procedures/functions.
2. **Method pointers** (`of object`) — point to a method bound to a specific object instance. Stored as a pair: (code pointer, data/object pointer).
3. **Method references** (`reference to`) — see [Chapter 12](#chapter-12-anonymous-methods-and-method-references).

A procedural type variable can hold `nil`.

Example:
```pascal
type
  TNotifyEvent = procedure(Sender: TObject) of object;
  TCompareFunc = function(const A, B: Integer): Integer;
  TProc        = reference to procedure;
```

#### 3.8.1 Compatibility Rules

- **Procedure pointer vs method pointer**: these two categories are **not** assignment-compatible. A plain procedure pointer cannot hold a method pointer value, and vice versa. Both differ from method references (`reference to`).
- **Calling convention must match**: assigning a `cdecl` function to a `stdcall` procedural type variable, or vice versa, is a type error. The calling convention is part of the type.
- **Nested routine restrictions**: a nested (local) procedure/function cannot be assigned to a procedural type variable because it requires access to the enclosing stack frame in a way that is incompatible with a plain code pointer. Only top-level (unit-level) or class/record methods are valid sources.
- **Method references** (`reference to`) are compatible with both plain procedural types and method pointers when the signatures match, because method references capture a closure that can wrap either. However, the assignment direction matters: you cannot assign a method reference to a plain procedure pointer type.

### 3.9 Variant Type

The `Variant` type can hold values of many different types at runtime. Variants are used for COM Automation and late-binding scenarios.

Internal layout: `TVarData` record (16 bytes), containing a type code (`VType: Word`) and a data area.

Supported types: all ordinal types, real types, `Currency`, `string`, `Boolean`, `IDispatch`, `IUnknown`, `OleVariant`, arrays of `Variant`, and `nil` (`Unassigned` / `Null`).

Operations on variants are resolved at **runtime** using type coercion rules. If a coercion is not possible, an `EVariantError` exception is raised.

`OleVariant` is a variant type restricted to OLE-compatible types (no `AnsiString`, no custom types). It is used for COM interop.

#### 3.9.1 Variant Conversion Rules

When performing operations on variants, the compiler inserts runtime conversion calls. The conversion priority (highest to lowest):

1. If both operands are the same type, no conversion occurs.
2. If either operand is a `string`, the other is converted to `string`.
3. If either operand is `Double` (or `Extended`), the other is converted to `Double`.
4. If either operand is `Currency`, the other is converted to `Currency`.
5. If either operand is `Int64`, the other is converted to `Int64`.
6. Otherwise, both are converted to `Integer` (if they fit) or `Int64`.

Assigning a `Variant` to a typed variable performs an implicit conversion. If the conversion is not possible, `EVariantError` is raised.

Special values:

- **`Unassigned`** — the variant has no value (initial state). Any operation on an `Unassigned` variant raises `EVariantError`.
- **`Null`** — represents a database null or missing value. Arithmetic with `Null` propagates `Null` (unless `NullStrictConvert` is `True`, which raises an exception instead).

**Custom variant types** can be created by descending from `TCustomVariantType` and registering the type, enabling variants to hold arbitrary data with custom conversion and operator semantics.

#### 3.9.2 Variant Caveats

1. **Performance**: Variant operations are significantly slower than typed equivalents. Every operation involves runtime type checking, potential conversion, and dynamic dispatch. Avoid variants in performance-sensitive code paths.
2. **Late-bound calls lack compile-time checking**: Calling methods via `V.SomeMethod` (late binding through `IDispatch`) has no compile-time verification. If the method does not exist on the underlying object, an `EOleSysError` or `EVariantError` is raised at runtime.
3. **Implicit conversions can produce unexpected results**: For example, adding a string variant `'3'` to an integer variant `4` may produce `7` (numeric addition) or `'34'` (string concatenation) depending on the operation and conversion rules, which can mask logic errors.
4. **Best practice**: Prefer typed alternatives when the type is known at compile time. Reserve variants for COM interop, database field values, and other genuinely dynamic scenarios where the type is not known until runtime.

### 3.10 Type Aliases and Distinct Types

```pascal
type
  TMyInt = Integer;            // type alias — identical to Integer
  TMyDistinct = type Integer;  // distinct type — new RTTI, compatible but not identical
```

A type alias creates an alternative name for an existing type. The alias and the original are the **same type** for all purposes.

A `type T` declaration creates a **distinct type** that:
- Has its own RTTI
- Is assignment-compatible with the base type
- Is NOT identical to the base type (affects overload resolution, generic constraints)

### 3.11 Type Helpers

"Type helper" is the umbrella term for **class helpers** ([§8.15](#815-class-helpers)) and **record helpers**. Record helpers (shown below) extend simple types and record types; class helpers extend class types. The syntax for both uses `record helper` or `class helper` respectively -- there is no distinct `type helper` keyword.

```
TYPE_HELPER = 'record' 'helper' [ '(' PARENT_HELPER ')' ] 'for' SIMPLE_TYPE
              { MEMBER_DECLARATION }
              'end' ;
```

Type helpers extend simple types (integers, floats, strings, enums, sets) with methods and properties without subclassing:

```pascal
type
  TIntHelper = record helper for Integer
    function ToString: string;
    function InRange(Low, High: Integer): Boolean;
  end;
```

Rules:

1. Only **one** helper per type can be active in a given scope. If multiple helpers for the same type are in scope, the **last one** in `uses` clause order wins — all others are hidden, not merged.
2. For simple type helpers, resolution is by **exact type match**. A helper for `Integer` does not apply to a distinct type `type TMyInt = type Integer`. (Class helpers follow different rules — see [§8.15](#815-class-helpers).)
3. Helpers can extend any named simple type, record type, class type, or enumerated type.
4. Helper methods receive `Self` as an implicit parameter (by value for value types, by reference for class types).
5. Helpers can be chained via inheritance: `TExtendedHelper = record helper(TBaseHelper) for Integer` inherits the base helper's methods. However, the one-helper-per-type rule still applies — if both are in scope, only the descendant is active.
6. A helper's methods and properties take **precedence over** the type's own members. If the helped type already has a method `Foo`, the helper's `Foo` hides it (the helper's member wins).

---

## Chapter 4: Declarations

### 4.1 Declaration Order

Within a block, declaration sections may appear in any order and may be repeated:

```
DECLARATION_SECTION = LABEL_SECTION
                    | CONST_SECTION
                    | TYPE_SECTION
                    | VAR_SECTION
                    | THREADVAR_SECTION
                    | PROCEDURE_DECLARATION
                    | FUNCTION_DECLARATION ;
```

There is no required ordering (unlike original Pascal which required `label`, `const`, `type`, `var`, then procedures).

### 4.2 Label Declarations

```
LABEL_SECTION = 'label' LABEL { ',' LABEL } ';' ;
LABEL = IDENT | INTEGER_LITERAL ;
```

Labels are targets for `goto` statements. Their use is strongly discouraged. Labels must be declared in the same block that contains the `goto` and the labeled statement.

### 4.3 Constant Declarations

#### 4.3.1 True Constants

```
CONST_DECL = IDENT [ ':' TYPE ] '=' CONST_EXPR ';' ;
```

When no type is given, the constant's type is inferred from the expression. A typed constant with a simple type is a true compile-time constant.

```pascal
const
  Pi = 3.14159265358979;          // inferred as Extended
  MaxItems: Integer = 100;        // typed constant (see [§4.3.2](#432-typed-constants-initialized-variables))
  AppName = 'MyApp';              // inferred as string
  Flags = [fsReadOnly, fsHidden]; // inferred as set
```

#### 4.3.2 Typed Constants (Initialized Variables)

When `{$J+}` (default off in modern Delphi) or `{$WRITEABLECONST ON}` is active, typed constants are **writable** — they are actually initialized global variables that persist across calls.

When `{$J-}` (the default), typed constants are **read-only** after initialization.

Typed constants of structured types (arrays, records) use aggregate constant syntax:

```pascal
const
  Origin: TPoint = (X: 0; Y: 0);
  Primes: array[0..4] of Integer = (2, 3, 5, 7, 11);
```

#### 4.3.3 Resource Strings

```
RESOURCESTRING_SECTION = 'resourcestring' { IDENT '=' STRING_CONST ';' } ;
```

Resource strings are string constants that are stored in the executable's resource section and can be localized. They are of type `string` and are read-only.

### 4.4 Type Declarations

```
TYPE_SECTION = 'type' { TYPE_DECL } ;
TYPE_DECL    = IDENT [ GENERIC_PARAMS ] '=' [ 'type' ] TYPE [ PORTABILITY_DIRECTIVE ] ';' ;
```

Forward declarations for classes and interfaces are permitted:

```pascal
type
  TNode = class;   // forward declaration
  PNode = ^TNode;
  TNode = class    // full declaration
    Next: PNode;
  end;
```

A forward declaration must be resolved within the same `type` block.

### 4.5 Variable Declarations

```
VAR_SECTION = 'var' { VAR_DECL } ;
VAR_DECL    = IDENT_LIST ':' TYPE [ '=' INITIAL_VALUE ] [ PORTABILITY_DIRECTIVE ] ';'
            | IDENT_LIST ':' TYPE ABSOLUTE_CLAUSE ';' ;
```

#### 4.5.1 Initialization

- **Global variables** are zero-initialized by default.
- **Local variables** of unmanaged types are **not initialized** — their initial value is undefined.
- **Local variables** of managed types (strings, dynamic arrays, interfaces, variants) are initialized to their "empty" state (`''`, `nil`, `Unassigned`).
- **Class fields** are zero-initialized when the object is created.

#### 4.5.2 The `absolute` Directive

```
ABSOLUTE_CLAUSE = 'absolute' ( IDENT | INTEGER_LITERAL ) ;
```

`absolute` overlays a variable at the same memory address as another variable or a fixed address:

```pascal
var
  L: LongInt;
  B: array[0..3] of Byte absolute L;  // B overlays L
```

Restrictions:
- **Dangerous with managed types.** Overlaying a managed type (string, interface, dynamic array) with an unmanaged alias bypasses reference-count logic, causing leaks or double-frees. Avoid `absolute` with any managed type.
- **No lifetime tracking.** The compiler does not insert initialization or finalization for the aliasing variable; lifetime is entirely the programmer's responsibility.
- **No range checking.** The alias variable may extend beyond the source variable's bounds without a compile-time error.

#### 4.5.3 Inline Variable Declarations (Delphi 10.3+)

Variables may be declared at the point of first use within a `begin..end` block:

```pascal
begin
  var X := 42;                    // type inferred as Integer
  var Name: string := 'Hello';    // explicit type
  for var I := 0 to 10 do         // loop variable declaration
    WriteLn(I);
end;
```

Rules:

1. The scope of an inline variable extends from its declaration to the end of the innermost enclosing block.
2. Type inference uses the same rules as `const` inference.
3. Inline variables of managed types are finalized when they go out of scope.

#### 4.5.4 Inline Constant Declarations (Delphi 10.3+)

Constants may also be declared inline within a `begin..end` block:

```pascal
begin
  const MaxRetries = 5;                    // type inferred as Integer
  const Greeting: string = 'Hello';        // explicit type
  const Factor = 2.5;                      // type inferred as Extended/Double

  for var I := 1 to MaxRetries do
    WriteLn(Greeting);
end;
```

Rules:

1. The scope of an inline constant extends from its declaration to the end of the innermost enclosing block.
2. Type inference follows the same rules as traditional constant declarations.
3. Inline constants are true constants — they cannot be assigned to after declaration.
4. Inline constants may be used anywhere a constant expression is expected within their scope.

### 4.6 Thread-Local Variables

```
THREADVAR_SECTION = 'threadvar' { VAR_DECL } ;
```

`threadvar` declares variables with **thread-local storage (TLS)**. Each thread has its own independent copy of the variable. Thread-local variables are zero-initialized for threads created by the Delphi RTL (`TThread`, `System.Generics`, etc.).

Restrictions:

- Cannot have initializers (no `= value` syntax).
- Cannot be of a type that requires compiler-managed initialization: interfaces and `Variant` are problematic -- the compiler cannot guarantee per-thread initialization/finalization for them.

Semantics and caveats:

- **New thread initialization.** Threads created directly via OS APIs (e.g., `CreateThread` on Windows) without going through the Delphi RTL will have their threadvar values zero-initialized but the RTL initialization hooks will not run. Managed-type threadvars may be in an inconsistent state in such threads.
- **No finalization guarantee.** When a thread exits, Delphi finalizes managed threadvar fields for RTL-managed threads. Threads created outside the RTL may not trigger this cleanup, causing leaks.
- **Per-thread instance.** Each threadvar is effectively a separate variable per thread; changes in one thread are invisible to all others.
- For managed types in multi-threaded code, prefer `threadvar` with RTL-created threads (which properly handle per-thread initialization and finalization). Third-party libraries such as Spring4D provide a `TThreadLocal<T>` wrapper for additional safety.

### 4.7 Portability Directives

Declarations may be annotated with portability directives:

| Directive      | Meaning                                         |
|----------------|-------------------------------------------------|
| `platform`     | Platform-specific; may not exist on all targets |
| `deprecated`   | Deprecated; usage generates a warning           |
| `deprecated 'msg'` | Deprecated with custom message             |
| `experimental` | Experimental; may change or be removed          |
| `library`      | Specific to library (DLL) usage                 |

---

## Chapter 5: Expressions

### 5.1 Expression Overview

An expression computes a value. Expressions are composed of **operands** (literals, constants, variables, function calls) combined with **operators**.

```
EXPRESSION = CONDITIONAL_EXPR | SIMPLE_EXPR [ REL_OP SIMPLE_EXPR ] ;
CONDITIONAL_EXPR = 'if' EXPRESSION 'then' EXPRESSION 'else' EXPRESSION ;
SIMPLE_EXPR = [ '+' | '-' ] TERM { ADD_OP TERM } ;
TERM = FACTOR { MUL_OP FACTOR } ;
FACTOR = DESIGNATOR [ '(' EXPR_LIST ')' ]
       | '@' DESIGNATOR
       | NUMBER
       | STRING_LITERAL
       | 'nil'
       | 'not' FACTOR
       | '(' EXPRESSION ')'
       | SET_CONSTRUCTOR
       | INHERITED_EXPR
       | VALUE_TYPE_CONSTRUCTOR ;
```

### 5.2 Operator Precedence

Operators are listed from highest to lowest precedence:

| Precedence | Operators                        | Category            |
|------------|----------------------------------|---------------------|
| 1 (highest)| `@`, `not`, unary `+`, unary `-` | Unary               |
| 2          | `*`, `/`, `div`, `mod`, `and`, `shl`, `shr`, `as` | Multiplicative |
| 3          | `+`, `-`, `or`, `xor`           | Additive            |
| 4          | `=`, `<>`, `<`, `>`, `<=`, `>=`, `in`, `is`, `not in`, `is not` | Relational |
| 5 (lowest) | `if`...`then`...`else`           | Conditional (Delphi 13+) |

All binary operators at the same precedence level are **left-associative**. The conditional operator is **right-associative** (nested `if`...`then`...`else` chains associate from right to left).

**Important:** Unlike C-family languages, `and` and `or` have **higher** precedence than relational operators. This means:

```pascal
if A > 0 and B > 0 then  // WRONG: parsed as A > (0 and B) > 0
if (A > 0) and (B > 0) then  // CORRECT
```

### 5.3 Arithmetic Operators

| Operator | Operation          | Operand Types        | Result Type       |
|----------|--------------------|----------------------|-------------------|
| `+`      | Addition           | Integer, Real        | Integer or Real   |
| `-`      | Subtraction        | Integer, Real        | Integer or Real   |
| `*`      | Multiplication     | Integer, Real        | Integer or Real   |
| `/`      | Real division      | Integer, Real        | Real (always)     |
| `div`    | Integer division   | Integer              | Integer           |
| `mod`    | Modulus            | Integer              | Integer           |
| `+`      | Unary plus         | Integer, Real        | same              |
| `-`      | Unary negation     | Integer, Real        | same              |

**Type promotion rules for mixed arithmetic:**

1. If both operands are integer types, the result is the common type (the smallest type that encompasses both).
2. If either operand is a real type, the other is promoted to `Extended` (or `Double` on 64-bit), and the result is `Extended` (or `Double`).
3. `/` always produces a real result, even with integer operands.
4. `div` truncates toward zero: `7 div 2 = 3`, `-7 div 2 = -3`.
5. `mod` is defined such that `A mod B = A - (A div B) * B`. The sign of the result matches the sign of `A`.

**Overflow behavior:**

- With `{$Q+}` (overflow checking), both signed and unsigned integer overflow raise `EIntOverflow`.
- With `{$Q-}` (the default), signed integer overflow wraps (two's complement).
- With `{$Q-}`, unsigned integer overflow wraps modulo 2^N.

### 5.4 Bitwise Operators

| Operator | Operation          | Operand Types | Result Type |
|----------|--------------------|---------------|-------------|
| `not`    | Bitwise complement | Integer       | same        |
| `and`    | Bitwise AND        | Integer       | Integer     |
| `or`     | Bitwise OR         | Integer       | Integer     |
| `xor`    | Bitwise XOR        | Integer       | Integer     |
| `shl`    | Shift left         | Integer       | Integer     |
| `shr`    | Shift right        | Integer       | Integer     |

`shr` performs **logical** (unsigned) shift for unsigned types and **arithmetic** (sign-extending) shift for signed types.

### 5.5 Boolean Operators

When applied to `Boolean` operands, `and`, `or`, `xor`, and `not` perform logical operations:

| Operator | Operation   |
|----------|-------------|
| `not`    | Logical NOT |
| `and`    | Logical AND |
| `or`     | Logical OR  |
| `xor`    | Logical XOR |

**Short-circuit evaluation:**

- With `{$B-}` (the default), `and` and `or` use **short-circuit** evaluation: the second operand is not evaluated if the result is determined by the first.
  - `A and B`: if `A` is `False`, `B` is not evaluated.
  - `A or B`: if `A` is `True`, `B` is not evaluated.
- With `{$B+}`, both operands are always evaluated (**complete evaluation**).

### 5.6 String Operators

| Operator | Operation      | Operand Types    | Result Type |
|----------|----------------|------------------|-------------|
| `+`      | Concatenation  | String, Char     | String      |
| `=`      | Equal          | String, Char     | Boolean     |
| `<>`     | Not equal      | String, Char     | Boolean     |
| `<`      | Less than      | String, Char     | Boolean     |
| `>`      | Greater than   | String, Char     | Boolean     |
| `<=`     | Less or equal  | String, Char     | Boolean     |
| `>=`     | Greater or equal | String, Char   | Boolean     |

String comparison is **ordinal** (compares character code points left to right). It is **case-sensitive**. For case-insensitive comparison, use runtime functions like `SameText` or `CompareText`.

### 5.7 Set Operators

| Operator | Operation       | Operand Types | Result Type |
|----------|-----------------|---------------|-------------|
| `+`      | Union           | Set           | Set         |
| `-`      | Difference      | Set           | Set         |
| `*`      | Intersection    | Set           | Set         |
| `=`      | Equal           | Set           | Boolean     |
| `<>`     | Not equal       | Set           | Boolean     |
| `<=`     | Subset          | Set           | Boolean     |
| `>=`     | Superset        | Set           | Boolean     |
| `in`     | Membership      | Ordinal, Set  | Boolean     |
| `not in` | Negated membership (Delphi 13+) | Ordinal, Set | Boolean |

A **set constructor** builds a set value:

```
SET_CONSTRUCTOR = '[' [ SET_ELEMENT { ',' SET_ELEMENT } ] ']' ;
SET_ELEMENT = EXPRESSION [ '..' EXPRESSION ] ;
```

### 5.8 Relational Operators

| Operator | Operation            | Result |
|----------|----------------------|--------|
| `=`      | Equal                | Boolean |
| `<>`     | Not equal            | Boolean |
| `<`      | Less than            | Boolean |
| `>`      | Greater than         | Boolean |
| `<=`     | Less than or equal   | Boolean |
| `>=`     | Greater than or equal | Boolean |
| `is`     | Type test            | Boolean |
| `is not` | Negated type test (Delphi 13+) | Boolean |
| `in`     | Set membership       | Boolean |
| `not in` | Negated set membership (Delphi 13+) | Boolean |

#### 5.8.1 The `is` Operator

```pascal
if Obj is TMyClass then ...
```

`is` tests whether an object is an instance of a given class or its descendants. The left operand must be a class-type expression; the right must be a class type. Returns `True` if the object's actual (runtime) class is the specified class or a descendant of it.

`is` can also test interface support:

```pascal
if Obj is IMyInterface then ...
```

#### 5.8.1a The `is not` Operator (Delphi 13+)

```pascal
if Obj is not TMyClass then ...
```

`is not` is the negation of `is`. It is equivalent to `not (Obj is TMyClass)` but avoids the need for parentheses and reads more naturally. The same rules as `is` apply — it works with class types and interfaces.

#### 5.8.1b The `not in` Operator (Delphi 13+)

```pascal
if Ch not in ['a'..'z'] then ...
```

`not in` is the negation of `in`. It is equivalent to `not (Ch in S)` but avoids the parentheses required by operator precedence. The left operand is an ordinal value; the right is a set.

#### 5.8.2 The `as` Operator

```pascal
var MyObj := Obj as TMyClass;
```

`as` performs a **checked typecast**. If the object is not an instance of the specified class (or does not support the specified interface), an `EInvalidCast` exception is raised.

For interfaces:

```pascal
var Intf := Obj as IMyInterface;
```

This calls `QueryInterface` internally and raises `EIntfCastError` on failure.

### 5.8.3 The Conditional Operator (Delphi 13+)

The **conditional operator** (also called the ternary operator) evaluates a boolean condition and returns one of two values:

```pascal
var X := if Condition then Value1 else Value2;
```

This is an **expression**, not a statement — it produces a value and can appear anywhere an expression is expected:

```pascal
ShowMessage(if Score >= 60 then 'Pass' else 'Fail');

var Discount := if IsMember then 0.20 else 0.0;

DoSomething(A, if Flag then B else C, D);
```

Rules:

1. The condition must be a `Boolean` expression.
2. Both branches must yield **type-compatible** values. If the types differ and no implicit conversion exists, the compiler reports an incompatible types error.
3. **Short-circuit evaluation** applies: only the selected branch is evaluated. This distinguishes the operator from `IfThen()` functions (which evaluate both arguments before calling).
4. The conditional operator has **lower precedence** than all arithmetic and relational operators. Use parentheses when embedding it in larger expressions:

```pascal
// Without parentheses, '+' binds tighter than else:
//   if X > 0 then 'Pos' else 'Neg' + '!'
// is parsed as:
//   if X > 0 then 'Pos' else ('Neg' + '!')

// Use parentheses for the intended grouping:
var S := (if X > 0 then 'Pos' else 'Neg') + '!';
```

5. Conditional operators may be **nested**:

```pascal
var Grade := if Score >= 90 then 'A'
             else if Score >= 80 then 'B'
             else if Score >= 70 then 'C'
             else 'F';
```

6. The `if` keyword serves as both a statement keyword and an operator keyword. The compiler disambiguates by syntactic position: when `if` appears where an expression is expected (right-hand side of assignment, function argument, etc.), it is parsed as the conditional operator.

### 5.9 The Address-of Operator (`@`)

```pascal
var P: Pointer;
P := @MyVariable;
```

- `@Variable` returns a `Pointer` (when `{$T-}`, the default) or a typed pointer `^T` (when `{$T+}`).
- `@Procedure` returns a pointer to the procedure's code.
- `@Object.Method` returns a method code pointer (not a method pointer pair; for that, use a method pointer type assignment).

### 5.10 The Dereference Operator (`^`)

```pascal
var P: ^Integer;
P^ := 42;  // dereference: access the Integer pointed to by P
```

### 5.11 Designators and Member Access

```
DESIGNATOR = IDENT { DESIGNATOR_PART } ;
DESIGNATOR_PART = '.' IDENT           (* member access *)
                | '[' EXPR_LIST ']'   (* array indexing *)
                | '^'                 (* pointer dereference *)
                | '(' EXPR_LIST ')'   (* function call / type cast *) ;
```

Examples:
```pascal
A[I]            // array index
P^              // dereference
Obj.Field       // member access
Obj.Method(X)   // method call
TMyClass(Obj)   // type cast
```

### 5.12 Type Casting

#### 5.12.1 Value Typecasts

```pascal
Integer(MyChar)    // convert Char to Integer (ordinal value)
Byte(MyInteger)    // truncate Integer to Byte
```

Value typecasts convert between types of the same size, or between ordinal types. The compiler may generate conversion code or simply reinterpret the bit pattern.

Rules:
1. Both the source and target must be ordinal types, pointer types, or types of the same size.
2. No runtime check is performed.

#### 5.12.2 Variable Typecasts (Hard Casts)

```pascal
TMyRec(MyPointer^)   // reinterpret memory at pointer as TMyRec
```

A variable typecast reinterprets a variable's memory as a different type. The source must be a variable reference (not a value). The cast produces an **lvalue** — it can appear on the left side of an assignment.

#### 5.12.3 Checked Casts (`as`)

See [§5.8.2](#582-the-as-operator). The `as` operator performs runtime type checking and raises an exception on failure.

### 5.13 Constant Expressions

A **constant expression** is an expression that can be evaluated at compile time.

```
CONST_EXPR     = EXPRESSION ;  (* restricted to compile-time-evaluable operands *)
INT_CONST_EXPR = CONST_EXPR ;  (* must evaluate to an integer value *)
ORD_CONST_EXPR = CONST_EXPR ;  (* must evaluate to an ordinal or set value *)
```

Constant expressions are required in:

- Array bounds (integer)
- Case labels (ordinal, matching the selector type)
- Constant declarations
- Enum element values (integer)
- Subrange bounds (ordinal)
- Default parameter values
- Property `default` values (ordinal or set)
- Property `index` values (integer)
- Property `dispid` values (integer)
- `message` directive values (integer or string)

Constant expressions may include:
- Numeric, string, and boolean literals
- Previously declared constants
- Arithmetic, logical, and relational operators
- Intrinsics: `Ord`, `Chr`, `Pred`, `Succ`, `High`, `Low`, `SizeOf`, `Length` (for static arrays and strings), `Abs`, `Round`, `Trunc`, `Odd`, `Lo`, `Hi`
- Typecast of constant values
- String concatenation

Constant expressions shall **not** include:
- Variable references
- Function calls (other than the intrinsics listed above)
- Pointer operations
- `@` operator

Note: Many syntactic positions that require compile-time values accept only a specific **subset** of constant expressions (e.g., integer-only or ordinal-only). The specific restriction is noted in each production.

### 5.14 Inline Expressions and Compiler Intrinsics

The compiler recognizes certain function-like constructs as intrinsics that are expanded inline:

| Intrinsic        | Description                                         |
|------------------|-----------------------------------------------------|
| `SizeOf(T)`      | Size of type T in bytes                             |
| `TypeInfo(T)`    | Pointer to RTTI for type T                          |
| `TypeOf(T)`      | Returns class reference for a class type            |
| `IsManagedType(T)` | True if T is a managed type                      |
| `HasWeakRef(T)`  | True if T supports weak references                  |
| `GetTypeKind(T)` | Returns the TTypeKind for T (resolved at compile time) |
| `IsConstValue(X)` | True if X is a compile-time constant               |
| `Assigned(P)`    | True if P is not nil (pointer, object, proc)        |
| `Default(T)`     | Default (zero) value of type T                      |
| `Assert(Cond [, Msg])` | Debug assertion                               |
| `Inc(X [, N])`   | Increment ordinal or pointer                        |
| `Dec(X [, N])`   | Decrement ordinal or pointer                        |
| `Include(S, E)`  | Add element to set                                  |
| `Exclude(S, E)`  | Remove element from set                             |
| `Swap(X)`        | Swap bytes of a Word value                          |
| `Lo(X)`          | Low byte of a word/integer                          |
| `Hi(X)`          | High byte of a word/integer                         |
| `NameOf(Ident)`  | String name of an identifier (Delphi 13+)           |

#### 5.14.1 The `NameOf` Intrinsic (Delphi 13+)

`NameOf` returns the **simple (unqualified) name** of an identifier as a compile-time string constant:

```pascal
var
  MyVariable: Integer;
begin
  WriteLn(NameOf(MyVariable));        // 'MyVariable'
  WriteLn(NameOf(TObject));           // 'TObject'
  WriteLn(NameOf(Form1.Button1));     // 'Button1' (last component only)
end;
```

`NameOf` accepts variables, types, fields, methods, properties, and qualified identifiers. It always returns the **final** identifier in a dotted path. Because the result is resolved at compile time, it has no runtime cost and cannot raise exceptions.

---

## Chapter 6: Statements

### 6.1 Statement Grammar

```
STATEMENT = [ LABEL ':' ] ( SIMPLE_STMT | STRUCTURED_STMT ) ;

SIMPLE_STMT = ASSIGNMENT_STMT
            | PROCEDURE_CALL
            | GOTO_STMT
            | INHERITED_STMT
            | RAISE_STMT
            | (* empty statement *) ;

STRUCTURED_STMT = COMPOUND_STMT
                | CONDITIONAL_STMT
                | LOOP_STMT
                | WITH_STMT
                | TRY_STMT
                | ASM_STMT ;
```

### 6.2 Assignment Statement

```
ASSIGNMENT_STMT = DESIGNATOR ':=' EXPRESSION ;
```

The expression's type must be assignment-compatible with the designator's type. The designator must be an **lvalue** (a writable variable, field, array element, pointer dereference, or property with a setter).

For **function results**, the function name or the implicit variable `Result` serves as the lvalue:

```pascal
function Add(A, B: Integer): Integer;
begin
  Result := A + B;    // using Result
  // or: Add := A + B;  // using function name (older style)
end;
```

### 6.3 Procedure and Function Calls

```
PROCEDURE_CALL = DESIGNATOR [ '(' EXPR_LIST ')' ] ;
```

Parentheses may be omitted if the procedure/function takes no parameters.

### 6.4 Compound Statement

```
COMPOUND_STMT = 'begin' STMT_LIST 'end' ;
STMT_LIST     = [ STATEMENT { ';' STATEMENT } ] ;
```

### 6.5 The `if` Statement

```
IF_STMT = 'if' EXPRESSION 'then' STATEMENT
          [ 'else' STATEMENT ] ;
```

The expression must be of type `Boolean`. The `else` clause binds to the nearest unmatched `if` (dangling else resolved by nearest match).

### 6.6 The `case` Statement

```
CASE_STMT = 'case' EXPRESSION 'of'
            CASE_SELECTOR { ';' CASE_SELECTOR }
            [ ';' ] [ 'else' STMT_LIST [ ';' ] ]
            'end' ;

CASE_SELECTOR = CASE_LABEL_LIST ':' STATEMENT ;
CASE_LABEL_LIST = CASE_LABEL { ',' CASE_LABEL } ;
CASE_LABEL = CONST_EXPR [ '..' CONST_EXPR ] ;
```

Rules:

1. The selector expression must be of an ordinal type.
2. Each case label must be a constant expression of a compatible ordinal type.
3. No two case labels may have the same value. Ranges must not overlap.
4. If the selector matches no label, the `else` clause executes (if present). If no `else` and no match, execution continues after `end`.
5. Unlike C, there is no fall-through between cases.

### 6.7 The `for` Statement

```
FOR_STMT = 'for' ( IDENT | 'var' IDENT [ ':' TYPE ] ) ':=' EXPRESSION
           ( 'to' | 'downto' ) EXPRESSION 'do' STATEMENT ;
```

Rules:

1. The control variable must be a local variable of an ordinal type.
2. The initial and final values are evaluated **once** before the loop begins.
3. `to` increments the control variable; `downto` decrements it.
4. If the initial value exceeds the final value (for `to`) or is less (for `downto`), the loop body does not execute.
5. The control variable is **undefined** after the loop terminates normally.
6. The loop body shall not modify the control variable.
7. The control variable may be declared inline: `for var I := 0 to 10 do ...` (Delphi 10.3+).

#### 6.7.1 The `for..in` Statement

```
FOR_IN_STMT = 'for' ( IDENT | 'var' IDENT [ ':' TYPE ] ) 'in' EXPRESSION 'do' STATEMENT ;
```

`for..in` iterates over:

1. **Arrays** (static and dynamic): iterates over elements.
2. **Strings**: iterates over characters.
3. **Sets**: iterates over members.
4. **Collections** with enumerator support: any type that provides a `GetEnumerator` method.

The enumerator protocol requires:

```pascal
type
  TMyEnumerator = class
    function MoveNext: Boolean;
    property Current: T read GetCurrent;
  end;

  TMyCollection = class
    function GetEnumerator: TMyEnumerator;
  end;
```

The `for..in` loop desugars to:

```pascal
var Enum := Collection.GetEnumerator;
try
  while Enum.MoveNext do
  begin
    var Item := Enum.Current;
    // loop body
  end;
finally
  Enum.Free;  // only for class-type enumerators
end;
```

The compiler generates different cleanup code depending on whether `GetEnumerator` returns a class or a record:

- **Class enumerators**: The compiler wraps the loop in `try..finally` with `Enum.Free` as shown above, since the enumerator is heap-allocated and must be explicitly freed.
- **Record enumerators**: The enumerator is stack-allocated and requires no explicit cleanup — no `try..finally` is generated. Record enumerators avoid heap allocation overhead and are the more common and efficient choice in modern Delphi. Most RTL and third-party collection enumerators (including Spring4D) use records.

### 6.8 The `while` Statement

```
WHILE_STMT = 'while' EXPRESSION 'do' STATEMENT ;
```

The expression must be `Boolean`. The statement executes repeatedly as long as the expression is `True`. If the expression is initially `False`, the body never executes.

### 6.9 The `repeat..until` Statement

```
REPEAT_STMT = 'repeat' STMT_LIST 'until' EXPRESSION ;
```

The statement list executes at least once. After each iteration, the expression is evaluated; if `True`, the loop terminates. Note: this is the opposite of `while` — the loop continues while the condition is `False`.

### 6.10 The `goto` Statement

```
GOTO_STMT = 'goto' LABEL ;
```

Jumps to the labeled statement. The label and the `goto` must be in the same block (procedure/function body). Jumping into or out of `try..finally` or `try..except` blocks is not permitted and results in undefined behavior.

### 6.11 The `Break` and `Continue` Intrinsics

- `Break` — exits the innermost enclosing `for`, `while`, or `repeat` loop.
- `Continue` — skips to the next iteration of the innermost loop.

These are compiler intrinsics, not true statements, though they are used in statement position.

### 6.12 The `Exit` Intrinsic

```pascal
Exit;              // exits the current procedure/function
Exit(Value);       // exits and sets Result (Delphi 2009+)
```

`Exit` without a parameter exits the current routine. `Exit(Value)` is equivalent to `Result := Value; Exit;` for functions.

### 6.13 The `Halt` and `RunError` Intrinsics

- `Halt [ ( ExitCode ) ]` — terminates the program with the given exit code (default 0).
- `RunError [ ( ErrorCode ) ]` — terminates with a runtime error.

### 6.14 The `with` Statement

```
WITH_STMT = 'with' DESIGNATOR_LIST 'do' STATEMENT ;
DESIGNATOR_LIST = DESIGNATOR { ',' DESIGNATOR } ;
```

`with` adds the fields/members of one or more records, objects, or classes to the current scope:

```pascal
with MyPoint do
begin
  X := 10;  // equivalent to MyPoint.X := 10
  Y := 20;
end;
```

Multiple designators are processed left to right; later ones take precedence:

```pascal
with A, B do   // equivalent to: with A do with B do
  Foo;         // B.Foo takes precedence over A.Foo
```

**Caution:** `with` can cause subtle bugs when the type of the designator changes (e.g., a field is added or renamed). Many style guides discourage its use. The compiler shall generate the same code with or without `with`.

### 6.15 The `raise` Statement

See [Chapter 13](#chapter-13-exception-handling) (Exception Handling).

### 6.16 The `try` Statement

See [Chapter 13](#chapter-13-exception-handling) (Exception Handling).

### 6.17 The `asm` Statement

See [Chapter 16](#chapter-16-inline-assembly) (Inline Assembly).

---

## Chapter 7: Procedures and Functions

### 7.1 Declarations

```
PROCEDURE_DECLARATION = PROCEDURE_HEADER ';' [ DIRECTIVE_LIST ';' ]
                        ( BLOCK ';' | EXTERNAL_DIRECTIVE ';' | 'forward' ';' ) ;

FUNCTION_DECLARATION  = FUNCTION_HEADER ';' [ DIRECTIVE_LIST ';' ]
                        ( BLOCK ';' | EXTERNAL_DIRECTIVE ';' | 'forward' ';' ) ;

PROCEDURE_HEADER = 'procedure' IDENT [ GENERIC_PARAMS ] [ FORMAL_PARAMS ] ;
FUNCTION_HEADER  = 'function' IDENT [ GENERIC_PARAMS ] [ FORMAL_PARAMS ] ':' RETURN_TYPE ;
```

### 7.2 Parameters

```
FORMAL_PARAMS = '(' PARAM_GROUP { ';' PARAM_GROUP } ')' ;
PARAM_GROUP   = [ PARAM_MODIFIER ] IDENT_LIST [ ':' PARAM_TYPE ] [ '=' DEFAULT_VALUE ] ;
PARAM_MODIFIER = 'var' | 'const' | 'out' | 'const' '[' 'ref' ']' | '[' 'ref' ']' ;
PARAM_TYPE     = TYPE | 'array' 'of' TYPE | 'array' 'of' 'const' ;
```

#### 7.2.1 Parameter Passing Modes

| Modifier     | Semantics                                                                 |
|-------------|---------------------------------------------------------------------------|
| *(none)*    | **Value**: a copy is made. Modifications do not affect the caller.        |
| `var`       | **Reference**: the parameter is an alias for the caller's variable. The caller must provide an lvalue. |
| `const`     | **Constant reference**: the parameter may be passed by value or by reference (implementation choice for efficiency). The callee shall not modify it. |
| `out`       | **Output**: like `var`, but the initial value is undefined. For managed types, the runtime initializes the parameter to its default value on entry. |
| `[ref]`     | **Explicit reference**: always passed by reference, even for types that would normally be passed by value. (Delphi 10.1+) |
| `const [ref]` | **Constant explicit reference**: combination of `const` and `[ref]`. Always by reference, not modifiable. |

#### 7.2.2 Default Parameter Values

```pascal
procedure Log(const Msg: string; Level: Integer = 0);
```

Rules:
1. Parameters with defaults must appear after all parameters without defaults.
2. The default value must be a constant expression.
3. When calling, trailing defaulted parameters may be omitted.

#### 7.2.3 Open Array Parameters

```pascal
procedure Sum(const Values: array of Integer);
```

See [§3.6.1](#361-array-types).

#### 7.2.4 Untyped Parameters

`var`, `const`, and `out` parameters may omit the type:

```pascal
procedure Move(const Source; var Dest; Count: NativeInt);
```

Untyped parameters accept any variable. Inside the routine, they must be typecast before use.

### 7.3 Function Return Values

The return type of a function is specified after the parameter list:

```pascal
function Add(A, B: Integer): Integer;
```

The return value is set by assigning to `Result` (the implicit local variable) or to the function name. `Result` is of the declared return type.

For managed types, `Result` is initialized to its default value on entry. For unmanaged types, `Result` is uninitialized.

### 7.4 Overloading

```pascal
procedure Show(X: Integer); overload;
procedure Show(X: string); overload;
```

Multiple routines with the same name may coexist in the same scope if they have the **`overload`** directive and their parameter lists are distinguishable.

#### 7.4.1 Overload Resolution

When a call to an overloaded routine is encountered, the compiler selects the best match:

1. **Exact match**: parameter types exactly match argument types.
2. **Compatible match**: argument types are assignment-compatible with parameter types but require implicit conversion.
3. **Most specific match**: among compatible candidates, the one requiring the least "widening" conversions.

If no single best match exists (ambiguity), a compile-time error is issued. See [Appendix E](#appendix-e-name-resolution-and-overload-resolution-rules) for full resolution rules.

### 7.5 Forward Declarations

```pascal
procedure Foo(X: Integer); forward;
// ... intervening declarations ...
procedure Foo(X: Integer);
begin
  // body
end;
```

A `forward` declaration separates the header from the body. The body must appear later in the **same** declaration section. The parameter list in the body may be omitted if it matches the forward declaration.

### 7.6 External Declarations

```pascal
function MessageBox(Wnd: HWND; Text, Caption: PChar; Flags: Cardinal): Integer;
  stdcall; external 'user32.dll' name 'MessageBoxW';
```

```
EXTERNAL_DIRECTIVE = 'external' [ ExternalKind ]
                     [ 'name' STRING_LITERAL | 'index' INTEGER_LITERAL ]
                     [ 'delayed' ] ;
ExternalKind       = STRING_LITERAL
                   | 'object' STRING_LITERAL
                   | 'framework' STRING_LITERAL ;
```

- **`external 'lib'`** — the routine is implemented in an external DLL/shared library.
- **`external object 'file.o'`** — the routine is implemented in a compiled object file (`.o` or `.obj`) that is statically linked into the executable.
- **`external framework 'Name'`** — the routine is implemented in a macOS/iOS framework (macOS and iOS targets only).
- **`name 'ExportName'`** — specifies the exported name (for name mangling differences).
- **`index N`** — specifies the export ordinal.
- **`delayed`** — the DLL is loaded on first call (delay-loaded), not at program startup. If the DLL is not found or the function is not exported, `EExternalException` is raised on the **first invocation** of the function. If the delayed function is never called, the DLL is never loaded and no error occurs. This makes `delayed` useful for optional functionality — the application can check for the DLL's existence before calling, or catch the exception at the call site. This contrasts with non-delayed externals, where a missing DLL prevents the application from loading entirely.

```pascal
// External DLL
function MessageBox(Wnd: HWND; Text, Caption: PChar; Flags: Cardinal): Integer;
  stdcall; external 'user32.dll' name 'MessageBoxW';

// External object file (static linking)
function ExpC(Value: Double): Double; cdecl;
  external object 'ExpC_LLVM_MINGW.obj';

// External framework (macOS/iOS)
procedure FirebaseCoreLoader; cdecl;
  external framework 'FirebaseCore';
```

### 7.7 Inline Expansion

```pascal
function Max(A, B: Integer): Integer; inline;
begin
  if A > B then Result := A else Result := B;
end;
```

The `inline` directive is a **hint** requesting that the compiler expand the routine's body at each call site instead of generating a procedure call. The compiler may ignore this request for complex routines or when optimization is disabled.

Rules:
1. `inline` is a hint, not a guarantee -- the compiler decides whether to actually inline the routine.
2. For cross-unit inlining, the routine's implementation must be visible to the calling unit. Defining the routine body in the interface section (or in a header-only unit) makes cross-unit inlining possible, but it is not a strict language requirement.
3. Recursive routines cannot be inlined.
4. Routines containing inline assembly cannot be inlined.

### 7.8 The `noreturn` Directive

```pascal
procedure FatalError(const Msg: string); noreturn;
begin
  raise EFatalException.Create(Msg);
end;
```

The `noreturn` directive declares that a procedure never returns to its caller — it always raises an exception, calls `Halt`, or enters an infinite loop. This enables the compiler to:

1. Eliminate unreachable code after calls to the procedure.
2. Suppress warnings about uninitialized results in calling code paths.

Rules:
1. `noreturn` applies to procedures and procedure-type class methods (not functions, method references, or anonymous methods).
2. If a `noreturn` procedure does return, behavior is undefined — the compiler may have removed code that follows the call site.

### 7.9 Nested Routines

Procedures and functions may be nested inside other routines:

```pascal
procedure Outer;
  procedure Inner;
  begin
    // can access Outer's local variables
  end;
begin
  Inner;
end;
```

Nested routines can access the local variables and parameters of all enclosing routines. This is implemented via a **frame pointer chain**: each nested routine receives a hidden pointer to the enclosing routine's stack frame.

### 7.10 Routine Directives Summary

| Directive      | Meaning                                                    |
|----------------|------------------------------------------------------------|
| `overload`     | Enables overloading by name                                |
| `inline`       | Request inline expansion                                   |
| `forward`      | Forward declaration                                        |
| `external`     | External (DLL/shared library) implementation               |
| `assembler`    | Body is pure assembly (legacy; `asm..end` is sufficient)   |
| `deprecated`   | Generates deprecation warning on use                       |
| `platform`     | Platform-specific                                          |
| `experimental` | Experimental                                               |
| `register`     | Register calling convention (default)                      |
| `cdecl`        | C calling convention                                       |
| `stdcall`      | Standard call (Win32 API)                                  |
| `safecall`     | Safecall (COM, with HRESULT wrapping)                      |
| `pascal`       | Pascal calling convention (legacy)                         |
| `winapi`       | Platform's native API convention (stdcall on Win32, Microsoft x64 ABI on Win64, cdecl on POSIX) |
| `varargs`      | C-style variadic arguments (with `cdecl`)                  |
| `static`       | Class method that doesn't receive Self                     |
| `virtual`      | Virtual dispatch                                           |
| `dynamic`      | Dynamic dispatch (smaller VMT, slower call)                |
| `abstract`     | No implementation (must be overridden)                     |
| `override`     | Override an inherited virtual/dynamic method                |
| `reintroduce`  | Hides an inherited method (suppresses warning)             |
| `message`      | Message handler                                            |
| `final`        | Prevents further overriding                                |
| `noreturn`     | Procedure never returns to the caller                      |

---

## Chapter 8: Classes

### 8.1 Class Declaration

```
CLASS_TYPE = 'class' [ ABSTRACT_OR_SEALED ] [ CLASS_HERITAGE ]
             { CLASS_MEMBER_SECTION }
             'end' ;

ABSTRACT_OR_SEALED = 'abstract' | 'sealed' ;

CLASS_HERITAGE = '(' TYPE_REF { ',' TYPE_REF } ')' ;
(* First TYPE_REF is the ancestor class; subsequent ones are interfaces *)

CLASS_MEMBER_SECTION = [ VISIBILITY ]
                       { FIELD_DECLARATION
                       | METHOD_DECLARATION
                       | PROPERTY_DECLARATION
                       | CONST_DECLARATION
                       | TYPE_DECLARATION
                       | CLASS_VAR_SECTION
                       | CLASS_CONSTRUCTOR_DECLARATION
                       | CLASS_DESTRUCTOR_DECLARATION } ;

VISIBILITY = 'public' | 'private' | 'protected' | 'published'
           | 'strict' 'private' | 'strict' 'protected' ;
```

A **forward declaration** of a class provides just the class name:

```pascal
type
  TNode = class;  // forward
```

### 8.2 Class Heritage and Inheritance

Every class inherits from exactly one ancestor class. If no ancestor is specified, the implicit ancestor is `TObject` (defined in the `System` unit).

```pascal
type
  TAnimal = class           // inherits from TObject
  end;
  TDog = class(TAnimal)     // inherits from TAnimal
  end;
```

Object Pascal supports **single inheritance** for classes. Multiple interfaces may be implemented (see [Chapter 9](#chapter-9-interfaces)).

#### 8.2.1 `abstract` and `sealed` Classes

- **`abstract`** class: should not be instantiated directly; the compiler issues a warning (W1020) if you do. It may contain abstract methods. Calling an unoverridden abstract method at runtime raises `EAbstractError`.
- **`sealed`** class: cannot be subclassed (no class may inherit from it).

```pascal
type
  TShape = class abstract
    function Area: Double; virtual; abstract;
  end;
  TFinalClass = class sealed
    // ...
  end;
```

### 8.3 Visibility Specifiers

| Visibility        | Access                                                         |
|-------------------|----------------------------------------------------------------|
| `public`          | Accessible from anywhere                                       |
| `private`         | Accessible only within the declaring unit                      |
| `protected`       | Accessible within the declaring unit and in descendant classes |
| `published`       | Like `public`, but generates RTTI for the member               |
| `strict private`  | Accessible only within the declaring class (not unit-wide)     |
| `strict protected`| Accessible only within the declaring class and descendants     |
| `automated`       | Legacy (COM Automation); like `public` with Automation RTTI    |

**Default visibility:** If no visibility specifier precedes the first members, they are:
- `published` if the class has `{$M+}` or descends from `TPersistent` (which has `{$M+}`)
- `public` otherwise

### 8.4 Fields

```
FIELD_DECLARATION = IDENT_LIST ':' TYPE ';' ;
```

Fields are stored inline in the object's memory layout. Fields are laid out in declaration order, respecting alignment rules (see [§8.18](#818-alignment-and-packing)).

#### 8.4.1 Class Fields (`class var`)

```pascal
class var InstanceCount: Integer;
```

Class variables are shared among all instances (like static fields in other languages). They reside in global memory, not in object instances.

### 8.5 Methods

```
METHOD_DECLARATION = METHOD_HEADER ';' [ DIRECTIVE_LIST ';' ] [ METHOD_BODY ';' ] ;
METHOD_HEADER = [ 'class' ] ( 'procedure' | 'function' | 'constructor' | 'destructor' )
                IDENT [ GENERIC_PARAMS ] [ FORMAL_PARAMS ]
                [ ':' RETURN_TYPE ] ;
```

Method bodies in the implementation section use a qualified name:

```pascal
procedure TMyClass.DoSomething;
begin
  // ...
end;
```

#### 8.5.1 Instance Methods

Instance methods receive an implicit `Self` parameter pointing to the object instance. Within a method, `Self` refers to the calling object.

#### 8.5.2 Class Methods

```pascal
class function TMyClass.Create: TMyClass;
```

Class methods receive the class reference (metaclass) as `Self` instead of an instance pointer. They can be called on a class or an instance.

#### 8.5.3 Static Class Methods

```pascal
class function TMyClass.DefaultBufferSize: Integer; static;
```

Static class methods receive **no** `Self` parameter. They cannot access instance members or be virtual. They are essentially namespaced standalone functions.

### 8.6 Constructors

```pascal
constructor Create;
constructor Create(const Name: string); overload;
```

Rules:

1. A constructor allocates and initializes an object instance when called on a **class reference** (`TMyClass.Create`). When called on an **instance** (`Self.Create` or `inherited Create`), it does not allocate — it only initializes.
2. **Allocation**: When called on a class reference, the constructor:
   a. Calls `NewInstance` (which calls `InstanceSize` and allocates memory).
   b. Zero-fills the instance memory.
   c. Sets the object's class pointer (first field in the VMT layout).
   d. Executes the constructor body.
   e. Calls `AfterConstruction`.
3. **Exception safety**: If an exception occurs during a constructor invoked on a **class reference** (the allocation form from rule 1), `Destroy` is called automatically and the allocated memory is freed. If the constructor was invoked on an existing instance (e.g., `inherited Create` or `Self.Create`), no automatic `Destroy` or deallocation occurs — the caller is responsible for cleanup.
4. Constructors can be `virtual`. When called through a class-reference variable (`TClass.Create`), the actual constructor dispatched depends on the runtime class.

### 8.7 Destructors

```pascal
destructor Destroy; override;
```

Rules:

1. By convention, the destructor is named `Destroy` and overrides `TObject.Destroy`.
2. `Free` (defined on `TObject`) checks for `nil` before calling `Destroy`.
3. Destructor execution:
   a. `BeforeDestruction` is called.
   b. The destructor body executes.
   c. `inherited` propagates up the chain.
   d. `FreeInstance` deallocates the memory.
4. Destructors should be tolerant of partially constructed objects (fields may be zero/nil if the constructor didn't complete).

### 8.8 Virtual Methods and Polymorphism

#### 8.8.1 The `virtual` Directive

```pascal
procedure Draw; virtual;
```

A `virtual` method is dispatched through the **Virtual Method Table (VMT)**. Each class has its own VMT containing pointers to its method implementations.

#### 8.8.2 The `dynamic` Directive

```pascal
procedure WndProc(var Message: TMessage); dynamic;
```

`dynamic` is semantically identical to `virtual` but uses a different dispatch mechanism: a compact message-map instead of a full VMT slot. This saves memory when many classes override few methods, but dispatch is slower (linear search). `dynamic` is primarily used for Windows message handlers.

**Modern practice:** Prefer `virtual` in almost all cases. The memory savings of `dynamic` are negligible on modern hardware (a few bytes per class in the VMT), and the slower dispatch via linear search rarely justifies it. `dynamic` remains relevant mainly for message handlers (which use the `message` directive and its own dispatch mechanism). When in doubt, use `virtual`.

#### 8.8.3 The `override` Directive

```pascal
procedure Draw; override;
```

`override` replaces the inherited virtual/dynamic method's entry in the VMT. The method signature must exactly match the inherited method (same name, same parameters, same return type, same calling convention).

#### 8.8.4 The `final` Directive

```pascal
procedure Draw; override; final;
```

`final` prevents descendants from further overriding the method. Attempting to override a `final` method is a compile-time error.

#### 8.8.5 Abstract Methods

```pascal
function Area: Double; virtual; abstract;
```

An abstract method has no implementation in the declaring class. Subclasses must override it. Calling an abstract method at runtime (if not overridden) raises `EAbstractError`.

#### 8.8.6 The `reintroduce` Directive

```pascal
procedure Draw; reintroduce;
```

`reintroduce` suppresses the compiler warning that occurs when a method in a descendant class has the same name as an inherited virtual method but does not override it. The new method **hides** (rather than overrides) the inherited one.

#### 8.8.7 Message Handler Methods

```pascal
procedure WMClose(var Msg: TMessage); message WM_CLOSE;
procedure WMUser(var Msg: TMessage); message WM_USER + 1;
```

The `message` directive registers the method as a message handler for the specified constant. When the object receives a message dispatch call (via `Dispatch` or the VCL/FMX message loop), the runtime routes messages to the handler whose `message` value matches the message ID.

Rules:
1. The method must take exactly one `var` parameter of a message-record type (typically `TMessage` or a compatible record). It must be a procedure (no return value).
2. The `message` constant must be a compile-time **integer** or **string** constant expression. Integer message constants are used for Windows message handling (VCL); string message constants are used for cross-platform message dispatch (FMX).
3. Message methods use **dynamic** dispatch internally (a compact message-map, not a VMT slot), making them efficient when many classes handle few messages.
4. Unlike `virtual`/`dynamic` methods, a message handler is invoked only via `Dispatch` or `DefaultHandler` -- not via a direct polymorphic call.
5. Descendants inherit message handlers from ancestors; a descendant may override a specific message by declaring its own handler with the same `message` value.

### 8.9 The `inherited` Keyword

```pascal
inherited;                    // call inherited method with same parameters
inherited MethodName(Args);   // call specific inherited method
inherited Create(Args);       // call inherited constructor
```

`inherited` without a method name calls the inherited method of the same name, passing the same parameters. `inherited` with a name calls the specified inherited method.

If the current class has no inherited method of that name, `inherited` does nothing (no error) in the no-argument form.

### 8.10 Properties

```
PROPERTY_DECLARATION = [ 'class' ] 'property' IDENT [ PROPERTY_INTERFACE ]
                       { PROPERTY_SPECIFIER } ';'
                       [ DEFAULT_DIRECTIVE ';' ] ;

PROPERTY_INTERFACE = [ '[' PARAM_LIST ']' ] ':' TYPE_IDENT ;

PROPERTY_SPECIFIER = 'read' DESIGNATOR
                   | 'write' DESIGNATOR
                   | 'stored' ( BOOL_CONST | IDENT )
                   | 'default' ORD_CONST_EXPR
                   | 'nodefault'
                   | 'index' INT_CONST_EXPR
                   | 'implements' IDENT_LIST
                   | 'dispid' INT_CONST_EXPR ;
```

#### 8.10.1 Basic Properties

```pascal
property Name: string read FName write SetName;
```

- **`read`** specifier: a field name or getter method. If omitted, the property is **write-only** (uncommon; reading the property is a compile-time error).
- **`write`** specifier: a field name or setter method. If omitted, the property is **read-only** (assignment is a compile-time error).

**Field vs method backing.** A property specifier may name either a field or a method:

- **Field-backed** (`read FName`): the compiler generates a direct memory access -- no method call overhead. Use field backing when no validation, notification, or computation is needed.
- **Method-backed** (`read GetName`): the compiler generates a method call. Use method backing when the getter/setter must validate input, fire events, compute derived values, or enforce invariants.

Getter signature: `function GetX: T;` (no extra params) or a field `FX: T`.

Setter signature: `procedure SetX(const Value: T);` or `procedure SetX(Value: T);`.

Property specifiers are **inherited**: a descendant class may re-declare a property from an ancestor to change only the specifiers (e.g., adding `write` to a read-only inherited property, or changing the backing field/method). The full type and name must match the inherited property.

#### 8.10.2 Array Properties (Indexed Properties)

```pascal
property Items[Index: Integer]: TItem read GetItem write SetItem;
```

Array properties take one or more index parameters. The getter/setter must accept the index parameters followed by (for setters) the value.

#### 8.10.3 Default Array Property

```pascal
property Items[Index: Integer]: TItem read GetItem write SetItem; default;
```

The `default` directive on an array property allows bracket access on the object: `MyList[3]` instead of `MyList.Items[3]`. Only one property per class can be the default.

#### 8.10.4 Index Specifiers

```pascal
property Red: Byte index 0 read GetColor write SetColor;
property Green: Byte index 1 read GetColor write SetColor;
property Blue: Byte index 2 read GetColor write SetColor;
```

The `index` specifier passes an integer constant to a shared getter/setter:

```pascal
function GetColor(Index: Integer): Byte;
procedure SetColor(Index: Integer; Value: Byte);
```

#### 8.10.5 The `stored` and `default` Specifiers

These control **streaming** (persistence via `TReader`/`TWriter`):

- **`stored`** — determines whether the property is saved during streaming. Can be `True`, `False`, or a Boolean field/method name.
- **`default Value`** — specifies a default value. During streaming, the property is only saved if its current value differs from the default. Only ordinal, pointer, and small set types (sets whose base type has ordinal values between 0 and 31) support `default`; floating-point, string, `Int64`, and class types cannot have a `default` specifier.
- **`nodefault`** — removes an inherited default value, forcing the streaming system to always write the property regardless of its current value.

**Default value inheritance.** When a descendant re-declares an inherited property, the ancestor's `default` value carries forward unless the descendant explicitly specifies a new `default` or `nodefault`. This means changing a default in an ancestor automatically affects all descendants that do not override it.

**Published properties and streaming.** Properties declared in a `published` section (in a class compiled with `{$M+}` or descending from `TPersistent`) are visible to the RTTI-based streaming system. At design time and when reading `.dfm`/`.fmx` files, `TReader` uses RTTI to discover published properties and set their values. Only published properties participate in streaming; `public` properties do not. The `stored` and `default` specifiers control whether `TWriter` writes a given property to the stream.

#### 8.10.6 The `implements` Directive

```pascal
property Impl: IMyInterface read FImpl implements IMyInterface;
```

Delegates an interface implementation to another object. See [§9.6](#96-interface-delegation-implements).

#### 8.10.7 Class Properties

```pascal
class property Instance: TSingleton read FInstance;
```

Class properties are accessed through the class, not instances. Their getters/setters must be class methods or class fields.

### 8.11 Events

An **event** is a property of a procedural type (typically a method pointer):

```pascal
type
  TNotifyEvent = procedure(Sender: TObject) of object;
  TButton = class
  private
    FOnClick: TNotifyEvent;
  published
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;
```

Events enable the observer pattern: the object calls the assigned method (if not `nil`) when the event occurs.

### 8.12 Operators (Record Operator Overloading)

On desktop/server compilers (Win32, Win64, Linux, macOS), operator overloading is supported **only for records**, not for classes. (Class operator overloading existed on the now-retired mobile ARC compilers and Delphi for .NET, but is not available on any current desktop target.) See [§10.4](#104-operator-overloading) for the full list of overloadable operators and examples.

### 8.13 TObject — The Root Class

All classes descend from `TObject`, defined in the `System` unit. Key members:

```pascal
TObject = class
  constructor Create;
  procedure Free;
  class function InitInstance(Instance: Pointer): TObject;
  procedure CleanupInstance;
  function ClassType: TClass;
  class function ClassName: string;
  class function ClassNameIs(const Name: string): Boolean;
  class function ClassParent: TClass;
  class function ClassInfo: Pointer;
  class function InstanceSize: Integer;
  class function InheritsFrom(AClass: TClass): Boolean;
  class function MethodAddress(const Name: ShortString): Pointer; overload;
  class function MethodAddress(const Name: string): Pointer; overload;
  class function MethodName(Address: Pointer): string;
  class function QualifiedClassName: string;
  function FieldAddress(const Name: ShortString): Pointer; overload;
  function FieldAddress(const Name: string): Pointer; overload;
  function GetInterface(const IID: TGUID; out Obj): Boolean;
  class function GetInterfaceEntry(const IID: TGUID): PInterfaceEntry;
  class function GetInterfaceTable: PInterfaceTable;
  class function UnitName: string;
  class function UnitScope: string;
  function Equals(Obj: TObject): Boolean; virtual;
  function GetHashCode: Integer; virtual;
  function ToString: string; virtual;
  procedure AfterConstruction; virtual;
  procedure BeforeDestruction; virtual;
  procedure Dispatch(var Message);
  procedure DefaultHandler(var Message); virtual;
  class function NewInstance: TObject; virtual;
  procedure FreeInstance; virtual;
  destructor Destroy; virtual;
end;
```

#### 8.13.1 AfterConstruction and BeforeDestruction

`AfterConstruction` and `BeforeDestruction` are virtual methods called automatically by the runtime at specific points in an object's lifecycle:

- **`AfterConstruction`** is called after the **outermost** constructor completes — that is, after the entire constructor chain (including all `inherited` calls) has finished and the object is fully initialized. This is the safe place to perform initialization that depends on the object being fully constructed, such as starting timers, registering with observers, or calling virtual methods that descendants may override.

- **`BeforeDestruction`** is called before the **outermost** destructor begins — that is, before any destructor body executes. This is the safe place to perform cleanup that requires the object to still be fully intact, such as unregistering from observers or stopping threads.

Both methods are `virtual` and can be overridden in descendants. The default `TObject` implementations do nothing.

### 8.14 Class References (Metaclasses)

```
CLASS_REF_TYPE = 'class' 'of' CLASS_TYPE_IDENT ;
```

```pascal
type
  TClass = class of TObject;
  TAnimalClass = class of TAnimal;
```

A class-reference variable holds a **class** (not an instance). It can be used to:

1. Call constructors: `MyClass.Create` (virtual construction — dispatches to the actual constructor of whichever class the variable holds at runtime, **provided the constructor is declared `virtual`**).
2. Call class methods: `MyClass.ClassName`.
3. Test with `is` and cast with `as`.
4. Compare: `if MyClass = TDog then ...`
5. RTTI access: `MyClass.ClassInfo` returns the `PTypeInfo` pointer, enabling inspection via the `TypInfo` and `RTTI` units.

`TClass` (defined as `class of TObject` in the `System` unit) is the root metaclass. Any class-reference type is assignment-compatible with `TClass`. The classic use is a factory pattern:

```pascal
type
  TAnimal = class
    constructor Create; virtual;  // must be virtual for polymorphic dispatch
  end;

  TAnimalClass = class of TAnimal;

function CreateAnimal(AClass: TAnimalClass): TAnimal;
begin
  Result := AClass.Create;  // virtual dispatch: creates the right subclass
end;
```

**Important:** For polymorphic dispatch through a class reference, the constructor **must** be declared `virtual` (and descendants must use `override`). `TObject.Create` is **not** virtual, so a base class that participates in a factory pattern must explicitly declare its constructor as `virtual` (as `TAnimal` does above). If a non-virtual constructor is called through a class-reference variable, the class reference's declared type's constructor executes — not the descendant's — which is almost never the intended behavior in a factory pattern.

### 8.15 Class Helpers

```
CLASS_HELPER = 'class' 'helper' [ '(' PARENT_HELPER ')' ] 'for' CLASS_TYPE
               { MEMBER_DECLARATION }
               'end' ;
```

```pascal
type
  TObjectHelper = class helper for TObject
    procedure Log;
  end;
```

Rules:
1. Only one class helper per class can be active in a given scope. The **last** in `uses` clause order wins; all others are hidden.
2. Class helpers can add methods and properties but **not** fields.
3. `Self` in a class helper refers to the instance of the helped class.
4. Helpers can access `private` and `protected` members of the helped class (within the same unit).
5. A class helper applies to the helped class **and all its descendants**. A helper for `TObject` is active on `TButton` — but is superseded by any helper for a closer ancestor (e.g., `TControl`) when both are in scope. The compiler picks the helper for the nearest class in the inheritance chain.
6. Class helpers can inherit from other class helpers via the parent clause: `TMyHelper = class helper(TBaseHelper) for TFoo`. The one-helper-per-class rule still applies.
7. A class helper's methods and properties take **precedence over** the helped class's own members. If the helped class defines a member with the same name, the helper's member hides it. The original member can still be accessed via a type cast.

### 8.16 Nested Types and Constants

Classes may contain nested type and constant declarations:

```pascal
type
  TContainer = class
  public
    type
      TItem = record
        Value: Integer;
      end;
    const
      MaxItems = 100;
  private
    FItems: array of TItem;
  end;
```

Nested types are accessed as `TContainer.TItem`.

### 8.17 Object Memory Layout

An object instance in memory is laid out as follows:

```
Offset 0: Pointer to VMT (the class pointer)
Offset 4/8: Fields from ancestor classes (in inheritance order, starting from the first class that declares fields)
... fields from this class (in declaration order) ...
```

Note: `TObject` itself declares no instance fields. The VMT pointer at offset 0 is the only per-instance data contributed by `TObject`. The first declared fields come from whichever descendant class in the inheritance chain first declares fields.

The first field is always a pointer to the **Virtual Method Table**, which in turn contains:

1. Pointers to virtual and dynamic method implementations
2. RTTI pointer
3. Interface table pointer
4. Class name
5. Instance size
6. Parent class pointer
7. And other metadata

### 8.18 Alignment and Packing

Fields are aligned according to their type's natural alignment:

| Type size | Default alignment |
|-----------|-------------------|
| 1 byte    | 1                 |
| 2 bytes   | 2                 |
| 3 bytes   | 1                 |
| 4 bytes   | 4                 |
| 5-8 bytes | 8                 |
| >8 bytes  | 8                 |

The `packed` keyword or `{$A1}` directive removes alignment padding:

```pascal
type
  TPackedRec = packed record
    A: Byte;
    B: Integer;  // no padding before B
  end;
```

Alignment directives: `{$A1}`, `{$A2}`, `{$A4}`, `{$A8}` (default), `{$A16}`.

### 8.19 The `packed` Modifier

`packed` can be applied to arrays, records, sets, and file types. It removes alignment padding between elements/fields, producing the densest possible layout at the potential cost of slower access on some architectures.

---

## Chapter 9: Interfaces

### 9.1 Interface Declaration

```
INTERFACE_TYPE = 'interface' [ INTERFACE_HERITAGE ] [ '[' GUID ']' ]
                 { INTERFACE_MEMBER }
                 'end'
               | 'interface' ;   (* forward declaration *)

INTERFACE_HERITAGE = '(' INTF_TYPE_REF ')' ;
GUID = STRING_LITERAL ;  (* format: '{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}' *)

INTERFACE_MEMBER = PROCEDURE_HEADER ';' [ CALLING_CONV ';' ]
                 | FUNCTION_HEADER ';' [ CALLING_CONV ';' ]
                 | PROPERTY_DECLARATION ;
```

Example:

```pascal
type
  ILogger = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    procedure Log(const Msg: string);
    function GetLevel: Integer;
    procedure SetLevel(Value: Integer);
    property Level: Integer read GetLevel write SetLevel;
  end;
```

### 9.2 IInterface — The Root Interface

All interfaces implicitly descend from `IInterface` (aliased as `IUnknown` for COM compatibility):

```pascal
IInterface = interface
  ['{00000000-0000-0000-C000-000000000046}']
  function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
  function _AddRef: Integer; stdcall;
  function _Release: Integer; stdcall;
end;
```

These three methods support **reference counting** and **interface querying**.

### 9.3 Implementing Interfaces

A class implements an interface by listing it in the class heritage:

```pascal
type
  TConsoleLogger = class(TInterfacedObject, ILogger)
    procedure Log(const Msg: string);
    function GetLevel: Integer;
    procedure SetLevel(Value: Integer);
  end;
```

Rules:

1. The class must implement **all** methods declared in the interface (and all ancestor interfaces).
2. Method names and signatures must match exactly.
3. A class may implement multiple interfaces.

### 9.4 Method Resolution Clauses

When a class implements multiple interfaces with conflicting method names:

```pascal
type
  TDual = class(TInterfacedObject, IFoo, IBar)
    procedure IFoo.DoSomething = DoFoo;
    procedure IBar.DoSomething = DoBar;
    procedure DoFoo;
    procedure DoBar;
  end;
```

The method resolution clause maps interface methods to differently-named class methods.

### 9.5 Reference Counting and Lifetime

#### 9.5.1 TInterfacedObject

`TInterfacedObject` provides the standard reference-counted implementation:

```pascal
TInterfacedObject = class(TObject, IInterface)
  protected
    FRefCount: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    property RefCount: Integer read FRefCount;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;
```

- `_AddRef` increments `FRefCount` (atomically).
- `_Release` decrements `FRefCount`; when it reaches 0, the object is destroyed.

#### 9.5.2 Compiler-Generated Reference Management

The compiler automatically inserts `_AddRef` and `_Release` calls for interface variables:

```pascal
var Intf: ILogger;
Intf := TConsoleLogger.Create;  // _AddRef called
// ... use Intf ...
Intf := nil;                    // _Release called → may destroy object
```

Interface variables are initialized to `nil` and finalized (released) when going out of scope.

#### 9.5.3 Non-Reference-Counted Interfaces

To disable reference counting (e.g., for an object whose lifetime is managed manually):

```pascal
function _AddRef: Integer; stdcall;
begin
  Result := -1;  // signal: not reference counted
end;
function _Release: Integer; stdcall;
begin
  Result := -1;
end;
```

Or inherit from `TNoRefCountObject` (Delphi 10.1+, declared in `System`) which provides this behavior. (Note: `TAggregatedObject` is a different pattern — it delegates `_AddRef`/`_Release` to a controlling outer object for COM aggregation, rather than disabling reference counting.)

### 9.6 Interface Delegation (`implements`)

```pascal
type
  TWrapper = class(TInterfacedObject, ILogger)
  private
    FLogger: ILogger;
  public
    property Logger: ILogger read FLogger implements ILogger;
  end;
```

The `implements` directive delegates an entire interface to a field or property. The delegating object does not need to implement the interface methods itself — they are forwarded to the delegate.

Rules:
1. The property type must be the interface type or a class implementing it.
2. The property must have a `read` specifier.
3. If the delegate is a class (not an interface), `as` is used internally to obtain the interface.

### 9.7 IDispatch and Dispatch Interfaces

```pascal
type
  IMyDispatch = dispinterface
    ['{...}']
    procedure DoSomething; dispid 1;
    property Value: Integer dispid 2;
  end;
```

`dispinterface` declares a COM dispatch interface for late binding via `IDispatch.Invoke`. Methods and properties are identified by dispatch IDs (`dispid`).

### 9.8 Interface GUIDs

Interfaces may have a GUID:

```pascal
['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
```

A GUID is required for:
- `QueryInterface` / `Supports` / `as` to work at runtime.
- COM interoperability.

Interfaces without a GUID can still be used for compile-time polymorphism but cannot be queried at runtime.

### 9.9 The `Supports` Function

```pascal
function Supports(const Instance: TObject; const IID: TGUID; out Intf): Boolean;
function Supports(const Instance: IInterface; const IID: TGUID; out Intf): Boolean;
```

`Supports` is a safer alternative to `as` — it returns `False` instead of raising an exception.

---

## Chapter 10: Advanced Records

### 10.1 Overview

Records may contain methods, properties, operators, constructors, nested types, and class members. This makes records behave like lightweight classes, but they remain **value types** with no inheritance and no virtual dispatch.

```pascal
type
  TVector3 = record
  private
    FX, FY, FZ: Double;
  public
    constructor Create(AX, AY, AZ: Double);
    function Length: Double;
    function Normalized: TVector3;
    class function Zero: TVector3; static;
    class operator Add(const A, B: TVector3): TVector3;
    class operator Implicit(const A: TVector3): string;
    property X: Double read FX write FX;
    property Y: Double read FY write FY;
    property Z: Double read FZ write FZ;
  end;
```

### 10.2 Record Constructors

Records may have constructors (but not destructors):

```pascal
constructor TVector3.Create(AX, AY, AZ: Double);
begin
  FX := AX;
  FY := AY;
  FZ := AZ;
end;
```

Rules:
1. Record constructors must have at least one parameter (the parameterless "constructor" is the default zero-initialization, which cannot be overridden).
2. Record constructors do not allocate memory — they initialize `Self` in place.

### 10.3 Record Methods

Records may have instance methods and class/static methods. Instance methods receive `Self` by reference (allowing modification). In a `const` context, `Self` is read-only.

### 10.4 Operator Overloading

Records can overload operators using the `class operator` syntax:

```pascal
class operator Add(const A, B: TMyType): TMyType;
class operator Subtract(const A, B: TMyType): TMyType;
```

Complete list of overloadable operators:

| Operator name   | Pascal symbol | Description              |
|-----------------|---------------|--------------------------|
| `Implicit`      | (assignment)  | Implicit type conversion |
| `Explicit`      | `T(x)`        | Explicit type cast       |
| `Negative`      | `-`           | Unary negation           |
| `Positive`      | `+`           | Unary positive           |
| `Inc`           | `Inc(x)`      | Increment                |
| `Dec`           | `Dec(x)`      | Decrement                |
| `LogicalNot`    | `not`         | Logical NOT              |
| `Trunc`         | `Trunc(x)`    | Truncate to integer      |
| `Round`         | `Round(x)`    | Round to integer         |
| `In`            | `in`          | Set membership           |
| `Equal`         | `=`           | Equality                 |
| `NotEqual`      | `<>`          | Inequality               |
| `GreaterThan`   | `>`           | Greater than             |
| `GreaterThanOrEqual` | `>=`    | Greater or equal         |
| `LessThan`      | `<`           | Less than                |
| `LessThanOrEqual` | `<=`       | Less or equal            |
| `Add`           | `+`           | Addition                 |
| `Subtract`      | `-`           | Subtraction              |
| `Multiply`      | `*`           | Multiplication           |
| `Divide`        | `/`           | Real division            |
| `IntDivide`     | `div`         | Integer division         |
| `Modulus`       | `mod`         | Modulus                  |
| `LeftShift`     | `shl`         | Left shift               |
| `RightShift`    | `shr`         | Right shift              |
| `LogicalAnd`    | `and`         | Logical/bitwise AND      |
| `LogicalOr`     | `or`          | Logical/bitwise OR       |
| `LogicalXor`    | `xor`         | Logical/bitwise XOR      |

Rules:
1. At least one parameter must be of the declaring type.
2. `Implicit` and `Explicit` have exactly one parameter.
3. Binary operators have exactly two parameters; unary operators have one.
4. Overloaded operators are resolved using the same overload resolution rules as functions.

### 10.5 Record Helpers

```pascal
type
  TDateTimeHelper = record helper for TDateTime
    function ToString: string;
    function Year: Word;
  end;
```

Record helpers extend existing record types or simple types with additional methods. Same scope rules as class helpers ([§8.15](#815-class-helpers)) and type helpers ([§3.11](#311-type-helpers)).

### 10.6 Managed Records (Delphi 10.4+)

Records with the `class operator Initialize` and `class operator Finalize` operators are **managed records**:

```pascal
type
  TManagedRec = record
    Data: Pointer;
    class operator Initialize(out Dest: TManagedRec);
    class operator Finalize(var Dest: TManagedRec);
    class operator Assign(var Dest: TManagedRec; const [ref] Src: TManagedRec);
  end;
```

| Operator     | When called                                        |
|--------------|----------------------------------------------------|
| `Initialize` | When a variable of this type comes into scope       |
| `Finalize`   | When a variable goes out of scope or is disposed    |
| `Assign`     | When one variable is assigned to another            |

Rules:
1. `Initialize` receives an `out` parameter (zero-initialized before the call).
2. `Finalize` receives a `var` parameter.
3. `Assign` receives `var Dest` and `const [ref] Src`.
4. If `Assign` is not defined, the compiler generates a default assignment: it first finalizes the destination's managed sub-fields (decrementing reference counts), copies the raw bytes, and then increments reference counts for the source's managed sub-fields.
5. Managed records incur overhead: the compiler inserts `Initialize`/`Finalize` calls around every scope where such a record exists.

#### 10.6.1 Implicit Self Parameter (Delphi 13+)

Starting with Delphi 13, the `Initialize` and `Finalize` operators may omit the explicit parameter declaration. The compiler implicitly provides `Self` as the record instance. (`Assign` still requires explicit parameters because it takes two operands — `var Dest` and `const [ref] Src`.)

```pascal
type
  TManagedRec = record
    Data: Pointer;
    class operator Initialize;   // implicit out Self: TManagedRec
    class operator Finalize;     // implicit var Self: TManagedRec
    class operator Assign(var Dest: TManagedRec; const [ref] Src: TManagedRec);
  end;

class operator TManagedRec.Initialize;
begin
  Self.Data := nil;  // Self is available implicitly
end;
```

The explicit parameter form of `Initialize` and `Finalize` remains valid. Both forms produce identical behavior and compiled code.

---

## Chapter 11: Generics

### 11.1 Overview

Generics (parameterized types) allow types and routines to be parameterized by one or more type parameters. Delphi generics are instantiated at **compile time** (similar to C++ templates but with constraints).

### 11.2 Generic Type Declarations

```
GENERIC_TYPE_DECL = IDENT '<' TYPE_PARAM_LIST '>' '=' TYPE ;
TYPE_PARAM_LIST   = TYPE_PARAM { ',' TYPE_PARAM } ;
TYPE_PARAM        = IDENT [ ':' CONSTRAINT_LIST ] ;
CONSTRAINT_LIST   = CONSTRAINT { ',' CONSTRAINT } ;
CONSTRAINT        = 'class'
                  | 'record'
                  | 'constructor'
                  | 'interface'
                  | 'unmanaged'
                  | INTERFACE_TYPE
                  | CLASS_TYPE ;
```

#### 11.2.1 Generic Classes

```pascal
type
  TStack<T> = class
  private
    FItems: TArray<T>;
    FCount: Integer;
  public
    procedure Push(const Item: T);
    function Pop: T;
    function Peek: T;
    property Count: Integer read FCount;
  end;
```

#### 11.2.2 Generic Records

```pascal
type
  TNullable<T: record> = record
  private
    FValue: T;
    FHasValue: Boolean;
  public
    constructor Create(const AValue: T);
    property HasValue: Boolean read FHasValue;
    property Value: T read FValue;
  end;
```

#### 11.2.3 Generic Interfaces

```pascal
type
  IComparer<T> = interface
    function Compare(const Left, Right: T): Integer;
  end;
```

### 11.3 Type Constraints

Constraints restrict what types may be used as type arguments:

| Constraint      | Meaning                                                 |
|-----------------|---------------------------------------------------------|
| `class`         | T must be a class type (reference type)                 |
| `record`        | T must be a value type (record, not a class)            |
| `constructor`   | T must have a parameterless constructor                  |
| `interface`     | T must be an interface type (Delphi 13+)                |
| `unmanaged`     | T must be a value type without managed fields (Delphi 13+) |
| `IInterface`    | T must implement the specified interface                  |
| `TBaseClass`    | T must be the specified class or a descendant            |

Multiple constraints can be combined:

```pascal
type
  TEntity<T: class, constructor, ISerializable> = class
    // T must be a class, have a parameterless constructor,
    // and implement ISerializable
  end;
```

**Constraint combination rules:**
- Only **one** class-type constraint is allowed per type parameter. `T: TFoo, TBar` (two class constraints) is a compile error, consistent with Delphi's single-inheritance model.
- Multiple **interface** constraints are allowed and can be combined with a single class constraint: `T: TFoo, IBar, IBaz`.
- The `class` and `record` constraints are mutually exclusive.
- The `class` and `unmanaged` constraints are mutually exclusive.
- All listed constraints must be satisfied simultaneously — they are additive, not alternatives.

#### 11.3.1 Operations Permitted by Constraints

Without constraints, only these operations are permitted on a type parameter `T`:
- Assignment
- Comparison with `nil` (only if T might be a reference type — ambiguous without constraints)
- `SizeOf(T)`, `Default(T)`, `TypeInfo(T)`

With the `class` constraint:
- Comparison with `nil`
- `Free`, `is`, `as`
- Access to `TObject` members

With a specific class constraint `TFoo`:
- All members of `TFoo` are accessible

With an interface constraint `IFoo`:
- All members of `IFoo` are accessible

With the `constructor` constraint:
- `T.Create` (parameterless constructor call)

With the `record` constraint:
- The type parameter is guaranteed to be a value type (may include managed fields such as strings or dynamic arrays)
- No nil comparison allowed

With the `unmanaged` constraint (Delphi 13+):
- Like `record`, the type parameter must be a value type
- Additionally, the type must not contain managed fields (no strings, dynamic arrays, interfaces, or Variants)
- Enables L-value casts on generic type variables, which is not safe with managed types
- The `unmanaged` constraint is a stricter subset of the `record` constraint

With the `interface` constraint (Delphi 13+):
- The type parameter must be an interface type
- Comparison with `nil` is allowed
- Access to `IInterface` members (`QueryInterface`, `_AddRef`, `_Release`) is available

### 11.4 Generic Methods

Standalone procedures/functions and methods can be generic:

```pascal
function Max<T: record>(const A, B: T): T;
// Note: requires IComparer or operator support to actually compare

procedure TMyClass.Process<T>(const Item: T);
```

#### 11.4.1 Type Inference

The compiler can infer type arguments for generic method calls in many cases:

```pascal
var X := Max<Integer>(3, 5);  // explicit
var Y := Max(3, 5);           // inferred: T = Integer
```

Type inference is not supported for generic type instantiations (only for method calls).

### 11.5 Generic Instantiation

A generic type is instantiated by providing type arguments:

```pascal
var
  IntStack: TStack<Integer>;
  StrStack: TStack<string>;
```

Each distinct instantiation produces a separate type. `TStack<Integer>` and `TStack<string>` are different types with no relationship.

### 11.6 Implementation Model

Delphi generics use a **code-specialization** model:

1. The generic type/method body is parsed and partially validated at declaration time.
2. At each instantiation point, the compiler creates a specialized copy with the type parameters replaced by actual types.
3. Full semantic analysis (including overload resolution and type checking) occurs on the specialized copy.
4. The linker may merge identical specializations to reduce code size (implementation-defined).

This means:
- The compiler validates the generic body against the declared constraints at **declaration time**. Operations on `T` that are not guaranteed by the constraints produce a compile-time error at the generic declaration, not at instantiation.
- At each instantiation point, a specialized copy is created with actual types substituted; additional type-specific errors (e.g., ambiguous overloads) may surface at instantiation time.

### 11.7 Generic Constraints vs. Duck Typing

Unlike C++ templates, Delphi generics are **constrained**: you can only use operations on `T` that are guaranteed by the constraints. The compiler enforces this at the generic declaration site — not at instantiation — so all type arguments that satisfy the constraints are guaranteed to work. Best practice is to always specify appropriate constraints.

### 11.7.1 Delphi-Specific Generic Limitations

- **No type inference for generic type instantiations.** Type arguments must be explicit when instantiating a generic type (`TStack<Integer>`). Inference is supported only for generic method calls ([§11.4.1](#1141-type-inference)).
- **Constraint combinations are additive, not union.** All listed constraints must be satisfied simultaneously: `T: class, constructor` requires a class with a parameterless constructor -- not one or the other.
- **Instantiation-time errors.** While constraint violations are caught at declaration time, certain errors (e.g., ambiguous overloads or incompatible assignments involving the actual type) are reported at the instantiation point. This can produce confusing error messages.
- **No partial specialization.** Unlike C++, Delphi does not support specializing a generic type for a specific type argument. All instantiations share the same generic body.
- **No variadic type parameters.** A generic type must have a fixed number of type parameters declared at definition time.
- **Open generic types cannot be used as type arguments.** `TList<TStack>` (without providing a type argument for `TStack`) is not permitted.

### 11.8 Predefined Generic Types

The `System` and `System.Generics.Collections` units provide:

| Type | Description |
|------|-------------|
| `TArray<T>` | Alias for `array of T` |
| `TList<T>` | Generic dynamic list |
| `TDictionary<TKey, TValue>` | Hash map |
| `TQueue<T>` | FIFO queue |
| `TStack<T>` | LIFO stack |
| `TObjectList<T: class>` | List that owns its objects |
| `TObjectDictionary<TKey, TValue>` | Dictionary with ownership options |
| `TComparer<T>` | Default comparer factory |
| `TEqualityComparer<T>` | Default equality comparer |
| `TPair<TKey, TValue>` | Key-value pair record |

### 11.9 Covariance and Contravariance

Object Pascal generics do **not** support variance annotations. `TList<TDog>` is not assignable to `TList<TAnimal>` even though `TDog` inherits from `TAnimal`. This is a deliberate design decision to preserve type safety.

### 11.10 Nested Generics and Complex Instantiation

Generic types may be nested inside other generic types:

```pascal
type
  TOuter<T> = class
    type
      TInner = class
        Value: T;
      end;
  end;
```

Instantiation: `TOuter<Integer>.TInner`.

Generic types can also be used as type arguments:

```pascal
var Dict: TDictionary<string, TList<Integer>>;
```

The `>>` at the end is correctly parsed as two closing angle brackets (not a shift operator) in a generic context.

---

## Chapter 12: Anonymous Methods and Method References

### 12.1 Method Reference Types

```
METHOD_REFERENCE = 'reference' 'to' ( PROCEDURE_TYPE | FUNCTION_TYPE ) ;
```

```pascal
type
  TProc = reference to procedure;
  TFunc<TResult> = reference to function: TResult;
  TFunc<T, TResult> = reference to function(Arg1: T): TResult;
  TFunc<T1, T2, TResult> = reference to function(Arg1: T1; Arg2: T2): TResult;
  TPredicate<T> = reference to function(Arg1: T): Boolean;
```

Method reference types can hold:
1. An **anonymous method** (closure)
2. A **regular procedure/function** (standalone)
3. A **method of object** (bound method)

This makes them the most flexible procedural type.

### 12.2 Anonymous Method Syntax

```pascal
var
  Greet: TProc;
begin
  Greet := procedure
    begin
      WriteLn('Hello');
    end;
  Greet();
end;
```

```pascal
var
  Add: TFunc<Integer, Integer, Integer>;
begin
  Add := function(const A, B: Integer): Integer
    begin
      Result := A + B;
    end;
end;
```

### 12.3 Variable Capture (Closures)

Anonymous methods can capture variables from the enclosing scope:

```pascal
function CreateCounter: TFunc<Integer>;
var
  Count: Integer;
begin
  Count := 0;
  Result := function: Integer
    begin
      Inc(Count);
      Result := Count;
    end;
end;
```

Rules:

1. Captured variables are captured **by reference**, not by value. Changes to the variable inside the anonymous method affect the original, and vice versa.
2. Captured variables are **lifetime-extended**: they are moved from the stack to a hidden reference-counted **capture object** (implemented as a compiler-generated interface). They survive as long as any anonymous method referencing them exists.
3. Multiple anonymous methods in the same scope share the same capture object (and thus the same captured variables).
4. Loop variables captured by reference share a single storage location, which may lead to unexpected behavior (all closures see the final value). This is a well-known gotcha. The standard workaround is to copy the loop variable to a local variable before capturing:

```pascal
for i := 0 to 9 do
begin
  var LocalCopy := i;  // new local per iteration
  Procs[i] :=
    procedure
    begin
      WriteLn(LocalCopy);  // each closure captures its own LocalCopy
    end;
end;
```

Each iteration creates a new `LocalCopy` variable with its own captured lifetime, so each anonymous method sees the value of `i` at the time it was copied.

### 12.4 Implementation Details

The compiler implements anonymous methods as:

1. A hidden class implementing an anonymous interface.
2. The captured variables become fields of this hidden class.
3. The anonymous method body becomes a method of the hidden class.
4. The method reference variable holds an interface reference to this hidden object.
5. Reference counting on the interface manages the lifetime of the capture object.

### 12.5 Compatibility

Method references are **not** type-compatible with `procedure of object` or plain `procedure` pointer types. They are a distinct category:

```pascal
type
  TPlainProc = procedure;
  TMethodProc = procedure of object;
  TRefProc = reference to procedure;
```

A `reference to` variable can hold all three kinds, but the reverse is not true. A `procedure of object` variable cannot hold an anonymous method.

---

## Chapter 13: Exception Handling

### 13.1 Exception Types

Exceptions in Object Pascal are objects — instances of classes that descend from `Exception` (defined in `System.SysUtils`):

```pascal
Exception = class(TObject)
  constructor Create(const Msg: string);
  constructor CreateFmt(const Msg: string; const Args: array of const);
  property Message: string;
  property HelpContext: Integer;
  property StackTrace: string;  // Delphi 2009+; requires a stack trace provider
end;
```

Standard exception classes include:

| Class | Description |
|-------|-------------|
| `EAbort` | Silent exception (does not display error) |
| `EAbstractError` | Call to abstract method |
| `EAccessViolation` | Invalid memory access |
| `EArgumentException` | Invalid argument |
| `EArgumentNilException` | Nil argument |
| `EArgumentOutOfRangeException` | Argument out of range |
| `EConvertError` | Type conversion error |
| `EDivByZero` | Integer division by zero |
| `EInOutError` | File I/O error |
| `EIntOverflow` | Integer overflow |
| `EInvalidCast` | Invalid typecast |
| `EInvalidOp` | Invalid floating-point operation |
| `ENotImplemented` | Feature not implemented |
| `EOutOfMemory` | Memory allocation failure |
| `ERangeError` | Range check error |
| `EStackOverflow` | Stack overflow |
| `EOverflow` | Floating-point overflow |
| `EUnderflow` | Floating-point underflow |
| `EZeroDivide` | Floating-point division by zero |

### 13.2 The `raise` Statement

```
RAISE_STMT = 'raise' [ EXPRESSION ] [ 'at' EXPRESSION ] ;
```

```pascal
raise Exception.Create('Something went wrong');
raise EArgumentException.CreateFmt('Invalid value: %d', [Value]);
raise;  // re-raise current exception (in except block only)
raise E at ReturnAddr;  // raise with custom return address
```

Rules:
1. The expression must evaluate to an object (class instance). By convention, a new exception object is created at the `raise` site.
2. After `raise`, control transfers to the nearest enclosing exception handler.
3. A bare `raise` (no expression) in an `except` block re-raises the current exception without destroying it.
4. The `at` clause specifies a code address for the exception's origin (for debugging).

### 13.3 The `try..except` Statement

```
TRY_EXCEPT = 'try'
               STMT_LIST
             'except'
               EXCEPTION_HANDLER_LIST
             'end' ;

EXCEPTION_HANDLER_LIST = EXCEPTION_HANDLER { ';' EXCEPTION_HANDLER }
                       | STMT_LIST ;

EXCEPTION_HANDLER = 'on' [ IDENT ':' ] TYPE_IDENT 'do' STATEMENT ;
```

Example:

```pascal
try
  DoSomething;
except
  on E: EConvertError do
    WriteLn('Conversion error: ', E.Message);
  on E: Exception do
    WriteLn('Error: ', E.Message);
  // no 'else' needed — unhandled exceptions propagate
end;
```

Rules:

1. Exception handlers are checked **top to bottom**; the first matching handler executes.
2. A handler `on E: TFoo do ...` matches if the exception object is an instance of `TFoo` or a descendant.
3. `E` is a local variable bound to the exception object within the handler.
4. If the handler does not re-raise the exception, the exception object is **destroyed** (freed) after the handler completes.
5. An `else` clause (or bare statement list without `on` handlers) catches all exceptions.
6. After the handler executes, control continues after the `end` of the `try..except`.

### 13.4 The `try..finally` Statement

```
TRY_FINALLY = 'try'
                STMT_LIST
              'finally'
                STMT_LIST
              'end' ;
```

```pascal
Stream := TFileStream.Create('data.bin', fmOpenRead);
try
  // use Stream
finally
  Stream.Free;  // always executed
end;
```

Rules:

1. The `finally` block **always** executes, whether the `try` block completes normally, raises an exception, or calls `Exit`/`Break`/`Continue`.
2. If an exception is pending, it is held during the `finally` block. After `finally` completes:
   - If `finally` raises a new exception, the original exception is destroyed and the new one propagates.
   - If `finally` completes normally, the original exception continues to propagate.
3. `try..finally` does not handle exceptions — it only ensures cleanup. For handling, use `try..except`.

### 13.5 Nested Exception Handling

`try..except` and `try..finally` can be nested:

```pascal
try
  try
    DoSomething;
  except
    on E: Exception do
      LogError(E.Message);  // handle
  end;
finally
  Cleanup;  // always runs
end;
```

### 13.6 Exception Chaining (Nested Exceptions)

Delphi supports exception chaining via `Exception.RaiseOuterException` and `Exception.InnerException`:

```pascal
try
  DoSomething;
except
  on E: Exception do
    Exception.RaiseOuterException(
      EMyException.Create('Wrapper: ' + E.Message));
end;
```

The original exception is preserved in the `InnerException` property.

### 13.7 Abort

`Abort` raises `EAbort`, a "silent" exception that is caught by the application's default handler without displaying an error message. It is used to cancel an operation without alarming the user.

---

## Chapter 14: Memory Management and Object Lifecycle

### 14.1 Memory Model Overview

Object Pascal uses **manual memory management** for class instances on the desktop/server compilers (Win32, Win64, Linux, macOS). Developers are responsible for creating and destroying objects.

#### 14.1.1 Stack Allocation
- Value types (integers, floats, records, static arrays, sets) are allocated on the stack for local variables.
- Passed by value to functions, copied on assignment.

#### 14.1.2 Heap Allocation
- Class instances are always heap-allocated (via `TObject.NewInstance` → `GetMem`).
- Dynamic arrays and long strings are heap-allocated and reference-counted.
- Pointers obtained via `New`, `GetMem`, `AllocMem`, or `ReallocMem` are heap-allocated.

### 14.2 Object Creation and Destruction

```pascal
var Obj: TMyClass;
Obj := TMyClass.Create;   // allocate + initialize
try
  // use Obj
finally
  Obj.Free;               // destroy + deallocate
end;
```

The `try..finally` pattern is the standard idiom for object lifetime management.

#### 14.2.1 FreeAndNil

```pascal
procedure FreeAndNil(const [ref] Obj: TObject);
```

`FreeAndNil` frees the object and sets the variable to `nil`. This prevents dangling pointer access. The type-safe signature (Delphi 10.4+) ensures that only `TObject` descendants are accepted, preventing misuse with non-object variables.

### 14.3 Reference Counting

The following types are **reference-counted** with **copy-on-write** (COW):

| Type | Ref-counted | COW |
|------|-------------|-----|
| `string` (UnicodeString) | Yes | Yes |
| `AnsiString` | Yes | Yes |
| Dynamic arrays | Yes | No (shared reference on assign) |
| Interfaces | Yes | No (shared, not COW) |
| `Variant` | No (managed; deep copy on assign) | N/A |

Reference counts are managed atomically (thread-safe increment/decrement).

### 14.4 Low-Level Memory Routines

| Routine | Description |
|---------|-------------|
| `GetMem(P, Size)` | Allocate Size bytes, store pointer in P |
| `FreeMem(P)` | Free memory at P |
| `ReallocMem(P, Size)` | Resize allocation |
| `AllocMem(Size)` | Allocate and zero-fill |
| `New(P)` | Allocate a typed pointer (`P: ^T`) |
| `Dispose(P)` | Free a typed pointer, finalize managed fields |
| `Initialize(V)` | Initialize managed fields of a variable |
| `Finalize(V)` | Finalize managed fields (release refs) |
| `Move(Src, Dst, Count)` | Copy bytes (no overlap check) |
| `FillChar(V, Count, Value)` | Fill memory with a byte value |

### 14.5 Weak References

Delphi supports the `[weak]` attribute for interface references to break reference cycles:

```pascal
type
  TChild = class
  private
    [weak] FParent: IParent;  // weak reference -- does not prevent destruction
  end;
```

When the referenced object is destroyed, weak references are automatically set to `nil`. The runtime tracks all weak references to a given object and zeroes them on destruction.

**Background.** `[weak]` was introduced for Automatic Reference Counting (ARC), originally targeting mobile platforms. On Win32/Win64, ARC is not used for class types, but `[weak]` is still honored for **interface** references. It is not meaningful for plain class-type fields on desktop platforms (use a non-owning raw pointer instead).

**`[unsafe]`** is a stronger variant: it does not participate in reference counting at all (no `_AddRef`/`_Release` calls) and is **not** automatically zeroed when the referenced object is destroyed. Accessing an `[unsafe]` reference after the referenced object is freed is undefined behavior -- the pointer may be dangling. Use `[unsafe]` only in interop scenarios where the lifetime is managed externally.

Lifetime implications:
- A `[weak]` reference extends the lifetime of nothing. If all strong references to an object go away, the object is destroyed and all weak references to it become `nil`.
- Always check a `[weak]` reference for `nil` before using it; the object may have been destroyed on another thread between the check and the use in multi-threaded code.
- `[unsafe]` offers no protection at all; the programmer is fully responsible for ensuring the referenced object outlives the reference.

### 14.6 Managed Types Summary

A type is "managed" if it requires compiler-generated initialization, finalization, or reference-count management:

| Managed type | Requires |
|-------------|----------|
| `string` (any) | Ref-count, finalize |
| Dynamic array | Ref-count, finalize |
| Interface | Ref-count, finalize |
| Variant | Deep copy, finalize |
| Record with managed fields | Recursive init/finalize |
| Managed record (Initialize/Finalize operators) | Custom init/finalize |

When a managed type goes out of scope, the compiler inserts finalization code.

---

## Chapter 15: Runtime Type Information (RTTI) and Attributes

### 15.1 RTTI Overview

Object Pascal generates **Runtime Type Information** (RTTI) for types, enabling reflection, serialization, and the streaming system. The amount of RTTI generated is controlled by compiler directives and visibility.

### 15.2 Classic RTTI (`TypInfo` Unit)

The classic RTTI system provides information about `published` properties and methods. Key types:

```pascal
type
  TTypeKind = (
    tkUnknown, tkInteger, tkChar, tkEnumeration, tkFloat,
    tkString, tkSet, tkClass, tkMethod, tkWChar, tkLString,
    tkWString, tkVariant, tkArray, tkRecord, tkInterface,
    tkInt64, tkDynArray, tkUString, tkClassRef, tkPointer,
    tkProcedure, tkMRecord
  );
```

Key functions:

| Function | Description |
|----------|-------------|
| `GetPropInfo(TypeInfo, PropName)` | Get property info by name |
| `GetPropValue(Instance, PropName)` | Get property value as Variant |
| `SetPropValue(Instance, PropName, Value)` | Set property value |
| `GetPropList(TypeInfo, ...)` | Get list of published properties |
| `IsPublishedProp(Instance, PropName)` | Check if property exists |

### 15.3 Extended RTTI (`System.Rtti` Unit, Delphi 2010+)

Extended RTTI provides comprehensive reflection for all types and members at all visibility levels (controlled by `{$RTTI}` directive).

#### 15.3.1 Core Types

```pascal
type
  TRttiContext = record
    function GetType(ATypeInfo: Pointer): TRttiType;
    function GetType(AClass: TClass): TRttiType;
    function FindType(const QualifiedName: string): TRttiType;
    function GetTypes: TArray<TRttiType>;
  end;

  TRttiType = class
    property Name: string;
    property QualifiedName: string;
    property TypeKind: TTypeKind;
    property TypeSize: Integer;
    property Handle: PTypeInfo;
    function GetMethods: TArray<TRttiMethod>;
    function GetMethod(const AName: string): TRttiMethod;
    function GetProperties: TArray<TRttiProperty>;
    function GetProperty(const AName: string): TRttiProperty;
    function GetFields: TArray<TRttiField>;
    function GetField(const AName: string): TRttiField;
    function GetAttributes: TArray<TCustomAttribute>;
  end;

  TRttiMethod = class(TRttiMember)
    property ReturnType: TRttiType;
    function GetParameters: TArray<TRttiParameter>;
    function Invoke(Instance: TObject; const Args: array of TValue): TValue;
    function Invoke(Instance: TClass; const Args: array of TValue): TValue;
  end;

  TRttiProperty = class(TRttiMember)
    property PropertyType: TRttiType;
    function GetValue(Instance: Pointer): TValue;
    procedure SetValue(Instance: Pointer; const AValue: TValue);
    property IsReadable: Boolean;
    property IsWritable: Boolean;
  end;

  TRttiField = class(TRttiMember)
    property FieldType: TRttiType;
    property Offset: Integer;
    function GetValue(Instance: Pointer): TValue;
    procedure SetValue(Instance: Pointer; const AValue: TValue);
  end;
```

#### 15.3.2 TValue

`TValue` is a universal value container (like a typed Variant) that can hold any Delphi value:

```pascal
var V: TValue;
V := TValue.From<Integer>(42);
V := TValue.From<string>('Hello');
var I := V.AsInteger;
var S := V.AsString;
```

### 15.4 Attributes

Attributes are custom metadata annotations attached to types, fields, methods, properties, and parameters.

#### 15.4.1 Declaring Custom Attributes

```pascal
type
  TableAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  RequiredAttribute = class(TCustomAttribute)
  end;
```

All attributes must descend from `TCustomAttribute`.

#### 15.4.2 Applying Attributes

```pascal
type
  [Table('Users')]
  TUser = class
  private
    [Required]
    FName: string;
    [Column('email_address')]
    FEmail: string;
  public
    property Name: string read FName write FName;
    property Email: string read FEmail write FEmail;
  end;
```

Syntax:

```
ATTRIBUTE_LIST = '[' ATTRIBUTE { ',' ATTRIBUTE } ']' ;
ATTRIBUTE = TYPE_IDENT [ '(' EXPR_LIST ')' ] ;
```

Rules:
1. The attribute class name can omit the `Attribute` suffix: `[Table('X')]` resolves to `TableAttribute`.
2. Constructor arguments must be constant expressions.
3. Attributes can be applied to: types, fields, methods, properties, method parameters, and return types (`[Result: MyAttr]`).
4. Multiple attributes can be in one bracket or separate brackets.
5. The same attribute class can be applied multiple times (unless the attribute is designed to prevent this).

#### 15.4.3 Querying Attributes at Runtime

```pascal
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Attr: TCustomAttribute;
begin
  RttiType := Ctx.GetType(TUser);
  for Attr in RttiType.GetAttributes do
    if Attr is TableAttribute then
      WriteLn('Table: ', TableAttribute(Attr).Name);
end;
```

### 15.5 The `{$RTTI}` Directive

Controls the amount of extended RTTI generated:

```pascal
{$RTTI EXPLICIT METHODS([vcPublic, vcPublished]) PROPERTIES([vcPublic, vcPublished]) FIELDS([vcPrivate..vcPublished])}
```

Options:
- `INHERIT` — use the parent type's RTTI settings
- `EXPLICIT` — specify exactly which visibility levels generate RTTI
- Visibility sets: `vcPrivate`, `vcProtected`, `vcPublic`, `vcPublished`

By default, full RTTI is generated for `published` members and limited RTTI for other visibility levels.

### 15.6 The `{$M}` Directive

`{$M+}` enables generation of `published` RTTI for a class and all its descendants. `TPersistent` has `{$M+}`, so all `TPersistent` descendants support published property streaming.

### 15.7 RTTI and Generic Types

Each distinct generic instantiation generates its own RTTI. `TList<Integer>` and `TList<string>` are separate types with separate RTTI records.

Rules:
1. **Naming**: `TRttiType.Name` returns names that include the fully qualified type arguments, e.g., `TList<System.Integer>`, `TDictionary<System.string,System.Integer>`.
2. **FindType**: `TRttiContext.FindType` requires the exact mangled name including type arguments. Finding a generic type by name requires knowing this precise form.
3. **Per-instantiation RTTI**: Each instantiation has its own `TypeInfo` pointer. `TypeInfo(TList<Integer>) <> TypeInfo(TList<string>)`.
4. **Uninstantiated generics**: Open generic types (e.g., `TList<T>` before instantiation) do not have RTTI. Only concrete instantiations produce RTTI records.

---

## Chapter 16: Inline Assembly

### 16.1 The `asm` Block

```
ASM_STMT = 'asm'
             { ASM_INSTRUCTION }
           'end' ;
```

```pascal
function SwapBytes(Value: Cardinal): Cardinal;
asm
  BSWAP EAX  // Win32: Value is in EAX, result in EAX
end;
```

### 16.2 Supported Architectures

| Platform | Instruction Set |
|----------|-----------------|
| Win32    | x86 (IA-32) with SSE/SSE2/AVX extensions |
| Win64    | x86-64 (AMD64) |
| Win64 Arm | ARM64 (Arm64EC) (Delphi 13.1+) |
| Linux64  | x86-64 |
| macOS64  | x86-64 or ARM64 (Apple Silicon) |
| Android  | ARM32 (ARMV7) or ARM64 (AArch64) |
| iOS      | ARM64 |

Inline assembly syntax varies by target platform. Win32 uses Intel syntax (register-based calling convention by default). Win64 uses Microsoft x64 calling convention.

### 16.3 Accessing Pascal Symbols

Inside `asm` blocks, you can reference:
- Local variables by name (compiler resolves to `[EBP+offset]` or `[RBP+offset]`)
- Parameters by name
- Global variables by name
- Type sizes via `TYPE` operator
- Record fields via dot notation: `[EAX].TPoint.X`
- `Self` in methods

### 16.4 Register Conventions

#### Win32 (register calling convention):
- First three parameters in `EAX`, `EDX`, `ECX`
- Result in `EAX` (ordinal/pointer), `EAX:EDX` (64-bit), or `ST(0)` (float)
- `EBX`, `ESI`, `EDI`, `EBP` must be preserved

#### Win64 (Microsoft x64 ABI):
- First four params in `RCX`, `RDX`, `R8`, `R9` (integer/pointer) or `XMM0`-`XMM3` (float)
- Result in `RAX` or `XMM0`
- `RBX`, `RBP`, `RDI`, `RSI`, `RSP`, `R12`-`R15` must be preserved

### 16.5 Pure Assembler Routines

An entire routine can be written in assembly:

```pascal
function FastAdd(A, B: Integer): Integer;
asm
  // Win32: A in EAX, B in EDX
  ADD EAX, EDX
end;
```

The `assembler` directive is optional (the presence of `asm..end` is sufficient).

### 16.6 Restrictions

1. `asm` blocks cannot be used in `inline` routines.
2. `asm` blocks in generic types/methods are not portable.
3. Platform-specific assembly makes code non-portable.
4. The compiler does not optimize across `asm` boundaries.

---

## Chapter 17: Compiler Directives

### 17.1 Overview

Compiler directives control compilation behavior. They appear in the source as special comments:

```
DIRECTIVE = '{$' DIRECTIVE_NAME [ DIRECTIVE_ARGS ] '}'
          | '(*$' DIRECTIVE_NAME [ DIRECTIVE_ARGS ] '*)' ;
```

Directives fall into three categories:
1. **Switch directives** — toggle a boolean setting (e.g., `{$R+}`, `{$R-}`)
2. **Parameter directives** — accept a value (e.g., `{$APPTYPE CONSOLE}`)
3. **Conditional compilation directives** — control which code is compiled

### 17.2 Switch Directives

| Directive | Default | Description |
|-----------|---------|-------------|
| `{$A+}` / `{$ALIGN ON}` | ON | Field alignment (8-byte) |
| `{$B+}` / `{$BOOLEVAL ON}` | OFF | Complete boolean evaluation |
| `{$C+}` / `{$ASSERTIONS ON}` | ON (debug) | Enable `Assert` |
| `{$D+}` / `{$DEBUGINFO ON}` | ON | Generate debug info |
| `{$G+}` / `{$IMPORTEDDATA ON}` | ON | Allow imported data references |
| `{$H+}` / `{$LONGSTRINGS ON}` | ON | `string` = `UnicodeString` (vs `ShortString`) |
| `{$I+}` / `{$IOCHECKS ON}` | ON | I/O error checking |
| `{$J-}` / `{$WRITEABLECONST OFF}` | OFF | Typed constants are read-only |
| `{$L+}` / `{$LOCALSYMBOLS ON}` | ON | Local symbol debug info |
| `{$M-}` / `{$TYPEINFO OFF}` | OFF | Generate published RTTI |
| `{$O+}` / `{$OPTIMIZATION ON}` | ON | Compiler optimization |
| `{$P+}` / `{$OPENSTRINGS ON}` | ON | Open string parameters (legacy) |
| `{$Q-}` / `{$OVERFLOWCHECKS OFF}` | OFF | Integer overflow checking |
| `{$R-}` / `{$RANGECHECKS OFF}` | OFF | Range checking |
| `{$T-}` / `{$TYPEDADDRESS OFF}` | OFF | `@` returns typed pointer |
| `{$U-}` / `{$SAFEDIVIDE OFF}` | OFF | Safe FDIV (Pentium bug workaround) |
| `{$V+}` / `{$VARSTRINGCHECKS ON}` | ON | Short string length checking |
| `{$W-}` / `{$STACKFRAMES OFF}` | OFF | Always generate stack frames |
| `{$X+}` / `{$EXTENDEDSYNTAX ON}` | ON | Extended syntax (function as procedure) |
| `{$Z1}` / `{$MINENUMSIZE 1}` | 1 | Minimum enum size |
| `{$POINTERMATH OFF}` | OFF | Enable pointer arithmetic |
| `{$SCOPEDENUMS OFF}` | OFF | Scoped enumerations |
| `{$ZEROBASEDSTRINGS OFF}` | OFF | 0-based string indexing |
| `{$METHODINFO OFF}` | OFF | Generate method RTTI |

### 17.3 Parameter Directives

| Directive | Description |
|-----------|-------------|
| `{$APPTYPE CONSOLE}` | Console application |
| `{$APPTYPE GUI}` | GUI application (default) |
| `{$DEFINE NAME}` | Define conditional symbol |
| `{$UNDEF NAME}` | Undefine conditional symbol |
| `{$I filename}` / `{$INCLUDE filename}` | Include source file |
| `{$R filename}` / `{$RESOURCE filename}` | Link resource file |
| `{$L filename}` / `{$LINK filename}` | Link object file (.obj, .o) |
| `{$MESSAGE 'text'}` | Emit compiler message |
| `{$MESSAGE HINT 'text'}` | Emit hint |
| `{$MESSAGE WARN 'text'}` | Emit warning |
| `{$MESSAGE ERROR 'text'}` | Emit error (stops compilation) |
| `{$MESSAGE FATAL 'text'}` | Emit fatal error |
| `{$WARN IDENT ON\|OFF\|ERROR\|DEFAULT}` | Control specific warnings |
| `{$REGION 'name'}` / `{$ENDREGION}` | Code folding regions |
| `{$LIBPREFIX 'prefix'}` | Library filename prefix |
| `{$LIBSUFFIX 'suffix'}` | Library filename suffix |
| `{$LIBVERSION 'version'}` | Library version string |
| `{$HPPEMIT 'text'}` | Emit text to C++ header |
| `{$EXTERNALSYM name}` | External symbol for C++ interop |
| `{$NODEFINE name}` | Suppress C++ header generation |
| `{$IMAGEBASE $address}` | Preferred image base address |
| `{$MINSTACKSIZE size}` | Minimum stack size |
| `{$MAXSTACKSIZE size}` | Maximum stack size |
| `{$SETPEFLAGS flags}` | PE header flags |
| `{$PUSHOPT}` | Save current compiler options (Delphi 13+) |
| `{$POPOPT}` | Restore previously saved compiler options (Delphi 13+) |

#### 17.3.1 The `{$PUSHOPT}` and `{$POPOPT}` Directives (Delphi 13+)

`{$PUSHOPT}` saves a snapshot of the current compiler switch settings onto an internal stack. `{$POPOPT}` restores the most recently saved snapshot:

```pascal
{$PUSHOPT}
{$R+}
{$Q+}
  // Range and overflow checking enabled here
  ProcessUntrustedInput(Data);
{$POPOPT}
// Original settings restored
```

Rules:
1. `{$PUSHOPT}` and `{$POPOPT}` calls must be balanced within a source file. The compiler emits a warning if there are more `{$PUSHOPT}` than `{$POPOPT}` at the end of a file.
2. Not all compiler options are eligible — consult the implementation documentation for the specific list of options saved and restored.
3. These directives are analogous to `#pragma option push` / `#pragma option pop` in C/C++.

### 17.4 Conditional Compilation

```
{$IFDEF SYMBOL}     // true if SYMBOL is defined
{$IFNDEF SYMBOL}    // true if SYMBOL is not defined
{$IF EXPRESSION}    // true if expression is true
{$ELSEIF EXPRESSION}
{$ELSE}
{$ENDIF}
{$IFEND}            // alternative to {$ENDIF} for {$IF}
```

#### 17.4.1 Predefined Conditional Symbols

| Symbol | Meaning |
|--------|---------|
| `MSWINDOWS` | Compiling for Windows |
| `LINUX` | Compiling for Linux |
| `MACOS` | Compiling for macOS |
| `ANDROID` | Compiling for Android |
| `IOS` | Compiling for iOS |
| `POSIX` | Compiling for POSIX (Linux, macOS, Android, iOS) |
| `WIN32` | 32-bit Windows target |
| `WIN64` | 64-bit Windows target (x64 or Arm) |
| `CPUX86` | x86 (32-bit) target |
| `CPUX64` | x86-64 (64-bit) target |
| `CPUARM` | ARM (32-bit) target |
| `CPUARM64` | ARM64 target (includes Win64 Arm, macOS, iOS, Android) |
| `CPU32BITS` | 32-bit CPU |
| `CPU64BITS` | 64-bit CPU |
| `UNICODE` | `Char` is `WideChar` (always true in modern Delphi) |
| `CONSOLE` | Console application |
| `DEBUG` | Debug configuration |
| `RELEASE` | Release configuration |
| `VERxxx` | Compiler version (e.g., `VER370` for Delphi 13, `VER360` for Delphi 12) |
| `CompilerVersion` | Compiler version as float (e.g., 37.0 for Delphi 13) |

#### 17.4.2 Conditional Expressions (`{$IF}`)

`{$IF}` supports full constant expressions:

```pascal
{$IF CompilerVersion >= 37.0}
  // Delphi 13+ code
{$ENDIF}

{$IF Defined(MSWINDOWS) and not Defined(WIN64)}
  // 32-bit Windows only
{$ENDIF}

{$IF SizeOf(Pointer) = 8}
  // 64-bit platform
{$ENDIF}
```

Available functions in `{$IF}` expressions:
- `Defined(SYMBOL)` — true if symbol is defined
- `Declared(IDENT)` — true if identifier is declared in the current scope
- `SizeOf(TYPE)` — size of type
- Standard arithmetic and boolean operators

#### 17.4.3 Testing Compiler Switch States (`{$IFOPT}`)

`{$IFOPT}` tests whether a specific compiler switch is on or off:

```pascal
{$IFOPT R+}
  // Range checking is enabled
{$ENDIF}

{$IFOPT O-}
  // Optimization is disabled
{$ENDIF}
```

The switch letter corresponds to the short form of the compiler directive (e.g., `R` for `{$RANGECHECKS}`, `Q` for `{$OVERFLOWCHECKS}`, `I` for `{$IOCHECKS}`, `O` for `{$OPTIMIZATION}`). `{$IFOPT}` only works with switches that have a short-form letter; it cannot test arbitrary symbols.

---

## Chapter 18: Calling Conventions and Interoperability

### 18.1 Calling Conventions

A **calling convention** determines how parameters are passed, how the stack is cleaned up, and which registers are preserved.

| Convention  | Keyword    | Parameter passing                        | Stack cleanup | Usage                        |
|------------|------------|------------------------------------------|---------------|------------------------------|
| Register   | `register` | First 3 in EAX/EDX/ECX (Win32); standard ABI (Win64) | Callee | Default for Object Pascal    |
| Cdecl      | `cdecl`    | Right-to-left on stack                   | Caller        | C library functions          |
| StdCall    | `stdcall`  | Right-to-left on stack                   | Callee        | Win32 API                    |
| SafeCall   | `safecall` | Like stdcall, wraps in HRESULT           | Callee        | COM methods                  |
| Pascal     | `pascal`   | Left-to-right on stack                   | Callee        | Legacy (Turbo Pascal)        |
| WinAPI     | `winapi`   | `stdcall` on Win32, Microsoft x64 ABI on Win64, `cdecl` on POSIX | Platform      | Cross-platform API calls     |

#### 18.1.1 Register Convention (Default)

On **Win32**:
- First parameter in `EAX`
- Second in `EDX`
- Third in `ECX`
- Remaining on the stack, left to right
- Result in `EAX` (ordinal/pointer up to 32 bits), `EAX:EDX` (64-bit), `ST(0)` (float)
- `Self` counts as the first parameter for methods

On **Win64** (Microsoft x64 ABI — used regardless of calling convention keyword):
- All calling conventions effectively use the Microsoft x64 ABI
- First four integer/pointer params: `RCX`, `RDX`, `R8`, `R9`
- First four float params: `XMM0`, `XMM1`, `XMM2`, `XMM3`
- Remaining on the stack
- 32-byte "shadow space" reserved by caller
- Result in `RAX` or `XMM0`

On **Win64 Arm** (Arm64EC ABI — Delphi 13.1+):
- Uses the Arm64EC (Emulation Compatible) calling convention, enabling native ARM64 code to interoperate with x64 emulated code on Windows on Arm devices
- Parameter passing follows the standard Windows ARM64 ABI: first eight integer/pointer params in `X0`-`X7`, first eight float/SIMD params in `V0`-`V7`
- Result in `X0` or `V0`
- Built on LLVM 20 infrastructure with Microsoft UCRT runtime

#### 18.1.2 SafeCall Convention

`safecall` is used for COM interface methods. The compiler:
1. Wraps the function body in a `try..except` that converts exceptions to `HRESULT` values.
2. Moves the declared return value to an `out` parameter.
3. The actual function returns `HRESULT`.

```pascal
// Declared as:
function GetName: string; safecall;

// Compiled as equivalent to:
function GetName(out Result: string): HRESULT; stdcall;
```

When calling a `safecall` method, the compiler:
1. Checks the returned `HRESULT`.
2. If it indicates failure, calls `SafeCallErrorProc` (set by the `ComObj` unit) which raises `EOleException` with the server's error information.

### 18.2 Interoperability with C/C++

#### 18.2.1 Calling C Functions

```pascal
function strlen(s: PAnsiChar): NativeUInt; cdecl; external 'msvcrt.dll';
```

#### 18.2.2 C-to-Pascal Type Mapping

| C type | Pascal type |
|--------|-------------|
| `char` | `AnsiChar` |
| `wchar_t` | `WideChar` (Win), platform-specific |
| `short` | `SmallInt` |
| `int` | `Integer` |
| `long` | `LongInt` (Win32: 4 bytes) |
| `long long` | `Int64` |
| `unsigned char` | `Byte` |
| `unsigned short` | `Word` |
| `unsigned int` | `Cardinal` |
| `unsigned long long` | `UInt64` |
| `float` | `Single` |
| `double` | `Double` |
| `void*` | `Pointer` |
| `char*` | `PAnsiChar` |
| `wchar_t*` | `PWideChar` |
| `T*` | `^T` |
| `T[]` | `array of T` or `^T` |
| `struct` | `record` (with matching alignment) |
| `enum` | Enumerated type (check size with `{$Z}`) |
| `bool` | `LongBool` (C) or `Boolean` (C++ `bool`) |
| `BOOL` (Win32) | `LongBool` |
| `HRESULT` | `HResult` |
| `BSTR` | `WideString` |
| `VARIANT` | `OleVariant` |

#### 18.2.3 Varargs

```pascal
function printf(format: PAnsiChar): Integer; cdecl; varargs;
  external 'msvcrt.dll';
```

The `varargs` directive (used with `cdecl`) allows passing additional untyped arguments like C variadic functions.

#### 18.2.4 Callback Functions

C libraries that accept function pointers can use Pascal procedural types with matching calling conventions:

```pascal
type
  TCompareFunc = function(const A, B: Pointer): Integer; cdecl;

procedure qsort(base: Pointer; num, size: NativeUInt; compare: TCompareFunc); cdecl;
  external 'msvcrt.dll';
```

### 18.3 COM Interoperability

#### 18.3.1 COM Interfaces

COM interfaces in Delphi use `interface` with a GUID and `stdcall` or `safecall` calling convention:

```pascal
type
  IMyComObject = interface(IUnknown)
    ['{...}']
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure DoSomething; safecall;
  end;
```

#### 18.3.2 COM Classes and Factories

```pascal
type
  TMyComObject = class(TComObject, IMyComObject)
    procedure DoSomething; safecall;
  end;

  TMyComFactory = class(TComObjectFactory)
    // ...
  end;

initialization
  TMyComFactory.Create(ComServer, TMyComObject, CLASS_MyComObject,
    'MyComObject', '', ciMultiInstance, tmApartment);
```

#### 18.3.3 Type Libraries

Delphi can import COM type libraries to generate Pascal interface declarations. The `tlibimp` tool or IDE integration handles this.

### 18.4 Dynamic Loading

```pascal
var
  LibHandle: THandle;
  MyFunc: function(X: Integer): Integer; cdecl;
begin
  LibHandle := LoadLibrary('mylib.dll');
  if LibHandle <> 0 then
  try
    @MyFunc := GetProcAddress(LibHandle, 'MyFunc');
    if Assigned(MyFunc) then
      WriteLn(MyFunc(42));
  finally
    FreeLibrary(LibHandle);
  end;
end;
```

The `delayed` directive provides a simpler alternative:

```pascal
function MyFunc(X: Integer): Integer; cdecl;
  external 'mylib.dll' delayed;
```

---

## Chapter 19: Predefined Identifiers and Intrinsic Routines

### 19.1 Predefined Type Identifiers

The following type identifiers are predefined in the `System` unit (always in scope):

**Ordinal types:** `Boolean`, `ByteBool`, `WordBool`, `LongBool`, `Byte`, `ShortInt`, `Word`, `SmallInt`, `Cardinal`, `Integer`, `LongInt`, `LongWord`, `UInt64`, `Int64`, `NativeInt`, `NativeUInt`, `Char`, `WideChar`, `AnsiChar`

**Real types:** `Single`, `Double`, `Extended`, `Real`, `Real48`, `Comp`, `Currency`

**String types:** `string`, `UnicodeString`, `AnsiString`, `WideString`, `ShortString`, `RawByteString`, `UTF8String`

**Other:** `Pointer`, `Variant`, `OleVariant`, `TObject`, `TClass`, `IInterface`, `IUnknown`, `TGUID`, `TArray<T>`, `PChar`, `PWideChar`, `PAnsiChar`, `PByte`, `PInteger`, `PWord`

### 19.2 Predefined Constants

| Constant | Type | Value |
|----------|------|-------|
| `True` | `Boolean` | 1 |
| `False` | `Boolean` | 0 |
| `nil` | (special) | Null pointer/reference |
| `MaxInt` | `Integer` | 2147483647 |
| `MaxLongInt` | `LongInt` | 2147483647 |

### 19.3 Intrinsic Functions (Compiler Magic)

These are built into the compiler and cannot be reassigned or referenced as procedural values:

#### 19.3.1 Ordinal Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `Ord(X)` | `Ord(X: ordinal): Integer` | Ordinal value |
| `Chr(X)` | `Chr(X: Integer): Char` | Character from ordinal |
| `Pred(X)` | `Pred(X: ordinal): ordinal` | Predecessor |
| `Succ(X)` | `Succ(X: ordinal): ordinal` | Successor |
| `High(X)` | `High(X): ordinal` | Highest value |
| `Low(X)` | `Low(X): ordinal` | Lowest value |
| `Odd(X)` | `Odd(X: Integer): Boolean` | True if X is odd |
| `Abs(X)` | `Abs(X: numeric): numeric` | Absolute value |

#### 19.3.2 Type Information Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `SizeOf(X)` | `SizeOf(X): Integer` | Size in bytes |
| `TypeInfo(T)` | `TypeInfo(T): Pointer` | RTTI pointer |
| `TypeOf(T)` | `TypeOf(T): TClass` | Class reference |
| `Default(T)` | `Default(T): T` | Default zero value |
| `IsManagedType(T)` | `IsManagedType(T): Boolean` | Is type managed |
| `HasWeakRef(T)` | `HasWeakRef(T): Boolean` | Supports weak refs |
| `GetTypeKind(T)` | `GetTypeKind(T): TTypeKind` | Type kind (compile-time) |
| `IsConstValue(X)` | `IsConstValue(X): Boolean` | Is compile-time constant |

#### 19.3.3 String Functions

| Function | Description |
|----------|-------------|
| `Length(S)` | Length of string or array |
| `SetLength(S, N)` | Set string/array length |
| `Copy(S, Index, Count)` | Substring / array slice |
| `Concat(S1, S2, ...)` | Concatenate strings |
| `Insert(Src, Dest, Pos)` | Insert into string |
| `Delete(S, Pos, Count)` | Delete from string |
| `StringOfChar(Ch, Count)` | Create string of repeated char |
| `Pos(Sub, S)` | Find substring |
| `Str(X [:Width [:Decimals]], S)` | Number to string |
| `Val(S, V, Code)` | String to number |

#### 19.3.4 Dynamic Array Functions

| Function | Description |
|----------|-------------|
| `SetLength(A, N)` | Set array length |
| `Length(A)` | Number of elements |
| `Copy(A [, Index, Count])` | Copy array |
| `Insert(Elem, A, Index)` | Insert element (Delphi XE7+) |
| `Delete(A, Index, Count)` | Delete elements (Delphi XE7+) |
| `Concat(A, B)` | Concatenate arrays (Delphi XE7+) |

#### 19.3.5 Memory and Variable Manipulation

| Function | Description |
|----------|-------------|
| `New(P)` | Allocate typed pointer |
| `Dispose(P)` | Free typed pointer |
| `GetMem(P, Size)` | Allocate untyped memory |
| `FreeMem(P [, Size])` | Free untyped memory |
| `ReallocMem(P, Size)` | Reallocate memory |
| `AllocMem(Size)` | Allocate zeroed memory |
| `Move(Src, Dst, Count)` | Copy bytes |
| `FillChar(X, Count, Value)` | Fill with byte value |
| `Initialize(V)` | Initialize managed variable |
| `Finalize(V [, Count])` | Finalize managed variable |
| `Addr(X)` | Address of X (same as @X) |
| `Assigned(P)` | True if not nil |

#### 19.3.6 Flow Control

| Function | Description |
|----------|-------------|
| `Break` | Exit innermost loop |
| `Continue` | Next iteration of loop |
| `Exit [( Value )]` | Return from routine |
| `Halt [( Code )]` | Terminate program |
| `RunError [( Code )]` | Terminate with error |
| `Assert(Cond [, Msg])` | Debug assertion |
| `Abort` | Raise silent exception |

#### 19.3.7 Mathematical Functions

| Function | Description |
|----------|-------------|
| `Abs(X)` | Absolute value |
| `Sqr(X)` | Square (X * X) |
| `Sqrt(X)` | Square root |
| `Sin(X)` | Sine |
| `Cos(X)` | Cosine |
| `ArcTan(X)` | Arctangent |
| `Exp(X)` | e^X |
| `Ln(X)` | Natural logarithm |
| `Round(X)` | Round to nearest integer (banker's rounding) |
| `Trunc(X)` | Truncate toward zero |
| `Int(X)` | Integer part as float |
| `Frac(X)` | Fractional part |
| `Pi` | 3.14159265358979... |
| `Random [( Range )]` | Pseudo-random number |
| `Randomize` | Seed random generator |

#### 19.3.8 I/O Routines

| Routine | Description |
|---------|-------------|
| `Write(...)` | Write to text file or stdout |
| `WriteLn(...)` | Write with line ending |
| `Read(...)` | Read from text file or stdin |
| `ReadLn(...)` | Read line |
| `AssignFile(F, Name)` | Associate file variable with filename |
| `Reset(F)` | Open for reading |
| `Rewrite(F)` | Open for writing (create/truncate) |
| `Append(F)` | Open for appending |
| `CloseFile(F)` | Close file |
| `Eof(F)` | End of file |
| `Eoln(F)` | End of line |
| `Seek(F, Pos)` | Seek in typed/untyped file |
| `FilePos(F)` | Current position |
| `FileSize(F)` | Size in records |
| `BlockRead(F, Buf, Count [, Result])` | Read block (untyped) |
| `BlockWrite(F, Buf, Count [, Result])` | Write block (untyped) |
| `IOResult` | Last I/O error code (when `{$I-}`) |

### 19.4 The `System` Unit

The `System` unit is implicitly used by every unit and program. It is always in scope and is searched last (after all explicit `uses`). It declares:

- All predefined types, constants, and intrinsic routines
- `TObject`, `IInterface`, `TGUID`
- Memory manager hooks (`GetMemoryManager`, `SetMemoryManager`)
- Exception support (`ExceptObject`, `ExceptAddr`, `RaiseList`)
- Thread support (`BeginThread`, `EndThread`, `IsMultiThread`)
- Module initialization (`_InitExe`, `_InitLib`, `_Halt0`)
- Variant support types and operations

### 19.5 The `SysInit` Unit

`SysInit` is implicitly linked before `System`. It handles the earliest stages of program initialization (setting up the memory manager, exception handling, etc.).

---

## Appendix A: Complete Reserved Words and Directives

### A.1 Reserved Words (65 total)

```
and           array         as            asm
at            begin         case          class
const         constructor   destructor    dispinterface
div           do            downto        else
end           except        exports       file
finalization  finally       for           function
goto          if            implementation in
inherited     initialization interface
is            label         library       mod
nil           not           object        of
on            or            packed        procedure
program       property      raise         record
repeat        resourcestring set          shl
shr           string        then          threadvar
to            try           type          unit
until         uses          var           while
with          xor
```

Note: `on` and `at` are context-sensitive reserved words (`on` only in `except` handlers; `at` only in `raise` statements), but they cannot be used as identifiers without the `&` prefix. `operator` and `out` are directives ([§A.2](#a2-directives-context-sensitive-70)), not reserved words.

### A.2 Directives (context-sensitive, 70+)

```
absolute      abstract      align         assembler     automated
cdecl         contains      default       delayed
deprecated    dispid        dynamic       experimental
export        external      far           final
forward       helper        implements    index
inline        local         message       name          near
nodefault     noreturn      operator      out
overload      override      package       pascal
platform      private       protected     public
published     read          readonly      reference
register      reintroduce   requires      resident
safecall      sealed        static        stdcall
stored        strict        unmanaged     unsafe
varargs       virtual       winapi        write
writeonly
```

---

## Appendix B: Operator Precedence Table

| Precedence | Category       | Operators                                           |
|------------|----------------|-----------------------------------------------------|
| 1 (highest)| Unary          | `@`, `not`, unary `+`, unary `-`                    |
| 2          | Multiplicative | `*`, `/`, `div`, `mod`, `and`, `shl`, `shr`, `as`  |
| 3          | Additive       | `+`, `-`, `or`, `xor`                               |
| 4          | Relational     | `=`, `<>`, `<`, `>`, `<=`, `>=`, `in`, `is`, `not in`, `is not` |
| 5 (lowest) | Conditional    | `if`...`then`...`else` (Delphi 13+)                 |

All binary operators are left-associative. The conditional operator is right-associative. Parentheses override precedence.

---

## Appendix C: Consolidated EBNF Grammar

### C.1 Program Structure

```ebnf
Goal              = Program | Package | Library | Unit ;

Program           = [ 'program' Ident [ '(' IdentList ')' ] ';' ]
                    [ UsesClause ]
                    Block '.' ;

Unit              = 'unit' QualifiedIdent [ PortabilityDir ] ';'
                    InterfaceSection
                    ImplementationSection
                    [ InitSection ]
                    'end' '.' ;

Package           = 'package' Ident ';'
                    [ RequiresClause ]
                    [ ContainsClause ]
                    'end' '.' ;

Library           = 'library' Ident ';'
                    [ UsesClause ]
                    Block '.' ;

UsesClause        = 'uses' UsesEntry { ',' UsesEntry } ';' ;
UsesEntry         = QualifiedIdent [ 'in' StringLiteral ] ;
RequiresClause    = 'requires' IdentList ';' ;
ContainsClause    = 'contains' UsesEntry { ',' UsesEntry } ';' ;

InterfaceSection  = 'interface' [ UsesClause ] { InterfaceDecl } ;
InterfaceDecl     = ConstSection | TypeSection | VarSection | ThreadVarSection
                  | ResourceStrSection
                  | ProcHeader ';' [ DirectiveList ';' ]
                  | FuncHeader ';' [ DirectiveList ';' ] ;
ImplementationSection = 'implementation' [ UsesClause ] { DeclSection } ;

InitSection       = 'initialization' StmtList [ 'finalization' StmtList ]
                  | 'begin' StmtList ;

Block             = { DeclSection } CompoundStmt ;
```

### C.2 Declarations

```ebnf
DeclSection       = LabelSection | ConstSection | TypeSection
                  | VarSection | ThreadVarSection | ResourceStrSection
                  | ProcedureDecl | FunctionDecl | ExportsClause ;

LabelSection      = 'label' Label { ',' Label } ';' ;
Label             = Ident | IntegerLiteral ;

ConstSection      = 'const' { ConstDecl } ;
ConstDecl         = Ident [ ':' Type ] '=' ConstExpr [ PortabilityDir ] ';' ;

ResourceStrSection = 'resourcestring' { Ident '=' StringConst ';' } ;

TypeSection       = 'type' { TypeDecl } ;
TypeDecl          = [ AttributeList ] Ident [ GenericParams ] '=' [ 'type' ] Type
                    [ PortabilityDir ] ';' ;

VarSection        = 'var' { VarDecl } ;
VarDecl           = IdentList ':' Type [ '=' ConstExpr ] [ PortabilityDir ] ';'
                  | IdentList ':' Type AbsoluteClause ';' ;
AbsoluteClause    = 'absolute' Ident ;

ThreadVarSection  = 'threadvar' { VarDecl } ;
```

### C.3 Types

```ebnf
Type              = SimpleType | StringType | StructuredType | PointerType
                  | ProcType | ClassType | ClassRefType | InterfaceType
                  | TypeIdent | GenericInstantiation ;

SimpleType        = OrdinalType | RealType ;
OrdinalType       = SubrangeType | EnumType | OrdIdent ;
SubrangeType      = ConstExpr '..' ConstExpr ;
EnumType          = '(' EnumElem { ',' EnumElem } ')' ;
EnumElem          = Ident [ '=' ConstExpr ] ;

StringType        = 'string' [ '[' ConstExpr ']' ] ;

StructuredType    = [ 'packed' ] ( ArrayType | RecordType | SetType | FileType ) ;
ArrayType         = 'array' [ '[' OrdinalType { ',' OrdinalType } ']' ] 'of' Type ;
SetType           = 'set' 'of' OrdinalType ;
FileType          = 'file' [ 'of' Type ] ;

RecordType        = 'record' [ RecordFieldList ] 'end' [ 'align' ConstExpr ] ;
RecordFieldList   = { RecordFieldSection } [ VariantPart ] ;
RecordFieldSection = [ Visibility ] ( FieldList ';' | MethodDecl | PropertyDecl
                    | ConstSection | TypeSection | ClassVarSection | OperatorDecl ) ;
FieldList         = IdentList ':' Type ;
VariantPart       = 'case' [ Ident ':' ] OrdinalType 'of'
                    Variant { ';' Variant } [ ';' ] ;
Variant           = ConstExprList ':' '(' FieldList { ';' FieldList } ')' ;

PointerType       = '^' TypeIdent ;

ProcType          = ( 'procedure' | 'function' ) [ FormalParams ] [ ':' Type ]
                    [ 'of' 'object' ] [ ';' CallingConv ]
                  | 'reference' 'to' ( 'procedure' | 'function' )
                    [ FormalParams ] [ ':' Type ] ;

ClassType         = 'class' [ AbstractOrSealed ] [ ClassHeritage ]
                    { ClassMemberSection } 'end'
                  | 'class' ;  (* forward *)
AbstractOrSealed  = 'abstract' | 'sealed' ;
ClassHeritage     = '(' TypeRef { ',' TypeRef } ')' ;
ClassMemberSection = [ Visibility ] { ClassMember } ;
ClassMember       = FieldDecl | MethodDecl | PropertyDecl
                  | ConstSection | TypeSection | ClassVarSection ;

ClassRefType      = 'class' 'of' TypeIdent ;

InterfaceType     = ( 'interface' | 'dispinterface' )
                    [ InterfaceHeritage ] [ '[' GUID ']' ]
                    { InterfaceMember } 'end'
                  | 'interface' ;  (* forward *)
InterfaceHeritage = '(' TypeRef ')' ;
InterfaceMember   = ProcHeader ';' [ CallingConv ';' ]
                  | FuncHeader ';' [ CallingConv ';' ]
                  | PropertyDecl ;
```

### C.4 Procedures and Functions

```ebnf
ProcedureDecl     = ProcHeader ';' [ DirectiveList ';' ]
                    ( Block ';' | ExternalDir ';' | 'forward' ';' ) ;
FunctionDecl      = FuncHeader ';' [ DirectiveList ';' ]
                    ( Block ';' | ExternalDir ';' | 'forward' ';' ) ;

ProcHeader        = [ 'class' ] 'procedure' Ident [ GenericParams ] [ FormalParams ] ;
FuncHeader        = [ 'class' ] 'function' Ident [ GenericParams ] [ FormalParams ]
                    ':' Type ;

MethodDecl        = MethodHeader ';' [ DirectiveList ';' ] ;
MethodHeader      = [ 'class' ] ( 'procedure' | 'function' | 'constructor' | 'destructor' )
                    Ident [ GenericParams ] [ FormalParams ]
                    [ ':' Type ] ;

FormalParams      = '(' ParamGroup { ';' ParamGroup } ')' ;
ParamGroup        = [ ParamModifier ] IdentList [ ':' ParamType ]
                    [ '=' ConstExpr ] ;
ParamModifier     = 'var' | 'const' | 'out'
                  | 'const' '[' 'ref' ']' | '[' 'ref' ']' ;
ParamType         = Type | 'array' 'of' Type | 'array' 'of' 'const' ;

DirectiveList     = Directive { ';' Directive } ;
Directive         = CallingConv | 'overload' | 'inline' | 'virtual'
                  | 'dynamic' | 'override' | 'abstract' | 'reintroduce'
                  | 'final' | 'static' | 'noreturn' | PortabilityDir
                  | 'message' ConstExpr ;
CallingConv       = 'register' | 'cdecl' | 'stdcall' | 'safecall'
                  | 'pascal' | 'winapi' ;

ExternalDir       = 'external' [ ExternalKind ]
                    [ 'name' StringLiteral | 'index' IntegerLiteral ]
                    [ 'delayed' ] ;
ExternalKind      = StringLiteral
                  | 'object' StringLiteral
                  | 'framework' StringLiteral ;

ExportsClause     = 'exports' ExportsEntry { ',' ExportsEntry } ';' ;
ExportsEntry      = Ident [ FormalParams ]
                    [ 'name' StringLiteral ] [ 'index' IntegerLiteral ]
                    [ 'resident' ] ;
```

### C.5 Generics

```ebnf
GenericParams     = '<' TypeParam { ',' TypeParam } '>' ;
TypeParam         = Ident [ ':' ConstraintList ] ;
ConstraintList    = Constraint { ',' Constraint } ;
Constraint        = 'class' | 'record' | 'constructor'
                  | 'interface' | 'unmanaged' | TypeIdent ;

GenericInstantiation = QualifiedIdent '<' Type { ',' Type } '>' ;
```

### C.6 Properties

```ebnf
PropertyDecl      = [ AttributeList ] [ 'class' ] 'property' Ident
                    [ PropertyInterface ] { PropertySpecifier } ';'
                    [ 'default' ';' ] ;
PropertyInterface = [ '[' ParamList ']' ] ':' TypeIdent ;
PropertySpecifier = 'read' Designator | 'write' Designator
                  | 'stored' ( BoolConst | Ident )
                  | 'default' OrdConstExpr | 'nodefault'
                  | 'index' IntConstExpr
                  | 'implements' IdentList
                  | 'dispid' IntConstExpr ;
```

### C.7 Statements

```ebnf
CompoundStmt      = 'begin' StmtList 'end' ;
StmtList          = [ Statement { ';' Statement } ] ;

Statement         = [ Label ':' ] ( SimpleStmt | StructuredStmt )
                  | InlineVarDecl
                  | InlineConstDecl ;

SimpleStmt        = Designator ':=' Expression    (* assignment *)
                  | Designator [ '(' ExprList ')' ] (* proc call *)
                  | 'inherited' [ Ident [ '(' ExprList ')' ] ]
                  | 'goto' Label
                  | 'raise' [ Expression [ 'at' Expression ] ]
                  | (* empty *) ;

StructuredStmt    = CompoundStmt | IfStmt | CaseStmt
                  | ForStmt | WhileStmt | RepeatStmt
                  | WithStmt | TryStmt | AsmStmt ;

IfStmt            = 'if' Expression 'then' Statement
                    [ 'else' Statement ] ;

CaseStmt          = 'case' Expression 'of'
                    CaseSelector { ';' CaseSelector } [ ';' ]
                    [ 'else' StmtList [ ';' ] ]
                    'end' ;
CaseSelector      = CaseLabelList ':' Statement ;
CaseLabelList     = CaseLabel { ',' CaseLabel } ;
CaseLabel         = ConstExpr [ '..' ConstExpr ] ;

ForStmt           = 'for' ( Ident | 'var' Ident [ ':' Type ] ) ':=' Expression
                    ( 'to' | 'downto' ) Expression 'do' Statement
                  | 'for' ( Ident | 'var' Ident [ ':' Type ] ) 'in' Expression
                    'do' Statement ;

WhileStmt         = 'while' Expression 'do' Statement ;
RepeatStmt        = 'repeat' StmtList 'until' Expression ;

WithStmt          = 'with' Designator { ',' Designator } 'do' Statement ;

TryStmt           = 'try' StmtList
                    ( 'except' ExceptBlock 'end'
                    | 'finally' StmtList 'end' ) ;
ExceptBlock       = ExceptHandler { ';' ExceptHandler } [ ';' ]
                    [ 'else' StmtList ]
                  | StmtList ;
ExceptHandler     = 'on' [ Ident ':' ] TypeIdent 'do' Statement ;

AsmStmt           = 'asm' { AsmInstruction } 'end' ;

InlineVarDecl     = 'var' Ident ':' Type [ ':=' Expression ]
                  | 'var' Ident ':=' Expression ;
InlineConstDecl   = 'const' Ident [ ':' Type ] '=' Expression ;
```

### C.8 Expressions

```ebnf
Expression        = ConditionalExpr
                  | SimpleExpr [ RelOp SimpleExpr ] ;
ConditionalExpr   = 'if' Expression 'then' Expression 'else' Expression ;
SimpleExpr        = [ '+' | '-' ] Term { AddOp Term } ;
Term              = Factor { MulOp Factor } ;
Factor            = Designator [ '(' ExprList ')' ]
                  | '@' Designator
                  | Number | StringLiteral | 'nil' | 'not' Factor
                  | '(' Expression ')'
                  | SetConstructor
                  | 'inherited' [ Ident [ '(' ExprList ')' ] ]
                  | AnonymousMethod
                  | TypeIdent '(' Expression ')' (* type cast *) ;

Designator        = QualifiedIdent { DesignatorPart } ;
DesignatorPart    = '.' Ident | '[' ExprList ']' | '^'
                  | '(' ExprList ')' ;

SetConstructor    = '[' [ SetElement { ',' SetElement } ] ']' ;
SetElement        = Expression [ '..' Expression ] ;

AnonymousMethod   = 'procedure' [ FormalParams ] Block
                  | 'function' [ FormalParams ] ':' Type Block ;

ExprList          = Expression { ',' Expression } ;

RelOp             = '=' | '<>' | '<' | '>' | '<=' | '>='
                  | 'in' | 'is' | 'not' 'in' | 'is' 'not' ;
AddOp             = '+' | '-' | 'or' | 'xor' ;
MulOp             = '*' | '/' | 'div' | 'mod' | 'and' | 'shl' | 'shr'
                  | 'as' ;
```

### C.9 Attributes

```ebnf
AttributeList     = '[' Attribute { ',' Attribute } ']' ;
Attribute         = TypeIdent [ '(' ExprList ')' ] ;
```

### C.10 Miscellaneous

```ebnf
QualifiedIdent    = Ident { '.' Ident } ;
IdentList         = Ident { ',' Ident } ;

ConstExpr         = Expression ;  (* restricted to compile-time-evaluable operands —
                                     see [§5.13](#513-constant-expressions) for permitted constituents *)
IntConstExpr      = ConstExpr ;   (* must evaluate to an integer value *)
OrdConstExpr      = ConstExpr ;   (* must evaluate to an ordinal or set value *)
ConstExprList     = ConstExpr { ',' ConstExpr } ;

PortabilityDir    = 'platform' | 'deprecated' [ StringLiteral ]
                  | 'experimental' | 'library' ;
Visibility        = 'public' | 'private' | 'protected' | 'published'
                  | 'strict' 'private' | 'strict' 'protected'
                  | 'automated' ;
```

---

## Appendix D: Type Compatibility and Assignment Compatibility Rules

### D.1 Type Identity

Two types `T1` and `T2` are **identical** if and only if one of:

1. `T1` and `T2` are the same type declaration.
2. `T1` is declared as `T1 = T2` (alias, without the `type` keyword).
3. Both are the same predefined type (e.g., `Integer`).

### D.2 Type Compatibility

Types `T1` and `T2` are **compatible** if:

1. `T1` and `T2` are identical.
2. Both are ordinal types and at least one is a subrange of the other (or both are subranges of the same type).
3. Both are real types.
4. Both are string types.
5. Both are set types with compatible base types.
6. Both are `packed` set types with identical base types, OR both are non-packed sets with compatible base types.
7. Both are class types and one is an ancestor of the other.
8. Both are class-reference types and one's class is an ancestor of the other's.
9. Both are procedure types with matching signatures and calling conventions.
10. Both are pointer types (`Pointer` is compatible with all pointer types).

### D.3 Assignment Compatibility

A value of type `Source` can be assigned to a variable of type `Dest` if:

1. `Source` and `Dest` are identical.
2. `Source` and `Dest` are compatible ordinal types and the source value is in the range of `Dest`.
3. `Source` and `Dest` are both real types (implicit promotion is performed).
4. `Source` is an integer type and `Dest` is a real type.
5. `Source` and `Dest` are both string types (automatic conversion occurs).
6. `Source` is a `Char` and `Dest` is a `string` type.
7. `Source` and `Dest` are compatible set types.
8. `Source` is a descendant class type of `Dest` (widening reference conversion).
9. `Source` is a class type that implements `Dest` (where `Dest` is an interface type).
10. `Source` is `nil` and `Dest` is a pointer, class, class-reference, interface, procedural, or dynamic array type.
11. `Source` is a `Variant` and `Dest` is a type for which automatic variant conversion is defined (ordinal, real, string, Boolean).
12. `Source` is a procedural type compatible with `Dest` (matching params and calling convention), or `Source` is an anonymous method compatible with `Dest`.
13. `Source` is a dynamic array type and `Dest` is the same dynamic array type (reference assignment) or `Dest` is `Pointer` or an open array parameter.

---

## Appendix E: Name Resolution and Overload Resolution Rules

### E.1 Name Lookup Order

When resolving an unqualified identifier, the compiler searches in this order:

1. Local scope (current block — innermost to outermost nested scope).
2. Enclosing routine scopes (for nested routines).
3. Class/record scope (if in a method body — including inherited members).
4. `with` scopes (if active, innermost first).
5. Unit implementation scope (private declarations).
6. Unit interface scope (public declarations).
7. Implementation `uses` clause (right to left — last unit wins).
8. Interface `uses` clause (right to left — last unit wins).
9. `System` unit.

The first match found is used. A qualified identifier (`UnitName.Ident`) bypasses this search and goes directly to the specified unit.

### E.2 Overload Resolution

When calling an overloaded routine:

1. **Candidate gathering**: Find all visible routines with the matching name and `overload` directive (or in the same scope).

2. **Argument matching**: For each candidate, check if the arguments can match the parameters:
   - Exact match: argument type is identical to parameter type.
   - Implicit conversion: argument type is assignment-compatible with parameter type (requires conversion).
   - Incompatible: no conversion exists → candidate eliminated.

3. **Ranking** (best to worst):
   a. Exact match (no conversion needed).
   b. Signed/unsigned promotion (e.g., `Byte` to `Integer`).
   c. Numeric widening (e.g., `Integer` to `Int64`, `Single` to `Double`).
   d. String conversion (e.g., `AnsiString` to `UnicodeString`).
   e. Variant conversion.

4. **Best candidate selection**: The candidate with the most "exact match" parameters wins. If tied, the candidate with the fewest and least-costly conversions wins.

5. **Ambiguity**: If no single best candidate can be determined, a compile-time error is issued.

### E.3 Default Parameters in Overload Resolution

Default parameters participate in overload resolution. A call `Foo(1)` can match `Foo(X: Integer)` and `Foo(X: Integer; Y: Integer = 0)`. The candidate with fewer parameters (exact arity match) is preferred.

### E.4 Generic Overload Resolution

For generic methods with type inference:
1. Type inference is attempted for each generic candidate.
2. If inference succeeds, the inferred specialization participates in overload resolution.
3. Non-generic candidates are preferred over generic candidates when both match equally well.

---

## Appendix F: Runtime Memory Layout

### F.1 Object Instance Layout

```
Offset 0:         Pointer to VMT (TClass)
Offset SizeOf(Pointer): Fields from ancestor classes (in inheritance order,
                  starting from the first class that declares fields;
                  TObject itself declares no instance fields)
...               Fields from declaring class (in declaration order)
                  (with alignment padding as needed)
```

Total size: `TObject.InstanceSize` (includes the VMT pointer but not the heap block header).

### F.2 VMT (Virtual Method Table) Layout

The VMT pointer points to the first virtual method entry. Negative offsets contain metadata:

| Offset | Field | Type |
|--------|-------|------|
| -88 | `vmtSelfPtr` | Pointer to VMT itself |
| -84 | `vmtIntfTable` | Pointer to interface table |
| -80 | `vmtAutoTable` | Automation info |
| -76 | `vmtInitTable` | Field initialization table |
| -72 | `vmtTypeInfo` | RTTI pointer |
| -68 | `vmtFieldTable` | Published field table |
| -64 | `vmtMethodTable` | Published method table |
| -60 | `vmtDynamicTable` | Dynamic method table |
| -56 | `vmtClassName` | Pointer to class name (ShortString) |
| -52 | `vmtInstanceSize` | Instance size |
| -48 | `vmtParent` | Pointer to parent VMT |
| -44 | `vmtEquals` | `Equals` virtual method (Delphi 2009+) |
| -40 | `vmtGetHashCode` | `GetHashCode` virtual method (Delphi 2009+) |
| -36 | `vmtToString` | `ToString` virtual method (Delphi 2009+) |
| -32 | `vmtSafeCallException` | `SafeCallException` virtual method |
| -28 | `vmtAfterConstruction` | `AfterConstruction` virtual method |
| -24 | `vmtBeforeDestruction` | `BeforeDestruction` virtual method |
| -20 | `vmtDispatch` | `Dispatch` virtual method |
| -16 | `vmtDefaultHandler` | `DefaultHandler` virtual method |
| -12 | `vmtNewInstance` | `NewInstance` virtual method |
| -8  | `vmtFreeInstance` | `FreeInstance` virtual method |
| -4  | `vmtDestroy` | `Destroy` virtual method |
| 0+  | User virtual method pointers | Code pointers |

(Exact offsets are platform-dependent; shown for Win32/Delphi 13.1 Florence. On Win64, entries that are pointers or `NativeInt` values occupy 8 bytes instead of 4, so the total size of the negative-offset metadata region differs from a simple doubling of Win32 offsets. Consult the `System` unit source for the actual `vmt*` constants on each target platform.)

### F.3 Dynamic Array Memory Layout

```
Header (before the pointer):
  [RefCount: Integer (4 bytes)]
  [Length: NativeInt (4 or 8 bytes)]
Data (the pointer points here):
  [Element 0][Element 1]...[Element Length-1]
```

### F.4 String Memory Layout (UnicodeString)

```
Header (before the pointer):
  [CodePage: Word (2 bytes)]
  [ElemSize: Word (2 bytes)]
  [RefCount: Integer (4 bytes)]
  [Length: Integer (4 bytes)]
Data (the pointer points here):
  [Char 0][Char 1]...[Char Length-1][#0#0]
```

The null terminator is not included in `Length`. The pointer stored in the string variable points to the first character (Char 0). A `nil` pointer represents an empty string.

---

## Appendix G: Program Startup and Shutdown Sequence

### G.1 Startup

1. Operating system loads the executable image.
2. `_InitExe` (or `_InitLib` for DLLs) is called.
3. The memory manager is initialized.
4. Exception handling support is initialized.
5. `SysInit` unit initialization runs.
6. `System` unit initialization runs.
7. Unit initialization sections execute in dependency order (depth-first, left-to-right within each `uses` clause).
8. The program's main `begin..end` block executes.

### G.2 Shutdown

1. The main block completes (or `Halt` is called).
2. `ExitProc` chain is called (if any exit procedures are registered).
3. Unit finalization sections execute in **reverse** order of initialization.
4. The memory manager is shut down.
5. The process terminates with the exit code (`ExitCode` global variable or `Halt` parameter).

---

*End of Object Pascal Language Specification*
