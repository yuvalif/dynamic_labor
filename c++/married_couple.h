#pragma once

#include "emax.h"

struct Parameters;

// update wife and husband emax for married couple case
// return number of internal iterations
unsigned married_couple(const Parameters& p, int WS, unsigned t, MarriedEmax& w_emax, MarriedEmax& h_emax, 
    const SingleWomenEmax& w_s_emax, const SingleMenEmax& h_s_emax, bool adjust_bp);

