#pragma once

#include "emax.h"

struct Parameters;

// update wife emax for single women case
// return number of internal iterations
unsigned single_women(const Parameters& p, unsigned WS, unsigned t, const MarriedEmax& w_m_emax, const MarriedEmax& h_m_emax,
    SingleWomenEmax& w_s_emax, const SingleMenEmax& h_s_emax, bool adjust_bp);

