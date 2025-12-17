CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -pedantic
TARGET = minigrep
SRC = main.cpp helpers.cpp matcher.cpp
OBJ = $(SRC:.cpp=.o)

.PHONY: build test clean

build: $(TARGET)

$(TARGET): $(OBJ)
	$(CXX) $(CXXFLAGS) -o $@ $^

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJ)

test: $(TARGET)
	@echo "=========================================="
	@echo "Running minigrep test suite"
	@echo "=========================================="
	@echo ""

	@echo "Test 1: Basic literal matching"
	@echo "  Input:    'hello'"
	@echo "  Pattern:  'hello'"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "hello" | ./$(TARGET) -E "hello" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 2: Matching digits with \\d"
	@echo "  Input:    'test123'"
	@echo "  Pattern:  'test\\\\d+' (test followed by one or more digits)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "test123" | ./$(TARGET) -E "test\\d+" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 3: Exact string match with anchors"
	@echo "  Input:    'test'"
	@echo "  Pattern:  '^test$$' (start to end match)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "test" | ./$(TARGET) -E "^test$$" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 4: Character class matching"
	@echo "  Input:    'abc'"
	@echo "  Pattern:  '[abc]+' (one or more of a, b, or c)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "abc" | ./$(TARGET) -E "[abc]+" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 5: Word character matching"
	@echo "  Input:    'word_123'"
	@echo "  Pattern:  '\\\\w+' (one or more word characters)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "word_123" | ./$(TARGET) -E "\\w+" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 6: Optional character"
	@echo "  Input:    'color'"
	@echo "  Pattern:  'colou?r' (matches both 'color' and 'colour')"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "color" | ./$(TARGET) -E "colou?r" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 7: Negation character class"
	@echo "  Input:    'abc'"
	@echo "  Pattern:  '[^xyz]+' (one or more characters that are NOT x, y, or z)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "abc" | ./$(TARGET) -E "[^xyz]+" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 8: Negative test - No match expected"
	@echo "  Input:    'hello'"
	@echo "  Pattern:  'world'"
	@echo -n "  Expected: Exit code 1 (no match) - "
	@echo "hello" | ./$(TARGET) -E "world" >/dev/null 2>&1; \
	if [ $$? -eq 1 ]; then \
		echo "✓ PASS (exit code: 1)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 9: Error handling - Unclosed bracket"
	@echo "  Input:    'test'"
	@echo "  Pattern:  '[abc' (unclosed character class - should error)"
	@echo -n "  Expected: Exit code 2 (error) - "
	@echo "test" | ./$(TARGET) -E "[abc" 2>/dev/null; \
	if [ $$? -eq 2 ]; then \
	    echo "✓ PASS (exit code: 2)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 10: Wildcard matching"
	@echo "  Input:    'hallo'"
	@echo "  Pattern:  'h.llo' (. matches any character)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "hallo" | ./$(TARGET) -E "h.llo" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 11: Pipe operator (alternation)"
	@echo "  Input:    'dog'"
	@echo "  Pattern:  '(cat|dog)' (matches cat or dog)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "dog" | ./$(TARGET) -E "(cat|dog)" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 12: Plus operator with character class"
	@echo "  Input:    'aaabbb'"
	@echo "  Pattern:  'a+b+' (one or more a's followed by one or more b's)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "aaabbb" | ./$(TARGET) -E "a+b+" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 13: Simple character class"
	@echo "  Input:    'abc'"
	@echo "  Pattern:  '[abc][abc][abc]' (three characters from a,b,c)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "abc" | ./$(TARGET) -E "[abc][abc][abc]" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 14: Error - Unclosed parentheses"
	@echo "  Input:    'test'"
	@echo "  Pattern:  '(abc' (unclosed group - should error)"
	@echo -n "  Expected: Exit code 2 (error) - "
	@echo "test" | ./$(TARGET) -E "(abc" 2>/dev/null; \
	if [ $$? -eq 2 ]; then \
		echo "✓ PASS (exit code: 2)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 15: Error - Invalid escape sequence"
	@echo "  Input:    'test'"
	@echo "  Pattern:  '\\x' (invalid escape - should error)"
	@echo -n "  Expected: Exit code 2 (error) - "
	@echo "test" | ./$(TARGET) -E "\\x" 2>/dev/null; \
	if [ $$? -eq 2 ]; then \
		echo "✓ PASS (exit code: 2)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 16: Complex pattern with multiple operators"
	@echo "  Input:    'hello123_world'"
	@echo "  Pattern:  '^hello\\d+_\\w+$$' (starts with hello, has digits, underscore, word chars)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "hello123_world" | ./$(TARGET) -E "^hello\\d+_\\w+$$" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 17: Optional character at end"
	@echo "  Input:    'colour'"
	@echo "  Pattern:  'colou?r' (u is optional)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "colour" | ./$(TARGET) -E "colou?r" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 18: Multiple pipe alternatives"
	@echo "  Input:    'green'"
	@echo "  Pattern:  '(red|green|blue)'"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "green" | ./$(TARGET) -E "(red|green|blue)" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 19: Simple negation test"
	@echo "  Input:    'xyz'"
	@echo "  Pattern:  '[^abc]+' (not a, b, or c)"
	@echo -n "  Expected: Exit code 0 (match) - "
	@echo "xyz" | ./$(TARGET) -E "[^abc]+" >/dev/null 2>&1; \
	if [ $$? -eq 0 ]; then \
		echo "✓ PASS (exit code: 0)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "Test 20: Simple no match case"
	@echo "  Input:    'apple'"
	@echo "  Pattern:  '^banana$$'"
	@echo -n "  Expected: Exit code 1 (no match) - "
	@echo "apple" | ./$(TARGET) -E "^banana$$" >/dev/null 2>&1; \
	if [ $$? -eq 1 ]; then \
		echo "✓ PASS (exit code: 1)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "=========================================="
	@echo "Test suite completed"
	@echo "=========================================="
