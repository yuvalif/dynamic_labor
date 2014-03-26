function minestimation_std(objective_function, global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws)


disp(sprintf('now running (std), with index(%d)...', wage_idx));

eps = 1e-1;
min_h = 1e-6;
disp(sprintf('index\tx\tf(x-3h)\tf(x-2h)\tf(x-h)\tf(x)\tf(x+h)\tf(x+2h)\tf(x+3h)\th'));

fval(5) = objective_function(global_param, 'all', 'no', global_param, T, numdraws, OBS, husband, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f,  v_b, v_f, unidraw, wage_idx, age, h_wage_par_chart);

for i = 1:length(global_param)

h = max([abs(eps*global_param(i)) min_h]);
x = global_param(i);

global_param(i) = x - 2*h;
fval(1) = objective_function(global_param, 'all', 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);

global_param(i) = x - h;
fval(2) = objective_function(global_param, 'all', 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);

global_param(i) = x + h;
fval(3) = objective_function(global_param, 'all', 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);

global_param(i) = x + 2*h;
fval(4) = objective_function(global_param, 'all', 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);

global_param(i) = x - 3*h;
fval(6) = objective_function(global_param, 'all', 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);

global_param(i) = x + 3*h;
fval(7) = objective_function(global_param, 'all', 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);



global_param(i) = x; % return the original value

% five point stencil derivative at x (should be zero)
%dx_dh = (-fval(4) + 8*fval(3) - 8*fval(2) + fval(1))/(12*h);

disp(sprintf('%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f', i, x, fval(6), fval(1), fval(2), fval(5), fval(3), fval(4), fval(7), h));

end % for on i
