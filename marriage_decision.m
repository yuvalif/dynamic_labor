function [M,prev_state_w,WE,HE,max_weighted_utility_index]=marriage_decision(U_H, U_W, BP, outside_option_h_v,outside_option_w_v,outside_option_w, WE, HE)  
    BP_FLAG_PLUS = 0;
    BP_FLAG_MINUS = 0;
    if (BP<0)
        error()
    end
       looking_for_solution = 1;
       max_iterations = 10;
       M = 0;
       prev_state_w = 0;
        while (looking_for_solution == 1)
            if (max_iterations == 0)
                BP
                BP_FLAG_PLUS
                BP_FLAG_MINUS
            end
            max_iterations = max_iterations - 1;
            weighted_utility=U_H(1:22).*BP+U_W(1:22).*(1-BP);  %weighted utility
            [max_weighted_utility,max_weighted_utility_index]=max(weighted_utility);      % max of weighted utility
           % max_weighted_utility_index
            if (U_H(max_weighted_utility_index) >= outside_option_h_v && U_W(max_weighted_utility_index) >= outside_option_w_v) 
                %the max in married for both is better than outside
                looking_for_solution = 0;
                M = 1 ;
                if (max_weighted_utility_index < 12)   %1-12 WOMEN UNEMPLOYED
                    prev_state_w = 0;
                    WE = WE;
                    HE = HE+1;
                elseif (max_weighted_utility_index > 11)   %12-22: wife employed  + husband employed
                    prev_state_w = 1;
                    WE = WE+1;
                    HE = HE+1;
                else
                    error()
                end            
            elseif (U_H(max_weighted_utility_index)< outside_option_h_v && U_W(max_weighted_utility_index)<outside_option_w_v) 
                %the outside option is better for both - no marriage
                looking_for_solution = 0;
                M = 0 ;
                if (outside_option_w_v == 1)   %3-unmarried+wife unemployed
                    prev_state_w = 0;
                    WE = WE;
                else     %3-unmarried+wife employed
                    prev_state_w = 1;
                    WE = WE+1;
                end    
            elseif (U_H(max_weighted_utility_index) >= outside_option_h_v && U_W(max_weighted_utility_index) < outside_option_w_v) 
                %the outside option is better for women
                % increase the wife bargaining power
                BP=BP-0.1;
                BP_FLAG_MINUS = 1;
                if (BP<0)|| (BP_FLAG_PLUS == 1)%the first condition: no solution the second condition: infinite loop of BP
                    looking_for_solution = 0;
                    M = 0 ;
                    if (outside_option_w == 1)   %3-unmarried+wife unemployed
                        prev_state_w = 0;
                        WE = WE;
                    else     %3-unmarried+wife employed
                        prev_state_w = 1;
                        WE = WE+1;
                    end    
                end    
            elseif (U_H(max_weighted_utility_index) < outside_option_h_v && U_W(max_weighted_utility_index) >= outside_option_w_v) 
                %the outside option is better for husband
                % increase the husband bargaining power
                BP=BP+0.1;
                BP_FLAG_PLUS = 1;
                if (BP>1)||(BP_FLAG_MINUS == 1)%the first condition: no solution the second condition: infinite loop of BP
                    looking_for_solution = 0;
                    M = 0 ;
                    if (outside_option_w == 1)   %3-unmarried+wife unemployed
                        prev_state_w = 0;
                        WE = WE;
                    else     %3-unmarried+wife employed
                        prev_state_w = 1;
                        WE = WE+1;
                    end    
                end    
            else
                error(0)
            end
        end%while - loop over BP, increase/decrease BP 
