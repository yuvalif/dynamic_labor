#pragma once

#include "emax.h"

class Parameters;

// update wife and husband emax for married couple case
// return number of internal iterations
unsigned married_couple(const Parameters& p, unsigned WS, unsigned t, Emax& EMAX_W, Emax& EMAX_H);

