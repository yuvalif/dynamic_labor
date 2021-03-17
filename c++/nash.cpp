#include "const_parameters.h"
#include "parameters.h"
#include "calculate_utility.h"
#include <algorithm>
#include <array>
#include <cassert>
#include <math.h>

double nash(const Parameters& p, const Utility& utility, double BP) {
    // marriage decision - outside option value wife
    const auto outside_option_w_v = std::max(utility.U_W_S[0], utility.U_W_S[1]);
    const auto outside_option_h_v = utility.U_H_S;

    UtilityArray weighted_utility;

    for (auto i = 0U; i < UTILITY_SIZE; ++i) {
        weighted_utility[i] = utility.U_H[i]*(1.0-BP) + utility.U_W[i]*BP;
    }

    UtilityArray nash_value;
    std::fill(nash_value.begin(), nash_value.end(), MINIMUM_UTILITY);

    // leave only positive surplus for both
    for (auto i = 0U; i < UTILITY_SIZE; ++i) {
        if (utility.U_W[i] > outside_option_w_v && utility.U_H[i] > outside_option_h_v) { 
            // if positive surplus for both
            nash_value[i] = pow(utility.U_W[i]-outside_option_w_v, 0.5)*pow(utility.U_H[i]-outside_option_h_v, 0.5);
        }
    }

    const auto max_weighted_utility_index = std::max_element(weighted_utility.begin(), weighted_utility.end()) - weighted_utility.begin();
    assert(max_weighted_utility_index < UTILITY_SIZE);
    const auto max_nash_value_index = std::max_element(nash_value.begin(), nash_value.end()) - nash_value.begin();
    const auto max_nash_value = nash_value[max_nash_value_index];

    // find the value of the bargaining power
    auto best_bp = NO_BP;
    if (max_nash_value > MINIMUM_UTILITY) {
        // there is at least one option with positive surplus for both
        if (max_nash_value_index == max_weighted_utility_index) {
            // input BP satisfies the condition
            return BP;
        } else {
            // search for a BP that satisfies the above and is closest to the input BP
            for (auto bp_id = 0; bp_id < CS_SIZE; ++bp_id) {
                const auto new_bp = bp_vector[bp_id];
                for (auto i = 0U; i < UTILITY_SIZE; ++i) {
                    weighted_utility[i] = utility.U_H[i]*(1.0-new_bp) + utility.U_W[i]*new_bp;
                }
                const auto max_weighted_utility_index = std::max_element(weighted_utility.begin(), weighted_utility.end()) - weighted_utility.begin();
                if (max_nash_value_index == max_weighted_utility_index) {
                    if (abs(best_bp - BP) > abs(new_bp - BP)) {
                        best_bp = new_bp;
                    }
                }
            }
        }
    }

    return best_bp;
}

