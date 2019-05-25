#include "calculate_utility.h"
#include "emax.h"
#include "parameters.h"
#include "const_parameters.h"
#include "gross_to_net.h"
#include "value_to_index.h"
#include <cmath>
#include <limits>
#include <array>

Utility calculate_utility(const Parameters& p, const Emax& EMAX_W, const Emax& EMAX_H, unsigned N_KIDS, unsigned N_KIDS_H,
        double wage_h, double wage_w, unsigned CHOOSE_PARTNER, unsigned CHOOSE_WORK_H, unsigned CHOOSE_WORK_W,
        unsigned M, unsigned similar_educ, unsigned Q, unsigned Q_INDEX, unsigned HS, unsigned WS, unsigned t, 
        unsigned ability_hi, unsigned ability_wi, unsigned HE, unsigned WE, unsigned BP, unsigned T_END, unsigned single_men, unsigned age_index) {

    unsigned WS_IDX = 1;
    unsigned HS_IDX = HS;
    if (single_men == 1) {
        WS_IDX = WS - 1;
        HS_IDX = 1;
    }

    const NetIncome net = gross_to_net(p, N_KIDS, wage_w, wage_h, t, age_index);

    Utility result;

    unsigned HSG = 0; unsigned SC = 0; unsigned CG = 0; unsigned PC = 0;
    unsigned H_HSD = 0; unsigned H_HSG = 0; unsigned H_SC = 0; unsigned H_CG = 0; unsigned H_PC = 0;

    if (M == 0  &&  CHOOSE_PARTNER == 0) {
        std::fill(result.U_W.begin(), result.U_W.end(), std::numeric_limits<double>::lowest());
        std::fill(result.U_H.begin(), result.U_H.end(), std::numeric_limits<double>::lowest());
    } else {
        N_KIDS_H = N_KIDS;
        if (WS == 2) {
            HSG = 1;
        } else if (WS == 3) {
            SC = 1;
        } else if (WS == 4) {
            CG = 1;
        } else {
            PC = 1; 
        }

        if (HS == 1) {
            H_HSD = 1;
        } else if (HS == 2) {
            H_HSG = 1;
        } else if (HS == 3) {
            H_SC = 1;
        } else if (HS == 4) {
            H_CG = 1;
        } else if (HS == 5) {
            H_PC = 1; 
        }

        // decision making - choose from up to 6 options, according to CHOOSE_HUSBAND and CHOOSE_WORK_H, CHOOSE_WORK_W  values
        // utility from each option:                                 
        // home production technology - parameters    
        // global hp sigma CRRA parameter
        // eqvivalent scale = 1 + M*0.7 + N_KIDS*0.4;

        std::array<double, 2> UC_W_S{};
        for (auto i = 0; i <= 10; ++i) {  //consumption share grid
            const auto CS = i*0.1;
            const auto total_cons1 = pow(net.net_income_m_unemp*(1.7+(N_KIDS)*0.4), p.hp) / pow(pow(CS, p.hp)+pow(1.0-CS, p.hp), 1.0/p.hp); // only men employed
            const auto total_cons2 = pow(net.net_income_m*(1.7+(N_KIDS)*0.4), p.hp) / pow(pow(CS, p.hp)+pow(1.0-CS, p.hp), 1.0/p.hp);       // both employed
            const auto women_cons_m1 = CS*total_cons1;          // women private consumption when married and unemployed
            const auto women_cons_m2 = CS*total_cons2;          // women private consumption when married and employed
            const auto men_cons_m1   = (1.0-CS)*total_cons1;    // men private consumption when married and women unemployed
            const auto men_cons_m2   = (1.0-CS)*total_cons2;    // men private consumption when married and women employed
            const auto UC_W1 = pow(women_cons_m1, p.alpha)/p.alpha + p.alpha1_w_m*(N_KIDS) + Q + similar_educ + p.alpha2_w*log(1.0+N_KIDS) + p.alpha3_w;
            const auto UC_W2 = pow(women_cons_m2, p.alpha)/p.alpha + p.alpha1_w_m*(N_KIDS) + Q + similar_educ;
            const auto UC_H1 = pow(men_cons_m1, p.alpha)/p.alpha   + p.alpha1_h_m*(N_KIDS) + Q + similar_educ;
            const auto UC_H2 = pow(men_cons_m2, p.alpha)/p.alpha   + p.alpha1_h_m*(N_KIDS) + Q + similar_educ;
            if (t == T_END) {
                // t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
                // t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
                // t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
                // t16 previous work state - wife 
                result.U_W[1+i] = UC_W1+p.t1_w*HSG+p.t2_w*SC+p.t3_w*CG+p.t4_w*PC+p.t5_w*WE        + p.t6_w*H_HSD+p.t7_w*H_HSG+p.t8_w*H_SC+p.t9_w*H_CG+
                    p.t10_w*H_PC+p.t11_w*(HE+1.0)+p.t12_w+p.t13_w*(N_KIDS)+p.t14_w*(Q+similar_educ)+p.t15_w*(N_KIDS)+p.t17_w;

                result.U_W[12+i] = UC_W2+p.t1_w*HSG+p.t2_w*SC+p.t3_w*CG+p.t4_w*PC+p.t5_w*(WE+1.0) + p.t6_w*H_HSD+p.t7_w*H_HSG+p.t8_w*H_SC+p.t9_w*H_CG+
                    p.t10_w*H_PC+p.t11_w*(HE+1.0)+p.t12_w+p.t13_w*(N_KIDS)+p.t14_w*(Q+similar_educ)+p.t15_w*(N_KIDS)+p.t16_w+p.t17_w;

                result.U_H[1+i] = UC_H1+p.t1_h*HSG+p.t2_h*SC+p.t3_h*CG+p.t4_h*PC+p.t5_h*WE        + p.t6_h*H_HSD+p.t7_h*H_HSG+p.t8_h*H_SC+p.t9_h*H_CG+
                    p.t10_h*H_PC+p.t11_h*(HE+1.0)+p.t12_h+p.t13_h*(N_KIDS)+p.t14_h*(Q+similar_educ)+p.t17_h;

                result.U_H[12+i] = UC_H2+p.t1_h*HSG+p.t2_h*SC+p.t3_h*CG+p.t4_h*PC+p.t5_h*(WE+1.0) + p.t6_h*H_HSD+p.t7_h*H_HSG+p.t8_h*H_SC+p.t9_h*H_CG+
                    p.t10_h*H_PC+p.t11_h*(HE+1.0)+p.t12_h+p.t13_h*(N_KIDS)+p.t14_h*(Q+similar_educ)+p.t16_h+p.t17_h;
            } else {
                // t < T_END
                // the loop goes from 28 to 1, but for SC, CG and PC the loop is shorter
                unsigned exp_wi; unsigned exp_hi; unsigned kidsi; unsigned BPi;	unsigned CSi;
                // calculate EMAX indexes when women unemployed
                value_to_index(WE, HE+1, N_KIDS, BP, CS, exp_wi, exp_hi, kidsi, BPi, CSi);
                result.U_W[1+i] = UC_W1+beta0*EMAX_W[t+1][exp_wi][exp_hi][kidsi][UNEMP][ability_wi][ability_hi][MARRIED][HS_IDX][WS_IDX][Q_INDEX][BPi];
                result.U_H[1+i] = UC_H1+beta0*EMAX_H[t+1][exp_wi][exp_hi][kidsi][UNEMP][ability_wi][ability_hi][MARRIED][HS_IDX][WS_IDX][Q_INDEX][BPi];
                // calculate EMAX indexes when women employed
                value_to_index(WE+1, HE+1, N_KIDS, BP, CS, exp_wi, exp_hi, kidsi, BPi, CSi);
                result.U_W[12+i] = UC_W2+beta0*EMAX_W[t+1][exp_wi][exp_hi][kidsi][EMP] [ability_wi][ability_hi][MARRIED][HS_IDX][WS_IDX][Q_INDEX][BPi];
                result.U_H[12+i] = UC_H2+beta0*EMAX_H[t+1][exp_wi][exp_hi][kidsi][EMP] [ability_wi][ability_hi][MARRIED][HS_IDX][WS_IDX][Q_INDEX][BPi];
            }
        }

        UC_W_S[1] = p.alpha1_w_s*(N_KIDS) + p.alpha2_w*log(1.0+N_KIDS) + p.alpha3_w;
        const auto women_cons_s2 = net.net_income_s_w*(1.0+N_KIDS*0.4); // women private consumption when single and employed
        UC_W_S[2] = pow(women_cons_s2,p.alpha)/p.alpha + p.alpha1_w_s*(N_KIDS);
        const auto UC_H_S = pow(net.net_income_s_h,p.alpha)/p.alpha;
        if (t == T_END) {
            result.U_W_S[1] = UC_W_S[1]+p.t1_w*HSG+p.t2_w*SC+p.t3_w*CG+p.t4_w*PC+p.t5_w*WE    +p.t13_w*N_KIDS;     
            result.U_W_S[2] = UC_W_S[2]+p.t1_w*HSG+p.t2_w*SC+p.t3_w*CG+p.t4_w*PC+p.t5_w*(WE+1.0)+p.t13_w*N_KIDS+p.t16_w;       
            result.U_H_S    = UC_H_S+p.t6_h*H_HSD+p.t7_h*H_HSG+p.t8_h*H_SC+p.t9_h*H_CG+p.t10_h*H_PC+p.t11_h*(HE+1.0)+p.t13_h*N_KIDS_H; 
        } else {
            unsigned exp_wi; unsigned exp_hi; unsigned kidsi; unsigned BPi;	unsigned CSi;
            value_to_index(WE, 0, N_KIDS, 0, 0, exp_wi, exp_hi, kidsi, BPi, CSi);
            result.U_W_S[1] = UC_W_S[1]+beta0*EMAX_W[t+1][exp_wi][1][kidsi][UNEMP][ability_wi][1][UNMARRIED][1][WS_IDX][1][1];

            value_to_index(WE+1, 0, N_KIDS, 0, 0, exp_wi, exp_hi, kidsi, BPi, CSi);
            result.U_W_S[2] = UC_W_S[2]+beta0*EMAX_W[t+1][exp_wi][1][kidsi][EMP][ability_wi][1][UNMARRIED][1][WS_IDX][1][1];

            value_to_index(0, HE+1, N_KIDS_H, 0, 0, exp_wi, exp_hi, kidsi, BPi, CSi);
            result.U_H_S    = UC_H_S   +beta0*EMAX_H[t+1][1][exp_hi][kidsi][UNEMP][1][ability_hi][UNMARRIED][HS_IDX][WS_IDX][1][1];
        }

        if (CHOOSE_WORK_W == 0) {
            // ALL 11 EMPLOYMENT OPTIONS ARE UNAVAILABLE
            std::fill(result.U_W.begin()+12, result.U_W.end(), std::numeric_limits<double>::lowest());
            std::fill(result.U_H.begin()+12, result.U_H.end(), std::numeric_limits<double>::lowest());
            std::fill(result.U_W_S.begin(), result.U_W_S.end(), std::numeric_limits<double>::lowest());
        }
    } 

    return result;
}
