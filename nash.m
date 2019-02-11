function [BP]=nash(M,U_W,U_H, BP);
                    global bp_vector;
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
                    weighted_utility=U_H(3:6).*BP+U_W(3:6).*(1-BP);  %weighted utility
                    [max_weighted_utility,max_weighted_utility_index]=max(weighted_utility);      % max of weighted utility
                   % max_weighted_utility_index=find(weighted_utility==max(weighted_utility(:)));  % the index:1-4 of max of weighted utility
                    % leave only positive surplus for both
                    for tmp=1:4
                        if ((U_W(tmp+2)-outside_option_w_v)>0 && (U_H(tmp+2)-outside_option_h_v)>0)%if positive surplus for both
                            nash_value(tmp) =((U_W(tmp+2)-outside_option_w_v).^0.5)*((U_H(tmp+2)-outside_option_h_v).^0.5) ;  %3-married+wife unemployed+ husband employed
                        else
                            nash_value(tmp)=-9999;
                        end
                    end
                    [max_nash_value,max_nash_value_index] = max(nash_value);% the value and index:1-4 of max of weighted utility
                
                    %%%%%   find the value of the bargaining power %%%%%%
                    if (max_nash_value> -999)%%there is at least one option with positive surplus for both
                        if(max_nash_value_index==max_weighted_utility_index && max_nash_value> -999)  %3-married+wife unemployed+ husband employed
                            BP = 0.5;
                        else
                            weighted_utility_option(:,1)=U_H(3).*bp_vector+U_W(3).*(1-bp_vector);  %weighted utility
                            weighted_utility_option(:,2)=U_H(4).*bp_vector+U_W(4).*(1-bp_vector);  %weighted utility
                            weighted_utility_option(:,3)=U_H(5).*bp_vector+U_W(5).*(1-bp_vector);  %weighted utility
                            weighted_utility_option(:,4)=U_H(6).*bp_vector+U_W(6).*(1-bp_vector);  %weighted utility
                            posibilities=(weighted_utility_option(:,max_nash_value_index)==max(weighted_utility_option')');      %a 11 elements vector, with 1 for all the alpha-bp where 3 is bigger than 4, all possible alphas
                            ind1 = 0; ind2 = 0;
                            for tmp=1:5
                                if posibilities(tmp)==1
                                    ind1=tmp;
                                end
                            end
                            for tmp=5:1
                                if posibilities(6+tmp)==1
                                    ind2=6+tmp;
                                end
                            end
                            if (ind1 ~=0 || ind2~=0)%need to update BP
                                 if (abs(6-ind1)<abs(6-ind2)) 
                                      BP=(ind1-1)*0.1;
                                 else
                                      BP=(ind2-1)*0.1;    
                                 end
                            end
                        end 
                    else
                        BP = -1;
                    end %(max_nash_value> -999)