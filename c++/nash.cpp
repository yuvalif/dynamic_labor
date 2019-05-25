#include "const_parameters.h"
#include "parameters.h"
#include "calculate_utility.h"
#include <algorithm>
#include <array>

double nash(const Parameters& p, const Utility& utility, double BP) {
    // marriage decision - outside option value wife
    const auto outside_option_w_v = std::max(utility.U_W_S[1], utility.U_W_S[2]);
    const auto outside_option_w = (utility.U_W_S[1] > utility.U_W_S[2]) ? UNEMP : EMP;
    const auto outside_option_h_v = utility.U_H_S;
    const auto outside_option_h = EMP;

    UtilityArray weighted_utility;

    for (auto i = 0U; i < UTILITY_SIZE; ++i) {
        weighted_utility[i] = utility.U_H[i]*BP + utility.U_W[i]*(1.0-BP);
    }

    UtilityArray nash_value;
    std::fill(nash_value.begin(), nash_value.end(), std::numeric_limits<double>::lowest());

    // leave only positive surplus for both
    for (auto i = 0U; i < UTILITY_SIZE; ++i) {
        if (utility.U_W[i] > outside_option_w_v && utility.U_H[i] > outside_option_h_v) { 
            // if positive surplus for both
            nash_value[i] = pow(utility.U_W[i]-outside_option_w_v, 0.5)*pow(utility.U_H[i]-outside_option_h_v, 0.5);
        }
    }

    const auto max_weighted_utility_index = std::max_element(weighted_utility.begin(), weighted_utility.end()) - weighted_utility.begin();
    const auto max_nash_value_index = std::max_element(nash_value.begin(), nash_value.end()) - nash_value.begin();
    const auto max_nash_value = nash_value[max_nash_value_index];

    // find the value of the bargaining power
    if (max_nash_value > std::numeric_limits<double>::lowest()) {
        // there is at least one option with positive surplus for both
        if (max_nash_value_index == max_weighted_utility_index) {
            return 0.5;
        } else {
            // TODO: 11 or 22? bp_vector is 11
            UtilityArray weighted_utility_option;
            for (auto i = 0U; i < UTILITY_SIZE; ++i) {
                weighted_utility_option[i] = utility.U_H[i]*bp_vector[i%11] + utility.U_W[i]*(1.0-bp_vector[i%11]);  // weighted utility
            }
            const auto weighted_utility_option_max = *(std::max_element(weighted_utility_option.begin(), weighted_utility_option.end()));
            // 22 elements vector, with 1 for all the alpha-bp where 3 is bigger than 4, all possible alphas
            std::array<unsigned, UTILITY_SIZE> possibilities{};
            for (auto i = 0U; i < UTILITY_SIZE; ++i) {
                if (weighted_utility_option[i] == weighted_utility_option_max) {
                    possibilities[i] = 1;
                }
            }
            int ind1 = 0; int ind2 = 0;
            for (int i = 1; i <= 5; ++i) {
                if (possibilities[i-1] == 1) {
                    ind1 = i;
                }
            }
            for (int i = 5; i > 0; --i) {
                if (possibilities[6+i-1] == 1) {
                    ind2 = 6+i;
                }
            }
            if (ind1 != 0 || ind2 != 0) {
                // need to update BP
                if (abs(6-ind1)<abs(6-ind2)) { 
                    return (ind1-1)*0.1;
                }
                return (ind2-1)*0.1;    
            }
        }
    }

    return -1.0;
}

