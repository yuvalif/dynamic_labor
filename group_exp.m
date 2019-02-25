function exp_grouped = group_exp(exp)
				if (exp == 0)   % 5 level grid: 0,1-2,3-4,5-10, 11+
					exp_grouped = 1;
				elseif (exp > 0 && exp < 3)  % 1 or 2 years
					exp_grouped = 2;
				elseif (exp > 2 && exp < 5)  % 3 or 4 years
					exp_grouped = 3;
				elseif (exp > 4  && exp <11)% 5 to 10 years
					exp_grouped = 4;
                elseif (exp > 10 )   % above 11 years of experience
					exp_grouped = 5;
				else
					error(0)
				end		