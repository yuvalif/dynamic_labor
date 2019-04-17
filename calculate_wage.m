function [wage, JOB_OFFER] = calculate_wage(sex, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE, w_draw, epsilon, prev_state_w, ability_w, ability_h,t)

global beta11_w; global beta12_w; global beta13_w; global beta14_w;
global beta21_w; global beta22_w; global beta23_w; global beta24_w;
global beta31_w; global beta32_w; global beta33_w; global beta34_w;
global beta10_h; global beta11_h; global beta12_h; global beta13_h; global beta14_h;
global beta20_h; global beta21_h; global beta22_h; global beta23_h; global beta24_h;
global beta30_h; global beta31_h; global beta32_h; global beta33_h; global beta34_h;
global row0_w;   global row11_w;  global row12_w;  global row13_w;  global row14_w; global row2_w;
global sigma;

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

