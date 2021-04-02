#include "calculate_utility.h"
#include "emax.h"
#include "parameters.h"
#include "const_parameters.h"
#include "gross_to_net.h"
#include "value_to_index.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include <cmath>
#include <array>
#include "to_string.h"

// initialize all values with MINIMUM_UTILITY
Utility::Utility() {
    std::fill(U_W.begin(), U_W.end(), MINIMUM_UTILITY);
    std::fill(U_H.begin(), U_H.end(), MINIMUM_UTILITY);
    std::fill(U_W_S.begin(), U_W_S.end(), MINIMUM_UTILITY);
    U_H_S = MINIMUM_UTILITY;
}

std::string to_string(const Utility& u) {
    std::stringstream ss;
    for (const auto x : u.U_W_S) ss << to_string_with_precision(x, 0) << " ";
    ss << std::endl;

    const auto x = u.U_H_S;
    ss << to_string_with_precision(x, 0) << " ";
    ss << std::endl;

    for (const auto xx : u.U_W) ss << to_string_with_precision(xx, 0) << " ";
    ss << std::endl;

    for (const auto xx : u.U_H) ss << to_string_with_precision(xx, 0) << " ";
    ss << std::endl;

    return ss.str();
}

std::string to_string(const UtilityArray& a) {
    std::stringstream ss;
    for (const auto xx : a) ss << to_string_with_precision(xx, 0) << " ";
    ss << std::endl;

    return ss.str();
}

Utility calculate_utility(const Parameters& p, const Emax& EMAX_W, const Emax& EMAX_H, unsigned kids,
        double wage_h, double wage_w, bool choose_partner,
        unsigned M, const Wife& wife, const Husband& husband, unsigned t, double BP, bool single_men) {

    const auto T_END = single_men ? husband.T_END : wife.T_END;
    assert(t <= T_END);
    const auto age_index = single_men ? husband.age_index : wife.age_index;

    const NetIncome net = gross_to_net(p, kids, wage_w, wage_h, t, age_index);

    Utility result;

    auto kids_h = NO_KIDS;

    if (M == MARRIED  || choose_partner) {
        kids_h = kids;
        // decision making - choose from up to 6 options, according to CHOOSE_HUSBAND and CHOOSE_WORK_H, CHOOSE_WORK_W  values
        // utility from each option:                                 
        // home production technology - parameters    
        // global hp sigma CRRA parameter
        // eqvivalent scale = 1 + M*0.7 + kids*0.4;

        for (auto i = 0; i < CS_SIZE; ++i) {  //consumption share grid
            const auto CS = cs_vector[i];
            const auto total_cons_denom = pow(pow(CS, p.hp)+pow(1.0-CS, p.hp), 1.0/p.hp)*(1.0+kids*0.3);
            const auto total_cons1 = net.net_income_m_unemp/total_cons_denom; // only men employed
            const auto total_cons2 = net.net_income_m/total_cons_denom;       // both employed
            const auto women_cons_m1 = CS*total_cons1;          // women private consumption when married and unemployed
            const auto women_cons_m2 = CS*total_cons2;          // women private consumption when married and employed
            const auto men_cons_m1 = (1.0-CS)*total_cons1;    // men private consumption when married and women unemployed
            const auto men_cons_m2 = (1.0-CS)*total_cons2;    // men private consumption when married and women employed
            const auto UC_W1 = pow(women_cons_m1, p.alpha)/p.alpha + p.alpha1_w_m*kids + wife.Q + wife.similar_educ + p.alpha2_w*log1p(kids) + p.alpha3_w;
            const auto UC_W2 = pow(women_cons_m2, p.alpha)/p.alpha + p.alpha1_w_m*kids + wife.Q + wife.similar_educ;
            const auto UC_H1 = pow(men_cons_m1, p.alpha)/p.alpha   + p.alpha1_h_m*kids + wife.Q + wife.similar_educ;
            const auto UC_H2 = pow(men_cons_m2, p.alpha)/p.alpha   + p.alpha1_h_m*kids + wife.Q + wife.similar_educ;
            if (t == T_END) {
                // t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
                // t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband - PC
                // t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
                // t16 previous work state - wife 
                result.U_W[i] = UC_W1+p.t1_w*wife.HSG+p.t2_w*wife.SC+p.t3_w*wife.CG+p.t4_w*wife.PC+p.t5_w*wife.WE + 
                    p.t6_w*husband.H_HSD+p.t7_w*husband.H_HSG+p.t8_w*husband.H_SC+p.t9_w*husband.H_CG+p.t10_w*husband.H_PC +
                    p.t11_w*(husband.HE+1.0)+p.t12_w+p.t13_w*kids+p.t14_w*(wife.Q+wife.similar_educ)+p.t15_w*kids+p.t17_w;

                result.U_W[CS_SIZE+i] = UC_W2+p.t1_w*wife.HSG+p.t2_w*wife.SC+p.t3_w*wife.CG+p.t4_w*wife.PC+p.t5_w*(wife.WE+1.0) + 
                    p.t6_w*husband.H_HSD+p.t7_w*husband.H_HSG+p.t8_w*husband.H_SC+p.t9_w*husband.H_CG+p.t10_w*husband.H_PC + 
                    p.t11_w*(husband.HE+1.0)+p.t12_w+p.t13_w*kids+p.t14_w*(wife.Q+wife.similar_educ)+p.t15_w*kids+p.t16_w+p.t17_w;

                result.U_H[i] = UC_H1+p.t1_h*wife.HSG+p.t2_h*wife.SC+p.t3_h*wife.CG+p.t4_h*wife.PC+p.t5_h*wife.WE +
                    p.t6_h*husband.H_HSD+p.t7_h*husband.H_HSG+p.t8_h*husband.H_SC+p.t9_h*husband.H_CG+p.t10_h*husband.H_PC + 
                    p.t11_h*(husband.HE+1.0)+p.t12_h+p.t13_h*kids+p.t14_h*(wife.Q+wife.similar_educ)+p.t17_h;

                result.U_H[CS_SIZE+i] = UC_H2+p.t1_h*wife.HSG+p.t2_h*wife.SC+p.t3_h*wife.CG+p.t4_h*wife.PC+p.t5_h*(wife.WE+1.0) +
                    p.t6_h*husband.H_HSD+p.t7_h*husband.H_HSG+p.t8_h*husband.H_SC+p.t9_h*husband.H_CG+p.t10_h*husband.H_PC + 
                    p.t11_h*(husband.HE+1.0)+p.t12_h+p.t13_h*kids+p.t14_h*(wife.Q+wife.similar_educ)+p.t16_h+p.t17_h;
            } else if (t < T_END) {
                // the loop goes from 28 to 1, but for SC, CG and PC the loop is shorter
                unsigned exp_wi; unsigned exp_hi; unsigned BPi;	unsigned CSi;
                // calculate EMAX indexes when women unemployed
                value_to_index(wife.WE, husband.HE+1, BP, CS, exp_wi, exp_hi, BPi, CSi);
                result.U_W[i] = UC_W1+beta0*EMAX_W[t+1][exp_wi][exp_hi][kids][UNEMP][wife.ability_wi][husband.ability_hi][MARRIED][husband.HS][wife.WS][wife.Q_INDEX][BPi];
                result.U_H[i] = UC_H1+beta0*EMAX_H[t+1][exp_wi][exp_hi][kids][UNEMP][wife.ability_wi][husband.ability_hi][MARRIED][husband.HS][wife.WS][wife.Q_INDEX][BPi];
                // calculate EMAX indexes when women employed
                value_to_index(wife.WE+1, husband.HE+1, BP, CS, exp_wi, exp_hi, BPi, CSi);
                result.U_W[CS_SIZE+i] = UC_W2+beta0*EMAX_W[t+1][exp_wi][exp_hi][kids][EMP][wife.ability_wi][husband.ability_hi][MARRIED][husband.HS][wife.WS][wife.Q_INDEX][BPi];
                result.U_H[CS_SIZE+i] = UC_H2+beta0*EMAX_H[t+1][exp_wi][exp_hi][kids][EMP][wife.ability_wi][husband.ability_hi][MARRIED][husband.HS][wife.WS][wife.Q_INDEX][BPi];
            }
        }
    }

    std::array<double, 2> UC_W_S{};
    UC_W_S[UNEMP] = p.alpha1_w_s*(kids) + p.alpha2_w*log1p(kids) + p.alpha3_w;
    const auto women_cons_s2 = net.net_income_s_w/(1.0+kids*0.3); // women private consumption when single and employed
    UC_W_S[EMP] = pow(women_cons_s2, p.alpha)/p.alpha + p.alpha1_w_s*kids;
    const auto UC_H_S = pow(net.net_income_s_h, p.alpha)/p.alpha;
    if (t == T_END) {
        result.U_W_S[UNEMP] = UC_W_S[UNEMP]+p.t1_w*wife.HSG+p.t2_w*wife.SC+p.t3_w*wife.CG+p.t4_w*wife.PC+p.t5_w*wife.WE      +p.t13_w*kids;     
        result.U_W_S[EMP] = UC_W_S[EMP]+p.t1_w*wife.HSG+p.t2_w*wife.SC+p.t3_w*wife.CG+p.t4_w*wife.PC+p.t5_w*(wife.WE+1.0)+p.t13_w*kids+p.t16_w;       
        result.U_H_S    = UC_H_S+p.t6_h*husband.H_HSD+p.t7_h*husband.H_HSG+p.t8_h*husband.H_SC+p.t9_h*husband.H_CG+p.t10_h*husband.H_PC+p.t11_h*(husband.HE+1.0)+p.t13_h*kids_h;
    } else {
        unsigned exp_wi; unsigned exp_hi; unsigned BPi;	unsigned CSi;
        value_to_index(wife.WE, 0, 0, 0, exp_wi, exp_hi, BPi, CSi);
        result.U_W_S[UNEMP] = UC_W_S[UNEMP]+beta0*EMAX_W[t+1][exp_wi][1][kids][UNEMP][wife.ability_wi][1][UNMARRIED][1][wife.WS][1][1];

        value_to_index(wife.WE+1, 0, 0, 0, exp_wi, exp_hi, BPi, CSi);
        result.U_W_S[EMP] = UC_W_S[EMP]+beta0*EMAX_W[t+1][exp_wi][1][kids][EMP][wife.ability_wi][1][UNMARRIED][1][wife.WS][1][1];

        value_to_index(0, husband.HE+1, 0, 0, exp_wi, exp_hi, BPi, CSi);
        result.U_H_S    = UC_H_S   +beta0*EMAX_H[t+1][1][exp_hi][kids][UNEMP][1][husband.ability_hi][UNMARRIED][husband.HS][wife.WS][1][1];
    }

    if (wage_w == 0.0) {
        // no women employment options
        std::fill(result.U_W.begin()+CS_SIZE, result.U_W.end(), MINIMUM_UTILITY);
        std::fill(result.U_H.begin()+CS_SIZE, result.U_H.end(), MINIMUM_UTILITY);
        result.U_W_S[EMP] = MINIMUM_UTILITY;
    }

    return result;
}

