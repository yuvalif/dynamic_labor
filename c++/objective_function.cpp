#include <chrono>
#include <iostream>
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
    SchoolingMatrix emp_choice_w = {{{0}}};
    SchoolingMatrix count_emp_choice_w{{{0}}};
    SchoolingMatrix emp_m{{{0}}};         // employment married
    SchoolingMatrix emp_um{{{0}}};        // employment unmarried
    SchoolingMatrix emp_m_up{{{0}}};      // employment unmarried up
    SchoolingMatrix emp_m_down{{{0}}};    // employment unmarried down
    SchoolingMatrix emp_m_eq{{{0}}};      // employment unmarried equal
    SchoolingMatrix emp_m_up_below{{{0}}};
    SchoolingMatrix emp_m_down_below{{{0}}};
    SchoolingMatrix emp_m_down_above{{{0}}};
    SchoolingMatrix emp_m_eq_below{{{0}}};
    SchoolingMatrix emp_m_up_above{{{0}}};
    SchoolingMatrix emp_m_eq_above{{{0}}};
    SchoolingMatrix count_emp_m_up{{{0}}};
    SchoolingMatrix count_emp_m_down{{{0}}};
    SchoolingMatrix count_emp_m_eq{{{0}}};
    SchoolingMatrix count_emp_m_up_below{{{0}}};
    SchoolingMatrix count_emp_m_down_below{{{0}}};
    SchoolingMatrix count_emp_m_eq_below{{{0}}};
    SchoolingMatrix count_emp_m_up_above{{{0}}};
    SchoolingMatrix count_emp_m_down_above{{{0}}};
    SchoolingMatrix count_emp_m_eq_above{{{0}}};
    SchoolingMatrix emp_m_no_kids{{{0}}};      // employment married no kids
    SchoolingMatrix emp_m_one_kid{{{0}}};      // employment married 1 kid
    SchoolingMatrix emp_m_2_kids{{{0}}};       // employment married 2 kids
    SchoolingMatrix emp_m_3_kids{{{0}}};       // employment married 2 kids
    SchoolingMatrix emp_m_4plus_kids{{{0}}};   // employment married 4 kids
    SchoolingMatrix count_emp_m_no_kids{{{0}}};
    SchoolingMatrix count_emp_m_one_kid{{{0}}};
    SchoolingMatrix count_emp_m_2_kids{{{0}}};
    SchoolingMatrix count_emp_m_3_kids{{{0}}};
    SchoolingMatrix count_emp_m_4plus_kids{{{0}}};
    SchoolingMatrix emp_um_no_kids{{{0}}}; // employment unmarried and no children
    SchoolingMatrix emp_um_kids{{{0}}};    // employment unmarried and children
    SchoolingMatrix divorce{{{0}}};
    SchoolingMatrix count_emp_um_no_kids{{{0}}};
    SchoolingMatrix count_emp_um_kids{{{0}}};
    SchoolingMatrix just_found_job_m{{{0}}};    // for transition matrix - unemployment to employment 
    SchoolingMatrix just_got_fired_m{{{0}}};    // transition matrix - employment to unemployment
    SchoolingMatrix just_found_job_um{{{0}}};   // for transition matrix - unemployment to employment 
    SchoolingMatrix just_got_fired_um{{{0}}};   // for transition matrix - employment to unemployment
    SchoolingMatrix just_found_job_mc{{{0}}};   // for transition matrix - unemployment to employment 
    SchoolingMatrix just_got_fired_mc{{{0}}};   // for transition matrix - employment to unemployment
    SchoolingMatrix count_just_got_fired_m{{{0}}};
    SchoolingMatrix count_just_found_job_m{{{0}}};
    SchoolingMatrix count_just_got_fired_um{{{0}}};
    SchoolingMatrix count_just_found_job_um{{{0}}};
    SchoolingMatrix count_just_got_fired_mc{{{0}}};
    SchoolingMatrix count_just_found_job_mc{{{0}}};
    // wages moments
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_h;
    // married men wages - 0 until 20+27 years of exp - 36-47 will be ignore in moments  
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_w;          // women wages if employed
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_w;        // married women wages if employed
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_h_up;     // married up men wages 
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_h_down;   // married down men wages 
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_h_eq;     // married equal men wages 
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_w_up;     // married up women wages if employed
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_w_down;   // married down women wages if employed
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_m_w_eq;     // married equal women wages if employed
    MeanMatrix<T_MAX, SCHOOL_LEN> wages_um_w;       // unmarried women wages if employed
    SchoolingMatrix married{{{0}}}; // fertilty and marriage rate moments   % married yes/no
    SchoolingMatrix just_married{{{0}}}; // for transition matrix from single to married
    SchoolingArray age_at_first_marriage{0}; // age at first marriage
    SchoolingArray count_age_at_first_marriage{0};
    SchoolingMatrix just_divorced{{{0}}};   // for transition matrix from married to divorce
    SchoolingMatrix newborn_um{{{0}}};      // new born in period t - for probability and distribution
    SchoolingMatrix newborn_m{{{0}}};       // new born in period t - for probability and distribution
    SchoolingArray duration_of_first_marriage{0}; // duration of marriage if divorce or 45-age of marriage if still married at 45.
    SchoolingArray count_dur_of_first_marriage{0};
    SchoolingArray assortative_mating_count{0};   // HUSBAND EDUCATION BY WIFE EDUCATION
    UMatrix<SCHOOL_LEN, SCHOOL_LEN> assortative_mating_hist{{{0}}};
    SchoolingMatrix count_just_married{{{0}}};
    SchoolingMatrix count_just_divorced{{{0}}};
    SchoolingMatrix count_newborn_um{{{0}}};
    SchoolingMatrix count_newborn_m{{{0}}};
    SchoolingArray kids{0};       // # of children by school group
    SchoolingArray count_kids{0}; // # of children by school group
    SchoolingArray kids_m{0};     // married women # of children by school group
    SchoolingArray kids_um{0};    // % married women # of children by school group

    // school_group 0 is only for calculating the emax if single men - not used here
    for (auto school_group : SCHOOL_W_VALUES) {
        for (auto draw_f = 0U; draw_f < DRAW_F; ++draw_f) {
            const unsigned IGNORE_T = 0;
            Husband husband;
            Wife wife;
            update_wife_schooling(school_group, IGNORE_T, wife);
            wife.emp_state = (draw_f > DRAW_F*UNEMP_WOMEN_RATIO) ? 1 : 0;

            unsigned count_age1 = 0; // the age of the oldest child under6
            unsigned count_age2 = 0; // the age of the 2nd oldest child under6
            unsigned count_age3 = 0; // the age of the 3rd oldest child under6
            unsigned count_age4 = 0; // the age of the 4th oldest child under6
            unsigned count_age5 = 0; // the age of the 5th oldest child under6
            // FIXME year_married not used?
            unsigned DIVORCE = 0;
            // FIXME should we use the newborn indicator insie or outside of the loop?
            //unsigned NEW_BORN = 0;
            unsigned N_KIDS = 0;
            unsigned N_KIDS_M = 0;
            unsigned N_KIDS_UM = 0;
            unsigned duration = 0;
            // FIXME duration_minus_1 is not used?
            // unsigned duration_minus_1 = 0;
            double Q_minus_1 = 0.0;
            double BP = INITIAL_BP;
            // FIXME similar_educ is not used?
            // unsigned similar_educ = 0;
            auto ability_wi = draw_3();
            auto ability_w = normal_arr[ability_wi]*p.sigma[3];
            unsigned ability_h = 0;
            std::array<unsigned, CS_SIZE> BP_INITIAL_DISTRIBUTION;
            std::array<unsigned, CS_SIZE> BP_DISTRIBUTION;
            std::array<unsigned, UTILITY_SIZE> CS_DISTRIBUTION;

            MarriageEmpDecision decision;
            // make choices for all periods
            for (auto t = 0U; t < wife.T_END; ++t) {
                const auto prev_emp_state_w = wife.emp_state;
                const auto prev_M = decision.M;
                // FIXME duration_minus_1 is not used?
                unsigned NEW_BORN = 0;

                bool choose_husband = false;
                // draw husband if not already married
                if (decision.M == UNMARRIED) {
                    BP = INITIAL_BP;
                    duration = 0;
                    wife.Q = 0.0;
                    // FIXME similar_educ is not used?
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
                    const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, N_KIDS, wage_h, wage_w,
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
                    const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, N_KIDS, wage_h, wage_w,
                        true /*choose partner*/, decision.M, wife, husband, t, BP, false /*not single men*/);
                    decision = marriage_emp_decision(utility, BP, wife, husband);
                } else {
                    const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, N_KIDS, wage_h, wage_w,
                        false /*no partner*/, decision.M, wife, husband, t, BP, false /*not single men*/);
                    wife.emp_state = wife_emp_decision(utility);
                }

                emp_choice_w[t+wife.age_index][school_group] += wife.emp_state;
                emp_m[t+wife.age_index][school_group] += decision.M == MARRIED ? wife.emp_state : 0;
                emp_um[t+wife.age_index][school_group] += decision.M == UNMARRIED ? wife.emp_state : 0;
                ++count_emp_choice_w[t+wife.age_index][school_group];

                if (BP != NO_BP) {
                    // TODO this is happening in initial case as well
                    const auto BP_INDEX = round(BP*10)+1;
                    ++BP_DISTRIBUTION[BP_INDEX];
                }
                if (decision.M == 1) {
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
                    p.c8*wife.PC*(wife.AGE+t) + p.c9*wife.PC*pow(wife.AGE+t,2) + p.c10*N_KIDS + p.c11*husband.HS*decision.M + p.c12*decision.M;
                const auto child_prob = boost::math::cdf(normal_dist, c_lamda);
                // FIXME: use array for count_ageN
                if (draw_p() < child_prob && wife.AGE+t < 40)  { 
                    NEW_BORN = 1;
                    if (N_KIDS < 3) {
                        ++N_KIDS;
                    }
                    if (decision.M == 1) {
                        ++N_KIDS_M;
                    } else {
                        ++N_KIDS_UM;
                    }

                    if (N_KIDS == 1) {
                        count_age1 = 1;
                    } else if (N_KIDS == 2) {   
                        count_age2 = 1;
                    } else if (N_KIDS == 3) {
                        count_age3 = 1;
                    } else if (N_KIDS == 4) {
                        count_age4 = 1;
                    } else if (N_KIDS == 5) {
                        count_age5 = 1;   
                    }
                } else if (N_KIDS > 0) {
                    // no new born, but kids at house so update ages
                    if (count_age1 == 18) {
                        //no new born, just update ages - kids above 18 leaves the household
                        count_age1=count_age2;
                        count_age2=count_age3;
                        count_age3=count_age4;
                        count_age4=count_age5;
                        count_age5=0;
                        --N_KIDS;
                    }         
                    ++count_age1;
                    if (count_age2 > 0) {
                        ++count_age2;
                    }
                    if (count_age3 > 0) {
                        ++count_age3;
                    }
                    if (count_age4 > 0) {
                        ++count_age4;
                    }
                    if (count_age5 > 0) {
                        ++count_age5;
                    }
                }

                //  UPDARE T+1 STATE SPACE - match quality 
                if (decision.M == 1) {
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
                if (decision.M == 1) {
                    // MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
                    if (N_KIDS == 0) {
                        emp_m_no_kids[t+age_index][school_group] += wife.emp_state; // employment married no kids
                        ++count_emp_m_no_kids[t+age_index][school_group];
                    } else if (N_KIDS == 1) {
                        emp_m_one_kid[t+age_index][school_group] += wife.emp_state; // employment married 1 kid
                        ++count_emp_m_one_kid[t+age_index][school_group];
                    } else if (N_KIDS == 2) {
                        emp_m_2_kids[t+age_index][school_group] += wife.emp_state; //employment married 2 kid
                        ++count_emp_m_2_kids[t+age_index][school_group];
                    } else if (N_KIDS == 3) {
                        emp_m_3_kids[t+age_index][school_group] += wife.emp_state; // employment married 3 kid
                        ++count_emp_m_3_kids[t+age_index][school_group];
                    } else {
                        emp_m_4plus_kids[t+age_index][school_group] += wife.emp_state; // employment married 4 kids
                        ++count_emp_m_4plus_kids[t+age_index][school_group];
                    }
                } else { 
                    // UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
                    if (N_KIDS == 0) {
                        emp_um_no_kids[t+age_index][school_group] += wife.emp_state; // un/employment unmarried and no children
                        ++count_emp_um_no_kids[t+age_index][school_group];
                    } else {
                        emp_um_kids[t+age_index][school_group] += wife.emp_state; // un/employment unmarried and children
                        ++count_emp_um_kids[t+age_index][school_group];
                    } 
                }
                // EMPLOYMENT TRANSITION MATRIX
                // FIXME: reorder if statements to decrease lines of code
                if (wife.emp_state == EMP && prev_emp_state_w == UNEMP) {
                    // for transition matrix - unemployment to employment
                    if (decision.M ==1) {
                        ++just_found_job_m[t+age_index][school_group];
                        ++count_just_found_job_m[t+age_index][school_group];
                        if (N_KIDS >0) {
                            ++just_found_job_mc[t+age_index][school_group];
                            ++count_just_found_job_mc[t+age_index][school_group];
                        }	
                    } else {
                        ++just_found_job_um[t+age_index][school_group];
                        ++count_just_found_job_um[t+age_index][school_group];
                    }	
                } else if (wife.emp_state == UNEMP && prev_emp_state_w == EMP) {
                    // for transition matrix - employment to unemployment
                    if (decision.M == 1) {
                        ++just_got_fired_m[t+age_index][school_group]; 
                        if (N_KIDS > 0) {
                            ++just_got_fired_mc[t+age_index][school_group];
                        }
                    } else {
                        ++just_got_fired_um[t+age_index][school_group];
                    }
                } else if (wife.emp_state == UNEMP && prev_emp_state_w == UNEMP) {
                    // no change employment
                    if (decision.M == 1) {
                        ++count_just_found_job_m[t+age_index][school_group];
                        if (N_KIDS > 0) {
                            ++count_just_found_job_mc[t+age_index][school_group];
                        }	
                    } else {
                        ++count_just_found_job_um[t+age_index][school_group];
                    }	
                } else if (wife.emp_state == EMP && prev_emp_state_w == EMP) {
                    // no change unemployment
                    if (decision.M == 1) {
                        ++count_just_got_fired_m[t+age_index][school_group];
                        if (N_KIDS > 0) {
                            ++count_just_got_fired_mc[t+age_index][school_group];
                        }
                    } else {
                        ++count_just_got_fired_um[t+age_index][school_group];
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
                    if (school_group > husband.HS) { 
                        // women married down, men married up
                        emp_m_down[t+age_index][school_group] += wife.emp_state;
                        ++count_emp_m_down[t+age_index][school_group];
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
                    } else if (school_group < husband.HS) {
                        // women married up, men married down
                        emp_m_up[t+age_index][school_group] += wife.emp_state;
                        ++count_emp_m_up[t+age_index][school_group];
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
                        emp_m_eq[t+age_index][school_group] += wife.emp_state; //employment married equal women
                        ++count_emp_m_eq[t+age_index][school_group];

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
                    if (decision.M == 1) {
                        wages_m_w.accumulate(wife.WE, school_group, wage_w);          // married women wages if employed
                        if (school_group < husband.HS) {
                            wages_m_w_up.accumulate(wife.WE, school_group, wage_w);   // married up women wages if employed
                        } else if (school_group > husband.HS) {
                            wages_m_w_down.accumulate(wife.WE, school_group, wage_w); // married down women wages if employed
                        } else {
                            wages_m_w_eq.accumulate(wife.WE, school_group, wage_w);   // married equal women wages if employed
                        }
                    } else {
                        wages_um_w.accumulate(wife.WE, school_group, wage_w); //unmarried women wages if employed
                    }
                }

                married[t+age_index][school_group] += decision.M;

                // FERTILITY AND MARRIED RATE MOMENTS
                if (decision.M ==1) {
                    newborn_m[t+age_index][school_group] += NEW_BORN;
                    ++count_newborn_m[t+age_index][school_group];
                } else {
                    newborn_um[t+age_index][school_group] = NEW_BORN;
                    ++count_newborn_um[t+age_index][school_group];
                }
                if (t == wife.T_END) {
                    kids[school_group] += N_KIDS; // # of children by school group
                    kids_m[school_group] += N_KIDS_M;
                    kids_um[school_group] += N_KIDS_UM;
                    ++count_kids[school_group];
                }
                if (decision.M == MARRIED && prev_M == UNMARRIED) {
                    // for transition matrix from single to married
                    ++just_married[t+age_index][school_group];
                    ++count_just_married[t+age_index][school_group];
                    if (age_at_first_marriage[school_group] == 0) {
                        age_at_first_marriage[school_group] += wife.AGE+t;
                        ++count_age_at_first_marriage[school_group];
                        ++assortative_mating_count[school_group];
                        ++assortative_mating_hist[school_group][husband.HS];
                    } 
                } else if (decision.M == MARRIED && prev_M == MARRIED) {
                    // for transition matrix from married to divorce
                    DIVORCE = 1;
                    ++just_divorced[t+age_index][school_group];
                    ++count_just_divorced[t+age_index][school_group];
                    if (duration_of_first_marriage[school_group] == 0) {
                        duration_of_first_marriage[school_group] += (duration - 1); // duration of marriage if divorce 
                        ++count_dur_of_first_marriage[school_group];
                    }
                } else if (decision.M == MARRIED && prev_M == UNMARRIED) {
                    // still single
                    ++count_just_married[t+age_index][school_group];
                } else if (decision.M == MARRIED && prev_M == MARRIED) {
                    // still married
                    ++count_just_divorced[t+age_index][school_group];
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
            estimated.emp_moments[t][offset] = mean(emp_choice_w, count_emp_choice_w, t, school_group);
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
            estimated.marr_fer_moments[t][offset] = mean(newborn_m, count_newborn_m, t, school_group);
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
        for (auto school_group = 1; school_group < SCHOOL_LEN; ++school_group) {
            estimated.wage_moments[t][school_group] = wages_w.mean(t, school_group); 
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.wage_moments[t][school_group+SCHOOL_LEN] = wages_m_h.mean(t, school_group);
        }
    }

    // calculate general moments
    { 
        // assortative mating
        auto offset = 0;
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            for (auto HS = 0; HS < SCHOOL_LEN; ++HS) {
                const auto count = assortative_mating_count[school_group];
                if (count == 0) {
                    estimated.general_moments[0][school_group+offset] = 0.0;
                } else {
                    estimated.general_moments[0][school_group+offset] = assortative_mating_hist[school_group][HS]/(double)count;
                }
                ++offset;
            }
        }
        // first marriage duration
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(duration_of_first_marriage, count_dur_of_first_marriage, school_group);
            ++offset;
        }
        // age at first marriage
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(age_at_first_marriage, count_age_at_first_marriage, school_group);
            ++offset;
        }
        // kids
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(kids, count_kids, school_group);
            ++offset;
        }
        // women wage by match: UP, EQUAL, DOWN 
        // FIXME what about t?
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = wages_m_w_up.mean(0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = wages_m_w_eq.mean(0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = wages_m_w_down.mean(0, school_group);
            ++offset;
        }
        // employment by match: UP, EQUAL, DOWN 
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_up, count_emp_m_up, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_eq, count_emp_m_eq, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_down, count_emp_m_down, 0, school_group);
            ++offset;
        }
        // employment by childred: NO KIDS, 1 KIDS, 2 KIDS, 3 KIDS, 4 KIDS, unmarried with kids, unmarried with NO KIDS
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_no_kids, count_emp_m_no_kids, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_one_kid, count_emp_m_one_kid, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_2_kids, count_emp_m_2_kids, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_3_kids, count_emp_m_3_kids, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_m_4plus_kids, count_emp_m_4plus_kids, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_um_kids, count_emp_um_kids, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(emp_um_no_kids, count_emp_um_no_kids, 0, school_group);
            ++offset;
        }
        // employment transition matrix: E to E married, UE to E married, E to E unmarried, UE to E unmarried, E to E married+children, UE to E married+children
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_got_fired_m, count_just_got_fired_m, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_found_job_m, count_just_found_job_m, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_got_fired_um, count_just_got_fired_um, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_found_job_um, count_just_found_job_um, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_got_fired_mc, count_just_got_fired_mc, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_found_job_mc, count_just_found_job_mc, 0, school_group);
            ++offset;
        }
        // marriage transition matrix
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_married, count_just_married, 0, school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(just_divorced, count_just_divorced, 0, school_group);
            ++offset;
        }
        // birth rate unmarried and married
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(newborn_um, count_newborn_um, 0 ,school_group);
            ++offset;
        }
        for (auto school_group = 0; school_group < SCHOOL_LEN; ++school_group) {
            estimated.general_moments[0][school_group+offset] = mean(newborn_m, count_newborn_m, 0, school_group);
            ++offset;
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
    //const auto general_moments_diff = square_diff(estimated_moments.general_moments, m.general_moments);
    // weight the difference by last row of actual moment
    // FIXME use t_MAX?
    const auto wage_moments_weighted_diff = divide_by_square(wage_moments_diff, m.wage_moments[T_MAX-1]);
    const auto marr_fer_moments_weighted_diff = divide(marr_fer_moments_diff, m.marr_fer_moments[T_MAX-1]); 
    const auto emp_moments_weighted_diff = divide(emp_moments_diff, m.emp_moments[T_MAX-1]); 
    // FIXME how to do general moments?
    
    const auto value = total_sum(wage_moments_weighted_diff) + total_sum(marr_fer_moments_weighted_diff) + total_sum(emp_moments_weighted_diff);

    return value;
}

/*
   emp_sd = nansum((emp_moments(1:28,2:13) - emp_moments_fitted_matrix).^2);
   disp('	WOMEN EMPLOYMENT ACTUAL 		   	     WOMEN EMPLOYMENT FITTED  ');
   temp = [emp_moments(1:28,2:5)  emp_moments_fitted_matrix(:,1:4)]
   disp('	MARRIED WOMEN EMPLOYMENT ACTUAL  	 	 MARRIED WOMEN EMPLOYMENT FITTED  ');
   temp = [emp_moments(1:28,6:9)  emp_moments_fitted_matrix(:,5:8)]
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   marr_fer_sd = nansum((marr_fer_moments(1:28,2:13) - marr_fer_moments_fitted_matrix).^2);
   disp('	MARRIAGE RATE ACTUAL  		   	   MARRIAGE RATE FITTED  ');
   temp = [marr_fer_moments(1:28,2:5)  marr_fer_moments_fitted_matrix(:,1:4)]
   disp('	FERTILITY RATE ACTUAL 		 	   FERTILITY RATE FITTED  ');
   temp = [marr_fer_moments(1:28,6:9)  marr_fer_moments_fitted_matrix(:,5:8)]
   disp('	DIVORCE RATE ACTUAL  		 	   DIVORCE RATE FITTED  ');
   temp = [marr_fer_moments(1:28,10:13)  marr_fer_moments_fitted_matrix(:,9:12)]
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

format short g;
disp('		WOMEN WAGE ACTUAL 				WOMEN WAGE FITTED ')
%disp('		HSG ACTUAL HSG FITTED SC ACTUAL SC FITTED CG ACTUAL CG FITTED PC ACTUAL PC FITTED ')
temp = [wage_moments(1:28,2:5)  f_wages_w(:,1:4)]% wage_moments(1:28,3)  f_wages_w(:,2) wage_moments(1:28,4)  f_wages_w(:,3) wage_moments(1:28,5)  f_wages_w(:,4) ]
%disp('		HSD ACTUAL HSD FITTED HSG ACTUAL HSG FITTED SC ACTUAL SC FITTED CG ACTUAL CG FITTED PC ACTUAL PC FITTED ')
disp('		MEN WAGE ACTUAL 				MEN WAGE FITTED ')
temp = [wage_moments(1:36,6:10)  f_wages_m_h(1:36,1:5)]% wage_moments(1:36,7)  f_wages_m_h(1:36,2) wage_moments(1:36,8)  f_wages_m_h(1:36,3) wage_moments(1:36,9)  f_wages_m_h(1:36,4) wage_moments(1:36,10)  f_wages_m_h(1:36,5) ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
general_sd = (general_moments(1:31,:) - general_moments_fitted).^2;
format short g;
disp('  ******   GENERAL MOMENTS     *******')
disp('	HSG ACTUAL HSG FITTED SC ACTUAL SC FITTED CG ACTUAL CG FITTED PC ACTUAL PC FITTED ');
disp('  ******   Assortative mating     *******')
temp = [general_moments(1:5,1:4) general_moments_fitted(1:5,1:4)]% general_moments(1:5,2) general_moments_fitted(1:5,2) general_moments(1:5,3) general_moments_fitted(1:5,3) general_moments(1:5,4) general_moments_fitted(1:5,4)]
disp('  ******   marriage_duration  age at first marriage    total # of kids by 40     *******')
temp = [general_moments(6:8,1:4) general_moments_fitted(6:8,1:4)]% general_moments(6:8,2) general_moments_fitted(6:8,2) general_moments(6:8,3) general_moments_fitted(6:8,3) general_moments(6:8,4) general_moments_fitted(6:8,4)]
disp('  ******   women wage by match  UP women wage by match   EQUAL women wage by match   DOWN      *******')
temp = [general_moments(9:11,1:4) general_moments_fitted(9:11,1:4)]% general_moments(9:11,2) general_moments_fitted(9:11,2) general_moments(9:11,3) general_moments_fitted(9:11,3) general_moments(9:11,4) general_moments_fitted(9:11,4)]
disp('  ******   employment by match   UP  employment by match   EQUAL  Employment by match   DOWN      *******')
temp = [general_moments(12:14,1:4) general_moments_fitted(12:14,1:4)]% general_moments(12:14,2) general_moments_fitted(12:14,2) general_moments(12:14,3) general_moments_fitted(12:14,3) general_moments(12:14,4) general_moments_fitted(12:14,4)]
disp('  ******   Emp by children for married - NO KIDS, 1 KIDS,2 KIDS,3 KIDS,4 KIDS,unmarried+KIDS,unmarried - NO KIDS      *******')
temp = [general_moments(15:21,1:4) general_moments_fitted(15:21,1:4)]% general_moments(15:21,2) general_moments_fitted(15:21,2) general_moments(15:21,3) general_moments_fitted(15:21,3) general_moments(15:21,4) general_moments_fitted(15:21,4)]
disp('  ******   emp to unemp   M, unemp to emp   M, emp to unemp   UM, unemp to emp   UM, emp to unemp - M+, unemp to emp - M+      ********')
temp = [general_moments(22:27,1:4) general_moments_fitted(22:27,1:4)]% general_moments(22:27,2) general_moments_fitted(22:27,2) general_moments(22:27,3) general_moments_fitted(22:27,3) general_moments(22:27,4) general_moments_fitted(22:27,4)]
disp('  ******   marriage to divorce, divorce to marriage, mean birth rate for unmarried, mean birth rate for married      ********')
temp = [general_moments(28:31,1:4) general_moments_fitted(28:31,1:4)]% general_moments(28:31,2) general_moments_fitted(28:31,2) general_moments(28:31,3) general_moments_fitted(28:31,3) general_moments(28:31,4) general_moments_fitted(28:31,4)]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           CLOSE MOMENTS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    objective_function = 0

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    ESTIMATION PROCESS - SGMM
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 5 moments matrixes: emp_sd(1, 1:12) marr_fer_sd(1, 1:12)  w_wage_sd(1, 1:4) h_wage_sd(1, 1:5) general_sd(1:31,1:4)
    w_wage_sd = w_wage_sd./(wage_moments(37,2:5).^2);
    h_wage_sd = h_wage_sd./(wage_moments(37,6:10).^2);
    general_sd = general_sd./general_moments(32:62,:);
    general_sd(21,4) = 0;
    general_sd(9:11,:)=general_sd(9:11,:)./general_moments(40:42,:);
    general_temp = nansum(general_sd);
objective_function=nansum(emp_sd)+nansum(marr_fer_sd)+nansum(w_wage_sd)+nansum(h_wage_sd)+nansum(general_temp)
    end
    */

