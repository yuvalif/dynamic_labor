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

unsigned married_couple(const Parameters& p, unsigned WS, unsigned t, Emax& EMAX_W, Emax& EMAX_H) { 
    unsigned iter_count = 0;

    unsigned U_W = 0; unsigned U_H = 0; unsigned N_KIDS_H = 0;
    unsigned AGE;
    unsigned T_END;
    unsigned age_index;
    unsigned MARRIED = 1;
    Wife wife;
    Husband husband;

    if (!update_wife_schooling(WS, t, wife)) {
        return 0;
    }

    for (auto W_EXP_INDEX = 1; W_EXP_INDEX <= exp_w_len; ++W_EXP_INDEX) { 
        // WIFE EXPERENCE - 5 GRID LEVEL
        wife.WE = exp_vector[W_EXP_INDEX];
        for (auto H_EXP_INDEX = 1; H_EXP_INDEX <= exp_h_len; ++H_EXP_INDEX) { 
            // HUSBAND EXPERENCE - 5 GRID LEVEL
            husband.HE = exp_vector[H_EXP_INDEX];
            for (auto N_KIDS_IND = 1;  N_KIDS_IND <= kids; ++N_KIDS_IND) {
                const auto N_KIDS = N_KIDS_IND-1;
                for (auto ability_wi = 1; ability_wi < ability_w; ++ability_wi) {
                    // wife ability - high, medium, low
                    wife.ability_w_value = normal_arr[ability_wi]*p.sigma[4];
                    for (auto ability_hi = 1; ability_hi < ability_h; ++ability_hi) {   
                        // husband ability - high, medium, low
                        husband.ability_h_value = normal_arr[ability_hi]*p.sigma[4];
                        for (auto prev = 1; prev <= 2; ++prev) { 
                            wife.prev_state_w = prev - 1;
                            for (auto HS = 1; HS <= school_h; ++HS) { // 5 levels 

                                if (HS == 1) husband.H_HSD = 1;
                                else if (HS == 2) husband.H_HSG = 1;
                                else if (HS == 3) husband.H_SC = 1;
                                else if (HS == 4) husband.H_CG = 1;
                                else husband.H_PC = 1;

                                if (HS == WS) {
                                    wife.similar_educ = p.EDUC_MATCH[WS];
                                }

                                for (auto Q_INDEX = 1; Q_INDEX <= match; ++Q_INDEX) { //3 level
                                    auto Q = normal_arr[Q_INDEX]*p.sigma[5];
                                    for (auto BPi = 1; BPi <= BP_W; ++BPi) { // 7 levels
                                        auto BP = 0.1 + BPi/10.0;  // the grid is 0.2 - 0.8
                                        auto ADD_EMAX_W = 0.0;
                                        auto ADD_EMAX_H = 0.0;
                                        for (auto draw_b = 1; draw_b <=  DRAW_B; ++draw_b) {
                                            // HUSBAND WAGE
                                            const auto JOB_OFFER_H = 1;
                                            const auto tmp1 = ability_h + p.beta10_h*(husband.HE*husband.H_HSD) + p.beta11_h*(husband.HE*husband.H_HSG) + 
                                                p.beta12_h*(husband.HE*husband.H_SC) + p.beta13_h*(husband.HE*husband.H_CG) + 
                                                p.beta14_h*(husband.HE*husband.H_PC) + pow(p.beta20_h*(husband.HE*husband.H_HSD),2) + 
                                                pow(p.beta21_h*(husband.HE*husband.H_HSG),2) + pow(p.beta22_h*(husband.HE*husband.H_SC),2) + 
                                                pow(p.beta23_h*(husband.HE*husband.H_CG),2) + pow(p.beta24_h*(husband.HE*husband.H_PC),2) +
                                                p.beta30_h*husband.H_HSD + p.beta31_h*husband.H_HSG + p.beta32_h*husband.H_SC + p.beta33_h*husband.H_CG + 
                                                p.beta34_h*husband.H_PC;
                                            const auto tmp2 = epsilon()*p.sigma[1];
                                            const auto wage_h = exp(tmp1 + tmp2);
                                            // JOB OFFER PROBABILITY + WAGE WIFE
                                            const auto PROB_TMP = p.row0_w*wife.prev_state_w + p.row11_w*wife.HSG + p.row12_w*wife.SC + 
                                                p.row13_w*wife.CG + p.row14_w*wife.PC + p.row2_w*wife.WE;
                                            const auto PROB_W = exp(PROB_TMP)/(1.0+exp(PROB_TMP));
                                            auto JOB_OFFER_W = 1;
                                            auto wage_w = 0.0;
                                            if (PROB_W > w_draw_p()) {
                                                const auto tmp1 = ability_w + p.beta11_w*(wife.WE*wife.HSG) + p.beta12_w*(wife.WE*wife.SC) + 
                                                    p.beta13_w*(wife.WE*wife.CG) + p.beta14_w*(wife.WE*wife.PC) +
                                                    pow(p.beta21_w*(wife.WE*wife.HSG),2) + pow(p.beta22_w*(wife.WE*wife.SC),2) + 
                                                    pow(p.beta23_w*(wife.WE*wife.CG),2) + pow(p.beta24_w*(wife.WE*wife.PC),2) +
                                                    p.beta31_w*wife.HSG + p.beta32_w*wife.SC + p.beta33_w*wife.CG + p.beta34_w*wife.PC;
                                                const auto tmp2 = epsilon()*p.sigma[2];
                                                wage_w = exp(tmp1 + tmp2);
                                            } 
                                            // calculate husbands and wives utility
                                            const auto CHOOSE_WIFE = 1; const auto M = 1; const auto single_men = 0;
                                            const Utility utility = calculate_utility(p, EMAX_W, EMAX_H, N_KIDS, N_KIDS_H, wage_h, wage_w, 
                                                    CHOOSE_WIFE, JOB_OFFER_H, JOB_OFFER_W, M, wife, HS, t, ability_hi, 
                                                    husband.HE, BP, wife.T_END, single_men, wife.age_index);

                                            // marriage decision - outside option value wife
                                            const MarriageDecision decision = marriage_decision(utility, BP, wife.WE, husband.HE);

                                            if (decision.M == 1) {
                                                ADD_EMAX_H += utility.U_H[decision.max_weighted_utility_index];
                                                ADD_EMAX_W += utility.U_W[decision.max_weighted_utility_index];
                                            } else {
                                                ADD_EMAX_H += utility.U_H_S; 
                                                ADD_EMAX_W += decision.outside_option_w_v;
                                            }
                                        }  //end draw backward loop                                        
                                        EMAX_H[t][W_EXP_INDEX][H_EXP_INDEX][N_KIDS_IND][prev][ability_wi][ability_hi][MARRIED][HS][WS][Q_INDEX][BPi] = 
                                            ADD_EMAX_H/DRAW_B;
                                        EMAX_W[t][W_EXP_INDEX][H_EXP_INDEX][N_KIDS_IND][prev][ability_wi][ability_hi][MARRIED][HS][WS][Q_INDEX][BPi] = 
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

