function married_couple(WS, t, G_exp_w, G_exp_h, G_kids, G_prev_w, G_school_h, G_match, G_BP_W, DRAW_B, TERMINAL)
global exp_vector;
global normal_arr;
global sigma;
global EMAX_W;
global EMAX_H;
global G_epsilon_b;
global G_w_draws;
global beta11_w; global beta12_w; global beta13_w; global beta14_w;
global beta21_w; global beta22_w; global beta23_w; global beta24_w;
global beta31_w; global beta32_w; global beta33_w; global beta34_w;
global beta10_h; global beta11_h; global beta12_h; global beta13_h; global beta14_h;
global beta20_h; global beta21_h; global beta22_h; global beta23_h; global beta24_h;
global beta30_h; global beta31_h; global beta32_h; global beta33_h; global beta34_h;
global row0_w;   global row11_w;  global row12_w;  global row13_w;  global row14_w; global row2_w;
global EDUC_MATCH_2; global EDUC_MATCH_3; global EDUC_MATCH_4; global EDUC_MATCH_5; 

    MARRIED = 1;
    % TODO check initializations
    HSG = 0; SC = 0; CG = 0; PC = 0;
    if (WS == 2)
        HSG = 1;AGE = 18;
        T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=28
    elseif (WS == 3)  
        SC = 1; AGE = 20;
        T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=26
        if (t > T_END)
            return
        end
     elseif (WS == 4)
        CG = 1;AGE = 22;
        T_END = TERMINAL - AGE+1;% TERMINAL = 45, T=24
        if (t > T_END)
            return
        end
     else
        PC = 1; AGE = 25;
        T_END = TERMINAL - AGE+1;   % TERMINAL = 45, T=21
        if (t > T_END)
            return
        end
    end
    for W_EXP_INDEX = 1 : G_exp_w %WIFE EXPERENCE - 5 GRID LEVEL
        WE = exp_vector(1, W_EXP_INDEX);
        for H_EXP_INDEX = 1 : G_exp_h %HUSBAND EXPERENCE - 5 GRID LEVEL
            HE = exp_vector(1, H_EXP_INDEX);
            for N_KIDS = 1 : G_kids
                for ability_wi = 1:3   %husband ability - high, medium, low
                    ability_w = normal_arr(ability_wi)*sigma(4,4);
                    for ability_hi = 1:3   %husband ability - high, medium, low
                        ability_h = normal_arr(ability_hi)*sigma(4,4);
                        for prev = 1 : G_prev_w
                            prev_state_w = prev - 1;
                            for HS = 1 : G_school_h %5 levels 
                                % TODO: check following initializations
                                H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
                                if (HS == 1)
                                    H_HSD = 1;
                                elseif (HS == 2)
                                    H_HSG = 1;
                                elseif (HS == 3)  
                                    H_SC = 1;
                                 elseif (HS == 4)
                                    H_CG = 1;
                                 else
                                    H_PC = 1;
                                end
                                if HS==2 && WS==2
                                    similar_educ = EDUC_MATCH_2;
                                elseif HS==3 && WS==3	
                                    similar_educ = EDUC_MATCH_3;
                                elseif HS==4 && WS==4	
                                    similar_educ = EDUC_MATCH_4;
                                elseif HS==5 && WS==5	
                                    similar_educ = EDUC_MATCH_5;
                                else
                                    similar_educ = 0;
                                end	
                                for Q_INDEX = 1 : G_match %3 level
                                    Q = normal_arr(Q_INDEX)*sigma(5,5);
                                    for BPi = 1 : G_BP_W % 7 levels
                                        BP = 0.1 + BPi./10 ;  % the grid is 0.2 - 0.8 : 7 levels
                                        ADD_EMAX_W = 0;
                                        ADD_EMAX_H = 0;
                                        for draw_b = 1 : DRAW_B
                                            %%%%%%%%%%%%%%%%%%%%%%%%    HUSBAND WAGE:    %%%%%%%%%%%%%%%%
                                            JOB_OFFER_H = 1;
                                            epsilon = G_epsilon_b(draw_b, t, WS, 1);
                                            tmp1 = ability_h + beta10_h*(HE*H_HSD) + beta11_h*(HE*H_HSG) + beta12_h*(HE*H_SC) + ...
                                                beta13_h*(HE*H_CG) + beta14_h*(HE*H_PC) + beta20_h*(HE*H_HSD).^2 + beta21_h*(HE*H_HSG).^2 + ...
                                                beta22_h*(HE*H_SC).^2 + beta23_h*(HE*H_CG).^2 + beta24_h*(HE*H_PC).^2 +...
                                                beta30_h*H_HSD + beta31_h*H_HSG + beta32_h*H_SC + beta33_h*H_CG + beta34_h*H_PC;
                                            tmp2 = epsilon*sigma(1,1);
                                            wage_h = exp(tmp1 + tmp2);
                                            %%%%%%%%%%%%%%%%%%%%%%%%   JOB OFFER PROBABILITY + WAGE WIFE     %%%%%%%%%%%%%%%%
                                            epsilon =  G_epsilon_b(draw_b, t, WS, 2);
                                            w_draw =  G_w_draws(draw_b, t, WS, 1);
                                            PROB_TMP = row0_w*prev_state_w + row11_w*HSG + row12_w*SC + row13_w*CG + row14_w*PC + row2_w*WE;
                                            PROB_W = exp(PROB_TMP)/(1+exp(PROB_TMP));
                                            if PROB_W > w_draw
                                                JOB_OFFER_W = 1;
                                                tmp1 = ability_w + beta11_w*(WE*HSG) + beta12_w*(WE*SC) + beta13_w*(WE*CG) + beta14_w*(WE*PC) +...
                                                    beta21_w*(WE*HSG).^2 + beta22_w*(WE*SC).^2 + beta23_w*(WE*CG).^2 + beta24_w*(WE*PC).^2 +...
                                                    beta31_w*HSG+beta32_w*SC + beta33_w*CG + beta34_w*PC;
                                                tmp2 = epsilon*sigma(2,2);
                                                wage_w = exp(tmp1 + tmp2);
                                            else
                                                JOB_OFFER_W = 0;
                                                wage_w = 0;
                                            end   
                                            %%%%%%%%%%%%%%%%%%%%%%%% calculate husbands and wives utility     %%%%%%%%%%%%%%%
                                            %%%%%%%%%%%%%%%%%%%%%%%% from each option + -999 for unavailable  %%%%%%%%%%%%%%%
                                            CHOOSE_WIFE = 1; M = 1;
                                            [U_W, U_H, U_W_S, U_H_S]=calculate_utility(N_KIDS, N_KIDS, wage_h, wage_w, CHOOSE_WIFE, JOB_OFFER_H, JOB_OFFER_W, ...
                                                M, similar_educ, Q,Q_INDEX,HS,WS,  t, ability_hi, ability_wi, HE,WE, BP, T_END);
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            %%%%%%%%%%%%%%%%%%%%%%%%   MAXIMIZATION - MARRIAGE + WORK DESICION  %%%%%%%%%%%%%
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            if U_W_S(1)>U_W_S(2)
                                                outside_option_w_v = U_W_S(1);
                                                outside_option_w = 1; %"unemployed"
                                            else        
                                                outside_option_w_v = U_W_S(2);
                                                outside_option_w = 2; %employed
                                            end
                                            outside_option_h_v = U_H_S;
                                            % outside_option_h = 2; %employed

                                            % marriage decision - outside option value wife
                                            [M,prev_state_w,WE,HE,max_weighted_utility_index]=marriage_decision(U_H, U_W, BP, outside_option_h_v,...
                                                outside_option_w_v,outside_option_w, WE, HE);
                                             if (M == 1)
                                                ADD_EMAX_H = ADD_EMAX_H + U_H(max_weighted_utility_index);
                                                ADD_EMAX_W = ADD_EMAX_W + U_W(max_weighted_utility_index);
                                            else
                                                ADD_EMAX_H = ADD_EMAX_H + U_H_S;
                                                ADD_EMAX_W = ADD_EMAX_W + outside_option_w_v;
                                            end   
                                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                        end   % end draw backward loop
                                        [exp_wi, exp_hi, kidsi, ~, ~] = value_to_index(WE, HE , N_KIDS, BP, 1);
                                        EMAX_W(t, exp_wi, exp_hi, kidsi, prev, ability_wi, ability_hi, MARRIED, HS, WS, Q_INDEX, BPi) = ADD_EMAX_W/DRAW_B;
                                        EMAX_H(t, exp_wi, exp_hi, kidsi, prev, ability_wi, ability_hi, MARRIED, HS, WS, Q_INDEX, BPi) = ADD_EMAX_H/DRAW_B;
                                    end   % end BP  loop
                                end   % end match quality loop
                            end   % end husband schooling loop
                        end   % end prev state w loop
                    end   % end husbands ability loop
                end   % end wife's ability loop
            end   % end kids loop
       end % end married men experience loop
    end % end married women experience loop

