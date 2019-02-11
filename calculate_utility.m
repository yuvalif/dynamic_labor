function [U_W,U_H]=calculate_utility(N_Y, N_O,N_Y_H,N_O_H, wage_h, wage_w, CHOOSE_HUSBAND, CHOOSE_WORK_H, CHOOSE_WORK_W, M, STATIC, COUNTER, similar_educ, Q, t, ability_h, ability_h_index,ability_w, ability_w_index, HE,WE)  
% Utility parameters WIFE:  
global alpha1_w ;global alpha2_w ;global alpha3_w ;global alpha1_h ;global alpha2_h;global alpha3_h;
global hp1;global hp2;global hp3; global hp4; global hp5 ;global hp6 ;global hp7 ;global alpha ;global T ;
global t1_w ;global t2_w;global t3_w ;global t4_w;global t5_w ;global t6_w ;global t7_w ;global t8_w ;global t9_w ;global t10_w ;global t11_w ;global t12_w ;global t13_w ;global t14_w ;global t15_w; global t16_w;global t17_w;
global t1_h ;global t2_h;global t3_h ;global t4_h;global t5_h ;global t6_h ;global t7_h ;global t8_h ;global t9_h ;global t10_h ;global t11_h ;global t12_h ;global t13_h ;global t14_h ;global t15_h; global t16_h ;global t17_h;
global HSD; global HSG; global SC; global CG; global PC ;global H_HSD; global H_HSG; global H_SC; global H_CG; global H_PC ;
% decision making - choose from up to 6 options, according to CHOOSE_HUSBAND and CHOOSE_WORK_H, CHOOSE_WORK_W  values
% utility from each option:
% home production - equal for both partners:     1-singe+unemployed
                                    %            2-singe+employed
                                    %            3-married+wife unemployed+ husband employed
                                    %            4-married+wife employed  + husband employed
                                    %            5-married+wife unemployed+ husband unemployed
                                    %            6-married+wife employed  + husband unemployed
%home production technology - parameters    
%global hp1 = global_param(36);         % # of young children influence on work at home hours
%global hp2 = global_param(37);         % # of old children influence on work at home hours
%global hp3 = global_param(38);         % husband leisure 
%global hp4 = global_param(39);         % wife leisure
%global hp5 = global_param(40);         % # of young children influence on consumption  
%global hp6 = global_param(41);         % # of old children influence on consumption
%global hp7 = global_param(42);         % sigma CRRA parameter
%   HP(S)=((1+hp1*N_Y+hp2*N_O)*(hp3+hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_w+wage_h)^hp7)^(1/hp7);

HP(1)=(((1+hp1*N_Y+hp2*N_O)*(hp4)).^hp7+((1+hp5*N_Y+hp6*N_O)*(0            )).^hp7).^(1/hp7);
HP(2)=(((1+hp1*N_Y+hp2*N_O)*(0  )).^hp7+((1+hp5*N_Y+hp6*N_O)*(wage_w       )).^hp7).^(1/hp7);%all cancel out but wage_w if no kids

HP(3)=(((1+hp1*N_Y+hp2*N_O)*(hp4)).^hp7+((1+hp1*N_Y+hp2*N_O)*(0            )).^hp7+((1+hp5*N_Y+hp6*N_O)*(wage_h       )).^hp7).^(1/hp7);
HP(4)=(((1+hp1*N_Y+hp2*N_O)*(0  )).^hp7+((1+hp1*N_Y+hp2*N_O)*(0            )).^hp7+((1+hp5*N_Y+hp6*N_O)*(wage_h+wage_w)).^hp7).^(1/hp7);
HP(5)=(((1+hp1*N_Y+hp2*N_O)*(hp4)).^hp7+((1+hp1*N_Y+hp2*N_O)*(hp3          )).^hp7+((1+hp5*N_Y+hp6*N_O)*(0     )).^hp7).^(1/hp7);
HP(6)=(((1+hp1*N_Y+hp2*N_O)*(0  )).^hp7+((1+hp1*N_Y+hp2*N_O)*(hp3          )).^hp7+((1+hp5*N_Y+hp6*N_O)*(wage_w)).^hp7).^(1/hp7);

HP(7)=((1+hp1*N_Y_H+hp2*N_O_H)*(hp3).^hp7+(1+hp5*N_Y_H+hp6*N_O_H)*(0     ).^hp7).^(1/hp7);
HP(8)=((1+hp1*N_Y_H+hp2*N_O_H)*(0  ).^hp7+(1+hp5*N_Y_H+hp6*N_O_H)*(wage_h).^hp7).^(1/hp7);%all cancel out but wage_w if no kids

% wife utility from each option
% U_W(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;                   
%scale_w = 1 + M*0.7 + (N_Y+N_O)*0.4;
UC_W(1)=(((HP(1)/(1  +(N_Y+N_O)*0.4)).^alpha)/alpha)+alpha1_w+alpha2_w*(N_Y+N_O);
UC_W(2)=(((HP(2)/(1  +(N_Y+N_O)*0.4)).^alpha)/alpha)         +alpha2_w*(N_Y+N_O);
UC_W(3)=(((HP(3)/(1.7+(N_Y+N_O)*0.4)).^alpha)/alpha)+alpha1_w+alpha2_w*(N_Y+N_O)+Q+similar_educ+alpha3_w*(N_Y+N_O);
UC_W(4)=(((HP(4)/(1.7+(N_Y+N_O)*0.4)).^alpha)/alpha)         +alpha2_w*(N_Y+N_O)+Q+similar_educ+alpha3_w*(N_Y+N_O);
UC_W(5)=(((HP(5)/(1.7+(N_Y+N_O)*0.4)).^alpha)/alpha)+alpha1_w+alpha2_w*(N_Y+N_O)+Q+similar_educ+alpha3_w*(N_Y+N_O);
UC_W(6)=(((HP(6)/(1.7+(N_Y+N_O)*0.4)).^alpha)/alpha)         +alpha2_w*(N_Y+N_O)+Q+similar_educ+alpha3_w*(N_Y+N_O);

[HE_IDX_1,HE_IDX_0,WE_IDX_1,WE_IDX_0, N_Y_arr, N_O_arr,M_IDX, UM_IDX,EMP_IDX,UNEMP_IDX  ] = value_to_index(WE, HE, N_Y, N_O);
U_W=zeros(1,6);
if (t == T)
    %t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
    %t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
    %t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
    %t16 previous work state - wife, 
    U_W(1)=UC_W(1)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*WE    +t13_w*(N_Y+N_O);     
    U_W(2)=UC_W(2)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(WE+1)+t13_w*(N_Y+N_O)+t16_w;       
    U_W(3)=UC_W(3)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*WE    +t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t17_w;       
    U_W(4)=UC_W(4)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(WE+1)+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t16_w+t17_w;     
    U_W(5)=UC_W(5)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*WE    +t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE)  +t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O);       
    U_W(6)=UC_W(6)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(WE+1)+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE)  +t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t16_w;     
else

        % EMAX(t,WE,N_Y,N_O,prev_state_W,ability_w_index,M,HE,HS,Q_INDEX, prev_state_h,ability_h_index,bp_dummy )
    if (STATIC == 0 && COUNTER ~= 1)
        U_W(1)=UC_W(1)+beta*EMAX_W(t+1,WE_IDX_0,N_Y_arr,N_O_arr,UNEMP_IDX,ability_w_index,UM_IDX,1       ,1 ,1      ,0+1      ,1             ,0+1     );
        U_W(2)=UC_W(2)+beta*EMAX_W(t+1,WE_IDX_1,N_Y_arr,N_O_arr,EMP_IDX  ,ability_w_index,UM_IDX,1       ,1 ,1      ,0+1      ,1              ,0+1     );
        U_W(3)=UC_W(3)+beta*EMAX_W(t+1,WE_IDX_0,N_Y_arr,N_O_arr,UNEMP_IDX,ability_w_index,M_IDX ,HE_IDX_1,HS,Q_INDEX,EMP_IDX  ,ability_h_index,bp_dummy);
        U_W(4)=UC_W(4)+beta*EMAX_W(t+1,WE_IDX_1,N_Y_arr,N_O_arr,EMP_IDX  ,ability_w_index,M_IDX ,HE_IDX_1,HS,Q_INDEX,EMP_IDX  ,ability_h_index,bp_dummy);
        U_W(5)=UC_W(5)+beta*EMAX_W(t+1,WE_IDX_0,N_Y_arr,N_O_arr,UNEMP_IDX,ability_w_index,M_IDX ,HE_IDX_0,HS,Q_INDEX,UNEMP_IDX,ability_h_index,bp_dummy);
        U_W(6)=UC_W(6)+beta*EMAX_W(t+1,WE_IDX_1,N_Y_arr,N_O_arr,EMP_IDX  ,ability_w_index,M_IDX ,HE_IDX_0,HS,Q_INDEX,UNEMP_IDX,ability_h_index,bp_dummy);
    else
        U_W(1)=UC_W(1);
        U_W(2)=UC_W(2);
        U_W(3)=UC_W(3);
        U_W(4)=UC_W(4);
        U_W(5)=UC_W(5);
        U_W(6)=UC_W(6);
    end
end

if M == 0  &&  CHOOSE_HUSBAND == 0
    U_W(3)  = -99999;
    U_W(4)  = -99999;
    U_W(5)  = -99999;
    U_W(6)  = -99999;
end
if CHOOSE_WORK_W == 0
    U_W(2) = -99999;
    U_W(4) = -99999;
    U_W(6) = -99999;
end
if CHOOSE_WORK_H == 0
    U_W(3) = -99999;
    U_W(4) = -99999;
end
% husband CURRENT utility from four options
% U_H(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;       
if (M == 1 ||  CHOOSE_HUSBAND == 1)
    UC_H(1)=(((HP(7)/(1  +(N_Y_H+N_O_H)*0.4)).^alpha)/alpha)+alpha1_h+alpha2_h*(N_Y_H+N_O_H);   % hp7 and alpha are for single male
    UC_H(2)=(((HP(8)/(1  +(N_Y_H+N_O_H)*0.4)).^alpha)/alpha)         +alpha2_h*(N_Y_H+N_O_H)+t17_h;
    UC_H(3)=(((HP(3)/(1.7+(N_Y+N_O)    *0.4)).^alpha)/alpha)         +alpha2_h*(N_Y+N_O)+Q+similar_educ+alpha3_h*(N_Y+N_O);
    UC_H(4)=(((HP(4)/(1.7+(N_Y+N_O)    *0.4)).^alpha)/alpha)         +alpha2_h*(N_Y+N_O)+Q+similar_educ+alpha3_h*(N_Y+N_O);
    UC_H(5)=(((HP(5)/(1.7+(N_Y+N_O)    *0.4)).^alpha)/alpha)+alpha1_h+alpha2_h*(N_Y+N_O)+Q+similar_educ+alpha3_h*(N_Y+N_O);
    UC_H(6)=(((HP(6)/(1.7+(N_Y+N_O)    *0.4)).^alpha)/alpha)+alpha1_h+alpha2_h*(N_Y+N_O)+Q+similar_educ+alpha3_h*(N_Y+N_O);
    if t == T
        %t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
        %t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
        %t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
        %t16 previous work state - wife, t17 previous work state - husband
        U_H(1)=UC_H(1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE  )+t13_h*(N_Y_H+N_O_H);     
        U_H(2)=UC_H(2)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+t13_h*(N_Y_H+N_O_H);     
        U_H(3)=UC_H(3)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*WE    +t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t17_h;       
        U_H(4)=UC_H(4)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*(WE+1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t16_h+t17_h;  
        U_H(5)=UC_H(5)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*WE    +t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE  )+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ);       
        U_H(6)=UC_H(6)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*(WE+1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE  )+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t16_h;  
    else
        % EMAX(t,WE,N_Y,N_O,prev_state_W,ability_w_index,M,HE,HS,Q_INDEX, prev_state_h,ability_h_index,bp_dummy )
        if (STATIC == 0 && COUNTER ~= 1)
            U_H(1)=UC_H(1)+beta*EMAX_H(t+1,WE_IDX_0,N_Y_arr,N_O_arr,UNEMP_IDX,ability_w_index,UM_IDX,0+1     ,1 ,0+1    ,0+1      ,1              ,0+1);
            U_H(2)=UC_H(2)+beta*EMAX_H(t+1,WE_IDX_1,N_Y_arr,N_O_arr,EMP_IDX  ,ability_w_index,UM_IDX,0+1     ,1 ,0+1    ,0+1      ,1              ,0+1);
            U_H(3)=UC_H(3)+beta*EMAX_H(t+1,WE_IDX_0,N_Y_arr,N_O_arr,UNEMP_IDX,ability_w_index,M_IDX ,HE_IDX_1,HS,Q_INDEX,EMP_IDX  ,ability_h_index,bp_dummy);
            U_H(4)=UC_H(4)+beta*EMAX_H(t+1,WE_IDX_1,N_Y_arr,N_O_arr,EMP_IDX  ,ability_w_index,M_IDX ,HE_IDX_1,HS,Q_INDEX,EMP_IDX  ,ability_h_index,bp_dummy);
            U_H(5)=UC_H(5)+beta*EMAX_H(t+1,WE_IDX_0,N_Y_arr,N_O_arr,UNEMP_IDX,ability_w_index,M_IDX ,HE_IDX_0,HS,Q_INDEX,UNEMP_IDX,ability_h_index,bp_dummy);
            U_H(6)=UC_H(6)+beta*EMAX_H(t+1,WE_IDX_1,N_Y_arr,N_O_arr,EMP_IDX  ,ability_w_index,M_IDX ,HE_IDX_0,HS,Q_INDEX,UNEMP_IDX,ability_h_index,bp_dummy);
        else
            U_H(1)=UC_H(1);
            U_H(2)=UC_H(2);
            U_H(3)=UC_H(3);
            U_H(4)=UC_H(4);
            U_H(5)=UC_H(5);
            U_H(6)=UC_H(6);
        end
    end
                  
    if CHOOSE_WORK_W == 0
        U_H(4) = -99999;
        U_H(6) = -99999;
    end
    if CHOOSE_WORK_H == 0
        U_H(3) = -99999;
        U_H(4) = -99999;
        U_H(2) = -99999;
    end
else   % no husband and no marriage offer
    U_H(1:6)=0;
end    