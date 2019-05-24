function [wage, JOB_OFFER] = calculate_wage(const_values, sex, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE, w_draw, epsilon, prev_state_w, ability_w, ability_h, t)

beta11_w = const_values.beta11_w; 
beta12_w = const_values.beta12_w; 
beta13_w = const_values.beta13_w;
beta14_w = const_values.beta14_w;
beta21_w = const_values.beta21_w;
beta22_w = const_values.beta22_w;
beta23_w = const_values.beta23_w;
beta24_w = const_values.beta24_w;
beta31_w = const_values.beta31_w;
beta32_w = const_values.beta32_w;
beta33_w = const_values.beta33_w;
beta34_w = const_values.beta34_w;
beta10_h = const_values.beta10_h;
beta11_h = const_values.beta11_h;
beta12_h = const_values.beta12_h;
beta13_h = const_values.beta13_h;
beta14_h = const_values.beta14_h;
beta20_h = const_values.beta20_h;
beta21_h = const_values.beta21_h;
beta22_h = const_values.beta22_h;
beta23_h = const_values.beta23_h;
beta24_h = const_values.beta24_h;
beta30_h = const_values.beta30_h;
beta31_h = const_values.beta31_h;
beta32_h = const_values.beta32_h;
beta33_h = const_values.beta33_h;
beta34_h = const_values.beta34_h;
row0_w = const_values.row0_w;
row11_w = const_values.row11_w;
row12_w = const_values.row12_w;
row13_w = const_values.row13_w;
row14_w = const_values.row14_w;
row2_w = const_values.row2_w;
sigma = const_values.sigma;

if (sex == 0)   % husband
    % JOB OFFER PROBABILITY + WAGE HUSBAND
    % 1 -job offer, 2-new child
    JOB_OFFER = 1;
    tmp1 = ability_h + beta10_h*(HE*H_HSD) + beta11_h*(HE*H_HSG) + beta12_h*(HE*H_SC) + beta13_h*(HE*H_CG) + beta14_h*(HE*H_PC) +...
                 beta20_h*(HE*H_HSD).^2 + beta21_h*(HE*H_HSG).^2 + beta22_h*(HE*H_SC).^2 + beta23_h*(HE*H_CG).^2 + beta24_h*(HE*H_PC).^2 +...
                 beta30_h*H_HSD + beta31_h*H_HSG + beta32_h*H_SC + beta33_h*H_CG + beta34_h*H_PC;
    tmp2 = epsilon*sigma(1,1);
    wage = exp(tmp1 + tmp2);
else   % wife
    % 1 -job offer, 2-new child
    PROB_TMP = row0_w*prev_state_w + row11_w*HSG + row12_w*SC + row13_w*CG + row14_w*PC + row2_w*WE;
    PROB_W = exp(PROB_TMP)/(1+exp(PROB_TMP));
    if PROB_W > w_draw
        JOB_OFFER = 1;
        tmp1 = ability_w + beta11_w*(WE*HSG) + beta12_w*(WE*SC) + beta13_w*(WE*CG) + beta14_w*(WE*PC) +...
                 beta21_w*(WE*HSG).^2 + beta22_w*(WE*SC).^2 + beta23_w*(WE*CG).^2 + beta24_w*(WE*PC).^2 +...
                 beta31_w*HSG+beta32_w*SC + beta33_w*CG + beta34_w*PC;
        tmp2 = epsilon*sigma(2,2);
        wage = exp(tmp1 + tmp2);
    else
        JOB_OFFER = 0;
        wage = 0;
    end   
end

