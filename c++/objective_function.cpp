#include <chrono>
#include <iostream>
#include <algorithm>
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

unsigned calculate_emax(const Parameters& p, Emax& EMAX_W, Emax& EMAX_H) {
    unsigned iter_count = 0;
    // running until the one before last period
    for (auto t = T_MAX - 2; t >= 0; --t) {
        // EMAX FOR SINGLE MEN
        for (auto HS : SCHOOL_H_VALUES) {
            iter_count += single_men(p, HS, t, EMAX_W, EMAX_H);
        } // end husband schooling loop

        // EMAX FOR SINGLE WOMEN
        for (auto WS : SCHOOL_W_VALUES) {
            iter_count += single_women(p, WS, t, EMAX_W, EMAX_H);
        } // end wife schooling loop

        // EMAX FOR MARRIED COUPLE
        for (auto WS : SCHOOL_W_VALUES) {
            iter_count += married_couple(p, WS, t, EMAX_W, EMAX_H);
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

EstimatedMoments calculate_moments(const Parameters& p, const Moments& m, const Emax& EMAX_W, const Emax& EMAX_H) {
    EstimatedMoments estimated;
    boost::math::normal normal_dist;
    SchoolingMatrix emp_total = {{{0}}};    // employment
    SchoolingMatrix count_emp_total{{{0}}};
    SchoolingMatrix emp_m{{{0}}};           // employment married
    SchoolingMatrix emp_um{{{0}}};          // employment unmarried
    SchoolingMeanArray emp_m_up;            // employment unmarried up
    SchoolingMeanArray emp_m_down;          // employment unmarried down
    SchoolingMeanArray emp_m_eq;            // employment unmarried equal
    static const auto M_KIDS_SIZE = 5; // no kids, 1 kis, 2 kids, 3 kids 4+kids
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
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_h;
    // married men wages - 0 until 20+27 years of exp - 36-47 will be ignore in moments  
    SchoolingMeanMatrix wages_w;        // women wages if employed
    SchoolingMeanArray wages_m_w_up;    // married up women wages if employed
    SchoolingMeanArray wages_m_w_down;  // married down women wages if employed
    SchoolingMeanArray wages_m_w_eq;    // married equal women wages if employed
    SchoolingMeanArray wages_um_w;      // unmarried women wages if employed
    SchoolingMatrix married{{{0}}};     // fertilty and marriage rate moments   % married yes/no
    SchoolingArray just_married{{0}};   // for transition matrix from single to married
    SchoolingArray just_divorced{{0}};  // for transition matrix from married to divorce
    SchoolingMeanArray age_at_first_marriage; // age at first marriage
    SchoolingMeanMatrix newborn_um;      // new born in period t - for probability and distribution
    SchoolingMeanMatrix newborn_m;       // new born in period t - for probability and distribution
    SchoolingMeanArray duration_of_first_marriage; // duration of marriage if divorce or 45-age of marriage if still married at 45.
    // husband education by wife education
    UMatrix<SCHOOL_LEN, SCHOOL_LEN> assortative_mating_hist{{{0}}};
    SchoolingArray assortative_mating_count{0};
    SchoolingArray count_just_married{{0}};
    SchoolingArray count_just_divorced{{0}};
    SchoolingMeanArray n_kids_arr;    // # of children by school group
    // FIXME: following 2 are set but not used
    SchoolingMeanArray n_kids_m_arr;   // # of children by school group for married women
    SchoolingMeanArray n_kids_um_arr;  // # of children by school group for unmarried women

    // counter factuals
    SchoolingMatrix emp_m_up_below{{{0}}};
    SchoolingMatrix emp_m_down_below{{{0}}};
    SchoolingMatrix emp_m_down_above{{{0}}};
    SchoolingMatrix emp_m_eq_below{{{0}}};
    SchoolingMatrix emp_m_up_above{{{0}}};
    SchoolingMatrix emp_m_eq_above{{{0}}};
    SchoolingMatrix count_emp_m_up_below{{{0}}};
    SchoolingMatrix count_emp_m_down_below{{{0}}};
    SchoolingMatrix count_emp_m_eq_below{{{0}}};
    SchoolingMatrix count_emp_m_up_above{{{0}}};
    SchoolingMatrix count_emp_m_down_above{{{0}}};
    SchoolingMatrix count_emp_m_eq_above{{{0}}};
    SchoolingMeanMatrix wages_m_w;      // married women wages if employed
    SchoolingMeanMatrix wages_m_h_up;   // married up men wages 
    SchoolingMeanMatrix wages_m_h_down; // married down men wages 
    SchoolingMeanMatrix wages_m_h_eq;   // married equal men wages 

    // school_group 0 is only for calculating the emax if single men - not used here
    for (auto school_group : SCHOOL_W_VALUES) {
        for (auto draw_f = 0U; draw_f < DRAW_F; ++draw_f) {
            const unsigned IGNORE_T = 0;
            Husband husband;
            Wife wife;
            update_wife_schooling(school_group, IGNORE_T, wife);
            wife.emp_state = (draw_f > DRAW_F*UNEMP_WOMEN_RATIO) ? 1 : 0;

            // FIXME: kids age is updated but not used
            // kid age array maximum number of kids = 4
            // 0 - oldest kid ... 3 - youngest kid
            const auto MAX_NUM_KIDS = 4;
            std::array<unsigned, MAX_NUM_KIDS> kid_age{0};
            // FIXME year_married not used?
            unsigned DIVORCE = 0;
            auto n_kids = 0;
            auto n_kids_m = 0;
            auto n_kids_um = 0;
            unsigned duration = 0;
            double Q_minus_1 = 0.0;
            double BP = INITIAL_BP;
            auto ability_wi = draw_3();
            auto ability_w = normal_arr[ability_wi]*p.sigma[3];
            unsigned ability_h = 0;
            
            // FIXME: followint 3 are updated but not used
            std::array<unsigned, CS_SIZE> BP_INITIAL_DISTRIBUTION;
            std::array<unsigned, CS_SIZE> BP_DISTRIBUTION;
            std::array<unsigned, UTILITY_SIZE> CS_DISTRIBUTION;

            MarriageEmpDecision decision;

            // following 2 indicators are used to count age at first marriage
            // and marriage duration only once per draw
            auto first_marriage = true;
            auto first_divorce = true;

            // make choices for all periods
            const auto last_t = wife.T_END;
            for (auto t = 0U; t <= last_t; ++t) {
                const auto prev_emp_state_w = wife.emp_state;
                const auto prev_M = decision.M;
                unsigned new_born = 0;

                bool choose_husband = false;
                // draw husband if not already married
                if (decision.M == UNMARRIED) {
                    BP = INITIAL_BP;
                    duration = 0;
                    wife.Q = 0.0;
                    // probability of meeting a potential husband
                    const auto choose_hudband_p = exp(p.p0_w+p.p1_w*(wife.AGE+t)+p.p2_w*pow(wife.AGE+t,2))/
                        (1.0+exp(p.p0_w+p.p1_w*(wife.AGE+t)+p.p2_w*pow(wife.AGE+t,2)));
                    if (draw_p() < choose_hudband_p) {
                        choose_husband = true;
                        husband = draw_husband(p, t, wife.age_index, wife.WS, wife.WS);
                        const auto dont_skip = update_husband_schooling(husband.HS, IGNORE_T, husband);
                        assert(dont_skip);
                    }
                }

                // potential or current husband wage
                const auto wage_h = (decision.M == MARRIED || choose_husband) ? calculate_wage_h(p, husband, epsilon()) : 0.0;
                const auto wage_w = calculate_wage_w(p, wife, draw_p(), epsilon());

                if (decision.M == UNMARRIED && choose_husband) {
                    // not married, but has potential husband - calculate initial BP
                    BP = INITIAL_BP;
                    const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, n_kids, wage_h, wage_w,
                            true /*choose partner*/, decision.M, wife, husband, t, BP, false /*not single men*/);
                    BP = nash(p, utility, BP); // Nash bargaining at first period of marriage  
                    if (BP != NO_BP) {
                        const int BP_INDEX = round(BP*10.0)+1;
                        ++BP_INITIAL_DISTRIBUTION[BP_INDEX];
                    } else {
                        choose_husband = false;
                    }
                }

                if (decision.M == MARRIED || choose_husband) {
                    // at this point the BP is 0.5 if there is no marriage offer
                    // BP is calculated by nash above if offer given
                    // and is from previous period if already married           
                    // utility is calculated again based on the new BP
                    const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, n_kids, wage_h, wage_w,
                        true /*choose partner*/, decision.M, wife, husband, t, BP, false /*not single men*/);
                    decision = marriage_emp_decision(utility, BP, wife, husband);
                } else {
                    const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, n_kids, wage_h, wage_w,
                        false /*no partner*/, decision.M, wife, husband, t, BP, false /*not single men*/);
                    wife.emp_state = wife_emp_decision(utility);
                }

                emp_total[t+wife.age_index][school_group] += wife.emp_state;
                emp_m[t+wife.age_index][school_group] += decision.M == MARRIED ? wife.emp_state : 0;
                emp_um[t+wife.age_index][school_group] += decision.M == UNMARRIED ? wife.emp_state : 0;
                ++count_emp_total[t+wife.age_index][school_group];

                if (BP != NO_BP) {
                    // TODO this is happening in initial case as well
                    const auto BP_INDEX = round(BP*10)+1;
                    ++BP_DISTRIBUTION[BP_INDEX];
                }
                if (decision.M == MARRIED) {
                    ++CS_DISTRIBUTION[decision.max_weighted_utility_index];
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
                const auto c_lamda = p.c1*wife.emp_state + p.c2*wife.HSG*(wife.AGE+t) + p.c3*wife.HSG*pow(wife.AGE+t,2) + 
                    p.c4*wife.SC*(wife.AGE+t) + p.c5*wife.SC*pow(wife.AGE+t,2) + p.c6*wife.CG*(wife.AGE+t) + p.c7*wife.CG*pow(wife.AGE+t,2) + 
                    p.c8*wife.PC*(wife.AGE+t) + p.c9*wife.PC*pow(wife.AGE+t,2) + p.c10*n_kids + p.c11*husband.HS*decision.M + p.c12*decision.M;
                const auto child_prob = boost::math::cdf(normal_dist, c_lamda);
                // FIXME: use array for count_ageN
                if (draw_p() < child_prob && wife.AGE+t < 40)  { 
                    new_born = 1;
                    n_kids = std::min(n_kids+1, MAX_NUM_KIDS);
                    if (decision.M == MARRIED) {
                        n_kids_m = std::min(n_kids_m+1, MAX_NUM_KIDS);
                    } else {
                        n_kids_um = std::min(n_kids_um+1, MAX_NUM_KIDS);
                    }
                    // set the age for the youngets kid
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
                        kid_age[sizeof(kid_age)-1] = 0;
                        --n_kids;
                        assert(n_kids>=0);
                    }         
                    for (auto order = 0; order < MAX_NUM_KIDS; ++order) {
                        if (kid_age[order] > 0) {
                            ++kid_age[order];
                        }
                    }
                }

                //  UPDARE T+1 STATE SPACE - match quality 
                if (decision.M == MARRIED) {
                    // update the match quality
                    DIVORCE = 0;
                    ++duration;
                    Q_minus_1 = wife.Q;
                    const auto MATCH_QUALITY_CHANGE_PROBABIITY = draw_p();
                    if (MATCH_QUALITY_CHANGE_PROBABIITY < p.MATCH_Q_DECREASE && wife.Q_INDEX > 0) {
                        --wife.Q_INDEX;
                        wife.Q = normal_arr[wife.Q_INDEX]*p.sigma[4];
                    } else if (MATCH_QUALITY_CHANGE_PROBABIITY > p.MATCH_Q_DECREASE && 
                            MATCH_QUALITY_CHANGE_PROBABIITY < p.MATCH_Q_DECREASE + p.MATCH_Q_INCREASE && wife.Q_INDEX < 2) {
                        ++wife.Q_INDEX;
                        wife.Q = normal_arr[wife.Q_INDEX]*p.sigma[4];
                    }
                }

                // FIXME: create an array by number of kids
                const auto age_index = wife.age_index;
                if (decision.M == MARRIED) {
                    // MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
                    emp_m_kids[n_kids].accumulate(wife.WS, wife.emp_state); // employment married no kids
                } else { 
                    // UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
                    emp_um_kids[n_kids == 0 ? 0 : 1].accumulate(wife.WS, wife.emp_state); // un/employment unmarried and no children
                }
                // EMPLOYMENT TRANSITION MATRIX
                // FIXME: reorder if statements to decrease lines of code
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

                // FIXME: reorder if statement to make code shorter
                if (decision.M == MARRIED) {
                    assert(wage_h > 0.0); // husband always works
                    wages_m_h.accumulate(husband.HE, husband.HS, wage_h); // husband always works
                    if (wife.WS > husband.HS) { 
                        // women married down, men married up
                        emp_m_down.accumulate(wife.WS, wife.emp_state);
                        if (husband.HE < 37  && wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS]) {
                            emp_m_down_above[t+age_index][school_group] += wife.emp_state;
                            ++count_emp_m_down_above[t+age_index][school_group];
                        } else {	
                            emp_m_down_below[t+age_index][school_group] += wife.emp_state;
                            ++count_emp_m_down_below[t+age_index][school_group];
                        }
                        wages_m_h_up.accumulate(husband.HE, husband.HS, wage_h); // married up men wages 
                        if (prev_M == UNMARRIED) {
                            // first period of marriage
                            estimated.ability_h_up.accumulate(t+age_index, husband.HS, ability_h);
                            estimated.match_w_down.accumulate(t+age_index, school_group, Q_minus_1);
                        }
                    } else if (wife.WS < husband.HS) {
                        // women married up, men married down
                        emp_m_up.accumulate(wife.WS, wife.emp_state);
                        if (husband.HE < 37 && wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS]) {
                            emp_m_up_above[t+age_index][school_group] += wife.emp_state;
                            ++count_emp_m_up_above[t+age_index][school_group];
                        } else {
                            emp_m_up_below[t+age_index][school_group] += wife.emp_state;
                            ++count_emp_m_up_below[t+age_index][school_group];
                        }
                        wages_m_h_down.accumulate(husband.HE, husband.HS, wage_h); // married down men wages
                        if (prev_M == UNMARRIED) {
                            // first period of marriage
                            estimated.ability_h_down.accumulate(t+age_index, husband.HS, ability_h);
                            estimated.ability_w_up.accumulate(t+age_index, school_group, ability_w);
                            estimated.match_w_up.accumulate(t+age_index, school_group, Q_minus_1);
                        }
                    } else {
                        // married equal
                        wages_m_h_eq.accumulate(husband.HE, husband.HS, wage_h); // married equal men wages 
                        emp_m_eq.accumulate(wife.WS, wife.emp_state); //employment married equal women

                        if (husband.HE < 37 && wage_h > m.wage_moments[husband.HE][SCHOOL_LEN+husband.HS+husband.HS]) {
                            emp_m_eq_above[t+age_index][school_group] += wife.emp_state;
                            ++count_emp_m_eq_above[t+age_index][school_group];
                        } else {
                            emp_m_eq_below[t+age_index][school_group] += wife.emp_state;
                            ++count_emp_m_eq_below[t+age_index][school_group];
                        }
                        if (prev_M == UNMARRIED) {
                            // first period of marriage
                            estimated.ability_h_eq.accumulate(t+age_index, husband.HS, ability_h);
                            estimated.ability_w_eq.accumulate(t+age_index, school_group, ability_w);
                            estimated.match_w_eq.accumulate(t+age_index, school_group, Q_minus_1);
                        }
                    }
                }

                if (wife.emp_state == EMP) {
                    // wife employed - emp_state is actually current state at this point
                    if (decision.M == MARRIED) {
                        wages_m_w.accumulate(wife.WE, school_group, wage_w);    // married women wages if employed
                        if (wife.WS < husband.HS) {
                            wages_m_w_up.accumulate(wife.WS, wage_w);           // married up women wages if employed
                        } else if (wife.WS > husband.HS) {
                            wages_m_w_down.accumulate(wife.WS, wage_w);         // married down women wages if employed
                        } else {
                            wages_m_w_eq.accumulate(wife.WS, wage_w);           // married equal women wages if employed
                        }
                    } else {
                        wages_um_w.accumulate(wife.WS, wage_w);                 // unmarried women wages if employed
                    }
                }

                married[t+age_index][school_group] += decision.M;

                // FERTILITY AND MARRIED RATE MOMENTS
                if (decision.M == MARRIED) {
                    newborn_m.accumulate(t+age_index, wife.WS, new_born);
                } else {
                    newborn_um.accumulate(t+age_index, wife.WS, new_born);
                }
                if (t == last_t) {
                    n_kids_arr.accumulate(wife.WS, n_kids); // # of children by school group
                    n_kids_m_arr.accumulate(wife.WS, n_kids_m);
                    n_kids_um_arr.accumulate(wife.WS, n_kids_um);
                }
                // marriage transition matrix
                if (decision.M == MARRIED && prev_M == UNMARRIED) {
                    // from single to married
                    ++just_married[school_group];
                    ++count_just_married[school_group];
                    if (first_marriage) {
                        age_at_first_marriage.accumulate(wife.WS, wife.AGE+t);
                        ++assortative_mating_count[school_group];
                        ++assortative_mating_hist[school_group][husband.HS];
                        first_marriage = false;
                    } 
                } else if (decision.M == UNMARRIED && prev_M == MARRIED) {
                    // from married to divorce
                    DIVORCE = 1;
                    ++just_divorced[school_group];
                    ++count_just_divorced[school_group];
                    if (first_divorce) {
                        duration_of_first_marriage.accumulate(wife.WS, duration - 1); // duration of marriage if divorce 
                        first_divorce = false;
                    }
                } else if (decision.M == MARRIED && prev_M == MARRIED) {
                    // still married
                    ++count_just_married[school_group];
                } else if (decision.M == UNMARRIED && prev_M == UNMARRIED) {
                    // still unmarried 
                    ++count_just_divorced[school_group];
                }
                divorce[t+age_index][school_group] += DIVORCE;
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
            estimated.marr_fer_moments[t][offset] = married[t][school_group]/(double)DRAW_F;
            ++offset;
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            estimated.marr_fer_moments[t][offset] = newborn_m.mean(t, school_group);
            ++offset;
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            estimated.marr_fer_moments[t][offset] = divorce[t][school_group]/(double)DRAW_F;
            ++offset;
        }
    }

    // calculate wage moments
    for (auto t = 0; t < T_MAX; ++t) {
        estimated.wage_moments[t][0] = t; // FIXME experience?
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
        // TODO: check why all zeros for first HS
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
        // TODO: check why no divorce
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
        // TODO: check why no divorce
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

double objective_function(const Parameters& p, const Moments& m, bool display_moments, bool no_emax) {
    auto EMAX_W = make_emax();
    auto EMAX_H = make_emax();

    if (!no_emax) {
        const auto t_start = std::chrono::high_resolution_clock::now();
        const auto iter_count = calculate_emax(p, EMAX_W, EMAX_H);
        const auto t_end = std::chrono::high_resolution_clock::now();
        std::cout << "emax calculation did " << iter_count << " iterations, over " 
            << std::chrono::duration<double, std::milli>(t_end-t_start).count() << " milliseconds" << std::endl;;
    } else {
        std::cout << "running static model (no emax calculation)" << std::endl;
    }

    const auto estimated_moments = calculate_moments(p, m, EMAX_W, EMAX_H);    

    if (display_moments) {
        print_mean_table("Ability Husband Up", estimated_moments.ability_h_up);
        print_mean_table("Ability Husband Equal", estimated_moments.ability_h_eq);
        print_mean_table("Ability Husband Down", estimated_moments.ability_h_down);
        print_mean_table("Ability Wife Up", estimated_moments.ability_w_up);
        print_mean_table("Ability Wife Equal", estimated_moments.ability_w_eq);
        print_mean_table("Ability Wife  Down", estimated_moments.ability_w_down);
        print_mean_table("Match Quality Up", estimated_moments.match_w_up);
        print_mean_table("Match Quality Equal", estimated_moments.match_w_eq);
        print_mean_table("Match Quality Down", estimated_moments.match_w_down);
        print_wage_moments(estimated_moments.wage_moments, true);
        print_wage_moments(m.wage_moments, false);
        print_emp_moments(estimated_moments.emp_moments, true);
        print_emp_moments(m.emp_moments, false);
        print_marr_moments(estimated_moments.marr_fer_moments, true);
        print_marr_moments(m.marr_fer_moments, false);
        print_gen_moments(estimated_moments.general_moments, true);
        print_gen_moments(m.general_moments, false);
    }

    // objective function calculation
    // calculate square difference between actual and estimated moments
    const auto wage_moments_diff = square_diff(estimated_moments.wage_moments, m.wage_moments); 
    // FIXME why splitting wage_sd to: w_wage_sd and wage_sd
    const auto marr_fer_moments_diff = square_diff(estimated_moments.marr_fer_moments, m.marr_fer_moments); 
    const auto emp_moments_diff = square_diff(estimated_moments.emp_moments, m.emp_moments); 
    // FIXME what to do with general_moments_diff?
    // const auto general_moments_diff = square_diff(estimated_moments.general_moments, m.general_moments);
    // weight the difference by last row of actual moment
    // FIXME use T_MAX?
    const auto wage_moments_weighted_diff = divide_by_square(wage_moments_diff, m.wage_moments[T_MAX-1]);
    const auto marr_fer_moments_weighted_diff = divide(marr_fer_moments_diff, m.marr_fer_moments[T_MAX-1]); 
    const auto emp_moments_weighted_diff = divide(emp_moments_diff, m.emp_moments[T_MAX-1]); 
    // FIXME how to do weighted general moments
    
    const auto value = total_sum(wage_moments_weighted_diff) + total_sum(marr_fer_moments_weighted_diff) + total_sum(emp_moments_weighted_diff);

    return value;
}

/*
 * %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           MOMENTS NOT FOR ESTIMATION - JUST FOR COUNTER FACTUALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3 moments: employment by match - UP   %employment by match - EQUAL    %employment by match - DOWN - ABOVE AND BELOW HUSBAND AVERAGE WAGE
f_emp_m_up_above = [sum(emp_m_up_above(:,:,2)); sum(emp_m_up_above(:,:,3)); sum(emp_m_up_above(:,:,4)); sum(emp_m_up_above(:,:,5))]';         % employment married up
f_emp_m_up_above = f_emp_m_up_above./count_emp_m_up_above(:,2:5);
ff_emp_m_up_above = nanmean(f_emp_m_up_above)
    f_emp_m_up_below = [sum(emp_m_up_below(:,:,2)); sum(emp_m_up_below(:,:,3)); sum(emp_m_up_below(:,:,4)); sum(emp_m_up_below(:,:,5))]';         % employment married up
    f_emp_m_up_below = f_emp_m_up_below./count_emp_m_up_below(:,2:5);
ff_emp_m_up_below = nanmean(f_emp_m_up_below)

    f_emp_m_eq_above = [sum(emp_m_eq_above(:,:,2)); sum(emp_m_eq_above(:,:,3)); sum(emp_m_eq_above(:,:,4)); sum(emp_m_eq_above(:,:,5))]'  ;       % employment married equal
    f_emp_m_eq_above = f_emp_m_eq_above./count_emp_m_eq_above(:,2:5);
ff_emp_m_eq_above = nanmean(f_emp_m_eq_above)
    f_emp_m_eq_below = [sum(emp_m_eq_below(:,:,2)); sum(emp_m_eq_below(:,:,3)); sum(emp_m_eq_below(:,:,4)); sum(emp_m_eq_below(:,:,5))]'  ;       % employment married equal
    f_emp_m_eq_below = f_emp_m_eq_below./count_emp_m_eq_below(:,2:5);
ff_emp_m_eq_below = nanmean(f_emp_m_eq_below)

    f_emp_m_down_above = [sum(emp_m_down_above(:,:,2)); sum(emp_m_down_above(:,:,3)); sum(emp_m_down_above(:,:,4)); sum(emp_m_down_above(:,:,5))]';           % employment married down
    f_emp_m_down_above = f_emp_m_down_above./count_emp_m_down_above(:,2:5);
ff_emp_m_down_above = nanmean(f_emp_m_down_above)
    f_emp_m_down_below = [sum(emp_m_down_below(:,:,2)); sum(emp_m_down_below(:,:,3)); sum(emp_m_down_below(:,:,4)); sum(emp_m_down_below(:,:,5))]';           % employment married down
    f_emp_m_down_below = f_emp_m_down_below./count_emp_m_down_below(:,2:5);
ff_emp_m_down_below = nanmean(f_emp_m_down_below)
*/
