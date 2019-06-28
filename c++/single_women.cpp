#include "parameters.h"
#include "const_parameters.h"
#include "emax.h"
#include "random_pools.h"
#include "draw_husband.h"
#include "draw_wife.h"
#include "calculate_wage.h"
#include "calculate_utility.h"
#include "nash.h"
#include "marriage_decision.h"

unsigned single_women(const Parameters& p, unsigned WS, unsigned t, Emax& EMAX_W, const Emax& EMAX_H) { 
    unsigned iter_count = 0;

    const unsigned N_KIDS_H = 0;

    Wife wife;

    if (!update_wife_schooling(WS, t, wife)) {
        return 0;
    }

    for (auto W_EXP_INDEX = 1; W_EXP_INDEX <= exp_w_len; ++W_EXP_INDEX) { 
        // WIFE EXPERENCE - 5 GRID LEVEL
        wife.WE = exp_vector[W_EXP_INDEX];
        for (auto ability_wi = 1; ability_wi < ability_w; ++ability_wi) {
            // wife ability - high, medium, low
            wife.ability_w_value = normal_arr[ability_wi]*p.sigma[4];
            double ADD_EMAX = 0;
            for (auto N_KIDS_IND = 1;  N_KIDS_IND <= kids; ++N_KIDS_IND) {
                const auto N_KIDS = N_KIDS_IND-1;
                for (auto prev = 1; prev <= 2; ++prev) { 
                    wife.prev_state_w = prev - 1;
                    for (auto draw_b = 1; draw_b <=  DRAW_B; ++draw_b) {
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
                        if (h_draw_p() < P_HUSBAND) {
                            CHOOSE_HUSBAND = 1;
                            // TODO: check that school_group is WS
                            husband = draw_husband(p, t, wife.age_index, WS, WS);
                        }
                        if (CHOOSE_HUSBAND == 1) {
                            wage_h = calculate_wage_h(p, husband, epsilon());
                        }
                        // JOB OFFER PROBABILITY + WAGE WIFE
                        wage_w =  calculate_wage_w(p, wife, w_draw_p(), epsilon());
                        // MAXIMIZATION - MARRIAGE + WORK DESICION

                        const unsigned JOB_OFFER_H = (wage_h > 0) ? 1 : 0;
                        const unsigned JOB_OFFER_W = (wage_w > 0) ? 1 : 0;

                        // calculate husbands and wives utility from each option -inf for unavailable
                        // at this point the BP IS .5 
                        // IF NO MARRIAGE AND NO OFFER, BP is calculated by nash 
                        // if offer and is from previous period if already married
                        double BP = 0.5;
                        const auto M = 1; const auto single_men = 0;
                        const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, N_KIDS, N_KIDS_H, wage_h, wage_w, CHOOSE_HUSBAND,
                                JOB_OFFER_H, JOB_OFFER_W, M, wife, HS, t, husband.ability_hi, husband.HE, BP, wife.T_END, single_men, wife.age_index);
                        //   MAXIMIZATION - MARRIAGE + WORK DESICION 
                        if (CHOOSE_HUSBAND == 1) {
                            BP = nash(p, utility, BP); // Nash bargaining at first period of marriage  
                        }

                        if (CHOOSE_HUSBAND == 1 && BP > -1) {
                            // marriage decision - outside option value wife
                            const MarriageDecision decision = marriage_decision(utility, BP, wife.WE, husband.HE);

                            if (decision.M == 1) {
                                ADD_EMAX = ADD_EMAX + utility.U_W[decision.max_weighted_utility_index];
                            } else {
                                ADD_EMAX = ADD_EMAX + decision.outside_option_w_v;
                            }
                        } else {
                            ADD_EMAX = ADD_EMAX + utility.U_H_S;
                        }
                        ++iter_count;
                    }   // end draw backward loop
                    EMAX_W[t][W_EXP_INDEX][1][N_KIDS_IND][prev][ability_wi][1][UNMARRIED][1][WS][1][1] = ADD_EMAX/DRAW_B;
                } // end prev_state_w        
            } // end of kids loop
        } // end single wemen ability loop
    } // end single women experience loop

    return iter_count;
}

