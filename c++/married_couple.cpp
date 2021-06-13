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

unsigned married_couple(const Parameters& p, int WS, unsigned t, MarriedEmax& w_emax, MarriedEmax& h_emax, 
		const SingleWomenEmax& w_s_emax, const SingleMenEmax& h_s_emax, bool adjust_bp, bool verbose) { 

	if (verbose) {
		std::cout << "====================== married couple: " << WS << ", " << t << " ======================" << std::endl;
	}

	Wife base_wife;
	Husband base_husband;

	if (!update_wife_schooling(WS, t, base_wife)) {
   if (verbose) {
      std::cout << "not calculating for couple" << std::endl;
      print_wife(base_wife);
    }   
		return 0;
	}

	unsigned iter_count = 0;

	for (auto w_exp_i : EXP_VALUES) { 
		base_wife.WE = exp_vector[w_exp_i];
		for (auto ability_wi : ABILITY_VALUES) {
			update_ability(p, ability_wi, base_wife);
			for (auto ability_hi : ABILITY_VALUES) {   
				update_ability(p, ability_hi, base_husband);
				for (auto kids : KIDS_VALUES) {
					for (auto prev_emp_state : WORK_VALUES) { 
							base_wife.emp_state = prev_emp_state;
							for (auto HS : SCHOOL_H_VALUES) {
								if (!update_school_and_age(HS, t, base_husband)) {
									if (verbose) {
                    std::cout << "skipping husband" << std::endl;
                    print_husband(base_husband);
				  std::cout << "================" << std::endl;
                  }
                  continue;
                }
								if (HS == WS) {
									base_wife.similar_educ = p.EDUC_MATCH[WS];
								}
								for (auto Q_INDEX : MATCH_Q_VALUES) {
									base_wife.Q = normal_arr[Q_INDEX]*p.sigma[4];
									base_wife.Q_INDEX = Q_INDEX;
									for (auto bpi = 1U; bpi < BP_W_LEN; ++bpi) {
										auto w_sum = 0.0;
										auto h_sum = 0.0;
										for (auto draw_b = 0U; draw_b <  DRAW_B; ++draw_b) {
										  auto bp = BP_W_VALUES[bpi];  // the grid is 0.2 - 0.8
                      auto wife = base_wife;
                      auto husband = base_husband;
											const auto wage_h = calculate_wage_h(p, husband, epsilon());
											auto wage_w = calculate_wage_w(p, wife, draw_p(), epsilon());
											const auto CHOOSE_PARTNER = 1; 
											const auto single_men = false;
											const Utility utility = calculate_utility(p, w_emax, h_emax, w_s_emax, h_s_emax, kids, wage_h, wage_w, 
													CHOOSE_PARTNER, MARRIED, wife, husband, t, bp, single_men);

			    if (verbose) {	
											  print_wife(wife);
                        print_husband(husband);
						std::cout << to_string(utility);
                      }

											// marriage decision - outside option value wife
											const auto decision = marriage_emp_decision(utility, bp, wife, husband, adjust_bp);

											if (decision.M == MARRIED) {
												w_sum += utility.U_W[decision.max_weighted_utility_index];
												h_sum += utility.U_H[decision.max_weighted_utility_index];
                        if (verbose) std::cout << "still married" << std::endl;
											} else {
												w_sum += decision.outside_option_w_v;
												h_sum += utility.U_H_S;
                        if (verbose) std::cout << "got divorced" << std::endl;
											}
                      if (verbose) std::cout << "====================== new draw ======================" << std::endl;
										}  //end draw backward loop                                        
										w_emax[t][w_exp_i][kids][prev_emp_state][ability_wi][ability_hi][HS][WS][Q_INDEX][bpi] = 
											w_sum/(double)DRAW_B;
										h_emax[t][w_exp_i][kids][prev_emp_state][ability_wi][ability_hi][HS][WS][Q_INDEX][bpi] = 
											h_sum/(double)DRAW_B;
						  if (verbose) {
						std::cout << "emax() = " << w_sum/(double)DRAW_B << ", " << h_sum/(double)DRAW_B << std::endl;
						std::cout << "======================================================" << std::endl;
						}

										++iter_count;
									}  // end BP loop
								}   // end match quality loop
							}  // end husband schooling loop
						}   // end prev state w loop
					}   // end husbands ability loop
				}   // end wife's ability loop
			}   // end kids loop
	} // end married women experience loop

	return iter_count;
}

