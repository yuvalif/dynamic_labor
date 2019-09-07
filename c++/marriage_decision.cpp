#include "calculate_utility.h"
#include "marriage_decision.h"
#include <stdexcept>
#include <string>
#include <cassert>

MarriageDecision marriage_decision(const Utility& utility, double BP, unsigned WE, unsigned HE) {

    MarriageDecision result;
    result.outside_option_w_v = std::max(utility.U_W_S[0], utility.U_W_S[1]);
    result.outside_option_h_v = utility.U_H_S;
    result.outside_option_w = (utility.U_W_S[0] > utility.U_W_S[1]) ? UNEMP : EMP;
    result.M = 0;
    result.prev_state_w = 0;
    
    if (BP < 0) {
        // no marriage is possible to begin with
        return result;
    }

    bool BP_FLAG_PLUS{false};
    bool BP_FLAG_MINUS{false};
    unsigned max_iterations = 10;

    while (true) {
        if (max_iterations == 0) {
            throw std::runtime_error("max iteration reached. BP=" + std::to_string(BP));
        }
        --max_iterations;

        UtilityArray weighted_utility;
        for (auto i = 0U; i < UTILITY_SIZE; ++i) {
            weighted_utility[i] = utility.U_H[i]*BP + utility.U_W[i]*(1.0-BP);
        }

        const auto max_weighted_utility_index = std::max_element(weighted_utility.begin(), weighted_utility.end()) - weighted_utility.begin();
        assert(max_weighted_utility_index < UTILITY_SIZE);
        [[maybe_unused]] const auto max_weighted_utility = weighted_utility[max_weighted_utility_index];
        const auto max_U_W = utility.U_W[max_weighted_utility_index];
        const auto max_U_H = utility.U_H[max_weighted_utility_index];
        result.max_weighted_utility_index = max_weighted_utility_index;

        if (max_U_H >= result.outside_option_h_v && max_U_W >= result.outside_option_w_v) {
            // the max in married for both is better than outside
            result.M = 1 ;
            if (max_weighted_utility_index < 11) {  
                // 0-10 WOMEN UNEMPLOYED
                result.prev_state_w = 0;
                result.WE = WE;
                result.HE = HE+1;
                return result;
            }
            // 11-21: wife employed  + husband employed
            result.prev_state_w = 1;
            result.WE = WE+1;
            result.HE = HE+1;
            return result;
        } else if (max_U_H < result.outside_option_h_v && max_U_H < result.outside_option_w_v) { 
            // the outside option is better for both - no marriage
            break;
        } else if (max_U_H  >= result.outside_option_h_v && max_U_W < result.outside_option_w_v) { 
            // the outside option is better for wife
            // increase the wife bargaining power
            BP -= 0.1;
            BP_FLAG_MINUS = true;
            if (BP < 0.0 || BP_FLAG_PLUS) { 
                // no solution - boundry reached or infinite loop of BP
                break;
            }
        } else if (max_U_H < result.outside_option_h_v && max_U_W >= result.outside_option_w_v) {
            // the outside option is better for husband
            // increase the husband bargaining power
            BP += 0.1;
            BP_FLAG_PLUS = true;
            if (BP > 1 || BP_FLAG_MINUS) {
                // no solution - boundry reached or infinite loop of BP
                break;
            }
        }
    }

    // no marriage
    result.M = 0;
    // TODO: check equality to 1 of double
    if (result.outside_option_w_v == 1) {  
        // 3-unmarried+wife unemployed
        result.prev_state_w = 0;
        result.WE = WE;
        return result;
    }
    // 3-unmarried+wife employed
    result.prev_state_w = 1;
    result.WE = WE+1;
    return result;   
}

