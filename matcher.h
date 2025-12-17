#ifndef MINIGREP_MATCHER_H
#define MINIGREP_MATCHER_H

#include <string>

// Core pattern matching functions
bool match_pattern(const std::string &input_line, const std::string &pattern);

bool match_at(size_t input_position, size_t pattern_position,
              const std::string &input_line, const std::string &pattern);

#endif
