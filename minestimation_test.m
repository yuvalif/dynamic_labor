function fval = minestimation_test(objective_function, global_param, T_MAX, DRAW_B, DRAW_F, SCHOOL_GROUP, husbands_2, husbands_3, husbands_4, husbands_5 , wives, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, h_draws_b, w_draws_b, w_ability_draw, h_draws, w_draws)


disp(strcat(strftime('%X',localtime(time)), ': now running (test) parameters...'));
fval = objective_function(global_param, 'all', 'text', global_param, T_MAX, DRAW_B, DRAW_F, SCHOOL_GROUP, husbands_2, husbands_3, husbands_4, husbands_5 , wives, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, h_draws_b, w_draws_b, w_ability_draw, h_draws, w_draws);
