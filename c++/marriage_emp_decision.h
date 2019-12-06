#pragma once

#include "calculate_utility.h"

struct MarriageEmpDecision {
    unsigned M = 0;
    unsigned max_weighted_utility_index = 0;
    double outside_option_w_v = MINIMUM_UTILITY;
    double outside_option_h_v = MINIMUM_UTILITY;
    unsigned outside_option_w = 0;
};

class Wife;
class Husband;

MarriageEmpDecision marriage_emp_decision(const Utility& utility, double BP, Wife& wife, Husband& husband);

unsigned wife_emp_decision(const Utility& utility);

