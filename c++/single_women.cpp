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

unsigned single_women(const Parameters& p, unsigned WS, unsigned t, Emax& EMAX_W, const Emax& EMAX_H) { 
    unsigned iter_count = 0;

    Wife wife;

    if (!update_wife_schooling(WS, t, wife)) {
        return 0;
    }

    for (auto w_exp_i : EXP_W_VALUES) { 
        wife.WE = exp_vector[w_exp_i];
        for (auto ability_wi : ABILITY_VALUES) {
            update_ability(p, ability_wi, wife);
            double ADD_EMAX = 0;
            for (auto kids : KIDS_VALUES) {
                for (auto prev : PREV_WORK_VALUES) { 
                    wife.emp_state = prev - 1;
                    for (auto draw_b = 0U; draw_b <  DRAW_B; ++draw_b) {
                        // DRAW A HUSBAND 
                        const auto HS = 1; 
                        // in forward solving school_group represents wife's education
                        // here it represents the education of the individual we calculate the EMAX for
                        double wage_h = 0; double wage_w = 0;
                        unsigned CHOOSE_HUSBAND = 0;
                        //1-wife; 
                        //2-wife EXP+SCHOOLING; 
                        //3-wife ABILITY; 
                        //4-INITIAL MATCH QUALITY; 
                        //5-JOB OFFER FOR MARRIED MEN AND WOMEN EMAX; 
                        //6-JOB OFFER FOR SINGLE MEN EMAX 
                        const auto P_HUSBAND = exp(p.p0_w+p.p1_w*(wife.AGE+t)+p.p2_w*pow(wife.AGE+t,2))/
                            (1.0+exp(p.p0_w+p.p1_w*(wife.AGE+t)+p.p2_w*pow(wife.AGE+t,2)));
                        Husband husband;
                        // PROBABILITY OF MEETING A POTENTIAL HUSBAND
                        if (draw_p() < P_HUSBAND) {
                            CHOOSE_HUSBAND = 1;
                            husband = draw_husband(p, t, wife.age_index, WS, WS);
                        }
                        update_husband_schooling(HS, t, husband);
                        if (CHOOSE_HUSBAND == 1) {
                            wage_h = calculate_wage_h(p, husband, epsilon());
                        }
                        // JOB OFFER PROBABILITY + WAGE WIFE
                        wage_w =  calculate_wage_w(p, wife, draw_p(), epsilon());
                        // MAXIMIZATION - MARRIAGE + WORK DESICION

                        // calculate husbands and wives utility from each option -inf for unavailable
                        // at this point the BP IS .5 
                        // IF NO MARRIAGE AND NO OFFER, BP is calculated by nash 
                        // if offer and is from previous period if already married
                        double bp = NO_BP;
                        const auto M = MARRIED; 
                        const auto single_men = false;
                        const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, kids, wage_h, wage_w, CHOOSE_HUSBAND,
                                M, wife, husband, t, bp, single_men);
                        //   MAXIMIZATION - MARRIAGE + WORK DESICION 
                        if (CHOOSE_HUSBAND == 1) {
                            bp = nash(p, utility); // Nash bargaining at first period of marriage  
                        }

                        if (bp == NO_BP) {
                            // marriage decision - outside option value wife
                            const auto decision = marriage_emp_decision(utility, bp, wife, husband, true);

                            if (decision.M == MARRIED) {
                                ADD_EMAX = ADD_EMAX + utility.U_W[decision.max_weighted_utility_index];
                            } else {
                                ADD_EMAX = ADD_EMAX + decision.outside_option_w_v;
                            }
                        } else {
                            ADD_EMAX = ADD_EMAX + utility.U_H_S;
                        }
                        ++iter_count;
                    }   // end draw backward loop
                    EMAX_W[t][w_exp_i][1][kids][prev][ability_wi][1][UNMARRIED][1][WS][1][1] = ADD_EMAX/(double)DRAW_B;
                } // end emp_state        
            } // end of kids loop
        } // end single wemen ability loop
    } // end single women experience loop

    return iter_count;
}

