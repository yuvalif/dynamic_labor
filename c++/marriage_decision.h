#pragma once

#include "calculate_utility.h"

struct MarriageDecision {
    unsigned M;
    unsigned prev_state_w;
    unsigned WE;
    unsigned HE;
    unsigned max_weighted_utility_index;
    double outside_option_w_v;
    double outside_option_h_v;
};

MarriageDecision marriage_decision(const Utility& utility, double BP, unsigned WE, unsigned HE);

