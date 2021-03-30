#include "const_parameters.h"
#include "parameters.h"
#include "calculate_utility.h"
#include <algorithm>
#include <array>
#include <cassert>
#include <math.h>

// find the BP value that has the maximum nash value
double nash(const Parameters& p, const Utility& utility) {
    // marriage decision - outside option value wife
    const auto outside_option_w_v = std::max(utility.U_W_S[0], utility.U_W_S[1]);
    const auto outside_option_h_v = utility.U_H_S;

    UtilityArray nash_value;
    std::fill(nash_value.begin(), nash_value.end(), MINIMUM_UTILITY);

    // leave only positive surplus for both
    for (auto i = 0U; i < UTILITY_SIZE; ++i) {
        if (utility.U_W[i] > outside_option_w_v && utility.U_H[i] > outside_option_h_v) { 
            // if positive surplus for both
            nash_value[i] = pow(utility.U_W[i]-outside_option_w_v, 0.5)*pow(utility.U_H[i]-outside_option_h_v, 0.5);
        }
    }

    const auto max_nash_value_index = std::max_element(nash_value.begin(), nash_value.end()) - nash_value.begin();
    const auto max_nash_value = nash_value[max_nash_value_index];
    if (max_nash_value == MINIMUM_UTILITY) { 
      return NO_BP;
    }

    return bp_vector[max_nash_value_index%CS_SIZE];
}

