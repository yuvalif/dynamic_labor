#pragma once

#include "const_parameters.h"

// time | w exp | h exp | kids  | work  | w ability | h ability | married | h school | w school | match q | bp    |
// 0-27 | 0 - 4 | 0 - 4 | 0 - 3 | 0 - 1 | 0 - 2     | 0 - 2     | 0 - 1   | 0 - 4    | 0 - 4    | 0 - 2   | 0 - 7 |

#ifdef USE_MULTI_ARRAY
#include "boost/multi_array.hpp"
using Emax = boost::multi_array<double, 12>;
#else
#include <memory>
using Emax = std::unique_ptr<float[]>;
#endif

Emax make_emax();


