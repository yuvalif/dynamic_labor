#include <chrono>
#include <iostream>
#include <algorithm>
#include <numeric>
#include <boost/math/distributions/normal.hpp>
#include "single_men.h"
#include "single_women.h"
#include "married_couple.h"
#include "draw_husband.h"
#include "draw_wife.h"
#include "calculate_wage.h"
#include "calculate_utility.h"
#include "marriage_emp_decision.h"
#include "nash.h"
#include "parameters.h"
#include "const_parameters.h"
#include "moments.h"
#include "emax.h"
#include "random_pools.h"
#include "print_moments.h"
#include "cpp-text-table/TextTable.h"

unsigned calculate_emax(const Parameters& p, MarriedEmax& w_m_emax, MarriedEmax& h_m_emax,
    SingleWomenEmax& w_s_emax, SingleMenEmax& h_s_emax, bool adjust_bp, bool verbose) 
{
  unsigned iter_count = 0;
  // running until the one before last period
  for (auto t = T_MAX - 2; t >= 0; --t) {
    // EMAX FOR SINGLE MEN
    for (auto HS : SCHOOL_H_VALUES) {
      iter_count += single_men(p, HS, t, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose);
    } // end husband schooling loop

    // EMAX FOR SINGLE WOMEN
    for (auto WS : SCHOOL_W_VALUES) {
      iter_count += single_women(p, WS, t, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose);
    } // end wife schooling loop

    // EMAX FOR MARRIED COUPLE
    for (auto WS : SCHOOL_W_VALUES) {
      iter_count += married_couple(p, WS, t, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose);
    } // end wife schooling loop
  }
  return iter_count;
}

double mean(const SchoolingMatrix& val_matrix, const SchoolingMatrix& count_matrix, unsigned t, unsigned school_group) {
  const auto count = count_matrix[t][school_group];
  if (count == 0) {
    return 0.0;
  }
  return (double)val_matrix[t][school_group]/(double)count;
}

double mean(const SchoolingArray& val_arr, const SchoolingArray& count_arr, unsigned school_group) {
  const auto count = count_arr[school_group];
  if (count == 0) {
    return 0.0;
  }
  return (double)val_arr[school_group]/(double)count;
}

EstimatedMoments calculate_moments(const Parameters& p, const Moments& m,
    const MarriedEmax& w_m_emax, const MarriedEmax& h_m_emax, 
    const SingleWomenEmax& w_s_emax, const SingleMenEmax& h_s_emax, bool adjust_bp, bool verbose) 
{
  EstimatedMoments estimated;
  boost::math::normal normal_dist;
  SchoolingMatrix emp_total = {{{0}}};    // employment
  SchoolingMatrix count_emp_total{{{0}}};
  SchoolingMatrix emp_m{{{0}}};           // employment married
  SchoolingMatrix emp_um{{{0}}};          // employment unmarried
  SchoolingMeanArray emp_m_up;            // employment unmarried up
  SchoolingMeanArray emp_m_down;          // employment unmarried down
  SchoolingMeanArray emp_m_eq;            // employment unmarried equal
  static const auto M_KIDS_SIZE = 5; // no kids, 1 kids, 2 kids, 3 kids 4+kids
  static const auto UM_KIDS_SIZE = 2; // no kids, with kids
  SchoolingMeanArray emp_m_kids[M_KIDS_SIZE];     // employment married no kids
  SchoolingMeanArray emp_um_kids[UM_KIDS_SIZE];   // employment unmarried and no children
  SchoolingMatrix divorce{{{0}}};
  SchoolingArray just_found_job_m{0};         // transition matrix - unemployment to employment (married) 
  SchoolingArray just_got_fired_m{0};         // transition matrix - employment to unemployment (married)
  SchoolingArray just_found_job_um{0};        // transition matrix - unemployment to employment (unmarried)
  SchoolingArray just_got_fired_um{0};        // transition matrix - employment to unemployment (unmarried)
  SchoolingArray just_found_job_mc{0};        // transition matrix - unemployment to employment (married+kids)
  SchoolingArray just_got_fired_mc{0};        // transition matrix - employment to unemployment (married+kids)
  SchoolingArray count_just_got_fired_m{0};
  SchoolingArray count_just_found_job_m{0};
  SchoolingArray count_just_got_fired_um{0};
  SchoolingArray count_just_found_job_um{0};
  SchoolingArray count_just_got_fired_mc{0};
  SchoolingArray count_just_found_job_mc{0};
  SchoolingMeanMatrix wages_m_h;
  // married men wages - 0 until 20+27 years of exp - 36-47 will be ignore in moments  
  SchoolingMeanMatrix wages_w;        // women wages if employed
  SchoolingMeanArray wages_m_w_up;    // married up women wages if employed
  SchoolingMeanArray wages_m_w_down;  // married down women wages if employed
  SchoolingMeanArray wages_m_w_eq;    // married equal women wages if employed
  SchoolingMeanArray wages_um_w;      // unmarried women wages if employed
  SchoolingMatrix married{{{0}}};     // fertility and marriage rate moments   % married yes/no
  SchoolingArray just_married{{0}};   // for transition matrix from single to married
  SchoolingArray just_divorced{{0}};  // for transition matrix from married to divorce
  SchoolingMeanArray age_at_first_marriage; // age at first marriage
  SchoolingMeanMatrix newborn_um;      // new born in period t - for probability and distribution
  SchoolingMeanMatrix newborn_m;       // new born in period t - for probability and distribution
  SchoolingMeanMatrix newborn_all;       // new born in period t - for probability and distribution
  SchoolingMeanArray duration_of_first_marriage; // duration of marriage if divorce or 45-age of marriage if still married at 45.
  // husband education by wife education
  UMatrix<SCHOOL_LEN, SCHOOL_LEN> assortative_mating_hist{{{0}}};
  SchoolingArray assortative_mating_count{0};
  SchoolingArray count_just_married{{0}};
  SchoolingArray count_just_divorced{{0}};
  SchoolingMeanArray n_kids_arr;    // # of children by school group

  // school_group 0 is only for calculating the emax if single men - not used here
  for (auto school_group : SCHOOL_W_VALUES) {
    for (auto draw_f = 0U; draw_f < DRAW_F; ++draw_f) {
      const unsigned IGNORE_T = 0;
      Husband husband;
      Wife wife;
      update_wife_schooling(school_group, IGNORE_T, wife);
      wife.emp_state = (draw_f > DRAW_F*UNEMP_WOMEN_RATIO) ? 1 : 0;

      // kid age array maximum number of kids = 4
      // 0 - oldest kid ... 3 - youngest kid
      const auto MAX_NUM_KIDS = KIDS_LEN - 1;
      std::array<unsigned, MAX_NUM_KIDS> kid_age{0};
      unsigned DIVORCE = 0;
      auto n_kids = 0;
      auto n_kids_m = 0;
      auto n_kids_um = 0;
      unsigned duration = 0;
      double Q_minus_1 = 0.0;
      double bp = INITIAL_BP;
      update_ability(p, draw_3(), wife);
      MarriageEmpDecision decision;

      // following 2 indicators are used to count age at first marriage
      // and marriage duration only once per draw
      auto first_marriage = true;
      auto first_divorce = true;

      // make choices for all periods
      const auto last_t = wife.T_END;
      if (verbose) {
        std::cout << "=========" << std::endl;
        std::cout << "new women" << std::endl;
        std::cout << "=========" << std::endl;
      }

      // FIXME: husband moments are calculated up to last_t and not T_MAX
      for (auto t = 0U; t <= last_t; ++t) {
        if (verbose) {
          std::cout << "========= " << t << " =========" << std::endl;
        }
        const auto prev_emp_state_w = wife.emp_state;
        const auto prev_M = decision.M;
        unsigned new_born = 0;

        bool choose_husband = false;
        // draw husband if not already married
        if (decision.M == UNMARRIED) {
          bp = INITIAL_BP;
          duration = 0;
          wife.Q = 0.0;
          // probability of meeting a potential husband
          const auto choose_hudband_p = exp(p.p0_w+p.p1_w*(wife.AGE)+p.p2_w*pow(wife.AGE,2))/
            (1.0+exp(p.p0_w+p.p1_w*(wife.AGE)+p.p2_w*pow(wife.AGE,2)));
          if (draw_p() < choose_hudband_p) {
            choose_husband = true;
	    // TODO: what school group to use here?
            husband = draw_husband(p, t, wife.age_index, wife.WS, wife.WS);
            wife.Q = husband.Q;
            update_school_and_age(husband.HS, wife, husband);
            assert(husband.AGE == wife.AGE);
            if (verbose) {
              std::cout << "new potential husband" << std::endl;
            }
          }
        }

        // potential or current husband wage
        const auto wage_h = (decision.M == MARRIED || choose_husband) ? calculate_wage_h(p, husband, epsilon()) : 0.0;
        const auto wage_w = calculate_wage_w(p, wife, draw_p(), epsilon());

        const auto is_single_men = false;
        if (decision.M == UNMARRIED && choose_husband) {
          // not married, but has potential husband - calculate initial BP
          const Utility utility = calculate_utility(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              true /*choose partner*/, decision.M, wife, husband, t, bp, is_single_men);
          // Nash bargaining at first period of marriage  
          bp = nash(p, utility);
          if (bp != NO_BP) {
            ++estimated.bp_initial_dist[bp*10];
          } else {
            choose_husband = false;
          }
        }

        if (decision.M == MARRIED) {
          if (verbose) {
            std::cout << "existing husband" << std::endl;
          }
        }

        Utility utility;
        if (decision.M == MARRIED || choose_husband) {
          // at this point the BP is 0.5 if there is no marriage offer
          // BP is calculated by nash above if offer given
          // and is from previous period if already married           
          // utility is calculated again based on the new BP
          utility = calculate_utility(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              true /*choose partner*/, decision.M, wife, husband, t, bp, is_single_men);
          decision = marriage_emp_decision(utility, bp, wife, husband, adjust_bp);
        } else {
          assert(wage_h == 0.0);
          utility = calculate_utility(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, n_kids, wage_h, wage_w,
              false /*no partner*/, decision.M, wife, husband, t, bp, is_single_men);
          wife.emp_state = wife_emp_decision(utility);
        }

        assert(t+wife.age_index < T_MAX);
        emp_total[t+wife.age_index][school_group] += wife.emp_state;
        emp_m[t+wife.age_index][school_group] += decision.M == MARRIED ? wife.emp_state : 0;
        emp_um[t+wife.age_index][school_group] += decision.M == UNMARRIED ? wife.emp_state : 0;
        ++count_emp_total[t+wife.age_index][school_group];

        if (bp != NO_BP) {
          ++estimated.bp_dist[bp*10];
        }
        if (decision.M == MARRIED) {
          ++estimated.cs_dist[decision.max_weighted_utility_index];
        }

        // FERTILITY EXOGENOUS PROCESS - check for another child + update age of children
        // probability of another child parameters:
        // c1 previous work state - wife   
        // c2 age wife - HSG   
        // c3 age square  wife - HSG  
        // c4 age wife - SC   
        // c5 age square  wife - SC   
        // c6 age wife - CG
        // c7 age square  wife - CG   
        // c8 age wife - PC   
        // c9 age square  wife - PC   
        // c10 number of children at household    
        // c11 schooling - husband  
        // c12 unmarried
        const auto c_lamda = p.c1*wife.emp_state + p.c2*wife.HSG*(wife.AGE) + p.c3*wife.HSG*pow(wife.AGE,2) + 
          p.c4*wife.SC*(wife.AGE) + p.c5*wife.SC*pow(wife.AGE,2) + p.c6*wife.CG*(wife.AGE) + p.c7*wife.CG*pow(wife.AGE,2) + 
          p.c8*wife.PC*(wife.AGE) + p.c9*wife.PC*pow(wife.AGE,2) + p.c10*n_kids + p.c11*husband.HS*decision.M + p.c12*decision.M;
        const auto child_prob = boost::math::cdf(normal_dist, c_lamda);
        if (draw_p() < child_prob && wife.AGE < MAX_FERTILITY_AGE)  { 
          new_born = 1;
          n_kids = std::min(n_kids+1, MAX_NUM_KIDS);
          if (decision.M == MARRIED) {
            n_kids_m = std::min(n_kids_m+1, MAX_NUM_KIDS);
          } else {
            n_kids_um = std::min(n_kids_um+1, MAX_NUM_KIDS);
          }
          // set the age for the youngest kid
          assert(n_kids>0);
          assert(n_kids<=MAX_NUM_KIDS);
          kid_age[n_kids-1] = 1;
        } else if (n_kids > 0) {
          // no new born, but kids at house, so update ages
          if (kid_age[0] == 18) {
            // oldest kids above 18 leaves the household
            for (auto order = 0; order < MAX_NUM_KIDS-1; ++order) {
              kid_age[order] = kid_age[order+1];
            }
            kid_age[MAX_NUM_KIDS-1] = 0;
            --n_kids;
            assert(n_kids>=0);
          }         
          for (auto order = 0; order < MAX_NUM_KIDS; ++order) {
            if (kid_age[order] > 0) {
              ++kid_age[order];
            }
          }
        }

        // update the match quality
        if (decision.M == MARRIED) {
          Q_minus_1 = wife.Q;
          DIVORCE = 0;
          ++duration;
          const auto match_quality_change_prob = draw_p();
          if (match_quality_change_prob < p.MATCH_Q_DECREASE && wife.Q_INDEX > 0) {
            --wife.Q_INDEX;
            wife.Q = normal_arr[wife.Q_INDEX]*p.sigma[4];
          } else if (match_quality_change_prob > p.MATCH_Q_DECREASE && 
              match_quality_change_prob < p.MATCH_Q_DECREASE + p.MATCH_Q_INCREASE && wife.Q_INDEX < 2) {
            ++wife.Q_INDEX;
            wife.Q = normal_arr[wife.Q_INDEX]*p.sigma[4];
          }
        }

        if (decision.M == MARRIED) {
          // MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          emp_m_kids[n_kids].accumulate(wife.WS, wife.emp_state); // employment married no kids
        } else { 
          // UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
          emp_um_kids[n_kids == 0 ? 0 : 1].accumulate(wife.WS, wife.emp_state); // un/employment unmarried and no children
        }
        // EMPLOYMENT TRANSITION MATRIX
        if (wife.emp_state == EMP && prev_emp_state_w == UNEMP) {
          // for transition matrix - unemployment to employment
          if (decision.M == MARRIED) {
            ++just_found_job_m[wife.WS];
            ++count_just_found_job_m[wife.WS];
            if (n_kids >0) {
              ++just_found_job_mc[wife.WS];
              ++count_just_found_job_mc[wife.WS];
            }	
          } else {
            ++just_found_job_um[wife.WS];
            ++count_just_found_job_um[wife.WS];
          }	
        } else if (wife.emp_state == UNEMP && prev_emp_state_w == EMP) {
          // for transition matrix - employment to unemployment
          if (decision.M == MARRIED) {
            ++just_got_fired_m[wife.WS]; 
            if (n_kids > 0) {
              ++just_got_fired_mc[wife.WS];
            }
          } else {
            ++just_got_fired_um[wife.WS];
          }
        } else if (wife.emp_state == UNEMP && prev_emp_state_w == UNEMP) {
          // no change employment
          if (decision.M == MARRIED) {
            ++count_just_found_job_m[wife.WS];
            if (n_kids > 0) {
              ++count_just_found_job_mc[wife.WS];
            }	
          } else {
            ++count_just_found_job_um[wife.WS];
          }	
        } else if (wife.emp_state == EMP && prev_emp_state_w == EMP) {
          // no change unemployment
          if (decision.M == MARRIED) {
            ++count_just_got_fired_m[wife.WS];
            if (n_kids > 0) {
              ++count_just_got_fired_mc[wife.WS];
            }
          } else {
            ++count_just_got_fired_um[wife.WS];
          }	
        }

        // women wages if employed by experience
        if (wife.emp_state == EMP && wage_w > 0.0) {
          wages_w.accumulate(wife.WE, school_group, wage_w);
        }

        if (decision.M == MARRIED) {
          assert(wage_h > 0.0); // husband always works
          wages_m_h.accumulate(husband.HE, husband.HS, wage_h); // husband always works
          if (wife.WS > husband.HS) { 
            // women married down, men married up
            emp_m_down.accumulate(wife.WS, wife.emp_state);
            if (husband.HE < 37  && wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS]) {
              estimated.up_down_moments.accumulate(emp_m_down_above, wife.WS, wife.emp_state);
            } else {	
              estimated.up_down_moments.accumulate(emp_m_down_below, wife.WS, wife.emp_state);
            }
            estimated.up_down_moments.accumulate(wages_m_h_up, husband.HS, wage_h); // married up men wages 
            if (prev_M == UNMARRIED) {
              // first period of marriage
              estimated.up_down_moments.accumulate(ability_h_up, husband.HS, husband.ability_h_value);
              estimated.up_down_moments.accumulate(ability_w_down, wife.WS, wife.ability_w_value);
              estimated.up_down_moments.accumulate(match_w_down, wife.WS, Q_minus_1);
            }
          } else if (wife.WS < husband.HS) {
            // women married up, men married down
            emp_m_up.accumulate(wife.WS, wife.emp_state);
            if (husband.HE < 37 && wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS]) {
              estimated.up_down_moments.accumulate(emp_m_up_above, wife.WS, wife.emp_state);
            } else {
              estimated.up_down_moments.accumulate(emp_m_up_below, wife.WS, wife.emp_state);
            }
            estimated.up_down_moments.accumulate(wages_m_h_down, husband.HS, wage_h); // married down men wages
            if (prev_M == UNMARRIED) {
              // first period of marriage
              estimated.up_down_moments.accumulate(ability_h_down, husband.HS, husband.ability_h_value);
              estimated.up_down_moments.accumulate(ability_w_up, wife.WS, wife.ability_w_value);
              estimated.up_down_moments.accumulate(match_w_up, wife.WS, Q_minus_1);
            }
          } else {
            // married equal
            estimated.up_down_moments.accumulate(wages_m_h_eq, husband.HS, wage_h); // married equal men wages 
            emp_m_eq.accumulate(wife.WS, wife.emp_state); //employment married equal women

            if (husband.HE < 37 && wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS+husband.HS]) {
              estimated.up_down_moments.accumulate(emp_m_eq_above, wife.WS,wife.emp_state);
            } else {
              estimated.up_down_moments.accumulate(emp_m_eq_below, wife.WS, wife.emp_state);
            }
            if (prev_M == UNMARRIED) {
              // first period of marriage
              estimated.up_down_moments.accumulate(ability_h_eq, husband.HS, husband.ability_h_value);
              estimated.up_down_moments.accumulate(ability_w_eq, wife.WS, wife.ability_w_value);
              estimated.up_down_moments.accumulate(match_w_eq, wife.WS, Q_minus_1);
            }
          }
        }

        if (wife.emp_state == EMP) {
          // wife employed - emp_state is actually current state at this point
          if (decision.M == MARRIED) {
            estimated.wages_m_w.accumulate(wife.WE, school_group, wage_w);  // married women wages if employed
            if (wife.WS < husband.HS) {
              wages_m_w_up.accumulate(wife.WS, wage_w);                   // married up women wages if employed
            } else if (wife.WS > husband.HS) {
              wages_m_w_down.accumulate(wife.WS, wage_w);                 // married down women wages if employed
            } else {
              wages_m_w_eq.accumulate(wife.WS, wage_w);                   // married equal women wages if employed
            }
          } else {
            wages_um_w.accumulate(wife.WS, wage_w);                         // unmarried women wages if employed
          }
        }

        married[t+wife.age_index][school_group] += decision.M;

        // FERTILITY AND MARRIED RATE MOMENTS
        newborn_all.accumulate(t+wife.age_index, wife.WS, new_born);
        if (decision.M == MARRIED) {
          newborn_m.accumulate(t+wife.age_index, wife.WS, new_born);
        } else {
          newborn_um.accumulate(t+wife.age_index, wife.WS, new_born);
        }
        if (wife.AGE == MAX_FERTILITY_AGE - 4) {
          n_kids_arr.accumulate(wife.WS, n_kids); // # of children by school group
          estimated.up_down_moments.accumulate(n_kids_m_arr, wife.WS, n_kids_m);
          estimated.up_down_moments.accumulate(n_kids_um_arr, wife.WS, n_kids_um);
        }

        // marriage transition matrix
        if (decision.M == MARRIED && prev_M == UNMARRIED) {
          if (verbose) {
            std::cout << "decided to get married" << std::endl;
            std::cout << "utility:" << std::endl;
            std::cout << to_string(utility) << std::endl;
            print_husband(husband);
            print_wife(wife);
            std::cout << "kids: " << n_kids << std::endl;
            std::cout << "husband wage:" << wage_h << std::endl;
            std::cout << "wife wage:" << wage_w << std::endl;
          }
          // from single to married
          ++just_married[school_group];
          ++count_just_married[school_group];
          if (first_marriage) {
            age_at_first_marriage.accumulate(wife.WS, wife.AGE);
            ++assortative_mating_count[school_group];
            ++assortative_mating_hist[school_group][husband.HS];
            first_marriage = false;
          } 
          assert(DIVORCE == 0);
        } else if (decision.M == UNMARRIED && prev_M == MARRIED) {
          if (verbose) {
            std::cout << "decided to get divorced" << std::endl;
            std::cout << "utility:" << std::endl;
            std::cout << to_string(utility) << std::endl;
            print_husband(husband);
            print_wife(wife);
            std::cout << "kids: " << n_kids << std::endl;
            std::cout << "husband wage:" << wage_h << std::endl;
            std::cout << "wife wage:" << wage_w << std::endl;
          }
          // from married to divorce
          DIVORCE = 1;
          ++just_divorced[school_group];
          ++count_just_divorced[school_group];
          if (first_divorce) {
            duration_of_first_marriage.accumulate(wife.WS, duration - 1); // duration of marriage if divorce 
            first_divorce = false;
          }
        } else if (decision.M == MARRIED && prev_M == MARRIED) {
          if (verbose) {
            std::cout << "still married" << std::endl;
            std::cout << "utility:" << std::endl;
            std::cout << to_string(utility) << std::endl;
            print_husband(husband);
            print_wife(wife);
            std::cout << "kids: " << n_kids << std::endl;
            std::cout << "husband wage:" << wage_h << std::endl;
            std::cout << "wife wage:" << wage_w << std::endl;
          }
          // still married
          ++count_just_married[school_group];
          assert(DIVORCE == 0);
        } else if (decision.M == UNMARRIED && prev_M == UNMARRIED) {
          // still unmarried 
          if (verbose) std::cout << "still " << (DIVORCE ? "divorced" : "single") << std::endl;
          ++count_just_divorced[school_group];
        }
        divorce[t+wife.age_index][school_group] += DIVORCE;
        ++wife.AGE;
        ++husband.AGE;
      } // close the time loop
    } // close the draw_f loop
  } // close the schooling_group loop

  // calculate employment moments
  for (auto t = 0; t < T_MAX; ++t) {
    estimated.emp_moments[t][0] = t+18;
    auto offset = 1;
    for (auto school_group : SCHOOL_W_VALUES) {
      estimated.emp_moments[t][offset] = mean(emp_total, count_emp_total, t, school_group);
      ++offset;
    }
    for (auto school_group : SCHOOL_W_VALUES) {
      estimated.emp_moments[t][offset] = mean(emp_m, married, t, school_group);
      ++offset;
    }
    for (auto school_group : SCHOOL_W_VALUES) {
      const auto unmarried = DRAW_F - married[t][school_group];
      if (unmarried == 0) {
        estimated.emp_moments[t][offset] = 0.0;
      } else {
        estimated.emp_moments[t][offset] = emp_um[t][school_group]/(double)unmarried;
      }
      ++offset;
    }
  }

  // calculate marriage/fertility moments
  for (auto t = 0; t < T_MAX; ++t) {
    estimated.marr_fer_moments[t][0] = t+18;
    auto offset = 1;
    for (auto school_group : SCHOOL_W_VALUES) {
      estimated.marr_fer_moments[t][offset] = (double)married[t][school_group]/(double)DRAW_F;
      ++offset;
    }
    for (auto school_group : SCHOOL_W_VALUES) {
      estimated.marr_fer_moments[t][offset] = newborn_all.mean(t, school_group);
      ++offset;
    }
    for (auto school_group : SCHOOL_W_VALUES) {
      estimated.marr_fer_moments[t][offset] = (double)divorce[t][school_group]/(double)DRAW_F;
      ++offset;
    }
  }

  // calculate wage moments
  for (auto t = 0; t < T_MAX; ++t) {
    estimated.wage_moments[t][0] = t;
    auto offset = 1;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.wage_moments[t][offset] = wages_w.mean(t, WS); 
      ++offset;
    }
    for (auto HS : SCHOOL_H_VALUES) {
      estimated.wage_moments[t][offset] = wages_m_h.mean(t, HS);
      ++offset;
    }
  }

  // calculate general moments
  { 
    // assortative mating
    auto row = 0;
    for (auto HS : SCHOOL_H_VALUES) {
      const auto count = assortative_mating_count[HS];
      for (auto WS : SCHOOL_W_VALUES) {
        if (count == 0) {
          estimated.general_moments[row][WS-1] = 0.0;
        } else {
          estimated.general_moments[row][WS-1] = assortative_mating_hist[WS][HS]/(double)count;
        }
      }
      ++row;
    }
    // first marriage duration
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = duration_of_first_marriage.mean(WS);
    }
    ++row;
    // age at first marriage
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = age_at_first_marriage.mean(WS);
    }
    ++row;
    // kids
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = n_kids_arr.mean(WS);
    }
    ++row;
    // women wage by match: UP, EQUAL, DOWN 
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = wages_m_w_up.mean(WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = wages_m_w_eq.mean(WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = wages_m_w_down.mean(WS);
    }
    ++row;
    // employment by match: UP, EQUAL, DOWN 
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = emp_m_up.mean(WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = emp_m_eq.mean(WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = emp_m_down.mean(WS);
    }
    ++row;
    // employment by childred: married with 0 - 4+ kids, unmarried with kids, unmarried with no kids
    for (auto kids_n = 0; kids_n < M_KIDS_SIZE; ++kids_n) {
      for (auto WS : SCHOOL_W_VALUES) {
        estimated.general_moments[row][WS-1] = emp_m_kids[kids_n].mean(WS);
      }
      ++row;
    }
    for (auto kids_n = 0; kids_n < UM_KIDS_SIZE; ++kids_n) {
      for (auto WS : SCHOOL_W_VALUES) {
        estimated.general_moments[row][WS-1] = emp_um_kids[kids_n].mean(WS);
      }
      ++row;
    }
    // employment transition matrix: 
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_got_fired_m, count_just_got_fired_m, WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_found_job_m, count_just_found_job_m, WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_got_fired_um, count_just_got_fired_um, WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_found_job_um, count_just_found_job_um, WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_got_fired_mc, count_just_got_fired_mc, WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_found_job_mc, count_just_found_job_mc, WS);
    }
    ++row;
    // marriage transition matrix
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_married, count_just_married, WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = mean(just_divorced, count_just_divorced, WS);
    }
    ++row;
    // birth rate unmarried and married
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = newborn_um.column_mean(WS);
    }
    ++row;
    for (auto WS : SCHOOL_W_VALUES) {
      estimated.general_moments[row][WS-1] = newborn_m.column_mean(WS);
    }
  }

  return estimated;
}

// summarize of MSE of moment, omitting first column (index) and any nan values
template<size_t SIZE>
double mse_nansum(const std::array<double, SIZE>& m) {
  return std::accumulate(m.begin()+1, m.end(), 0.0, [](double sum, double val) {return (isfinite(val) ? sum+val : sum);});
}

// in place normalization of MSE by respective standard variations
template<size_t SIZE>
void mse_normalize(std::array<double, SIZE>& m, const std::array<double, SIZE-1>& m_stdev) {
  std::transform(m.begin()+1, m.end(), m_stdev.begin(),
      m.begin()+1, std::divides<double>());
}

void print_distributions(const BPDist& bp_initial_dist, const BPDist& bp_dist, const CSDist& cs_dist) {
  TextTable table_headline;
  table_headline.add("Ditributions");
  table_headline.endOfRow();

  TextTable table(' ');
  {
    const auto& dist = bp_initial_dist;
    const auto total = std::accumulate(dist.begin(), dist.end(), 0.0);
    table.add("Initial BP Distribution");

    if (total > 0.0) {
      std::for_each(dist.begin(), dist.end(), [&table, total](unsigned val){
          table.add(std::to_string((double)val/total));
          });
    } else {
      table.add("no values");
    }
    table.endOfRow();
  }
  {
    const auto& dist = bp_dist;
    const auto total = std::accumulate(dist.begin(), dist.end(), 0.0);
    table.add("BP Distribution");

    if (total > 0.0) {
      std::for_each(dist.begin(), dist.end(), [&table, total](unsigned val){
          table.add(std::to_string((double)val/total));
          });
    } else {
      table.add("no values");
    }
    table.endOfRow();
  }
  {
    const auto& dist = cs_dist;
    const auto begin = dist.begin();
    const auto end = dist.begin() + CS_SIZE;

    table.add("Unemployed CS Distribution");
    const auto total = std::accumulate(begin, end, 0.0);

    if (total > 0.0) {
      std::for_each(begin, end, [&table, total](unsigned val){
          table.add(std::to_string((double)val/total));
          });
    } else {
      table.add("no values");
    }
    table.endOfRow();
  }
  {
    const auto& dist = cs_dist;
    const auto begin = dist.begin() + CS_SIZE;
    const auto end = dist.end();

    table.add("Employed CS Distribution");
    const auto total = std::accumulate(begin, end, 0.0);

    if (total > 0.0) {
      std::for_each(begin, end, [&table, total](unsigned val){
          table.add(std::to_string((double)val/total));
          });
    } else {
      table.add("no values");
    }
    table.endOfRow();
  }
  std::cout << std::endl << table_headline;
  std::cout << table;
}

double objective_function(const Parameters& p, const Moments& m, const MomentsStdev& m_stdev, 
    bool display_moments, bool no_emax, bool adjust_bp, bool verbose, bool verbose_emax, const std::string& prefix, bool infile, bool outfile) 
{
  auto w_m_emax = make_emax<MarriedEmax>();
  auto h_m_emax = make_emax<MarriedEmax>();
  auto w_s_emax = make_emax<SingleWomenEmax>();
  auto h_s_emax = make_emax<SingleMenEmax>();

  if (!no_emax) {
    const auto t_start = std::chrono::high_resolution_clock::now();
    const auto iter_count = calculate_emax(p, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose_emax);
    const auto t_end = std::chrono::high_resolution_clock::now();
    std::cout << "emax calculation did " << iter_count << " iterations, over " 
      << std::chrono::duration<double, std::milli>(t_end-t_start).count() << " milliseconds" << std::endl;;
    if (outfile) {
      dump_emax(prefix + "_married_women.csv", w_m_emax);
      dump_emax(prefix + "_married_men.csv", h_m_emax);
      dump_emax(prefix + "_single_women.csv", w_s_emax);
      dump_emax(prefix + "_single_men.csv", h_s_emax);
    }
  } else {
    std::cout << "running static model (no emax calculation)" << std::endl;
  }

  const auto estimated_moments = calculate_moments(p, m, w_m_emax, h_m_emax, w_s_emax, h_s_emax, adjust_bp, verbose);    

  if (display_moments) {
    print_up_down_moments(estimated_moments.up_down_moments);
    print_distributions(estimated_moments.bp_initial_dist, estimated_moments.bp_dist, estimated_moments.cs_dist);

    print_wage_moments(estimated_moments.wage_moments, m.wage_moments);
    print_emp_moments(estimated_moments.emp_moments, m.emp_moments);
    print_marr_moments(estimated_moments.marr_fer_moments, m.marr_fer_moments);
    print_gen_moments(estimated_moments.general_moments, m.general_moments);
  }

  // objective function calculation:
  // (1) calculate MSE for each moment that has a time dimension and normalize by its standard deviation
  //     note that the first column of the moments (index) is skipped
  // (2) for general moments, each one is normalize by its standard deviation
  // (3) the value of the objecttive function is the sum of all the values in (1) and (2)

  auto wage_moments_mse = MSE(estimated_moments.wage_moments, m.wage_moments);
  mse_normalize(wage_moments_mse, m_stdev.wage_moments_stdev);

  auto marr_fer_moments_mse = MSE(estimated_moments.marr_fer_moments, m.marr_fer_moments); 
  mse_normalize(marr_fer_moments_mse, m_stdev.marr_fer_moments_stdev);

  auto emp_moments_mse = MSE(estimated_moments.emp_moments, m.emp_moments); 
  mse_normalize(emp_moments_mse, m_stdev.emp_moments_stdev);

  auto general_moments_mse = divide(square_diff(estimated_moments.general_moments, m.general_moments), m_stdev.general_moments_stdev);

  const auto value = mse_nansum(wage_moments_mse) + 
    mse_nansum(marr_fer_moments_mse) + 
    mse_nansum(emp_moments_mse) +
    total_nansum(general_moments_mse);

  return value;
}

