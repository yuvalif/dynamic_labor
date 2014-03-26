function [x, global_param] = minestimation_ga(objective_function, global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws)

x_idx = get_global_param_idx(f_type);
disp('initial population value and ramge:');
x0 = global_param(x_idx)
x0_lb = x0 - 0.1*abs(x0)
x0_ub = x0 + 0.1*abs(x0)
nvars = length(x_idx);
Aeq = zeros(nvars);
beq = zeros(nvars,1);
population_factor = 2;
% define optimization options
my_options = gaoptimset(@ga);
% display after each iteration
my_options.PopulationType = 'doubleVector';
my_options.PopulationSize = nvars*population_factor;
my_options.PopInitRange = [x0_lb; x0_ub]; 
my_options.InitialPopulation = x0;
my_options.Display = 'iter';
my_options.Generations = 100;
my_options.FitnessLimit = 1e-3;
my_options.StallGenLimit = 50;
my_options.TolFun = 1e-3;
my_options

my_func = @(x) objective_function(x, f_type, 'no', global_param, T_MAX, DRAW_B, DRAW_F, husbands_HSG, husbands_SC, husbands_CG, husbands_PC, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, w_ability_draw, h_draws, w_draws);

disp(sprintf('now minimizing (ga) %s parameters, with index(%d)...', f_type, wage_idx));

[x fval exitflag output] = ga(my_func, length(x_idx), [], [], [], [], [], [], [], my_options);

global_param(x_idx) = x;
