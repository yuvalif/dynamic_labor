#pragma once

#include "const_parameters.h"
#include "boost/multi_array.hpp"

using Emax = boost::multi_array<double, 12>;
 
Emax make_emax();

/*
// alternative non boost implementation
#include <memory>
using Emax = std::unique_ptr<float[]>;
*/

