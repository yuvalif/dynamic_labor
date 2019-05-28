#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"
#include "emax.h"
#include "random_pools.h"
#include "draw_wife.h"
#include "calculate_wage.h"
#include "calculate_utility.h"
#include "marriage_decision.h"
#include "nash.h"
#include <cstdlib>

unsigned single_men(const Parameters& p, unsigned HS, unsigned t, Emax& EMAX_W, Emax& EMAX_H, unsigned TERMINAL) {

    const unsigned W = 1;
    const unsigned H = 0;

    unsigned H_HSD = 0; unsigned H_HSG = 0; unsigned H_SC = 0; unsigned H_CG = 0; unsigned H_PC = 0; 
    unsigned T_END; unsigned AGE;
    unsigned age_index;

    if (HS == 1) {
        H_HSD = 1; AGE = 18;
        T_END = TERMINAL - AGE+1; // TERMINAL = 45, T=28
        age_index = 0;
    } else if (HS == 2) {
        H_HSG = 1; AGE = 18;
        T_END = TERMINAL - AGE+1; // TERMINAL = 45, T=28
        age_index = 0;
    } else if (HS == 3) {
        H_SC = 1; AGE = 20;
        T_END = TERMINAL - AGE+1; // TERMINAL = 45, T=26
        age_index = 2;
        if (t > T_END) {
            return 0;
        }
    } else if (HS == 4) {
        H_CG = 1; AGE = 22;
        T_END = TERMINAL - AGE+1; // TERMINAL = 45, T=24
        age_index = 4;
        if (t > T_END) {
            return 0;
        }
    } else {
        H_PC = 1; AGE = 25;
        T_END = TERMINAL - AGE+1; // TERMINAL = 45, T=21
        age_index = 7;
        if (t > T_END) {
            return 0;
        }
    }

    unsigned iter_count = 0;

    for (auto H_EXP_INDEX = 1; H_EXP_INDEX <= exp_h_len; ++H_EXP_INDEX) { 
        // HUSBAND EXPERENCE - 5 GRID LEVEL
        for (auto ability_hi = 1; ability_hi < ability_h; ++ability_hi) {   
            // husband ability - high, medium, low
            const auto ability_h_value = normal_arr[ability_hi]*p.sigma[4];
            double ADD_EMAX = 0.0;
            for (auto draw_b = 1; draw_b <= DRAW_B; ++draw_b) {
                // DRAW A WIFE 
                Wife wife;
                unsigned M = 0; unsigned N_KIDS = 0; unsigned N_KIDS_H = 0;
                const auto HE = exp_vector[H_EXP_INDEX];
                // PROBABILITY OF MEETING A POTENTIAL HUSBAND
                const auto P_WIFE = exp(p.p0_h+p.p1_h*(AGE+t)+p.p2_h*pow(AGE+t,2))/(1.0+exp(p.p0_h+p.p1_h*(AGE+t)+p.p2_h*pow(AGE+t,2))); 
                unsigned CHOOSE_WIFE = 0;
                if (h_draw_p() < P_WIFE) {
                    CHOOSE_WIFE = 1;
                    wife = draw_wife(p, t, age_index, HS);
                }
                // HUSBAND WAGE
                const auto wage_h = calculate_wage_h(p, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, ability_h_value, epsilon());
                double wage_w = 0.0;
                // JOB OFFER PROBABILITY + WAGE WIFE
                if  (CHOOSE_WIFE == 1) {
                    wage_w = calculate_wage_w(p, wife, w_draw_p(), epsilon());
                }

                const unsigned JOB_OFFER_H = (wage_h > 0) ? 1 : 0;
                const unsigned JOB_OFFER_W = (wage_w > 0) ? 1 : 0;

                // calculate husbands and wives utility from each option -inf for unavailable
                
        
                double BP = 0.5;
                const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, N_KIDS, N_KIDS_H, wage_h, wage_w, CHOOSE_WIFE, 
                        JOB_OFFER_H, JOB_OFFER_W, M, wife, HS, t, ability_hi, HE, BP, T_END, 1, age_index);
                //   MAXIMIZATION - MARRIAGE + WORK DESICION 
                if (CHOOSE_WIFE == 1) {
                    BP = nash(p, utility, BP); // Nash bargaining at first period of marriage  
                }
                // at this point the BP IS .5 IF NO MARRIAGE AND NO OFFER, 
                // is calculated by nash if offer and is from previous period if already married 

                if (CHOOSE_WIFE == 1 && BP > -1.0) {
                    // marriage decision - outside option value wife
                    // TODO take WE from wife or from decision ?
                    // take HE from decision?
                    const MarriageDecision decision = marriage_decision(utility, BP, wife.WE, HE);
                    if (decision.M == 1) {
                        ADD_EMAX += utility.U_H[decision.max_weighted_utility_index];
                    } else {
                        ADD_EMAX += utility.U_H_S;
                    }
                } else {
                    ADD_EMAX = ADD_EMAX + utility.U_H_S;
                }
            }
            EMAX_H[t][1][H_EXP_INDEX][1][1][1][ability_hi][UNMARRIED][HS][1][1][1] = ADD_EMAX/DRAW_B;
            ++iter_count;
        }
    }
    return iter_count;
}

