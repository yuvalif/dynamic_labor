function EMAX_W_T = single_women(WS, t, EMAX_W_T, EMAX_H_T, DRAW_B, TERMINAL, husbands_2, husbands_3, husbands_4, husbands_5)
global exp_vector;
global normal_arr;
global sigma;
global G_epsilon_b;
global G_h_draws_b;
global G_w_draws;
global G_w_draws_b;
global p0_w; global p1_w; global p2_w;
global G_exp_w;
global G_kids;

NO_T = 1;
NO_WS = 1;

W = 1;
H = 0;
HSD = 0; HSG = 0; SC = 0; CG = 0; PC = 0;
U_W = 0;
U_H = 0;
N_KIDS_H = 0;
CHOOSE_WIFE = 0;
UNMARRIED = 2;
    if (WS == 2)
        HSG = 1;AGE = 18;
        T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=28
        age_index = 0;
        husbands = husbands_2;
    elseif (WS == 3)  
        SC = 1; AGE = 20;
        T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=26
        age_index = 2;
        if (t > T_END)
            return
        end
        husbands = husbands_3;
    elseif (WS == 4)
        CG = 1;AGE = 22;
        T_END = TERMINAL - AGE+1;% TERMINAL = 45, T=24
        age_index = 4;
        if (t > T_END)
            return
        end
        husbands = husbands_4;
    else
        PC = 1; AGE = 25;
        T_END = TERMINAL - AGE+1;   % TERMINAL = 45, T=21
        age_index = 7;
        if (t > T_END)
            return
        end
        husbands = husbands_5;
    end
    for W_EXP_INDEX = 1 : G_exp_w %WIFE EXPERENCE - 5 GRID LEVEL
        WE = exp_vector(1, W_EXP_INDEX);
        for ability_wi = 1:3   %husband ability - high, medium, low
            ability_w = normal_arr(ability_wi)*sigma(4,4);
            ADD_EMAX = 0;
            for N_KIDS = 1: G_kids
                for prev = 1: 2 
                    prev_state_w = prev - 1;
                    for draw_b = 1 : DRAW_B
                        % DRAW A HUSBAND 
                        similar_educ = 0;
                        HE = 0;
                        HS = 1; %in forward solving school_group represents wife's education, here it represents the education of the individual we calculate the EMAX  for
                        M = 0;
                        Q = 0; Q_INDEX = 1;
                        ability_h = 0;
                        ability_hi = 1;
                        wage_h = 0; wage_w = 0; BP = 0.5;
                        JOB_OFFER_W = 0; JOB_OFFER_H = 1;
                        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
                        %w_draws_b = rand(DRAW_B, T_MAX, SCHOOL_GROUPS, 6);
                        %1- wife; 2-wife EXP+SCHOOLING; 3-wife ABILITY; 4 - INITIAL MATCH QUALITY; 5 - JOB OFFER FOR MARRIED MEN AND WOMEN EMAX; 6-JOB OFFER FOR SINGLE MEN EMAX 
                        P_HUSBAND =  (exp(p0_w+p1_w*(AGE+t)+p2_w*(AGE+t).^2))/(1+exp(p0_w+p1_w*(AGE+t)+p2_w*(AGE+t).^2));   % PROBABILITY OF MEETING A POTENTIAL HUSBAND
                        if G_h_draws_b(draw_b,t,HS,1) < P_HUSBAND
                             CHOOSE_HUSBAND = 1;
                             [ability_h, ability_hi, Q, Q_INDEX,HS,H_HSD, H_HSG, H_SC, H_CG, H_PC,HE, similar_educ ]=...
                                              draw_husband(husbands, t, age_index, draw_b, G_w_draws_b, WS);
                        else
                            CHOOSE_HUSBAND = 0;
                        end 
                        %%%%%%%%%%%%%%%%%%%%%%%%    HUSBAND WAGE:    %%%%%%%%%%%%%%%%
                        if (CHOOSE_HUSBAND == 1)
                           [wage_h, JOB_OFFER_H] = calculate_wage(H, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE,...
                                0, G_epsilon_b(draw_b, t, WS, 1), prev_state_w, ability_w, ability_h);
                        end
                        %%%%%%%%%%%%%%%%%%%%%%%%   JOB OFFER PROBABILITY + WAGE WIFE     %%%%%%%%%%%%%%%%
                        [wage_w, JOB_OFFER_W] = calculate_wage(W, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE,...
                               G_w_draws(draw_b, t, WS, 1), G_epsilon_b(draw_b, t, WS, 2), prev_state_w, ability_w, ability_h);
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%   MAXIMIZATION - MARRIAGE + WORK DESICION  %%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %   at this point the BP IS .5 IF NO MARRIAGE AND NO OFFER, is calculated by nash if offer  and is from previous period if already married
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%% calculate husbands and wives utility     %%%%%%%%%%%%%%%
                        %%%%%%%%%%%%%%%%%%%%%%%% from each option + -999 for unavailable  %%%%%%%%%%%%%%%
                        [U_W,U_H,U_W_S,U_H_S]=calculate_utility(EMAX_W_T, EMAX_H_T, N_KIDS, N_KIDS_H, wage_h, wage_w,...
                            CHOOSE_WIFE, JOB_OFFER_H, JOB_OFFER_W, ...
                            M, similar_educ, Q, Q_INDEX, HS, WS, t, ability_hi, ability_wi, HE, WE, BP, T_END, 0);  
                        if (CHOOSE_HUSBAND == 1)
                            [BP]=nash(U_W,U_H,U_W_S,U_H_S,0.5); % Nash bargaining at first period of marriage  
                            %BP_INDEX = round(BP*10)+1;
                        end
                        
                        if U_W_S(1)>U_W_S(2)
                            outside_option_w_v = U_W_S(1);
                            outside_option_w = 1; %unemployed
                        else        
                            outside_option_w_v = U_W_S(2);
                            outside_option_w = 2; %employed
                        end
                        outside_option_h_v = U_H_S;
                        %outside_option_h = 2; %employed

                        if (CHOOSE_HUSBAND == 1 && BP > -1)
                            % marriage decision - outside option value wife
                            [M,~,~,~,max_weighted_utility_index]=marriage_decision(U_H, U_W, BP, outside_option_h_v, ...
                                    outside_option_w_v,outside_option_w, WE, HE);
                        end
                        if (M == 1)
                            ADD_EMAX = ADD_EMAX + U_W(max_weighted_utility_index);
                        elseif (M == 0)
                            ADD_EMAX = ADD_EMAX + outside_option_w_v;
                        end
                    end   % end draw backward loop
                    EMAX_W_T(NO_T, W_EXP_INDEX, 1, N_KIDS, prev, ability_wi, 1, UNMARRIED, 1, NO_WS, 1, 1) = ADD_EMAX/DRAW_B;                
                end % end prev_state_w        
            end % end of kids loop
        end % end single wemen ability loop
    end % end single women experience loop
    
    
