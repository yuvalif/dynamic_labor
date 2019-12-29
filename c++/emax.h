#pragma once

#include "const_parameters.h"

#ifdef USE_MULTI_ARRAY
#include "boost/multi_array.hpp"
using Emax = boost::multi_array<double, 12>;
#else
#include <memory>
using Emax = std::unique_ptr<float[]>;
#endif

Emax make_emax();


