function [x, global_param] = minestimation_simplex(objective_function, global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws)

x_idx = get_global_param_idx(f_type);
x0 = global_param(x_idx);

% define optimization options
my_options = optimset;
% display after each iteration
my_options.Display = 'iter';
my_options.TolFun = 1e-3;
my_options.MaxIter = 200;
my_func = @(x) objective_function(x, f_type, 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);

disp(sprintf('now minimizing (simplex) %s parameters, with index(%d)...', f_type, wage_idx));

[x fval exitflag output] = fminsearch(my_func, x0, my_options)

global_param(x_idx) = x;
