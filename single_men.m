function [EMAX_H_T_OUT, iter_count] = single_men(const_values, HS, t, EMAX_W_T, EMAX_H_T, DRAW_B, TERMINAL, wives)

p0_h = const_values.p0_h;
p1_h = const_values.p1_h;
p2_h = const_values.p2_h;  

THIS_T = 1;
NO_HS = 1;

H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0; 
W = 1;
H = 0;
UNMARRIED = 2;

iter_count = 0;

EMAX_H_T_OUT(THIS_T, :, :, :, :, :, :, :, NO_HS, :, :, :) = EMAX_H_T(THIS_T, :, :, :, :, :, :, :, NO_HS, :, :, :);

if (HS == 1)
    H_HSD = 1;AGE = 18;
    T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=28
    age_index = 0;
elseif (HS == 2)
    H_HSG = 1;AGE = 18;
    T_END= TERMINAL - AGE+1; % TERMINAL = 45, T=28
    age_index = 0;
elseif (HS == 3)  
    H_SC = 1; AGE = 20;
    T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=26
    age_index = 2;
    if (t > T_END)
        return
    end
elseif (HS == 4)
    H_CG = 1;AGE = 22;
    T_END = TERMINAL - AGE+1;% TERMINAL = 45, T=24
    age_index = 4;
    if (t > T_END)
        return
    end
else
    H_PC = 1; AGE = 25;
    T_END = TERMINAL - AGE+1;   % TERMINAL = 45, T=21
    age_index = 7;
    if (t > T_END)
        return
    end
end

for H_EXP_INDEX = 1 : const_values.exp_h %HUSBAND EXPERENCE - 5 GRID LEVEL
   for ability_hi = 1 : const_values.ability_h   %husband ability - high, medium, low
        ability_h = const_values.normal_arr(ability_hi)*const_values.sigma(4,4);
        ADD_EMAX = 0;
        for draw_b = 1 : DRAW_B
            % DRAW A WIFE 
            WS = 2;   %if no wife, the default is 2, WS goes from 2 to 5, so in martix we use WS-1
            similar_educ = 0;
            WE = 0;
            M = 0;
            Q = 0; Q_INDEX = 1;
            N_KIDS = 0;
            N_KIDS_H = 0;
            HE = const_values.exp_vector(1, H_EXP_INDEX);
            prev_state_w = 0;
            ability_w = 0;
            ability_wi = 1;
            wage_h = 0; wage_w = 0;BP = 0.5;JOB_OFFER_W = 0;
            HSD = 0; HSG = 0; SC = 0; CG = 0; PC = 0;
            %w_draws_b = rand(DRAW_B, T_MAX, SCHOOL_GROUPS, 6);
            %1- wife; 2-wife EXP+SCHOOLING; 3-wife ABILITY; 4 - INITIAL MATCH QUALITY; 5 - JOB OFFER FOR MARRIED MEN AND WOMEN EMAX; 6-JOB OFFER FOR SINGLE MEN EMAX 
            P_WIFE = (exp(p0_h+p1_h*(AGE+t)+p2_h*(AGE+t).^2))/(1+exp(p0_h+p1_h*(AGE+t)+p2_h*(AGE+t).^2));   % PROBABILITY OF MEETING A POTENTIAL HUSBAND
            if const_values.h_draws_b(draw_b,t,HS,1) < P_WIFE
                 CHOOSE_WIFE = 1;
                 [ability_w, ability_wi, Q, Q_INDEX,WS,HSD, HSG, SC, CG, PC,WE, similar_educ, prev_state_w]=...
                                       draw_wife(const_values, wives, t, age_index, draw_b, const_values.h_draws_b, HS);
            else
                CHOOSE_WIFE = 0;
            end 
            %%%%%%%%%%%%%%%%%%%%%%%%    HUSBAND WAGE:    %%%%%%%%%%%%%%%%
            [wage_h, JOB_OFFER_H] = calculate_wage(const_values, H, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE,...
                0, const_values.epsilon_b(draw_b, t, HS, 1), prev_state_w, ability_w, ability_h,t);
            %%%%%%%%%%%%%%%%%%%%%%%%   JOB OFFER PROBABILITY + WAGE WIFE     %%%%%%%%%%%%%%%%
            if  (CHOOSE_WIFE == 1)
                [wage_w, JOB_OFFER_W] = calculate_wage(const_values, W, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE,...
                    const_values.w_draws(draw_b, t, HS, 1), const_values.epsilon_b(draw_b, t, WS, 2), prev_state_w, ability_w, ability_h,t);
            end
            %%%%%%%%%%%%%%%%%%%%%%%% calculate husbands and wives utility     %%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%% from each option + -999 for unavailable  %%%%%%%%%%%%%%%
            [U_W,U_H,U_W_S,U_H_S] = calculate_utility(const_values, EMAX_W_T, EMAX_H_T, N_KIDS, N_KIDS_H,...
                wage_h, wage_w, CHOOSE_WIFE, JOB_OFFER_H, JOB_OFFER_W, ...
                M, similar_educ, Q, Q_INDEX, HS, WS, t, ability_hi, ability_wi, HE, WE, BP, T_END, 1, age_index);  
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%   MAXIMIZATION - MARRIAGE + WORK DESICION  %%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if (CHOOSE_WIFE == 1)
                BP = nash(const_values, U_W, U_H, U_W_S, U_H_S, 0.5); % Nash bargaining at first period of marriage  
                %BP_INDEX = round(BP*10)+1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %   at this point the BP IS .5 IF NO MARRIAGE AND NO OFFER, is calculated by nash if offer  and is from previous period if already married %          
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if U_W_S(1)>U_W_S(2)
                outside_option_w_v = U_W_S(1);
                outside_option_w = 1; %"unemployed"
            else        
                outside_option_w_v = U_W_S(2);
                outside_option_w = 2; %employed
            end
            outside_option_h_v = U_H_S;
            %outside_option_h = 2; %employed

            if (CHOOSE_WIFE == 1 && BP > -1)
            % marriage decision - outside option value wife
                [M,~,~,~,max_weighted_utility_index] = marriage_decision(U_H, U_W, BP, outside_option_h_v,outside_option_w_v,outside_option_w, WE, HE);
                if (M == 1)
                    ADD_EMAX = ADD_EMAX + U_H(max_weighted_utility_index);
                else
                    ADD_EMAX = ADD_EMAX + U_H_S;
                end
            else 
                ADD_EMAX = ADD_EMAX + U_H_S;
            end
        end   % end draw backward loop
        EMAX_H_T_OUT(THIS_T, 1, H_EXP_INDEX, 1, 1, 1, ability_hi, UNMARRIED, NO_HS, 1, 1, 1) = ADD_EMAX/DRAW_B;
        iter_count = iter_count + 1;
    end % end single men ability loop
end % end single men experience loop
