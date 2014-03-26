function [M,marriage_choice, prev_state_w, WE, emp_choice_w, prev_state_h, HE, emp_choice_h]=choose(M, CHOOSE_HUSBAND, U_W, U_H, 

if (M == 1 || CHOOSE_HUSBAND == 1 )
    % need optimization - not efficient programming      
    M_T_minus_1 = M;
    % marriage decision - outside option value wife
    if U_W(1)>U_W(2)
        outside_option_w_v = U_W(1);
        outside_option_w = 1; %"unemployed"
    else        
        outside_option_w_v = U_W(2);
        outside_option_w = 2; %employed
    end
    if U_H(1)>U_H(2)
        outside_option_h_v = U_H(1);
        outside_option_h = 1; %"unemployed"
    else        
        outside_option_h_v = U_H(2);
        outside_option_h = 2; %employed
    end
    looking_for_solution = 1;
    while (looking_for_solution == 1)
        weighted_utility=U_H(3:6).*BP+U_W(3:6).*(1-BP);  %weighted utility
        max_weighted_utility=max(weighted_utility);      % max of weighted utility
        max_weighted_utility_index=find(weighted_utility==max(weighted_utility(:)));  % the index:1-4 of max of weighted utility
        if (U_H(max_weighted_utility_index+2)> outside_option_h_v && U_W(max_weighted_utility_index+2)> outside_option_w_v) %the max in married for both is better than outside
            looking_for_solution = 0;
            M = 1 ;
            marriage_choice(draw_f,t,school_group) = 1;
            if (max_weighted_utility_index+2 == 3)   %3-married+wife unemployed+ husband employed
                prev_state_w = 0;
                WE = WE;
                emp_choice_w(draw_f,t,school_group) = 0;
                prev_state_h = 1;
                HE = HE+1;
                emp_choice_h(draw_f,t,school_group) = 1;
            elseif (max_weighted_utility_index+2 == 4)   %4-married+wife employed  + husband employed
                prev_state_w = 1;
                WE = WE+1;
                emp_choice_w(draw_f,t,school_group) = 1;
                prev_state_h = 1;
                HE = HE+1;
                emp_choice_h(draw_f,t,school_group) = 1;    
            elseif (max_weighted_utility_index+2 == 5   %5-married+wife unemployed+ husband unemployed
                prev_state_w = 0;
                WE = WE;
                emp_choice_w(draw_f,t,school_group) = 0;
                prev_state_h = 0;
                HE = HE;
                emp_choice_h(draw_f,t,school_group) = 0;                   
                elseif (max_weighted_utility_index+2 == 5   %6-married+wife employed  + husband unemployed
                prev_state_w = 1;
                WE = WE+1;
                emp_choice_w(draw_f,t,school_group) = 1;
                prev_state_h = 0;
                HE = HE;
                emp_choice_h(draw_f,t,school_group) = 0;                   
            else
                error()
            end            
        elseif (U_H(max_weighted_utility_index+2)< outside_option_h_v && U_W(max_weighted_utility_index+2)<outside_option_w_v) %the outside option is better for both - no marriage
            looking_for_solution = 0;
            M = 0 ;
            marriage_choice(draw_f,t,school_group) = 0;
            if (outside_option_w == 1);   %3-unmarried+wife unemployed
                prev_state_w = 0;
                WE = WE;
                emp_choice_w(draw_f,t,school_group) = 0;
            else     %3-unmarried+wife employed
                prev_state_w = 1;
                WE = WE+1;
                emp_choice_w(draw_f,t,school_group) = 1;
            end    
            if (outside_option_h == 1);   %3-unmarried+husband unemployed
                prev_state_h = 0;
                HE = HE;
                emp_choice_h(draw_f,t,school_group) = 0;
            else     %3-unmarried+husband employed
                prev_state_h = 1;
                HE = HE+1;
                emp_choice_h(draw_f,t,school_group) = 1;
            end  
        elseif (U_H(max_weighted_utility_index+2) > outside_option_h_v && U_W(max_weighted_utility_index+2) < outside_option_w_v) %the outside option is better for women
        % increase the wife bargaining power
            BP=BP-0.1;
            if (BP<0)
                looking_for_solution = 0;
                M = 0 ;
                marriage_choice(draw_f,t,school_group) = 0;
                if (outside_option_w == 1);   %3-unmarried+wife unemployed
                    prev_state_w = 0;
                    WE = WE;
                    emp_choice_w(draw_f,t,school_group) = 0;
                else     %3-unmarried+wife employed
                    prev_state_w = 1;
                    WE = WE+1;
                    emp_choice_w(draw_f,t,school_group) = 1;
                end    
                if (outside_option_h == 1);   %3-unmarried+husband unemployed
                    prev_state_h = 0;
                    HE = HE;
                    emp_choice_h(draw_f,t,school_group) = 0;
                else     %3-unmarried+husband employed
                    prev_state_h = 1;
                    HE = HE+1;
                    emp_choice_h(draw_f,t,school_group) = 1;
                end  
            end    
        elseif (U_H(max_weighted_utility_index+2) < outside_option_h_v && U_W(max_weighted_utility_index+2) > outside_option_w_v) %the outside option is better for husband
        % increase the husband bargaining power
            BP=BP+0.1;
            if (BP>1)
                looking_for_solution = 0;
                M = 0 ;
                marriage_choice(draw_f,t,school_group) = 0;
                if (outside_option_w == 1);   %3-unmarried+wife unemployed
                    prev_state_w = 0;
                    WE = WE;
                    emp_choice_w(draw_f,t,school_group) = 0;
                else     %3-unmarried+wife employed
                    prev_state_w = 1;
                    WE = WE+1;
                    emp_choice_w(draw_f,t,school_group) = 1;
                end    
                if (outside_option_h == 1);   %3-unmarried+husband unemployed
                    prev_state_h = 0;
                    HE = HE;
                    emp_choice_h(draw_f,t,school_group) = 0;
                else     %3-unmarried+husband employed
                    prev_state_h = 1;
                    HE = HE+1;
                    emp_choice_h(draw_f,t,school_group) = 1;
                end  
            end    
        end
    endwhile
elseif ( M==0 && CHOOSE_HUSBAND == 0)
    M = 0 ;
    marriage_choice(draw_f,t,school_group) = 0;
    if (outside_option_w == 1);   %3-unmarried+wife unemployed
        prev_state_w = 0;
        WE = WE;
        emp_choice_w(draw_f,t,school_group) = 0;
    else     %3-unmarried+wife employed
        prev_state_w = 1;
        WE = WE+1;
        emp_choice_w(draw_f,t,school_group) = 1;
    end    
    prev_state_h = 0;
    HE = 0;
    emp_choice_h(draw_f,t,school_group) = -999;
end    