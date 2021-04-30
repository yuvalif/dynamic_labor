#pragma once
#include <string>
#include <sstream>

// based on: 
// https://stackoverflow.com/questions/16605967/set-precision-of-stdto-string-when-converting-floating-point-values
inline std::string to_string_with_precision(double a_value, int n = 3)
{
  std::ostringstream out;
  out.precision(n);
  out << std::fixed << a_value;
  return out.str();
}

