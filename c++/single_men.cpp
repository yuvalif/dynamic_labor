#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"
#include "emax.h"
#include "random_pools.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include "calculate_wage.h"
#include "calculate_utility.h"
#include "marriage_emp_decision.h"
#include "nash.h"
#include "value_to_index.h"
#include <cstdlib>
#include <iostream>

unsigned single_men(const Parameters& p, unsigned HS, unsigned t, const MarriedEmax& w_emax, const MarriedEmax& h_emax, 
    const SingleWomenEmax& w_s_emax, SingleMenEmax& h_s_emax, bool adjust_bp, bool verbose) {
  Husband base_husband;
  if (verbose) {
    std::cout << "====================== single_men: " << HS << ", " << t << " ======================" << std::endl;
  }

  if (!update_husband_schooling(HS, std::nullopt, t, base_husband)) {
    if (verbose) {
      std::cout << "not calculating for husband" << std::endl;
      print_husband(base_husband);
    }
    return 0;
  }

  unsigned iter_count = 0;

  for (auto ability_i : ABILITY_VALUES) {   
    // husband ability - high, medium, low
    update_ability(p, ability_i, base_husband);
    const auto wage_h = calculate_wage_h(p, base_husband, epsilon());
    double sum = 0.0;
    if (verbose) {
      print_husband(base_husband);
    }
    for (auto draw = 0U; draw < DRAW_B; ++draw) {
      Husband husband = base_husband;
      // DRAW A WIFE 
      Wife wife;
      // PROBABILITY OF MEETING A POTENTIAL wife
      const auto p_wife = exp(p.p0_h+p.p1_h*(husband.AGE+t)+p.p2_h*pow(husband.AGE+t,2))/(1.0+exp(p.p0_h+p.p1_h*(husband.AGE+t)+p.p2_h*pow(husband.AGE+t,2))); 
      unsigned CHOOSE_WIFE = 0;
      double wage_w = 0.0;
      if (draw_p() < p_wife) {
        CHOOSE_WIFE = 1;
        wife = draw_wife(p, t, husband.age_index, HS);
        update_wife_schooling(wife.WS, t, wife);
        wage_w = calculate_wage_w(p, wife, draw_p(), epsilon());
      }

      // calculate husbands and wives utility from each option -inf for unavailable
      double bp = INITIAL_BP;
      const auto is_single_men = true; 
      const Utility utility = calculate_utility(p, w_emax, h_emax, w_s_emax, h_s_emax, NO_KIDS, wage_h, wage_w, CHOOSE_WIFE, 
          UNMARRIED, wife, husband, t, bp, is_single_men);
      // MAXIMIZATION - MARRIAGE + WORK DESICION 
      if (CHOOSE_WIFE == 1) {
        bp = nash(p, utility); // Nash bargaining at first period of marriage  
      } else {
        bp = NO_BP;
      }

      if (verbose && CHOOSE_WIFE) {
        print_wife(wife);
        std::cout << to_string(utility); 
      }

      if (bp != NO_BP) {
        // marriage decision - outside option value wife
        const auto decision = marriage_emp_decision(utility, bp, wife, husband, adjust_bp);
        if (decision.M == MARRIED) {
          sum += utility.U_H[decision.max_weighted_utility_index];
          if (verbose) std::cout << "got married" << std::endl;
        } else {
          sum += decision.outside_option_h_v;
          assert(decision.outside_option_h_v == utility.U_H_S);
          if (verbose) std::cout << "did not get married" << std::endl;
        }
      } else {
        sum += utility.U_H_S;
        if (verbose) std::cout << "did not get marriage offer" << std::endl;
      }
      if (verbose) std::cout << "====================== new draw ======================" << std::endl;
    }

    h_s_emax[t][ability_i][HS] = sum/(double)DRAW_B;
    if (verbose) {
      std::cout << "emax(" << t << ", " << ability_i << ", " << HS << ")=" << sum/(double)DRAW_B << std::endl;
      std::cout << "======================================================" << std::endl;
    }
    ++iter_count;
  }
  return iter_count;
}

