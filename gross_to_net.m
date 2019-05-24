function [net_income_s_h, net_income_s_w, net_income_m, net_income_m_unemp ] = gross_to_net(const_values, N_KIDS, wage_w, wage_h, t, age_index)
% the tax brackets and the deductions and exemptions starts at 1980 and
% ends at 2035. most of the sample turn 18 at 1980 (NLSY79)
row_number = t + age_index;
% row number on matrix 1980-2035. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deductions_m = const_values.ded(row_number,2);
exemptions_m = const_values.ded(row_number,4) + const_values.ded(row_number,6)*N_KIDS;
deductions_s = const_values.ded(row_number,3); 
exemptions_s_w = const_values.ded(row_number,5) + const_values.ded(row_number,6)*N_KIDS;
exemptions_s_h = const_values.ded(row_number,5);

net_income_s_h = 0;net_income_s_w = 1;net_income_m = 0;net_income_m_unemp = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE NET INCOME FOR SINGLE WOMEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (wage_w>0)
    shift = 0; % single 2-22, married 23-42
    reduced_income_s_w = wage_w - deductions_s - exemptions_s_w;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE INCOME TAX           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tax = 0;
    if reduced_income_s_w > 0
        for i = 2:10
            if (reduced_income_s_w < const_values.tax(row_number,i+shift))
                tax = tax + (reduced_income_s_w - const_values.tax(row_number,(i-1)+shift))*const_values.tax(row_number,11+(i-1)+shift);
            break
            end
            tax = tax + (const_values.tax(row_number,i+shift) - const_values.tax(row_number,(i-1)+shift)) ...
                   * const_values.tax(row_number,11+(i-1)+shift);
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE EICT                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EICT = 0;
 
    if (wage_w < const_values.ded(row_number,8+6*N_KIDS))               % first interval  credit rate
        EICT = wage_w*const_values.ded(row_number,7+6*N_KIDS);
        tax = 0;
    elseif  ((wage_w > const_values.ded(row_number,8+6*N_KIDS))...      % second (flat) interval - max EICT 
            && (wage_w < const_values.ded(row_number,11+6*N_KIDS)))
        EICT = const_values.ded(row_number,9+6*N_KIDS);
        tax = 0;
    elseif  ((wage_w > const_values.ded(row_number,11+6*N_KIDS))...     % third interval - phaseout rate
            && (wage_w < const_values.ded(row_number,12+6*N_KIDS)))
        EICT = wage_w*const_values.ded(row_number,10+6*N_KIDS);
        tax = 0;
    else
        EICT = 0;                                                       % income too high for EICT
    end    
    net_income_s_w = wage_w - tax + EICT; 
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE NET INCOME FOR SINGLE MEN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (wage_h > 0)
    shift = 0; % single 2-22, married 23-42
    reduced_income_s_h =  wage_h- deductions_s-exemptions_s_h;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE INCOME TAX           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tax = 0;
    if reduced_income_s_h > 0
        for i = 2:10
            if (reduced_income_s_h < const_values.tax(row_number,i+shift))
                tax = tax + (reduced_income_s_h - const_values.tax(row_number,(i-1)+shift))*const_values.tax(row_number,11+(i-1)+shift);
            break
            end
            tax = tax + (const_values.tax(row_number,i+shift) - const_values.tax(row_number,(i-1)+shift)) ...
                   * const_values.tax(row_number,11+(i-1)+shift);
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE EICT                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EICT = 0;
    N_KIDS_SINGLE = 0;
    if (wage_h < const_values.ded(row_number,8+6*N_KIDS_SINGLE))               % first interval  credit rate
        EICT = wage_h*const_values.ded(row_number,7+6*N_KIDS_SINGLE);
        tax = 0;
    elseif  ((wage_h > const_values.ded(row_number,8+6*N_KIDS_SINGLE))...      % second (flat) interval - max EICT 
            && (wage_h < const_values.ded(row_number,11+6*N_KIDS_SINGLE)))
        EICT = const_values.ded(row_number,9+6*N_KIDS_SINGLE);
        tax = 0;
    elseif  ((wage_h > const_values.ded(row_number,11+6*N_KIDS_SINGLE))...     % third interval - phaseout rate
            && (wage_h < const_values.ded(row_number,12+6*N_KIDS_SINGLE)))
        EICT = wage_h*const_values.ded(row_number,10+6*N_KIDS_SINGLE);
        tax = 0;
    else
        EICT = 0;                                                   % income too high for EICT
    end    
    net_income_s_h = wage_h - tax + EICT; 
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      NET SALARY FOR MARRIED COUPLE IF WOMEN CHOOSE TO WORK 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (wage_h > 0 )
    shift = 21; % single 2-22, married 23-42
    reduced_income_m = wage_h + wage_w  - deductions_m-exemptions_m;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE INCOME TAX           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tax = 0;
    if reduced_income_m > 0
        for i = 2:10
            if (reduced_income_m < const_values.tax(row_number,i+shift))
                tax = tax + (reduced_income_m - const_values.tax(row_number,(i-1)+shift))*const_values.tax(row_number,11+(i-1)+shift);
            break
            end
            tax = tax + (const_values.tax(row_number,i+shift) - const_values.tax(row_number,(i-1)+shift)) ...
                   * const_values.tax(row_number,11+(i-1)+shift);
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE EICT                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EICT = 0;
    tot_inc = wage_h + wage_w;
    if (tot_inc < const_values.ded(row_number,8+6*N_KIDS))             % first interval  credit rate
        EICT = tot_inc*const_values.ded(row_number,7+6*N_KIDS);
        tax = 0;
    elseif  ((tot_inc > const_values.ded(row_number,8+6*N_KIDS))...    % second (flat) interval - max EICT 
            && (tot_inc < const_values.ded(row_number,11+6*N_KIDS)))
        EICT = const_values.ded(row_number,9+6*N_KIDS);
        tax = 0;
    elseif  ((tot_inc > const_values.ded(row_number,11+6*N_KIDS))...   % third interval - phaseout rate
            && (tot_inc < const_values.ded(row_number,12+6*N_KIDS)))
        EICT = tot_inc*const_values.ded(row_number,10+6*N_KIDS);
        tax = 0;
    else
        EICT = 0;                                           % income too high for EICT
    end    
    net_income_m = tot_inc - tax + EICT;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NET SALARY IF MARRIED AND WOMEN CHOOSES NOT TO WORK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    shift = 21; % single 2-22, married 23-42
    reduced_income_m_unemp = wage_h - deductions_m-exemptions_m;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE INCOME TAX           %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tax = 0;
    if reduced_income_m_unemp > 0
        for i=2:10
            if (reduced_income_m_unemp < const_values.tax(row_number,i+shift))
                tax = tax + (reduced_income_m_unemp - const_values.tax(row_number,(i-1)+shift))*const_values.tax(row_number,11+(i-1)+shift);
            break
            end
            tax = tax + (const_values.tax(row_number,i+shift) - const_values.tax(row_number,(i-1)+shift)) ...
                   * const_values.tax(row_number,11+(i-1)+shift);
        end
    end    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  CALCULATE EICT if women married and unemployed               %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    EICT = 0;
    tot_inc = wage_h;
    if (tot_inc < const_values.ded(row_number,8+6*N_KIDS))              % first interval  credit rate
        EICT = tot_inc*const_values.ded(row_number,7+6*N_KIDS);
        tax = 0;
    elseif  ((tot_inc > const_values.ded(row_number,8+6*N_KIDS))...     % second (flat) interval - max EICT 
            && (tot_inc < const_values.ded(row_number,11+6*N_KIDS)))
        EICT = const_values.ded(row_number,9+6*N_KIDS);
        tax = 0;
    elseif  ((tot_inc > const_values.ded(row_number,11+6*N_KIDS))...    % third interval - phaseout rate
            && (tot_inc < const_values.ded(row_number,12+6*N_KIDS)))
        EICT = tot_inc*const_values.ded(row_number,10+6*N_KIDS);
        tax = 0;
    else
        EICT = 0;                                                       % income too high for EICT
    end    
    net_income_m_unemp =  tot_inc - tax + EICT;
end
    
