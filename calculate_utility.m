function [U_W, U_H, U_W_S, U_H_S] = calculate_utility(EMAX_W_T, EMAX_H_T, N_KIDS, N_KIDS_H,...
                                                      wage_h, wage_w, CHOOSE_PARTNER, CHOOSE_WORK_H, CHOOSE_WORK_W,...
                                                      M, similar_educ, Q, Q_INDEX, HS, WS, t, ability_hi, ability_wi, HE, WE, BP, T_END, single_men, age_index)  
% Utility parameters WIFE:  
global alpha; global alpha1_w_m; global alpha1_w_s; global alpha1_h_m; global alpha2_w; global alpha3_w;
global hp; global beta0;
global t1_w; global t2_w; global t3_w; global t4_w; global t5_w; global t6_w; global t7_w; global t8_w; global t9_w; global t10_w; 
global t11_w; global t12_w; global t13_w; global t14_w; global t15_w; global t16_w; global t17_w;
global t1_h; global t2_h; global t3_h;global t4_h; global t5_h; global t6_h; global t7_h; global t8_h; global t9_h; global t10_h;
global t11_h; global t12_h; global t13_h; global t14_h; global t15_h; global t16_h ;global t17_h;
global G_tax; 
global G_ded;
HSG = 0; SC = 0; CG = 0; PC = 0; H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
UNEMP = 1;
EMP = 2;
MARRIED = 1;
UNMARRIED = 2;
NEXT_T = 2;
U_W = zeros(1,22);
U_H = zeros(1,22);
U_W_S = zeros(1,2);
U_H_S = 0;
    
if (single_men == 1)
    WS_IDX = WS-1;
    HS_IDX = 1;
else
    WS_IDX = 1;
    HS_IDX = HS;
end
[net_income_s_h, net_income_s_w, net_income_m, net_income_m_unemp ]= gross_to_net(N_KIDS,  wage_w, wage_h,t, age_index);

if (M == 0  &&  CHOOSE_PARTNER == 0)
    U_W(1, 1:22) = -99999;
    U_H(1, 1:22) = -99999;
else
    N_KIDS_H = N_KIDS;
    if (WS == 2)
        HSG = 1;
    elseif (WS == 3)  
        SC = 1;
    elseif (WS == 4)
        CG = 1;
    else
        PC = 1; 
    end
    if (HS == 1)
        H_HSD = 1;
    elseif (HS == 2)  
        H_HSG = 1;
    elseif (HS == 3)  
        H_SC = 1;
    elseif (HS == 4)
        H_CG = 1;
    elseif (HS == 5)
        H_PC = 1; 
    end
    % decision making - choose from up to 6 options, according to CHOOSE_HUSBAND and CHOOSE_WORK_H, CHOOSE_WORK_W  values
    % utility from each option:
                                        
    % home production technology - parameters    
    % global hp sigma CRRA parameter
    % eqvivalent scale = 1 + M*0.7 + (N_KIDS)*0.4;

    total_cons1 = 0;
    total_cons2 = 0;
    women_cons_m1 = 0;
    women_cons_m2 = 0;
    men_cons_m1 = 0;
    men_cons_m2 = 0;
    UC_W1 = 0;
    UC_W2 = 0;
    UC_H1 = 0;
    UC_H2 = 0;
    UC_W_S = zeros(1,2);
    UC_H_S = 0; 
    for i = 0:10  % consumption share grid
        CS = i*0.1;
        total_cons1   = ((net_income_m_unemp*(1.7+(N_KIDS)*0.4)).^hp / (CS.^hp+(1-CS).^hp)  ).^(1/hp); % only men employed
        total_cons2   = ((net_income_m*(1.7+(N_KIDS)*0.4)).^hp / (CS.^hp+(1-CS).^hp)  ).^(1/hp); % both employed
        women_cons_m1 = CS*total_cons1;      % women private consumption when married and unemployed
        women_cons_m2 = CS*total_cons2;      % women private consumption when married and employed
        men_cons_m1   = (1-CS)*total_cons1;   % men private consumption when married and women unemployed
        men_cons_m2   = (1-CS)*total_cons2;  % men private consumption when married and women employed
        UC_W1 = (women_cons_m1.^alpha)/alpha + alpha1_w_m*(N_KIDS) + Q + similar_educ + alpha2_w*log(1+N_KIDS) + alpha3_w;
        UC_W2 = (women_cons_m2.^alpha)/alpha + alpha1_w_m*(N_KIDS) + Q + similar_educ;
        UC_H1 = (men_cons_m1.^alpha)/alpha   + alpha1_h_m*(N_KIDS) + Q + similar_educ;
        UC_H2 = (men_cons_m2.^alpha)/alpha   + alpha1_h_m*(N_KIDS) + Q + similar_educ;
        if (t == T_END)
            %t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
            %t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
            %t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
            %t16 previous work state - wife, 
            U_W(1,1+i) = UC_W1 +t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*WE    +t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+1)+...
                t12_w+t13_w*(N_KIDS)+t14_w*(Q+similar_educ)+t15_w*(N_KIDS)+t17_w;     
            U_W(1,12+i)= UC_W2 +t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(WE+1)+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+1)+...
                t12_w+t13_w*(N_KIDS)+t14_w*(Q+similar_educ)+t15_w*(N_KIDS)+t16_w+t17_w;    
            U_H(1,1+i) = UC_H1 +t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*WE    +t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+...
                t12_h+t13_h*(N_KIDS)+t14_h*(Q+similar_educ)+t17_h;       
            U_H(1,12+i)= UC_H2 +t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*(WE+1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+...
                t12_h+t13_h*(N_KIDS)+t14_h*(Q+similar_educ)+t16_h+t17_h;  
        elseif (t < T_END)   % the loop goes from 28 to 1, but for SC, CG and PC the loop is shorter
            [exp_wi, exp_hi, kidsi, BPi, ~] = value_to_index(WE, HE+1, N_KIDS, BP, CS);%calculate EMAX indexes when women unemployed
            U_W(1,1+i) =UC_W1 +beta0*EMAX_W_T(NEXT_T, exp_wi, exp_hi, kidsi, UNEMP, ability_wi, ability_hi, MARRIED, HS_IDX, WS_IDX, Q_INDEX, BPi);
            U_H(1,1+i) =UC_H1 +beta0*EMAX_H_T(NEXT_T, exp_wi, exp_hi, kidsi, UNEMP, ability_wi, ability_hi, MARRIED, HS_IDX, WS_IDX, Q_INDEX, BPi);
            [exp_wi, exp_hi, kidsi, BPi, ~] = value_to_index(WE+1, HE+1, N_KIDS, BP, CS);%calculate EMAX indexes when women employed            
            U_W(1,12+i)=UC_W2 +beta0*EMAX_W_T(NEXT_T, exp_wi, exp_hi, kidsi,   EMP, ability_wi, ability_hi, MARRIED, HS_IDX, WS_IDX, Q_INDEX, BPi);
            U_H(1,12+i)=UC_H2 +beta0*EMAX_H_T(NEXT_T, exp_wi, exp_hi, kidsi,   EMP, ability_wi, ability_hi, MARRIED, HS_IDX, WS_IDX, Q_INDEX, BPi);
        end
    end
end
UC_W_S(1,1) = alpha1_w_s*(N_KIDS)+ alpha2_w*log(1+N_KIDS) + alpha3_w;
women_cons_s2 = net_income_s_w*(1+(N_KIDS)*0.4);% women private consumption when single and employed
UC_W_S(1,2) = (women_cons_s2.^alpha)/alpha + alpha1_w_s*(N_KIDS);
UC_H_S = ((net_income_s_h).^alpha)/alpha;
if (t == T_END)
    U_W_S(1,1) = UC_W_S(1,1)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*WE    +t13_w*(N_KIDS);     
    U_W_S(1,2) = UC_W_S(1,2)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(WE+1)+t13_w*(N_KIDS)+t16_w;       
    U_H_S      = UC_H_S+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+t13_h*(N_KIDS_H); 
elseif ( t < T_END)
    [exp_wi, ~, kidsi, ~, ~] = value_to_index(WE, 0, N_KIDS, 0, 0);
    U_W_S(1,1) = UC_W_S(1,1)+beta0*EMAX_W_T(NEXT_T, exp_wi, 1, kidsi, UNEMP, ability_wi, 1, UNMARRIED, 1, WS_IDX, 1, 1);
    [exp_wi, ~, kidsi, ~, ~] = value_to_index(WE+1, 0, N_KIDS, 0, 0);
    U_W_S(1,2) = UC_W_S(1,2)+beta0*EMAX_W_T(NEXT_T, exp_wi, 1, kidsi, EMP, ability_wi, 1, UNMARRIED, 1, WS_IDX, 1, 1);
    [~, exp_hi, kidsi, ~, ~] = value_to_index(0, HE+1, N_KIDS_H, 0, 0);
    U_H_S      = UC_H_S     +beta0*EMAX_H_T(NEXT_T, 1, exp_hi, kidsi, UNEMP, 1, ability_hi, UNMARRIED, HS_IDX, WS_IDX, 1, 1);
else
    error("invalid value of t: " + string(t))
end

if (CHOOSE_WORK_W == 0)
    U_W(1, 12:22) = -99999; % ALL 11 EMPLOYMENT OPTIONS ARE UNAVAILABLE
    U_H(1, 12:22) = -99999;
    U_W_S(1,:)= -99999;
end
