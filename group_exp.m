function exp_grouped = group_exp(e)
    if (e == 0)   % 5 level grid: 0,1-2,3-4,5-10, 11+
        exp_grouped = 1;
    elseif (e > 0 && e < 3)  % 1 or 2 years
        exp_grouped = 2;
    elseif (e > 2 && e < 6)  % 3 or 5 years
        exp_grouped = 3;
    elseif (e > 5  && e < 11)% 6 to 10 years
        exp_grouped = 4;
    elseif (e > 10)   % above 11 years of experience
        exp_grouped = 5;
    else
        error(0)
    end		

