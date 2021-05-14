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
#include <iostream>

unsigned single_women(const Parameters& p, unsigned school_group, unsigned t, const MarriedEmax& w_m_emax, const MarriedEmax& h_m_emax,
    SingleWomenEmax& w_s_emax, const SingleMenEmax& h_s_emax, bool adjust_bp, bool verbose) { 

  if (verbose) {
    std::cout << "====================== single women: " << school_group << ", " << t << " ======================" << std::endl;
  }

  Wife base_wife;

  if (!update_wife_schooling(school_group, t, base_wife)) {
    if (verbose) {
      std::cout << "not calculating for wife" << std::endl;
      print_wife(base_wife);
    }
    return 0;
  }

  unsigned iter_count = 0;

  for (auto w_exp_i : EXP_VALUES) {
    base_wife.WE = w_exp_i;
    for (auto ability_i : ABILITY_VALUES) {
      update_ability(p, ability_i, base_wife);
      for (auto kids : KIDS_VALUES) {
        for (auto prev_emp_state : WORK_VALUES) { 
          base_wife.emp_state = prev_emp_state;
          double sum = 0;
          if (verbose) {
            print_wife(base_wife);
          }
          for (auto draw_b = 0U; draw_b <  DRAW_B; ++draw_b) {
            auto wife = base_wife;
            Husband husband;
            // probabilty of meeting a potential husband
            const auto p_husband = exp(p.p0_w+p.p1_w*(wife.AGE+t)+p.p2_w*pow(wife.AGE+t,2))/(1.0+exp(p.p0_w+p.p1_w*(wife.AGE+t)+p.p2_w*pow(wife.AGE+t,2)));
            unsigned CHOOSE_HUSBAND = 0;
            double wage_h = 0.0; 
            double wage_w = 0.0;
            if (draw_p() < p_husband) {
              CHOOSE_HUSBAND = 1;
              husband = draw_husband(p, t, wife.age_index, school_group, school_group);
              update_husband_schooling(school_group, t, husband);
              wage_h = calculate_wage_h(p, husband, epsilon());
            }
            wage_w =  calculate_wage_w(p, wife, draw_p(), epsilon());

            double bp = INITIAL_BP;
            const auto is_single_men = false;
            const Utility utility = calculate_utility(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w, CHOOSE_HUSBAND,
                UNMARRIED, wife, husband, t, bp, is_single_men);
            if (CHOOSE_HUSBAND == 1) {
              bp = nash(p, utility); // Nash bargaining at first period of marriage  
            } else {
              bp = NO_BP;
            }
 						
						if (verbose && CHOOSE_HUSBAND) {
          		print_wife(wife);
          		std::cout << to_string(utility); 
        		}

            if (bp != NO_BP) {
              // marriage decision
              const auto decision = marriage_emp_decision(utility, bp, wife, husband, adjust_bp);

              if (decision.M == MARRIED) {
                sum += utility.U_W[decision.max_weighted_utility_index];
                if (verbose) std::cout << "got married" << std::endl;
              } else {
                sum += decision.outside_option_w_v;
                if (verbose) std::cout << "did not get married" << std::endl;
              }
            } else {
              sum += std::max(utility.U_W_S[UNEMP], utility.U_W_S[EMP]);
              if (verbose) std::cout << "did not get marriage offer" << std::endl;
            }
            if (verbose) std::cout << "====================== new draw ======================" << std::endl;
          }   // end draw backward loop
          w_s_emax[t][w_exp_i][kids][prev_emp_state][ability_i][school_group] = sum/(double)DRAW_B;
          if (verbose) {
            std::cout << "emax(" << t << ", " << ability_i << ", " << school_group << ")=" << sum/(double)DRAW_B << std::endl;
            std::cout << "======================================================" << std::endl;
          }   
          ++iter_count;
        } // end prev_emp_state
      } // end of kids loop
    } // end single wemen ability loop
  } // end single women experience loop

  return iter_count;
}

