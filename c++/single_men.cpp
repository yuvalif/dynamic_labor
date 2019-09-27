#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"
#include "emax.h"
#include "random_pools.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include "calculate_wage.h"
#include "calculate_utility.h"
#include "marriage_decision.h"
#include "nash.h"
#include <cstdlib>

unsigned single_men(const Parameters& p, unsigned HS, unsigned t, const Emax& EMAX_W, Emax& EMAX_H) {
    Husband husband;

    if (!update_husband_schooling(HS, t, husband)) {
        return 0;
    }

    unsigned iter_count = 0;

    for (auto h_exp_i : EXP_H_VALUES) { 
        // HUSBAND EXPERENCE - 5 GRID LEVEL
        husband.HE = exp_vector[h_exp_i];
        for (auto ability_hi : ABILITY_VALUES) {   
            // husband ability - high, medium, low
            update_ability(p, ability_hi, husband);
            double ADD_EMAX = 0.0;
            for (auto draw_b = 0U; draw_b < DRAW_B; ++draw_b) {
                // DRAW A WIFE 
                Wife wife;
                // PROBABILITY OF MEETING A POTENTIAL HUSBAND
                const auto P_WIFE = exp(p.p0_h+p.p1_h*(husband.AGE+t)+p.p2_h*pow(husband.AGE+t,2))/(1.0+exp(p.p0_h+p.p1_h*(husband.AGE+t)+p.p2_h*pow(husband.AGE+t,2))); 
                unsigned CHOOSE_WIFE = 0;
                if (h_draw_p() < P_WIFE) {
                    CHOOSE_WIFE = 1;
                    wife = draw_wife(p, t, husband.age_index, HS);
                }
                // HUSBAND WAGE
                const auto wage_h = calculate_wage_h(p, husband, epsilon());
                double wage_w = 0.0;
                // JOB OFFER PROBABILITY + WAGE WIFE
                if  (CHOOSE_WIFE == 1) {
                    wage_w = calculate_wage_w(p, wife, w_draw_p(), epsilon());
                }

                // calculate husbands and wives utility from each option -inf for unavailable
                double BP = 0.5;
                const bool single_men = true; 
                const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, NO_KIDS, wage_h, wage_w, CHOOSE_WIFE, 
                        UNMARRIED, wife, husband, t, BP, single_men);
                // MAXIMIZATION - MARRIAGE + WORK DESICION 
                if (CHOOSE_WIFE == 1) {
                    BP = nash(p, utility, BP); // Nash bargaining at first period of marriage  
                }
                // at this point the BP IS .5 IF NO MARRIAGE AND NO OFFER, 
                // is calculated by nash if offer and is from previous period if already married 

                if (CHOOSE_WIFE == 1 && BP != -1.0) {
                    // marriage decision - outside option value wife
                    const auto decision = marriage_decision(utility, BP, wife, husband);
                    if (decision.M == MARRIED) {
                        ADD_EMAX += utility.U_H[decision.max_weighted_utility_index];
                    } else {
                        ADD_EMAX += decision.outside_option_h_v;
                    }
                } else {
                    ADD_EMAX = ADD_EMAX + utility.U_H_S;
                }
            }
            EMAX_H[t][1][h_exp_i][1][1][1][ability_hi][UNMARRIED][HS][1][1][1] = ADD_EMAX/(double)DRAW_B;
            ++iter_count;
        }
    }
    return iter_count;
}

