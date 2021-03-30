#pragma once

#include "calculate_utility.h"

struct MarriageEmpDecision {
    unsigned M = UNMARRIED;
    unsigned max_weighted_utility_index = 0;
    double outside_option_w_v = MINIMUM_UTILITY;
    double outside_option_h_v = MINIMUM_UTILITY;
    unsigned outside_option_w = 0;
};

struct Wife;
struct Husband;

MarriageEmpDecision marriage_emp_decision(const Utility& utility, double& bp, Wife& wife, Husband& husband, bool adjust_bp);

unsigned wife_emp_decision(const Utility& utility);

