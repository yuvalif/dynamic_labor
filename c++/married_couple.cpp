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

unsigned married_couple(const Parameters& p, int WS, unsigned t, Emax& EMAX_W, Emax& EMAX_H, bool adjust_bp) { 
    unsigned iter_count = 0;

    Wife wife;
    Husband husband;

    if (!update_wife_schooling(WS, t, wife)) {
        return 0;
    }

    for (auto W_EXP_INDEX : EXP_W_VALUES) { 
        // WIFE EXPERENCE - 5 GRID LEVEL
        wife.WE = exp_vector[W_EXP_INDEX];
        for (auto H_EXP_INDEX : EXP_H_VALUES) { 
            // HUSBAND EXPERENCE - 5 GRID LEVEL
            husband.HE = exp_vector[H_EXP_INDEX];
            for (auto kids : KIDS_VALUES) {
                for (auto ability_wi : ABILITY_VALUES) {
                    // wife ability - high, medium, low
                    update_ability(p, ability_wi, wife);
                    for (auto ability_hi : ABILITY_VALUES) {   
                        update_ability(p, ability_hi, husband);
                        for (auto prev : PREV_WORK_VALUES) { 
                            wife.emp_state = prev;
                            for (auto HS : SCHOOL_H_VALUES) {
                                update_husband_schooling(HS, t, husband);
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
                                            wife.WE = 0;
                                            husband.HE = 0;
                                            // HUSBAND WAGE
                                            const auto tmp1 = husband.ability_h_value + p.beta10_h*husband.HE*husband.H_HSD + p.beta11_h*husband.HE*husband.H_HSG + 
                                                p.beta12_h*husband.HE*husband.H_SC + p.beta13_h*husband.HE*husband.H_CG + 
                                                p.beta14_h*husband.HE*husband.H_PC + pow(p.beta20_h*husband.HE*husband.H_HSD,2) + 
                                                pow(p.beta21_h*husband.HE*husband.H_HSG,2) + pow(p.beta22_h*husband.HE*husband.H_SC,2) + 
                                                pow(p.beta23_h*husband.HE*husband.H_CG,2) + pow(p.beta24_h*husband.HE*husband.H_PC,2) +
                                                p.beta30_h*husband.H_HSD + p.beta31_h*husband.H_HSG + p.beta32_h*husband.H_SC + p.beta33_h*husband.H_CG + 
                                                p.beta34_h*husband.H_PC;
                                            const auto tmp2 = epsilon()*p.sigma[0];
                                            const auto wage_h = exp(tmp1 + tmp2);
                                            // JOB OFFER PROBABILITY + WAGE WIFE
                                            const auto PROB_TMP = p.row0_w*wife.emp_state + p.row11_w*wife.HSG + p.row12_w*wife.SC + 
                                                p.row13_w*wife.CG + p.row14_w*wife.PC + p.row2_w*wife.WE;
                                            const auto PROB_W = exp(PROB_TMP)/(1.0+exp(PROB_TMP));
                                            auto wage_w = 0.0;
                                            if (PROB_W > draw_p()) {
                                                const auto tmp1 = wife.ability_w_value + p.beta11_w*wife.WE*wife.HSG + p.beta12_w*wife.WE*wife.SC + 
                                                    p.beta13_w*wife.WE*wife.CG + p.beta14_w*wife.WE*wife.PC +
                                                    pow(p.beta21_w*wife.WE*wife.HSG,2) + pow(p.beta22_w*wife.WE*wife.SC,2) + 
                                                    pow(p.beta23_w*wife.WE*wife.CG,2) + pow(p.beta24_w*wife.WE*wife.PC,2) +
                                                    p.beta31_w*wife.HSG + p.beta32_w*wife.SC + p.beta33_w*wife.CG + p.beta34_w*wife.PC;
                                                const auto tmp2 = epsilon()*p.sigma[1];
                                                wage_w = exp(tmp1 + tmp2);
                                            } 
                                            // calculate husbands and wives utility
                                            const auto CHOOSE_WIFE = 1; 
                                            const auto single_men = false;
                                            const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, kids, wage_h, wage_w, 
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
                                        EMAX_H[t][W_EXP_INDEX][H_EXP_INDEX][kids][prev][ability_wi][ability_hi][MARRIED][HS][WS][Q_INDEX][bpi] = 
                                            ADD_EMAX_H/DRAW_B;
                                        EMAX_W[t][W_EXP_INDEX][H_EXP_INDEX][kids][prev][ability_wi][ability_hi][MARRIED][HS][WS][Q_INDEX][bpi] = 
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

