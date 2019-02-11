function exp_grouped = group_exp(exp)
				if (exp == 0)   % max of 10 years: 0,1-2,3-5,6-10
					exp_grouped = 1;
				elseif (exp > 0 && exp < 3)  % 2 years
					exp_grouped = 2;
				elseif (exp > 2 && exp < 5)
					exp_grouped = 3;
				elseif (exp > 4  && exp <9)
					exp_grouped = 4;
                elseif (exp > 8 )
					exp_grouped = 5;
				else
					error(0)
				end		