#include "helpers.h"
#include <cctype>
#include <string>
#include <vector>

bool isWordChar(char c) {
  return c == '_' || std::isalnum(static_cast<unsigned char>(c));
}

bool isDigit(char c) { return std::isdigit(static_cast<unsigned char>(c)); }

std::vector<std::string> split(const std::string &s, char delimiter) {
  std::vector<std::string> result;
  std::string current;

  for (char c : s) {
    if (c == delimiter) {
      result.push_back(current);
      current.clear();
    } else {
      current += c;
    }
  }

  result.push_back(current);
  return result;
}
