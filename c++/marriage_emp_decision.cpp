#include "calculate_utility.h"
#include "marriage_emp_decision.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include <stdexcept>
#include <string>
#include <cassert>

unsigned wife_emp_decision(const Utility& utility) {
    return (utility.U_W_S[0] > utility.U_W_S[1]) ? UNEMP : EMP;
}

MarriageEmpDecision marriage_emp_decision(const Utility& utility, double BP, Wife& wife, Husband& husband) {

    MarriageEmpDecision result;
    result.outside_option_w_v = std::max(utility.U_W_S[0], utility.U_W_S[1]);
    result.outside_option_h_v = utility.U_H_S;
    result.outside_option_w = wife_emp_decision(utility);
    
    if (BP == NO_BP) {
        // no marriage is possible to begin with
        return result;
    }

    bool BP_FLAG_PLUS{false};
    bool BP_FLAG_MINUS{false};
    unsigned max_iterations = 20;

    while (true) {
        if (max_iterations == 0) {
            throw std::runtime_error("max iteration reached. BP=" + std::to_string(BP));
        }
        --max_iterations;

        UtilityArray weighted_utility;
        for (auto i = 0U; i < UTILITY_SIZE; ++i) {
            weighted_utility[i] = utility.U_H[i]*(1.0-BP) + utility.U_W[i]*BP;
        }

        const auto max_weighted_utility_index = std::max_element(weighted_utility.begin(), weighted_utility.end()) - weighted_utility.begin();
        assert(max_weighted_utility_index < UTILITY_SIZE);
        const auto max_U_W = utility.U_W[max_weighted_utility_index];
        const auto max_U_H = utility.U_H[max_weighted_utility_index];
        result.max_weighted_utility_index = max_weighted_utility_index;

        if (max_U_H >= result.outside_option_h_v && max_U_W >= result.outside_option_w_v) {
            // the max in married for both is better than outside
            result.M = MARRIED;
            if (max_weighted_utility_index < 11) {  
                // 0-10 WOMEN UNEMPLOYED
                wife.emp_state = UNEMP;
                ++husband.HE;
                return result;
            }
            // 11-21: wife employed  + husband employed
            wife.emp_state = EMP;
            ++wife.WE;
            ++husband.HE;
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
    result.M = UNMARRIED;
    if (result.outside_option_w == UNEMP) {  
        // unmarried+wife unemployed
        wife.emp_state = UNEMP;
        return result;
    } else {
        // unmarried+wife employed
        wife.emp_state = EMP;
        ++wife.WE;
    }
    return result;
}

