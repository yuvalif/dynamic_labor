#pragma once

#include "calculate_utility.h"

struct MarriageDecision {
    unsigned M;
    unsigned max_weighted_utility_index;
    double outside_option_w_v;
    double outside_option_h_v;
    unsigned outside_option_w;
};

class Wife;
class Husband;

MarriageDecision marriage_decision(const Utility& utility, double BP, Wife& wife, Husband& husband);

