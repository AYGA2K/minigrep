#include "matcher.h"
#include "helpers.h"
#include <stdexcept>
#include <string>

bool match_pattern(const std::string &input_line, const std::string &pattern) {
  for (size_t start = 0; start < input_line.size(); ++start) {
    if (match_at(start, 0, input_line, pattern))
      return true;
  }
  return false;
}

bool match_at(size_t input_position, size_t pattern_position,
              const std::string &input_line, const std::string &pattern) {

  while (pattern_position < pattern.size()) {
    char token = pattern[pattern_position];

    // Handle zero or one (?) operator
    if (pattern_position + 1 < pattern.size() &&
        pattern[pattern_position + 1] == '?') {
      // Try zero occurrences (skip the character before ?)
      if (match_at(input_position, pattern_position + 2, input_line, pattern))
        return true;
    }

    // Skip ? token
    if (token == '?') {
      pattern_position++;
      continue;
    }

    if (input_position >= input_line.size())
      return token == '$';

    char input_char = input_line[input_position];

    // Wildcard
    if (token == '.') {
      input_position++;
      pattern_position++;
      continue;
    }

    if (token == '\\') {
      // Move past '\'
      pattern_position++;
      if (pattern_position >= pattern.size())
        throw std::runtime_error("Incorrect escape char in pattern: " +
                                 pattern);
      char esc = pattern[pattern_position];
      switch (esc) {

      // Any character match
      case 'w':
        if (!isWordChar(input_char))
          return false;
        ++input_position;
        ++pattern_position;
        continue;
        // Any number match
      case 'd':
        if (!isDigit(input_char))
          return false;
        ++input_position;
        ++pattern_position;
        continue;
      default:
        throw std::runtime_error("Unhandled escape \\" + std::string(1, esc) +
                                 " in pattern: " + pattern);
      }
    }

    // Start anchor match
    else if (token == '^') {
      if (input_position != 0)
        return false;
      ++pattern_position;
      continue;
    }

    // End anchor match
    else if (token == '$') {
      // Check if we're at the end of the input
      if (input_position < input_line.size())
        return false;
      ++pattern_position;
      continue;
    }
    // Group match
    else if (token == '[') {
      pattern_position++; // move past '['
      if (pattern_position >= pattern.size())
        throw std::runtime_error("Unclosed character class in pattern: " +
                                 pattern);

      bool negate = false;
      if (pattern[pattern_position] == '^') {
        negate = true;
        ++pattern_position;
      }

      std::size_t end = pattern.find(']', pattern_position);

      if (end != std::string::npos) {
        std::string char_set =
            pattern.substr(pattern_position, end - pattern_position);
        pattern_position = end; // points to ']'
        bool in_set = (char_set.find(input_char) != std::string::npos);
        if (negate ? in_set : !in_set)
          return false;
      } else {
        // Missing closing ']'
        throw std::runtime_error("Unclosed character class in pattern: " +
                                 pattern);
      }
      // Consume input char and closing ']'
      input_position++;
      pattern_position++; // past ']'
      continue;
    }
    // Pipe operator
    else if (token == '(') {
      pattern_position++; // move past '('
      if (pattern_position >= pattern.size())
        throw std::runtime_error("Unclosed character class in pattern: " +
                                 pattern);

      std::size_t end = pattern.find(')', pattern_position);

      if (end != std::string::npos) {
        std::string char_set =
            pattern.substr(pattern_position, end - pattern_position);

        std::string group =
            pattern.substr(pattern_position, end - pattern_position);
        // Split pattern by '|'
        std::vector<std::string> pipes_splits = split(group, '|');
        bool pipeMatched = false;
        for (std::string pipe_pattern : pipes_splits) {
          size_t ip = input_position;
          bool ok = true;
          for (char c : pipe_pattern) {
            if (ip >= input_line.size() || input_line[ip] != c) {
              ok = false;
              break;
            }
            ip++;
          }
          if (ok) {
            input_position = ip;
            pipeMatched = true;
            break;
          }
        }
        if (pipeMatched) {
          pattern_position = end + 1;

          return match_at(input_position, pattern_position, input_line,
                          pattern);
        } else {
          return false;
        }

      } else {
        // Missing closing ')'
        throw std::runtime_error("Unclosed character class in pattern: " +
                                 pattern);
      }
    }

    // Plus operator
    else if (token == '+') {
      // The character before '+' has already been matched once
      // We need to match zero or more additional occurrences

      // Save the character/pattern that needs to be repeated
      // pattern_position points to '+', so go back one character
      if (pattern_position == 0) {
        throw std::runtime_error(
            "'+' without preceding character in pattern: " + pattern);
      }

      // Check if it's an escape sequence like \d or \w
      bool is_escape_seq = false;
      char escape_type = '\0';
      char repeat_token = pattern[pattern_position - 1];

      if (pattern_position >= 2 && pattern[pattern_position - 2] == '\\') {
        is_escape_seq = true;
        escape_type = repeat_token; // 'd' or 'w'
        repeat_token = '\\';        // The actual token to match is '\'
      }

      // Helper function to check if current input character matches the
      // repeated token
      auto charMatches = [&](size_t pos) -> bool {
        if (pos >= input_line.size())
          return false;
        char input_char = input_line[pos];

        if (is_escape_seq) {
          if (escape_type == 'd') {
            return isDigit(input_char);
          } else if (escape_type == 'w') {
            return isWordChar(input_char);
          }
          return false;
        } else if (repeat_token == '.') {
          return true; // . matches any character
        } else {
          return input_char == repeat_token;
        }
      };

      // Save current state for backtracking
      size_t saved_input_position = input_position;

      // First, find maximum number of additional matches possible
      size_t max_additional = 0;
      while (charMatches(saved_input_position + max_additional)) {
        max_additional++;
      }

      // Try from most matches to least (greedy matching)
      // Move past the '+' in the pattern
      size_t next_pattern_position = pattern_position + 1;

      for (size_t additional = max_additional; additional > 0; additional--) {
        input_position = saved_input_position + additional;
        if (match_at(input_position, next_pattern_position, input_line,
                     pattern)) {
          return true;
        }
      }

      // Finally try zero additional matches
      input_position = saved_input_position;
      if (match_at(input_position, next_pattern_position, input_line,
                   pattern)) {
        return true;
      }

      // No match found with any number of additional characters
      return false;
    }

    // Literal match
    else {
      if (input_char != token)
        return false;
      input_position++;
      pattern_position++;
      continue;
    }
  }
  return true;
}
