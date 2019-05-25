#include <cmath>
#include "parameters.h"
#include "draw_wife.h"

double calculate_wage_h(const Parameters& p, unsigned H_HSD, unsigned H_HSG, unsigned H_SC, unsigned H_CG, unsigned H_PC, 
        unsigned HE, double ability_h_value, double epsilon) {
    const double tmp1 = ability_h_value + p.beta10_h*(HE*H_HSD) + p.beta11_h*(HE*H_HSG) + p.beta12_h*(HE*H_SC) + p.beta13_h*(HE*H_CG) + p.beta14_h*(HE*H_PC) +
        p.beta20_h*pow(HE*H_HSD,2) + p.beta21_h*pow(HE*H_HSG,2) + p.beta22_h*pow(HE*H_SC,2) + p.beta23_h*pow(HE*H_CG,2) + p.beta24_h*pow(HE*H_PC,2) +
        p.beta30_h*H_HSD + p.beta31_h*H_HSG + p.beta32_h*H_SC + p.beta33_h*H_CG + p.beta34_h*H_PC;
    const double tmp2 = epsilon*p.sigma[1];
    return exp(tmp1 + tmp2);
}

double calculate_wage_w(const Parameters& p, const Wife& wife, double w_draw, double epsilon) {
    const double PROB_TMP = p.row0_w*wife.prev_state_w + p.row11_w*wife.HSG + p.row12_w*wife.SC + p.row13_w*wife.CG + p.row14_w*wife.PC + p.row2_w*wife.WE;
    const double PROB_W = exp(PROB_TMP)/(1+exp(PROB_TMP));
    if (PROB_W > w_draw) {
        const double tmp1 = wife.ability_w_value + p.beta11_w*wife.WE*wife.HSG + p.beta12_w*wife.WE*wife.SC + p.beta13_w*wife.WE*wife.CG + 
            p.beta14_w*wife.WE*wife.PC +p.beta21_w*pow(wife.WE*wife.HSG,2) + p.beta22_w*pow(wife.WE*wife.SC,2) + p.beta23_w*pow(wife.WE*wife.CG,2) + 
            p.beta24_w*pow(wife.WE*wife.PC,2) +  p.beta31_w*wife.HSG+p.beta32_w*wife.SC + p.beta33_w*wife.CG + p.beta34_w*wife.PC;
        const double tmp2 = epsilon*p.sigma[2];
        return exp(tmp1 + tmp2);
    }
    return 0.0;
}

