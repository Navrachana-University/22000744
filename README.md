# Authors
Harshil Brahmani (22000744)

# Hinglish Compiler

A simple compiler for the custom **Hinglish** programming language, implemented using **Flex** (lexical analysis) and **Bison** (parsing and Three-Address Code generation). This project reads a `.txt` source program written in Hinglish, performs lexical and syntactic analysis, and emits Three-Address Code (TAC) to `output.txt`.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Language Specification](#language-specification)
  - [Keywords](#keywords)
  - [Operators](#operators)
  - [Syntax](#syntax)

## Introduction

This compiler processes programs written in a Hindi-inspired language called **Hinglish**, supporting basic programming constructs such as assignments, arithmetic expressions, conditionals, loops, and output statements. The end goal is to produce an intermediate Three-Address Code representation, illustrating how high-level constructs map to lower-level TAC instructions.

## Features

- Lexical Analysis with Flex  
- Syntactic Analysis and TAC Generation with Bison  
- Temporary variable and label management (`t1, t2, …`, `L1, L2, …`)  
- Supports:
  - Variable assignment
  - Integer arithmetic (`+`, `-`, `*`, `/`)
  - Relational (`==`, `!=`, `<`, `>`, `<=`, `>=`)
  - Logical (`&&`, `||`, `!`)
  - `if`/`else` (`agar`/`nahi to`)
  - `while` loops (`jabtak`)
  - Print/output (`bolo`)

## Language Specification

### Keywords

| Hinglish  | Equivalent in C-style              |
|-----------|------------------------------------|
| `shuru`   | start of program (like `main`)     |
| `bolo`    | print/output (like `printf`/`cout`)|
| `agar`    | `if` condition                     |
| `nahi to` | `else` clause                      |
| `jabtak`  | `while` loop                       |

### Operators

- **Arithmetic**: `+`, `-`, `*`, `/`
- **Relational**: `==`, `!=`, `<`, `>`, `<=`, `>=`
- **Logical**: `&&`, `||`, `!`
- **Assignment**: `=`

### Syntax

```bnf
<program>    ::= shuru <stmt_list>
<stmt_list>  ::= <stmt> | <stmt> <stmt_list>
<stmt>       ::= <assign> ";" 
               | bolo <expr> ";" 
               | agar "(" <expr> ")" "{" <stmt_list> "}" nahi to "{" <stmt_list> "}"
               | jabtak "(" <expr> ")" "{" <stmt_list> "}"
<assign>     ::= IDENTIFIER "=" <expr>
<expr>       ::= <term> { ("+"|"-") <term> }
<term>       ::= <factor> { ("*"|"/") <factor> }
<factor>     ::= NUMBER | IDENTIFIER | "!" <factor> | "(" <expr> ")"
