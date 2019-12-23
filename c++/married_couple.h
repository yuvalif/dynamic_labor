#pragma once

#include "emax.h"

struct Parameters;

// update wife and husband emax for married couple case
// return number of internal iterations
unsigned married_couple(const Parameters& p, int WS, unsigned t, Emax& EMAX_W, Emax& EMAX_H);

