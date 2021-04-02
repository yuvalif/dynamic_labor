#include "calculate_utility.h"
#include "marriage_emp_decision.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include <stdexcept>
#include <string>
#include <cassert>

unsigned wife_emp_decision(const Utility& utility) {
  return (utility.U_W_S[UNEMP] > utility.U_W_S[EMP]) ? UNEMP : EMP;
}

MarriageEmpDecision marriage_emp_decision(const Utility& utility, double& bp, Wife& wife, Husband& husband, bool adjust_bp) {

  MarriageEmpDecision result;
  result.outside_option_w_v = std::max(utility.U_W_S[UNEMP], utility.U_W_S[EMP]);
  result.outside_option_h_v = utility.U_H_S;
  result.outside_option_w = wife_emp_decision(utility);

  if (bp == NO_BP) {
    // no marriage is possible to begin with
    return result;
  }

  bool BP_FLAG_PLUS{false};
  bool BP_FLAG_MINUS{false};
  unsigned max_iterations = CS_SIZE;

  while (true) {
    if (max_iterations == 0) {
      throw std::runtime_error("max iteration reached. BP=" + std::to_string(bp));
    }

    assert(bp >= 0.0 && bp <= 1.0);

    UtilityArray weighted_utility_both; // weighted utilities when both has options better than the outside
    UtilityArray weighted_utility_one;  // weighted utilities when only one has option better than the outside
    std::fill(weighted_utility_both.begin(), weighted_utility_both.end(), MINIMUM_UTILITY);
    std::fill(weighted_utility_one.begin(), weighted_utility_one.end(), MINIMUM_UTILITY);
    for (auto csi = 0U; csi < CS_SIZE*2; ++csi) {
      const auto u_h = utility.U_H[csi];
      const auto u_w = utility.U_W[csi];
      if (u_h >= result.outside_option_h_v && u_w >= result.outside_option_w_v) {
        weighted_utility_both[csi] = u_h*(1.0-bp) + u_w*bp;
      } else if (u_h > result.outside_option_h_v || u_w > result.outside_option_w_v) {
        weighted_utility_one[csi] = u_h*(1.0-bp) + u_w*bp;
      }
    }

    result.max_weighted_utility_index = std::max_element(weighted_utility_both.begin(), weighted_utility_both.end()) - weighted_utility_both.begin();

    const auto max_weighted_utility_both = weighted_utility_both[result.max_weighted_utility_index];

    if (max_weighted_utility_both != MINIMUM_UTILITY) {
      // the max in married for both is better than outside
      // no change to bp
      result.M = MARRIED;
      const auto employed = result.max_weighted_utility_index >= CS_SIZE;
      wife.emp_state = employed ? EMP : UNEMP;
      wife.WE += (employed ? 1 : 0);
      ++husband.HE;
      return result;
    }

    if (!adjust_bp) {
      break;
    }

    --max_iterations;

    const auto max_weighted_utility_one_index = std::max_element(weighted_utility_one.begin(), weighted_utility_one.end()) - weighted_utility_one.begin(); 
    const auto max_weighted_utility_one = weighted_utility_one[max_weighted_utility_one_index];

    if (max_weighted_utility_one == MINIMUM_UTILITY) {
      // the outside option is better for either - no marriage
      break;
    }

    const auto max_U_H = utility.U_H[max_weighted_utility_one_index];
    const auto max_U_W = utility.U_W[max_weighted_utility_one_index];

    // change bp to try and find valid option
    if (max_U_H >= result.outside_option_h_v && max_U_W < result.outside_option_w_v) { 
      // the outside option is better for wife
      // increase the wife bp
      bp += 0.1;
      if (bp > 1.0 || BP_FLAG_MINUS) { 
        // no solution - boundry reached or resolution is not high enough
        break;
      }
      BP_FLAG_PLUS = true;
    } else if (max_U_H < result.outside_option_h_v && max_U_W >= result.outside_option_w_v) {
      // the outside option is better for husband
      // increase the husband bp
      bp -= 0.1;
      if (bp < 0.0 || BP_FLAG_PLUS) {
        // no solution - boundry reached or resolution is not high enough
        break;
      }
      BP_FLAG_MINUS = true;
    } else {
      throw std::runtime_error("no adjustment should be done at this point. max(H,W)=(" +
          std::to_string(max_U_H) + "," + std::to_string(max_U_W) + "). " +
          "outside(H,W)=(" + std::to_string(result.outside_option_h_v) + "," + std::to_string(result.outside_option_w_v) + ")");
    }
  }

  // no marriage
  bp = NO_BP;
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

