CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra -pedantic
TARGET = minigrep
SRC = main.cpp
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
	@echo -n "  Expected: Exit code 1 (error) - "
	@echo "test" | ./$(TARGET) -E "[abc" 2>/dev/null; \
	if [ $$? -eq 1 ]; then \
		echo "✓ PASS (exit code: 1)"; \
	else \
		echo "✗ FAIL (exit code: $$?)"; \
	fi
	@echo ""

	@echo "=========================================="
	@echo "Test suite completed"
	@echo "=========================================="
