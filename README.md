# minigrep - A Minimal Grep-like Tool

`minigrep` is a lightweight implementation of a grep-like pattern matching tool written in C++.

## Features

- **Basic Pattern Matching**: Match literal characters and sequences
- **Character Classes**: Support for `[abc]` and `[^abc]` (negation)
- **Escape Sequences**:
  - `\d` - matches digits (0-9)
  - `\w` - matches word characters (a-z, A-Z, 0-9, \_)
- **Anchors**:
  - `^` - match at start of string
  - `$` - match at end of string
- **Quantifiers**:
  - `+` - match one or more times
  - `?` - match zero or one time

## Usage

```bash
# Basic usage pattern
echo "input string" | ./minigrep -E "pattern"

# Examples
echo "hello123" | ./minigrep -E "hello\d+"
echo "test" | ./minigrep -E "^test$"
echo "abc" | ./minigrep -E "[abc]+"
echo "word_123" | ./minigrep -E "\w+"
```

### Return Codes

- `0` - Pattern matched successfully
- `1` - Pattern did not match or error occurred

## Building

Since this is a minimal C++ project with a single source file, you can compile it directly:

```bash
g++ -std=c++11 -o minigrep main.cpp
```

Or use the provided Makefile:

```bash
make
```

This will build the `minigrep` executable.
