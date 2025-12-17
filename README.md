# minigrep - A Minimal Grep-like Tool

`minigrep` is a lightweight implementation of a grep-like pattern matching tool written in C++.

## Features

- **Literal characters**: Match exact text
- **Wildcard (.)**: Match any single character
- **Anchors**: `^` for start of string, `$` for end of string
- **Character classes**: `[abc]` matches a, b, or c; `[^abc]` matches anything except a, b, or c
- **Quantifiers**: `+` (one or more), `?` (zero or one)
- **Alternation**: `(a|b)` matches either a or b
- **Escape sequences**: `\d` for digits, `\w` for word characters

## Usage

```bash
# Basic pattern matching
echo "hello" | ./minigrep -E "hello"

# Match digits
echo "test123" | ./minigrep -E "test\d+"

# Exact string match
echo "test" | ./minigrep -E "^test$"

# Character classes
echo "abc" | ./minigrep -E "[abc]+"

# Word characters
echo "word_123" | ./minigrep -E "\w+"

# Optional character
echo "color" | ./minigrep -E "colou?r"

# Alternation
echo "cat" | ./minigrep -E "(cat|dog)"
```

### Return Codes

- `0`: Pattern matched successfully
- `1`: Pattern did not match
- `2`: Error occurred (malformed pattern, etc.)

## Building

```bash
make
```

Or compile manually:

```bash
g++ -std=c++11 -o minigrep main.cpp helpers.cpp matcher.cpp
```

## Testing

Run the test suite:

```bash
make test
```

## Project Structure

- `main.cpp`: Main program and argument handling
- `helpers.cpp`: Utility functions
- `matcher.cpp`: Core pattern matching logic
- `helpers.h`, `matcher.h`: Header files
