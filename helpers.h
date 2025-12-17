#ifndef MINIGREP_HELPERS_H
#define MINIGREP_HELPERS_H

#include <string>
#include <vector>

// Helper function declarations
bool isWordChar(char c);
bool isDigit(char c);
std::vector<std::string> split(const std::string &s, char delimiter);

#endif
