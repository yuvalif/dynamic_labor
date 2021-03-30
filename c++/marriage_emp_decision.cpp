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

MarriageEmpDecision marriage_emp_decision(const Utility& utility, double& bp, Wife& wife, Husband& husband, bool adjust_bp) {

  MarriageEmpDecision result;
  result.outside_option_w_v = std::max(utility.U_W_S[0], utility.U_W_S[1]);
  result.outside_option_h_v = utility.U_H_S;
  result.outside_option_w = wife_emp_decision(utility);

  if (bp == NO_BP) {
    // no marriage is possible to begin with
    return result;
  }

  bool BP_FLAG_PLUS{false};
  bool BP_FLAG_MINUS{false};
  unsigned max_iterations = 20;


  while (true) {
    if (max_iterations == 0) {
      throw std::runtime_error("max iteration reached. BP=" + std::to_string(bp));
    }
    --max_iterations;

    assert(bp >= 0.0 && bp <= 1.0);

    const unsigned bpi_uemp = bp*10.0;
    const unsigned bpi_emp = bp*10.0+CS_SIZE;
    const auto U_W_uemp = utility.U_W[bpi_uemp];
    const auto U_H_uemp = utility.U_H[bpi_uemp];
    const auto U_W_emp = utility.U_W[bpi_emp];
    const auto U_H_emp = utility.U_H[bpi_emp];
    double max_U_W;
    double max_U_H;
    bool employed;
    bool valid_option_found;

    if (U_H_uemp >= result.outside_option_h_v && U_W_uemp >= result.outside_option_w_v &&
        U_H_emp >= result.outside_option_h_v && U_W_emp >= result.outside_option_w_v) {
      // both employment and unemployment are valid options - find the maximum weighted utility
      if ((U_H_uemp*(1-bp) + U_W_uemp*bp) > (U_H_emp*(1-bp) + U_W_emp*bp)) {
        max_U_H = U_H_uemp;
        max_U_W = U_W_uemp;
        employed = false;
      } else {
        max_U_H = U_H_emp;
        max_U_W = U_W_emp;
        employed = true;
      }
      valid_option_found = true;
    } else if (U_H_uemp >= result.outside_option_h_v && U_W_uemp >= result.outside_option_w_v) {
      // only unemployment is a valid option
      max_U_H = U_H_uemp;
      max_U_W = U_W_uemp;
      employed = false;
      valid_option_found = true;
    } else if (U_H_emp >= result.outside_option_h_v && U_W_emp >= result.outside_option_w_v) {
      // only employment is a valid option
      max_U_H = U_H_emp;
      max_U_W = U_W_emp;
      employed = true;
      valid_option_found = true;
    } else {
      // both employment and unemployment are not valid options - find the maximum weighted utility
      // TODO: is this correct, or should we try to adjust for both employment and unemployment?
      if ((U_H_uemp*(1-bp) + U_W_uemp*bp) > (U_H_emp*(1-bp) + U_W_emp*bp)) {
        max_U_H = U_H_uemp;
        max_U_W = U_W_uemp;
        employed = false;
      } else {
        max_U_H = U_H_emp;
        max_U_W = U_W_emp;
        employed = true;
      }
      valid_option_found = false;
    }

    if (valid_option_found) {
      // the max in married for both is better than outside
      // no change to bp
      result.M = MARRIED;
      wife.emp_state = employed ? EMP : UNEMP;
      wife.WE += (employed ? 1 : 0);
      ++husband.HE;
      return result;
    }

    if (!adjust_bp) {
      break;
    }

    // change bp to try and find valid option
    if (max_U_H < result.outside_option_h_v && max_U_W < result.outside_option_w_v) { 
      // the outside option is better for both - no marriage
      break;
    } else if (max_U_H  >= result.outside_option_h_v && max_U_W < result.outside_option_w_v) { 
      // the outside option is better for wife
      // increase the wife bp
      bp += 0.1;
      if (bp > 1.0 || BP_FLAG_MINUS) { 
        // no solution - boundry reached or infinite loop of BP
        break;
      }
      BP_FLAG_PLUS = true;
    } else if (max_U_H < result.outside_option_h_v && max_U_W >= result.outside_option_w_v) {
      // the outside option is better for husband
      // increase the husband bp
      bp -= 0.1;
      if (bp < 0.0 || BP_FLAG_PLUS) {
        // no solution - boundry reached or infinite loop of BP
        break;
      }
      BP_FLAG_MINUS = true;
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

