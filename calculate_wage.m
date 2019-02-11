function [wage, JOB_OFFER] = calculate_wage(sex, H_HSD, H_HSG,H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE , h_draws, w_draws, epsilon, draw_f, t, school_group, prev_state_w, prev_state_h, ability_w, ability_h)
% Wage parameters wife
global beta1_w  ;global beta2_w ;global beta31_w ;global beta32_w ;global beta33_w ;global beta34_w ;
global beta1_h  ;global beta2_h ;global beta30_h ;global beta31_h ;global beta32_h ;global beta33_h ;global beta34_h ;
global row_w    ;global row0_w   ;global row11_w  ;global row12_w  ;global row13_w  ;global row14_w ;global row2_w   ;
global row_h    ;global row0_h   ;global row11_h  ;global row12_h  ;global row13_h  ;global row14_h ;global row2_h   ; global sigma;

if (sex == 0)   % H=0
    % JOB OFFER PROBABILITY + WAGE HUSBAND
    %h_draws = rand(DRAW_F,T,2); 1 -job offer, 2-new child, 
    PROB_TMP=row_h+row0_h*prev_state_h + row11_h*H_HSG +row12_h*H_SC +row13_h*H_CG +row14_h*H_PC + row2_h*HE;
    PROB_H= exp(PROB_TMP) ./ (1+exp(PROB_TMP));
    if PROB_H > h_draws(draw_f,t,school_group,6)
        JOB_OFFER = 1;
        tmp1_h = ability_h + beta1_h*(HE)+ beta2_h*(HE).^2+ beta30_h*H_HSD+beta31_h*H_HSG+ beta32_h*H_SC+ beta33_h*H_CG+ beta34_h*H_PC;
        tmp2_h = (epsilon(draw_f, t,school_group,1)*sigma(1,1)); %epsilon_f(draw_f, t, sex)
        wage = exp(tmp1_h + tmp2_h);
    else
        JOB_OFFER = 0;
        wage = 0;
    end
    
else   %sex == W
    %w_draws = rand(DRAW_F,T,2); 1 -job offer, 2-new child, 
    PROB_TMP=row_w+row0_w*prev_state_w +row11_w*HSG +row12_w*SC +row13_w*CG +row14_w*PC + row2_w*WE;
    PROB_W= exp(PROB_TMP) ./ (1+exp(PROB_TMP));
    if PROB_W > w_draws(draw_f,t,school_group,1)
        JOB_OFFER = 1;
        tmp1_w = ability_w + beta1_w*WE + beta2_w*WE.^2 + beta31_w*HSG+beta32_w*SC+ beta33_w*CG+ beta34_w*PC;
        tmp2_w = (epsilon(draw_f, t, school_group,2)*sigma(2,2)); %epsilon_f(draw_f, t, sex)  
        wage = exp(tmp1_w + tmp2_w);
    else
        JOB_OFFER = 0;
        wage = 0;
    end   
end    