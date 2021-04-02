#pragma once

#include "emax.h"

struct Parameters;

// update husband emax for single men case
// return number of internal iterations
unsigned single_men(const Parameters& p, unsigned HS, unsigned t, const Emax& EMAX_W, Emax& EMAX_H, bool adjust_bp);

