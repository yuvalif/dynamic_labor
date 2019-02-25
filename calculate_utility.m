function [U_W,U_H,U_W_S,U_H_S]=calculate_utility(N_Y, N_O,N_Y_H,N_O_H, wage_h, wage_w, CHOOSE_HUSBAND, CHOOSE_WORK_H, CHOOSE_WORK_W, M, STATIC, COUNTER, similar_educ, Q,Q_INDEX,HS, t, ability_h, ability_hi,ability_w, ability_wi, HE,WE,BP)  
% Utility parameters WIFE:  
global alpha; global alpha1_w_m ;global alpha1_w_s ;global alpha1_h_m ;global alpha2_w ;global alpha3_w ;
global hp;global T ;global beta0;
global t1_w ;global t2_w;global t3_w ;global t4_w;global t5_w ;global t6_w ;global t7_w ;global t8_w ;global t9_w ;global t10_w ;global t11_w ;global t12_w ;global t13_w ;global t14_w ;global t15_w; global t16_w;global t17_w;
global t1_h ;global t2_h;global t3_h ;global t4_h;global t5_h ;global t6_h ;global t7_h ;global t8_h ;global t9_h ;global t10_h ;global t11_h ;global t12_h ;global t13_h ;global t14_h ;global t15_h; global t16_h ;global t17_h;
global HSD; global HSG; global SC; global CG; global PC ;global H_HSD; global H_HSG; global H_SC; global H_CG; global H_PC ;
global EMAX_W; global EMAX_H;

% decision making - choose from up to 6 options, according to CHOOSE_HUSBAND and CHOOSE_WORK_H, CHOOSE_WORK_W  values
% utility from each option:
                                    
%home production technology - parameters    
%global hp sigma CRRA parameter
% eqvivalent scale = 1 + M*0.7 + (N_Y+N_O)*0.4;
women_cons_s(1) = 0;  %women private consumption when single and unemployed
women_cons_s(2) = wage_w*(1+(N_Y+N_O)*0.4);%women private consumption when single and employed
men_cons_s = wage_h; % men private consumption when single and employed
total_earning = zeros(1,2);
total_earning(1,1)= wage_h;   % only men employed
total_earning(1,2) = wage_h+wage_w; % both employed
total_cons = zeros(1,22);
women_cons_m = zeros(1,22);
men_cons_m = zeros(1,22);
UC_W = zeros(1,22);
UC_H = zeros(1,22);
U_W = zeros(1,22);
U_H = zeros(1,22);
for i = 0:10  % consumption share grid
    CS = i*0.1;
    total_cons(1,1+i)  = ((total_earning(1,1)*(1.7+(N_Y+N_O)*0.4)).^hp / (CS.^hp+(1-CS).^hp)  ).^(1/hp); % only men employed
    total_cons(1,12+i) = ((total_earning(1,2)*(1.7+(N_Y+N_O)*0.4)).^hp / (CS.^hp+(1-CS).^hp)  ).^(1/hp); % both employed
    women_cons_m(1,1+i) = CS*total_cons(1,1+i); % women private consumption when married and unemployed
    women_cons_m(1,12+i) = CS*total_cons(1,12+i);% women private consumption when married and employed
    men_cons_m(1,1+i) = (1-CS)*total_cons(1,1+i);% men private consumption when married and women unemployed
    men_cons_m(1,12+i) = (1-CS)*total_cons(1,12+i);% men private consumption when married and women employed
    UC_W(1,1+i) =((women_cons_m(1,1 +i)).^alpha)/alpha  + alpha1_w_m*(N_Y+N_O)+  +Q+similar_educ + alpha2_w*log(1+N_Y+N_O) + alpha3_w;
    UC_W(1,12+i)=((women_cons_m(1,12+i)).^alpha)/alpha  + alpha1_w_m*(N_Y+N_O)+  +Q+similar_educ ;
    UC_H(1,1+i) =((men_cons_m(1,1 +i)).^alpha)/alpha  + alpha1_h_m*(N_Y+N_O)+  +Q+similar_educ  ;
    UC_H(1,12+i)=((men_cons_m(1,12+i)).^alpha)/alpha  + alpha1_h_m*(N_Y+N_O)+  +Q+similar_educ ;
    if (t == T)
        %t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
        %t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
        %t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
        %t16 previous work state - wife, 
        U_W(1,1+i) = UC_W(1,1+i) +t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*WE    +t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t17_w;     
        U_W(1,12+i)= UC_W(1,12+i)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(WE+1)+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t16_w+t17_w;    
        U_H(1,1+i) = UC_H(1,1+i) +t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*WE    +t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t17_h;       
        U_H(1,12+i)= UC_H(1,12+i)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*(WE+1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t16_h+t17_h;  
    else
        %T_MAX = 28;       %HSG:18-45 (28 PERIODS), SC:20-25,CG:22-45, PC:25-45
        %G_exp_w = 5;     %(0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
        %G_exp_h = 5;     %(0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
        %G_kids = 3;    %  children(0, 1-2, 3+)
        %G_prev_w = 2;    % previous work status(employed/unemployed)
        %G_ability_w = 3; % ability wife(high,medium,low)
        %G_ability_h = 3; % ability husband(high,medium,low)
        %G_marr = 2;      %(married/unmarried)
        %G_school_h = 5;  % only husbands schooling since we solve for a representative women given her education
        %G_match = 3;     % match quality(high,medium,low)
        %G_BP_w = 7;      % wife bargening power(0.2, 0.3, 0.4, 0.5, 0.6, 0.7,0.8)
        %G_CS_w = 7;      % wife consumption share(0.2,0.3,0.4,0.5,0.6,0.7,0.8)
        [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ] = value_to_index(WE, HE+1, N_Y, N_O, BP, CS);%calculate EMAX indexes when women unemployed
        %                         EMAX  (t  ,G_exp_w, G_exp_h,G_kids, G_prev_w, G_ability_w, G_ability_h, G_marr, G_school_h, G_match, G_BP_W, G_CS_w)  
        %T
        %t+1
        %exp_wi
        %exp_hi
        %kidsi
        %ability_wi
        %ability_hi
        %HS
        
       % Q_INDEX
       % BPi
       % CSi
       % size(EMAX_W)
        U_W(1,1+i) =UC_W(1,1+i) +beta0*EMAX_W(t+1,exp_wi   ,exp_hi, kidsi  ,  1  , ability_wi,    ability_hi,     1  , HS         , Q_INDEX,  BPi   , CSi   );
        U_H(1,1+i) =UC_H(1,1+i) +beta0*EMAX_H(t+1,exp_wi   ,exp_hi, kidsi  ,  1  , ability_wi,    ability_hi,     1  , HS         , Q_INDEX,  BPi   , CSi   );
        [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ] = value_to_index(WE+1, HE+1, N_Y, N_O, BP, CS);%calculate EMAX indexes when women employed            
        U_W(1,12+i)=UC_W(1,12+i)+beta0*EMAX_W(t+1,exp_wi   ,exp_hi, kidsi  ,  2  , ability_wi,    ability_hi,     1  , HS         , Q_INDEX,  BPi   , CSi   );
        U_H(1,12+i)=UC_H(1,12+i)+beta0*EMAX_H(t+1,exp_wi   ,exp_hi, kidsi  ,  2  , ability_wi,    ability_hi,     1  , HS         , Q_INDEX,  BPi   , CSi   );
    end
end

UC_W_S(1,1) = alpha1_w_s*(N_Y+N_O)+   alpha2_w*log(1+N_Y+N_O) + alpha3_w;
UC_W_S(1,2) = ((women_cons_s(1,2)).^alpha)/alpha  + alpha1_w_s*(N_Y+N_O);
UC_H_S = ((men_cons_s).^alpha)/alpha;
if (t == T)
    U_W_S(1,1)=UC_W_S(1,1)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*WE    +t13_w*(N_Y+N_O);     
    U_W_S(1,2)=UC_W_S(1,2)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(WE+1)+t13_w*(N_Y+N_O)+t16_w;       
    U_H_S   = UC_H_S  +t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+t13_h*(N_Y_H+N_O_H); 
else
    [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ] = value_to_index(WE  ,   0 , N_Y, N_O   , 0,0);
    U_W_S(1,1)=UC_W_S(1,1)+beta0*EMAX_W(t+1,exp_wi   ,1     , kidsi  ,  1  , ability_wi,    1         ,     2  , 1         , 1,  1   , 1   );   
    [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ] = value_to_index(WE+1, 0   , N_Y, N_O   , 0,0);
    U_W_S(1,2)=UC_W_S(1,2)+beta0*EMAX_W(t+1,exp_wi   ,1     , kidsi  ,  2  , ability_wi,    1         ,     2  , 1         , 1,  1   , 1   );
    [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ] = value_to_index(0   , HE+1, N_Y_H,N_O_H, 0,0);
    U_H_S   =UC_H_S   +beta0*EMAX_H(t+1,exp_wi   ,exp_hi, kidsi  ,  1  , 1         ,    ability_hi,     2  , HS         , 1,  1   , 1   );
end
 if (M == 1) || (CHOOSE_HUSBAND == 1)
       %total_cons
       %women_cons_m
       %men_cons_m
       %UC_W
       %UC_W_S
       %UC_H
       %Q
       %similar_educ
    end
if M == 0  &&  CHOOSE_HUSBAND == 0
    U_W(1, 1:22) = -99999;
    U_H(1, 1:22) = -99999;
end
if CHOOSE_WORK_W == 0
    U_W(1, 12:22) = -99999; % ALL 11 EMPLOYMENT OPTIONS ARE UNAVAILABLE
    U_H(1, 12:22) = -99999;
    U_W_S(2)= -99999;
end
                
    