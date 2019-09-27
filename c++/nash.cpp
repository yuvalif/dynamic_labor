#include "const_parameters.h"
#include "parameters.h"
#include "calculate_utility.h"
#include <algorithm>
#include <array>
#include <cassert>

double nash(const Parameters& p, const Utility& utility, double BP) {
    // marriage decision - outside option value wife
    const auto outside_option_w_v = std::max(utility.U_W_S[0], utility.U_W_S[1]);
    const auto outside_option_h_v = utility.U_H_S;

    UtilityArray weighted_utility;

    for (auto i = 0U; i < UTILITY_SIZE; ++i) {
        weighted_utility[i] = utility.U_H[i]*BP + utility.U_W[i]*(1.0-BP);
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
    if (max_nash_value > MINIMUM_UTILITY) {
        // there is at least one option with positive surplus for both
        if (max_nash_value_index == max_weighted_utility_index) {
            return 0.5;
        } else {
            UtilityArray weighted_utility_option;
            for (auto i = 0U; i < UTILITY_SIZE; ++i) {
                weighted_utility_option[i] = utility.U_H[i]*bp_vector[i%CS_SIZE] + utility.U_W[i]*(1.0-bp_vector[i%CS_SIZE]);  // weighted utility
            }
            const auto weighted_utility_option_max = *(std::max_element(weighted_utility_option.begin(), weighted_utility_option.end()));
            // 11 elements vector, with 1 for all the alpha-bp where 3 is bigger than 4, all possible alphas
            std::array<unsigned, CS_SIZE> possibilities{};
            for (auto i = 0U; i < CS_SIZE; ++i) {
                if (weighted_utility_option[i] == weighted_utility_option_max) {
                    possibilities[i] = 1;
                }
            }
            // initialize the indexes to alway be further from the center
            int ind1 = -1; int ind2 = CS_SIZE;
            // search for the last "1" in the index range of: 0-4
            for (auto i = 0; i < 5; ++i) {
                if (possibilities[i] == 1) {
                    ind1 = i;
                }
            }
            // search for the first "1" in the index range of: 10-6
            for (int i = 5; i > 0; --i) {
                if (possibilities[5+i] == 1) {
                    ind2 = 5+i;
                }
            }
            if (ind1 != -1 || ind2 != CS_SIZE) {
                // need to update BP
                if (5 - ind1 < ind2 - 5) {
                    // ind1 is closer to the center
                    return (double)ind1*0.1;
                }
                // ind2 is closer to the center
                return (double)ind2*0.1;    
            }
            // in case there there are no "1" smaller or larger than 5 we return -1
        }
    }

    return -1.0;
}

