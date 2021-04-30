#pragma once

#include "emax.h"

struct Parameters;

// update husband emax for single men case
// return number of internal iterations
unsigned single_men(const Parameters& p, unsigned HS, unsigned t, const MarriedEmax& w_emax, const MarriedEmax& h_emax, 
    const SingleWomenEmax& w_s_emax, SingleMenEmax& h_s_emax, bool adjust_bp);

