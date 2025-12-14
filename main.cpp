#include <algorithm>
#include <cctype>
#include <cstddef>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

std::vector<std::string> tokenize(const std::string &pattern) {
  std::vector<std::string> tokens;

  for (size_t i = 0; i < pattern.size();) {
    if (pattern[i] == '\\') {
      if (i + 1 >= pattern.size()) {
        throw std::runtime_error("Invalid escape at end of pattern");
      }
      tokens.push_back(pattern.substr(i, 2));
      i += 2;
    } else if (pattern[i] == '[') {
      size_t end = pattern.find(']', i + 1);
      if (end == std::string::npos) {
        throw std::runtime_error("Unclosed [ in pattern");
      }
      tokens.push_back(pattern.substr(i, end - i + 1));
      i = end + 1;
    } else {
      tokens.push_back(pattern.substr(i, 1)); // literal char
      i += 1;
    }
  }

  return tokens;
}

bool match_one(char c, const std::string &token) {
  unsigned char uc = static_cast<unsigned char>(c);

  if (token == "\\d") {
    return std::isdigit(uc);
  }
  if (token == "\\w") {
    return std::isalnum(uc) || c == '_';
  }

  if (token.size() >= 2 && token.front() == '[' && token.back() == ']') {
    bool neg = token[1] == '^';
    std::string content = neg ? token.substr(2, token.size() - 3)
                              : token.substr(1, token.size() - 2);

    bool found = content.find(c) != std::string::npos;
    return neg ? !found : found;
  }

  // literal
  return token.size() == 1 && token[0] == c;
}

bool match_at(const std::string &input, const std::vector<std::string> &tokens,
              size_t pos) {
  size_t i = pos;

  for (size_t j = 0; j < tokens.size(); ++j) {
    if (i >= input.size())
      return false;

    const std::string &tok = tokens[j];

    // Handle +
    if (j + 1 < tokens.size() && tokens[j + 1] == "+") {
      // Must match at least once
      if (!match_one(input[i], tok))
        return false;

      // Match one or more
      while (i < input.size() && match_one(input[i], tok)) {
        i++;
      }

      // Skip token and '+'
      j++;

      while (j + 1 < tokens.size() && tokens[j + 1] == tok) {
        j++;
      }

      continue;
    }

    // Handle ?
    if (j + 1 < tokens.size() && tokens[j + 1] == "?") {
      // Match zero or one times
      if (i < input.size() && match_one(input[i], tok)) {
        i++; // Match one time
      }
      // If doesn't match, skip (match zero times)
      j += 1;   // Skip current token
      continue; // '?' will be skipped by loop increment
    }

    // Normal single match
    if (!match_one(input[i], tok))
      return false;

    i++;
  }

  return true;
}

bool match_pattern(const std::string &input, const std::string &pattern) {
  auto tokens = tokenize(pattern);
  bool anchored_start = false;
  bool anchored_end = false;

  if (!tokens.empty() && tokens.front() == "^") {
    anchored_start = true;
    tokens.erase(tokens.begin()); // remove "^"
  }

  if (!tokens.empty() && tokens.back() == "$") {
    anchored_end = true;
    tokens.pop_back(); // remove "$"
  }

  // ^ and $
  if (anchored_start && anchored_end) {
    // lengths must match exactly
    if (tokens.size() != input.size() &&
        std::find(tokens.begin(), tokens.end(), "+") == tokens.end()) {
      return false;
    }
    return match_at(input, tokens, 0);
  }

  // Only ^
  if (anchored_start) {
    return match_at(input, tokens, 0);
  }

  // Only $
  if (anchored_end) {
    if (tokens.size() > input.size()) {
      return false;
    }
    size_t start = input.size() - tokens.size();
    return match_at(input, tokens, start);
  }
  // Try to match the entire token sequence
  for (size_t start = 0; start < input.size(); start++) {
    if (match_at(input, tokens, start)) {
      return true;
    }
  }
  return false;
}

int main(int argc, char *argv[]) {
  std::cout << std::unitbuf;
  std::cerr << std::unitbuf;

  if (argc != 3) {
    std::cerr << "Expected two arguments" << std::endl;
    return 1;
  }

  std::string flag = argv[1];
  std::string pattern = argv[2];

  if (flag != "-E") {
    std::cerr << "Expected first argument to be '-E'" << std::endl;
    return 1;
  }

  std::string input_line;
  std::getline(std::cin, input_line);

  try {
    return match_pattern(input_line, pattern) ? 0 : 1;
  } catch (const std::runtime_error &e) {
    std::cerr << e.what() << std::endl;
    return 1;
  }
}
