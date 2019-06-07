#pragma once

#include "emax.h"

class Parameters;

// update wife emax for single women case
// return number of internal iterations
unsigned single_women(const Parameters& p, unsigned WS, unsigned t, Emax& EMAX_W, const Emax& EMAX_H);

