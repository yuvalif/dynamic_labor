#include "parameters.h"
#include "const_parameters.h"
#include "emax.h"
#include "random_pools.h"
#include "draw_husband.h"
#include "draw_wife.h"
#include "calculate_wage.h"
#include "calculate_utility.h"
#include "nash.h"
#include "marriage_emp_decision.h"

unsigned married_couple(const Parameters& p, int WS, unsigned t, MarriedEmax& w_emax, MarriedEmax& h_emax, 
    const SingleWomenEmax& w_s_emax, const SingleMenEmax& h_s_emax, bool adjust_bp) { 
  unsigned iter_count = 0;

  Wife wife;
  Husband husband;

  if (!update_wife_schooling(WS, t, wife)) {
    return 0;
  }

  for (auto W_EXP_INDEX : EXP_VALUES) { 
    // WIFE EXPERENCE - 5 GRID LEVEL
    wife.WE = exp_vector[W_EXP_INDEX];
    for (auto H_EXP_INDEX : EXP_VALUES) { 
      // HUSBAND EXPERENCE - 5 GRID LEVEL
      husband.HE = exp_vector[H_EXP_INDEX];
      for (auto kids : KIDS_VALUES) {
        for (auto ability_wi : ABILITY_VALUES) {
          // wife ability - high, medium, low
          update_ability(p, ability_wi, wife);
          for (auto ability_hi : ABILITY_VALUES) {   
            update_ability(p, ability_hi, husband);
            for (auto prev : WORK_VALUES) { 
              wife.emp_state = prev;
              for (auto HS : SCHOOL_H_VALUES) {
                update_husband_schooling(WS, t, husband);
                if (HS == WS) {
                  wife.similar_educ = p.EDUC_MATCH[WS];
                }
                for (auto Q_INDEX : MATCH_Q_VALUES) {
                  wife.Q = normal_arr[Q_INDEX]*p.sigma[4];
                  wife.Q_INDEX = Q_INDEX;
                  for (auto bpi = 1U; bpi < BP_W_LEN; ++bpi) {
                    auto bp = BP_W_VALUES[bpi];  // the grid is 0.2 - 0.8
                    auto ADD_EMAX_W = 0.0;
                    auto ADD_EMAX_H = 0.0;
                    for (auto draw_b = 0U; draw_b <  DRAW_B; ++draw_b) {
                      // reset experience - values are updated in marriage_decision
                      // HUSBAND WAGE
                      const auto wage_h = calculate_wage_h(p, husband, epsilon());
                      // JOB OFFER PROBABILITY + WAGE WIFE
                      auto wage_w = calculate_wage_w(p, wife, draw_p(), epsilon());
                      // calculate husbands and wives utility
                      const auto CHOOSE_WIFE = 1; 
                      const auto single_men = false;
                      const Utility utility = calculate_utility(p, w_emax, h_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w, 
                          CHOOSE_WIFE, MARRIED, wife, husband, t, bp, single_men);

                      // marriage decision - outside option value wife
                      const auto decision = marriage_emp_decision(utility, bp, wife, husband, adjust_bp);

                      if (decision.M == MARRIED) {
                        ADD_EMAX_H += utility.U_H[decision.max_weighted_utility_index];
                        ADD_EMAX_W += utility.U_W[decision.max_weighted_utility_index];
                      } else {
                        ADD_EMAX_H += utility.U_H_S; 
                        ADD_EMAX_W += decision.outside_option_w_v;
                      }
                    }  //end draw backward loop                                        
                    h_emax[t][W_EXP_INDEX][H_EXP_INDEX][kids][prev][ability_wi][ability_hi][HS][WS][Q_INDEX][bpi] = 
                      ADD_EMAX_H/DRAW_B;
                    w_emax[t][W_EXP_INDEX][H_EXP_INDEX][kids][prev][ability_wi][ability_hi][HS][WS][Q_INDEX][bpi] = 
                      ADD_EMAX_W/DRAW_B;
                    ++iter_count;
                  }   // end BP  loop
                }   // end match quality loop
              }  // end husband schooling loop
            }   // end prev state w loop
          }   // end husbands ability loop
        }   // end wife's ability loop
      }   // end kids loop
    } // end married men experience loop
  } // end married women experience loop

  return iter_count;
}

