
function objective_function = estimation_f(param, f_type, display, global_param, T_MAX, DRAW_B, DRAW_F, SCHOOL_GROUPS, husbands_2,husbands_3,husbands_4,husbands_5, wives, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, h_draws_b, w_draws_b, w_ability_draw, h_draws, w_draws, tax_brackets,deductions_exemption) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   estimation_f
%   Author: Osnat Lifshitz
%   Date: 12-March-2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% define values
H = 0;
W = 1;
global WE1;WE1= 0;
global WE2;WE2 = 2;
global WE3;WE3 = 4;
global WE4;WE4 = 8;
global WE5;WE5 = 16;
global HE1;HE1 = 0;
global HE2;HE2 = 2;
global HE3;HE3 = 4;
global HE4;HE4 = 8;
global HE5;HE5 = 16;
global beta0; beta0 = 0.983;       % discount rate
global normal_arr; normal_arr = [ -1.150, 0 , 1.150];    %low, medium, high
global bp_vector; bp_vector = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
global cs_vector; cs_vector = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
global exp_vector; exp_vector(1,1:5) = [WE1, WE2, WE3, WE4, WE5];

global G_epsilon_b; G_epsilon_b = epsilon_b;
global G_w_draws; G_w_draws = w_draws;
global G_h_draws_b; G_h_draws_b = h_draws_b;
global G_w_draws_b; G_w_draws_b = w_draws_b;
global G_tax; G_tax = tax_brackets;
global G_ded; G_ded = deductions_exemption;
% standart normal distribution array : 5%, 15%, 25%, 35%, 45%, 55%, 65%, 75%, 85%, 95%
%normal_arr = [-1.645, -1.036, -0.674, -0.385, -0.126, 0.126, 0.385, 0.674,1.036, 1.645];% 10 points
%normal_arr = [-1.2817,  -0.524,  0.000,  0.524, 1.2817];  % 5 POINTS
%T_MAX = 28;       %HSG:18-45 (28 PERIODS), SC:20-25,CG:22-45, PC:25-45
global G_exp_w; G_exp_w = 5;     % (0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
global G_exp_h; G_exp_h = 5;     % (0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
global G_kids; G_kids = 4;      % children(0, 1,2, 3+)
global G_prev_w; G_prev_w = 2;    % previous work status(employed/unemployed)
global G_ability_w; G_ability_w = 3; % ability wife(high,medium,low)
global G_ability_h; G_ability_h = 3; % ability husband(high,medium,low)
global G_marr; G_marr = 2;      % marital status
global G_school_h; G_school_h = 5;  % only husbands schooling since we solve for a representative women given her education
global G_school_w; G_school_w = 4;  % only husbands schooling since we solve for a representative women given her education
global G_match; G_match = 3;     % match quality(high,medium,low)
global G_BP_W; G_BP_W = 7;      % wife bargening power(0.2, 0.3, 0.4, 0.5, 0.6, 0.7,0.8)
% wife consumption share(0.2,0.3,0.4,0.5,0.6,0.7,0.8)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  SMALL SCALE                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set small scale to 1 for running in small scale
small_scale = 0;
if (small_scale == 1)
    TERMINAL = 24;
 %   T_MAX = 5;
    G_exp_w = 5;     % (0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
    G_exp_h = 5;     % (0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
    G_kids = 4;      % children(0, 1,2, 3+)
    G_prev_w = 2;    % previous work status(employed/unemployed)
    G_ability_w = 3; % ability wife(high,medium,low)
    G_ability_h = 3; % ability husband(high,medium,low)
    G_marr = 2;      % marital status
    G_school_h = 5;  % only husbands schooling since we solve for a representative women given her education
    G_school_w = 4;  % only husbands schooling since we solve for a representative women given her education
    G_match = 3;     % match quality(high,medium,low)
    G_BP_W = 7;      % wife bargening power(0.2, 0.3, 0.4, 0.5, 0.6, 0.7,0.8)
    % wife consumption share(0.2,0.3,0.4,0.5,0.6,0.7,0.8)
else
     TERMINAL = 45;
end

%%%%%%%%%%%%%%% define EMAX %%%%%%%%%%%%%%%%%%%%%%%%%%%%
EMAX_W = zeros(T_MAX, G_exp_w, G_exp_h, G_kids, G_prev_w, G_ability_w, G_ability_h, G_marr, G_school_h, G_school_w, G_match, G_BP_W); 
EMAX_H = zeros(T_MAX, G_exp_w, G_exp_h, G_kids, G_prev_w, G_ability_w, G_ability_h, G_marr, G_school_h, G_school_w, G_match, G_BP_W); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           COUNTER FACTUALS + STATIC          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
STATIC = 1;    % only no EMAX
COUNTER = 0;
%COUNTER = 1; % static model in EMAX, wage, job offer - k+prev_state
%COUNTER = 2; % no return for experience in wage
if COUNTER == 1
    beta0 = 0; % - static model !!!
end
if COUNTER == 2
    beta1_w  = 0;
    beta2_w  = 0;
    row2 = 0;
end	

DUMP_EMAX = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%  PARAMETERS   %%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_idx = get_global_param_idx(f_type);
global_param(x_idx) = param;
global sigma;sigma = zeros(5,5);
% Utility parameters:  
global alpha;alpha = global_param(1);        % CRRA income parameter 
global alpha1_w_m;alpha1_w_m = global_param(2);        % women utility from children when married
global alpha1_w_s;alpha1_w_s = global_param(3);        % women utility from children when single
global alpha1_h_m;alpha1_h_m = global_param(4);        % men utility from children when maarried
global alpha2_w;alpha2_w = global_param(5);        % utility from leisure as a function of number of children
global alpha3_w;alpha3_w = global_param(6);        % utility from leisure
% Wage parameters wife
global beta11_w;beta11_w  = global_param(7);     %experience 
global beta12_w;beta12_w  = global_param(8);     %experience 
global beta13_w;beta13_w  = global_param(9);     %experience 
global beta14_w;beta14_w  = global_param(10);    %experience 
global beta21_w;beta21_w  = global_param(11);    %exp^2  
global beta22_w;beta22_w  = global_param(12);    %exp^2  
global beta23_w;beta23_w  = global_param(13);    %exp^2  
global beta24_w;beta24_w  = global_param(14);    %exp^2  
%beta30_w = global_param();     %HSD - schooling    
global beta31_w;beta31_w = global_param(15);    %HSG - schooling    
global beta32_w;beta32_w = global_param(16);    %SC -  schooling    
global beta33_w;beta33_w = global_param(17);    %CG -  schooling    
global beta34_w;beta34_w = global_param(18);    %PC -  schooling
% Wage parameters husband
global beta10_h;beta10_h  = global_param(19);    %experience 
global beta11_h;beta11_h  = global_param(20);    %experience 
global beta12_h;beta12_h  = global_param(21);    %experience 
global beta13_h;beta13_h  = global_param(22);    %experience 
global beta14_h;beta14_h  = global_param(23);    %experience 
global beta20_h;beta20_h  = global_param(24);    %exp^2
global beta21_h;beta21_h  = global_param(25);    %exp^2
global beta22_h;beta22_h  = global_param(26);    %exp^2
global beta23_h;beta23_h  = global_param(27);    %exp^2
global beta24_h;beta24_h  = global_param(28);    %exp^2
global beta30_h;beta30_h = global_param(29);    %HSD - schooling    
global beta31_h;beta31_h = global_param(30);    %HSG- schooling 
global beta32_h;beta32_h = global_param(31);    %SC -  schooling    
global beta33_h;beta33_h = global_param(32);    %CG -  schooling    
global beta34_h;beta34_h = global_param(33);    %PC -  schooling    
% Job offer parameters  wife 
global row0_w;row0_w   = global_param(34);      % work in previous period
global row11_w;row11_w  = global_param(35);     % HSG -schooling
global row12_w;row12_w  = global_param(36);     % SC - schooling
global row13_w;row13_w  = global_param(37);     % CG - schooling
global row14_w;row14_w  = global_param(38);     % PC - schooling
global row2_w;row2_w   = global_param(39);      % work experience
%home production technology - parameters    
global hp;hp = global_param(40);         % sigma CRRA parameter
%probability of another child parameters    
global c1;c1 = global_param(41);            % previous work state - wife
global c2;c2 = global_param(42);            % age wife - HSG
global c3;c3 = global_param(43);            % age square wife - HSG
global c4;c4 = global_param(44);            % age wife - SC
global c5;c5= global_param(45);             % age square wife - SC
global c6;c6 = global_param(46);            % age wife - CG
global c7;c7 = global_param(47);            % age square wife - CG
global c8;c8 = global_param(48);            % age wife - PC
global c9;c9 = global_param(49);            % age square wife - PC
global c10;c10 = global_param(50);          % number of children at household    
global c11;c11 = global_param(51);          % schooling - husband
global c12;c12 = global_param(52);          % married - M
% terminal value Parameters
%t0 = global_param();           % schooling wife - HSD
global t1_w;t1_w = global_param(53);        % schooling wife - HSG
global t2_w;t2_w = global_param(54);        % schooling wife - SC
global t3_w;t3_w = global_param(55);        % schooling wife - CG
global t4_w;t4_w = global_param(56);        % schooling wife - PC
global t5_w;t5_w = global_param(57);        % exp wife
global t6_w;t6_w = global_param(58);        % schooling husband if married - HSD
global t7_w;t7_w = global_param(59);        % schooling husband if married - HSG
global t8_w;t8_w = global_param(60);        % schooling husband if married - SC
global t9_w;t9_w = global_param(61);        % schooling husband if married - CG
global t10_w;t10_w = global_param(62);      % schooling husband if married - PC
global t11_w;t11_w = global_param(63);      % exp husband if married 
global t12_w;t12_w = global_param(64);      % martial status
global t13_w;t13_w = global_param(65);      % number of children
global t14_w;t14_w = global_param(66);      % match quality if married
global t15_w;t15_w = global_param(67);      % number of children if married
global t16_w;t16_w = global_param(68);      % previous work state - wife
global t17_w;t17_w = global_param(69);      % previous work state - husband if married
% terminal value Parameters
%t0 = global_param();           % schooling wife if married - HSD
global t1_h;t1_h = global_param(70);        % schooling wife if married- HSG
global t2_h;t2_h = global_param(71);        % schooling wife if married- SC
global t3_h;t3_h = global_param(72);        % schooling wife if married- CG
global t4_h;t4_h = global_param(73);        % schooling wife if married- PC
global t5_h;t5_h = global_param(74);        % exp wife if married
global t6_h;t6_h = global_param(75);        % schooling husband - HSD
global t7_h;t7_h = global_param(76);        % schooling husband - HSG
global t8_h;t8_h = global_param(77);        % schooling husband - SC
global t9_h;t9_h = global_param(78);        % schooling husband - CG
global t10_h;t10_h = global_param(79);      % schooling husband - PC
global t11_h;t11_h = global_param(80);      % exp husband  
global t12_h;t12_h = global_param(81);      % martial status if married
global t13_h;t13_h = global_param(82);      % number of children if married
global t14_h;t14_h = global_param(83);      % match quality if married
global t15_h;t15_h = global_param(84);      % number of children if married - NO NEED
global t16_h;t16_h = global_param(85);      % previous work state - wife if married
global t17_h;t17_h = global_param(86);      % previous work state - husband 
% match quality parameters
global p0_w; p0_w = global_param(87);  %probability of meeting a potential husband - wife constant
global p1_w; p1_w = global_param(88);  %probability of meeting a potential husband - wife age
global p2_w; p2_w = global_param(89);  %probability of meeting a potential husband - wife age square
global p0_h; p0_h = global_param(90);  %probability of meeting a potential husband - husband constant
global p1_h; p1_h = global_param(91);  %probability of meeting a potential husband - husband age
global p2_h; p2_h = global_param(92);  %probability of meeting a potential husband - husband age square
global MATCH_Q_DECREASE;MATCH_Q_DECREASE = (exp(global_param(93)))/(1+exp(global_param(93)));   % probability of match quality decrease
global MATCH_Q_INCREASE;MATCH_Q_INCREASE = (exp(global_param(94)))/(1+exp(global_param(94)));   % probability of match quality increase
global EDUC_MATCH_2;EDUC_MATCH_2 = global_param(95);  %education match parameter
global EDUC_MATCH_3;EDUC_MATCH_3 = global_param(96);  %education match parameter
global EDUC_MATCH_4;EDUC_MATCH_4 = global_param(97);  %education match parameter
global EDUC_MATCH_5;EDUC_MATCH_5 = global_param(98);  %education match parameter
% random shocks variance-covariance matrix
sigma(1,1) = exp(global_param(99));              % wage error variance husband;
sigma(2,2) = exp(global_param(100));             % wage error variance wife;
sigma(3,3) = exp(global_param(101));             % variance wife ability
sigma(4,4) = exp(global_param(102));             % variance husband ability
sigma(5,5) = exp(global_param(103));             % variance match quality

p = gcp();

obj = estimation_parameters(global_param, epsilon_b, w_draws, h_draws, w_draws_b, tax_brackets, deductions_exemption);

%obj_w = WorkerObjWrapper(obj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%               SOLVING BACKWARD                    %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic();
% when t = T_MAX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   EMAX FOR SINGLE MEN     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for HS = 1 : 5  %HUSBAND SCHOOLING
    F(HS) = parfeval(p, @single_men, 2, obj, HS, T_MAX,...
        EMAX_W(T_MAX, :, :, :, :, :, :, :, HS, :, :, :),...
        EMAX_H(T_MAX, :, :, :, :, :, :, :, HS, :, :, :),...
        DRAW_B, TERMINAL, wives);
end % end husband schooling loop

% collect results
for HS = 1 : 5  %HUSBAND SCHOOLING
    [idx, EMAX_H_T, iter_count] = fetchNext(F);
    EMAX_H(T_MAX, :, :, :, :, :, :, :, idx, :, :, :) = EMAX_H_T(1, :, :, :, :, :, :, :, 1, :, :, :);
    fprintf('HUSBAND SCHOOLING %d at time %d did %d iteration\n', idx, T_MAX, iter_count);
end % end husband schooling loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%     emax for single women     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for WS = 2 : 5 % no need to calclate emax of HSD single women - HSG to PC
    F(WS-1) = parfeval(p, @single_women, 2, obj, WS, T_MAX,...
        EMAX_W(T_MAX, :, :, :, :, :, :, :, :, WS-1, :, :),...
        EMAX_H(T_MAX, :, :, :, :, :, :, :, :, WS-1, :, :),...
        DRAW_B, TERMINAL, husbands_2, husbands_3, husbands_4, husbands_5);
end %close wife's schooling loop

% collect results
for WS = 2 : 5
    [idx, EMAX_W_T, iter_count] = fetchNext(F);
    EMAX_W(T_MAX, :, :, :, :, :, :, :, :, idx, :, :) = EMAX_W_T(1, :, :, :, :, :, :, :, :, 1, :, :);
    fprintf('WIFE SCHOOLING %d at time %d did %d iteration\n', idx, T_MAX, iter_count);
end %close wife's schooling loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%   Emax for Married Couple     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for WS = 2 : 5 % no need to calclate emax of HSD single women
    F(WS-1) = parfeval(p, @married_couple, 3, obj, WS, T_MAX, ...
        EMAX_W(T_MAX, :, :, :, :, :, :, :, :, WS-1, :, :),...
        EMAX_H(T_MAX, :, :, :, :, :, :, :, :, WS-1, :, :),...
        DRAW_B, TERMINAL);
end %close wife schooling loop

% collect results
for WS = 2 : 5
    [idx, EMAX_W_T, EMAX_H_T, iter_count] = fetchNext(F);
    EMAX_W(T_MAX, :, :, :, :, :, :, :, :, idx, :, :) = EMAX_W_T(1, :, :, :, :, :, :, :, :, 1, :, :);
    EMAX_H(T_MAX, :, :, :, :, :, :, :, :, idx, :, :) = EMAX_H_T(1, :, :, :, :, :, :, :, :, 1, :, :);
    fprintf('MARRIED WIFE SCHOOLING %d at time %d did %d iteration\n', idx, T_MAX, iter_count);
end

toc()

tic();
for t = T_MAX-1 : -1 :  1 %TIME
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   EMAX FOR SINGLE MEN     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for HS = 1 : 5  %HUSBAND SCHOOLING
         F(HS) = parfeval(p, @single_men, 2, obj, HS, t,...
            EMAX_W(t:t+1, :, :, :, :, :, :, :, HS, :, :, :),...
            EMAX_H(t:t+1, :, :, :, :, :, :, :, HS, :, :, :),...
            DRAW_B, TERMINAL, wives);
    end % end husband schooling loop
    
    % collect results
    for HS = 1 : 5  %HUSBAND SCHOOLING
        [idx, EMAX_H_T, iter_count] = fetchNext(F);
        EMAX_H(t, :, :, :, :, :, :, :, idx, :, :, :) = EMAX_H_T(1, :, :, :, :, :, :, :, 1, :, :, :);
        fprintf('HUSBAND SCHOOLING %d at time %d did %d iteration\n', idx, t, iter_count);
    end % end husband schooling loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%     emax for single women     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for WS = 2 : 5 % no need to calclate emax of HSD single women - HSG to PC
        F(WS-1) = parfeval(p, @single_women, 2, obj, WS, t,...
            EMAX_W(t:t+1, :, :, :, :, :, :, :, :, WS-1, :, :),...
            EMAX_H(t:t+1, :, :, :, :, :, :, :, :, WS-1, :, :),...
            DRAW_B, TERMINAL, husbands_2, husbands_3, husbands_4, husbands_5);
    end %close wife's schooling loop
    
    % collect results
    for WS = 2 : 5
        [idx, EMAX_W_T, iter_count] = fetchNext(F);
        EMAX_W(t, :, :, :, :, :, :, :, :, idx, :, :) = EMAX_W_T(1, :, :, :, :, :, :, :, :, 1, :, :);
        fprintf('WIFE SCHOOLING %d at time %d did %d iteration\n', idx, t, iter_count);
    end %close wife's schooling loop

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%   Emax for Married Couple     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for WS = 2 : 5 % no need to calclate emax of HSD single women
        F(WS-1) = parfeval(p, @married_couple, 3, obj, WS, t, ...
            EMAX_W(t:t+1, :, :, :, :, :, :, :, :, WS-1, :, :),...
            EMAX_H(t:t+1, :, :, :, :, :, :, :, :, WS-1, :, :),...
            DRAW_B, TERMINAL);
    end %close wife schooling loop
    
    % collect results
    for WS = 2 : 5
        [idx, EMAX_W_T, EMAX_H_T, iter_count] = fetchNext(F);
        EMAX_W(t, :, :, :, :, :, :, :, :, idx, :, :) = EMAX_W_T(1, :, :, :, :, :, :, :, :, 1, :, :);
        EMAX_H(t, :, :, :, :, :, :, :, :, idx, :, :) = EMAX_H_T(1, :, :, :, :, :, :, :, :, 1, :, :);
        fprintf('MARRIED WIFE SCHOOLING %d at time %d did %d iteration\n', idx, t, iter_count);
    end
    
end % T backward loop
toc()

objective_function = 0;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%               SOLVING FORWARD                  %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic();
global G_EMAX_W; G_EMAX_W = EMAX_W;
global G_EMAX_H; G_EMAX_H = EMAX_H;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculated Moments INITIALIZATION      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
emp_choice_w =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment total
emp_m =                 zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married
emp_um =                zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment unmarried
emp_m_up =              zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married up
emp_m_down =            zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married down
emp_m_eq =              zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married equal
emp_m_up_below =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married up
emp_m_down_below =      zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married down
emp_m_eq_below =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married equal
emp_m_up_above =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married up
emp_m_down_above =      zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married down
emp_m_eq_above =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married equal
count_emp_m_up =        zeros(T_MAX, SCHOOL_GROUPS);                % employment married up
count_emp_m_down =      zeros(T_MAX, SCHOOL_GROUPS);                % employment married down
count_emp_m_eq =        zeros(T_MAX, SCHOOL_GROUPS);                % employment married equal
count_emp_m_up_below =  zeros(T_MAX, SCHOOL_GROUPS);                % employment married up
count_emp_m_down_below =zeros(T_MAX, SCHOOL_GROUPS);                % employment married down
count_emp_m_eq_below =  zeros(T_MAX, SCHOOL_GROUPS);                % employment married equal
count_emp_m_up_above =  zeros(T_MAX, SCHOOL_GROUPS);                % employment married up
count_emp_m_down_above =zeros(T_MAX, SCHOOL_GROUPS);                % employment married down
count_emp_m_eq_above =  zeros(T_MAX, SCHOOL_GROUPS);                % employment married equal
emp_m_no_kids =         zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married no kids
emp_m_one_kid =         zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 1 kid
emp_m_2_kids =  		zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 2-3 kids
emp_m_3_kids =        	zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 2-3 kids
emp_m_4plus_kids =      zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 4  kids
count_emp_m_no_kids =   zeros(T_MAX, SCHOOL_GROUPS);   
count_emp_m_one_kid =   zeros(T_MAX, SCHOOL_GROUPS);   
count_emp_m_2_kids =    zeros(T_MAX, SCHOOL_GROUPS);  
count_emp_m_3_kids =    zeros(T_MAX, SCHOOL_GROUPS);  
count_emp_m_4plus_kids= zeros(T_MAX, SCHOOL_GROUPS);
emp_um_no_kids =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % employment unmarried and no children
emp_um_kids =           zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % employment unmarried and children
divorce = 	        	zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);  
count_emp_um_no_kids =  zeros(T_MAX, SCHOOL_GROUPS);
count_emp_um_kids =     zeros(T_MAX, SCHOOL_GROUPS);
just_found_job_m =      zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - unemployment to employment 
just_got_fired_m =      zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - employment to unemployment
just_found_job_um =     zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - unemployment to employment 
just_got_fired_um =     zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - employment to unemployment
just_found_job_mc =     zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - unemployment to employment 
just_got_fired_mc =     zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - employment to unemployment
count_just_got_fired_m  = zeros(T_MAX, SCHOOL_GROUPS);
count_just_found_job_m 	= zeros(T_MAX, SCHOOL_GROUPS);
count_just_got_fired_um = zeros(T_MAX, SCHOOL_GROUPS);
count_just_found_job_um = zeros(T_MAX, SCHOOL_GROUPS);
count_just_got_fired_mc = zeros(T_MAX, SCHOOL_GROUPS);
count_just_found_job_mc = zeros(T_MAX, SCHOOL_GROUPS);
ability_h_up    =       zeros(T_MAX, SCHOOL_GROUPS);      % ability moments
ability_h_down  =       zeros(T_MAX, SCHOOL_GROUPS);
ability_h_eq    =       zeros(T_MAX, SCHOOL_GROUPS);
ability_w_up    =       zeros(T_MAX, SCHOOL_GROUPS);
ability_w_down  =       zeros(T_MAX, SCHOOL_GROUPS);
ability_w_eq    =       zeros(T_MAX, SCHOOL_GROUPS);
match_w_up      =       zeros(T_MAX, SCHOOL_GROUPS);
match_w_down    =       zeros(T_MAX, SCHOOL_GROUPS);
match_w_eq      =       zeros(T_MAX, SCHOOL_GROUPS);
count_ability_h_up    = zeros(T_MAX, SCHOOL_GROUPS);      % ability count moments
count_ability_h_down  = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_h_eq    = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_w_up    = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_w_down  = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_w_eq    = zeros(T_MAX, SCHOOL_GROUPS);
count_match_w_up      = zeros(T_MAX, SCHOOL_GROUPS);
count_match_w_down    = zeros(T_MAX, SCHOOL_GROUPS);
count_match_w_eq      = zeros(T_MAX, SCHOOL_GROUPS);
wages_m_h 	          = zeros(48, SCHOOL_GROUPS);  % wages moments% married men wages - 0 until 20+27 years of exp - 36-47 will be ignore in moments  
count_wages_m_h	      = zeros(48,SCHOOL_GROUPS); 
wages_w 	          = zeros(T_MAX, SCHOOL_GROUPS);  % women wages if employed
count_wages_w	      = zeros(T_MAX, SCHOOL_GROUPS);
wages_m_w 	          = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married women wages if employed
wages_m_h_up 	      = ones(DRAW_F,48, SCHOOL_GROUPS).*-99999;  % married up men wages 
wages_m_h_down 	      = ones(DRAW_F,48, SCHOOL_GROUPS).*-99999;  % married down men wages 
wages_m_h_eq 	      = ones(DRAW_F,48, SCHOOL_GROUPS).*-99999;  % married equal men wages 
wages_m_w_up	      = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married up women wages if employed
wages_m_w_down        = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married down women wages if employed
wages_m_w_eq 		  = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married equal women wages if employed
count_wages_m_h_up 	  = zeros(48, SCHOOL_GROUPS);     % count observation of married up men wages 
count_wages_m_h_down  = zeros(48, SCHOOL_GROUPS);     % count observation of married down men wages 
count_wages_m_h_eq 	  = zeros(48, SCHOOL_GROUPS);     % count observation of married equal men wages 
count_wages_m_w_up 	  = zeros(T_MAX, SCHOOL_GROUPS);  % count observation of married up women wages if employed
count_wages_m_w_down  = zeros(T_MAX, SCHOOL_GROUPS);  % count observation of married down women wages if employed
count_wages_m_w_eq 	  = zeros(T_MAX, SCHOOL_GROUPS);  % count observation of married equal women wages if employed
wages_um_w 	    	  = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % unmarried women wages if employed
married               	    = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);    % fertilty and marriage rate moments   % married yes/no
just_married          	    = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       %for transition matrix from single to married
age_at_first_marriage 	    = zeros(DRAW_F, SCHOOL_GROUPS);             %age at first marriage
just_divorced         	    = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       %for transition matrix from married to divorce
newborn_um                  = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       % new born in period t - for probability and distribution
newborn_m                   = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       % new born in period t - for probability and distribution
duration_of_first_marriage 	= zeros(DRAW_F, SCHOOL_GROUPS);         % duration of marriage if divorce or 45-age of marriage if still married at 45.
count_dur_of_first_marriage = zeros(SCHOOL_GROUPS,1);
assortative_mating    		= zeros(DRAW_F, SCHOOL_GROUPS);             % HUSBAND EDUCATION BY WIFE EDUCATION
count_just_married 		    = zeros(T_MAX, SCHOOL_GROUPS);
count_just_divorced 		= zeros(T_MAX, SCHOOL_GROUPS);
count_newborn_um 		= zeros(T_MAX, SCHOOL_GROUPS);
count_newborn_m 		= zeros(T_MAX, SCHOOL_GROUPS);
kids = zeros(DRAW_F,SCHOOL_GROUPS);          % # of children by school group
kids_m = zeros(DRAW_F,SCHOOL_GROUPS); % married women # of children by school group
kids_um = zeros(DRAW_F,SCHOOL_GROUPS); % married women # of children by school group
marriage_choice = zeros(DRAW_F,T_MAX,SCHOOL_GROUPS);

BP_INITIAL_DISTRIBUTION = zeros(1,11);
BP_DISTRIBUTION = zeros(1,11);
CS_DISTRIBUTION = zeros(1,22);

for school_group=2 : 5       % school_group 1 is only for calculating the emax if single men, other than that, there is a "if school_group>1"
    if (school_group == 1)
        HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        HSD = 1;
        HS = 1; H_HSD = 1;
        AGE = 18;
        T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=28
        age_index = 0;
        husbands = husbands_2;  %only for initialization - no use!
    elseif (school_group == 2)
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        HSG = 1;
        HS = 2; H_HSG = 1;
        AGE = 18;
        T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=28
        age_index = 0;
        husbands = husbands_2;
    elseif (school_group == 3)  
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        SC = 1;
        HS = 3; H_SC = 1;
        AGE = 20;
        T_END = TERMINAL - AGE+1; % TERMINAL = 45, T=26
        age_index = 2;
        husbands = husbands_3;
    elseif (school_group == 4)
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        CG = 1;
        HS = 4; H_CG = 1;
        AGE = 22;
        T_END = TERMINAL - AGE+1;% TERMINAL = 45, T=24
        age_index = 4;
        husbands = husbands_4;
    else
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        PC = 1;
        HS = 5; H_PC = 1;
        AGE = 25;
        T_END = TERMINAL - AGE+1;   % TERMINAL = 45, T=21
        age_index = 7;
        husbands = husbands_5;
    end
    % Initialize state according to school level
    if school_group > 1  % do not run the forward for HSD women
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;   %update the schooling 
        if school_group == 2
            HSD = 0; HSG = 1;  SC = 0;  CG = 0; PC = 0;
        elseif school_group == 3    
            HSD = 0; HSG = 0;  SC = 1;  CG = 0; PC = 0;
        elseif school_group == 4
            HSD = 0; HSG = 0;  SC = 0; CG = 1; PC = 0;
        else
            HSD = 0; HSG = 0;  SC = 0;  CG = 0;     PC = 1;
        end
        WS = school_group;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        % repeat forward DRAW_F times to generalize the result of a specific sample
        for draw_f = 1 : DRAW_F
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
            WE=0;
            if draw_f < DRAW_F*0.45   % 0.45 proportion of unemployed women
                prev_state_w = 0;
            else
                prev_state_w = 1;
            end 
            prev_state_w_T_minus_1 = 0;
            prev_state_h = 0;
            prev_state_h_T_minus_1 = 0;

            count_age1 = 0; %the age of the oldest child under6
            count_age2 = 0; %the age of the 2nd oldest child under6
            count_age3 = 0; %the age of the 3rd oldest child under6
            count_age4 = 0; %the age of the 4th oldest child under6
            count_age5 = 0; %the age of the 5th oldest child under6
            year_married = 0;
            M=0 ;
            M_T_minus_1=0;
            DIVORCE = 0;
            NEW_BORN = 0;
            N_KIDS_H = 0;
            N_KIDS = 0;
            N_KIDS_M = 0;
            N_KIDS_UM = 0;
            duration = 0 ;
            Q = 0;
            HS = 1;
            HE = 0;
            BP = 0.5;
            similar_educ = 0;
            ability_w = normal_arr(w_ability_draw(draw_f, school_group))*sigma(3,3);
            ability_wi = w_ability_draw(draw_f,school_group);
            ability_h = 0;
            ability_hi = 1; %index must be 1 if no husband
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Make choices for all periods
            
            for t = 1 : T_END
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                CHOOSE_HUSBAND = 0;
                prev_state_w_T_minus_1 = prev_state_w;
                prev_state_h_T_minus_1 = prev_state_h;
                duration_minus_1 = duration;
                NEW_BORN = 0;
                %%%%%%%%%%%%%%%%%%%%%     DRAW HUSBAND    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if M == 0
                    BP = 0.5;
                    duration = 0;
                    Q = 0;
                    Q_INDEX = 1; %index must be 1 if no husband
                    similar_educ = 0;
                    % DRAW A POTENTIAL HUSBAND: EXP, SCHOOLING, MATCH QUALITY, ABILITY
                    P_HUSBAND =  (exp(p0_w+p1_w*(AGE+t)+p2_w*(AGE+t).^2))/(1+exp(p0_w+p1_w*(AGE+t)+p2_w*(AGE+t).^2));   % PROBABILITY OF MEETING A POTENTIAL HUSBAND
                    if h_draws(draw_f,t,school_group,1)<P_HUSBAND
                        CHOOSE_HUSBAND = 1;
                        [ability_h, ability_hi, Q, Q_INDEX,HS,H_HSD, H_HSG, H_SC, H_CG, H_PC,HE, similar_educ]=draw_husband(husbands,... 
                            t, age_index, draw_f, h_draws,school_group );
                    else
                        CHOOSE_HUSBAND = 0;
                    end 
                end     

                %%%%%%%%%%%%%%%%%%%%%%%%%   COUNTER FACTUALS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if COUNTER == 1 % first counter_factuals - static model
                    WE = t-1;
                    prev_state_w = 0;
                    prev_state_h = 0;
                    HE=HE+t-1;% husband experience 
                end	
                %%%%%%%%%%%%%%%%%%%%%%%%   POTENTIAL OR CURRENT HUSBAND WAGE:    %%%%%%%%%%%%%%%%
                if (M == 1 ||  CHOOSE_HUSBAND == 1)
                    [wage_h, JOB_OFFER_H] = calculate_wage(H, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE,...
                        0, epsilon_f(draw_f, t, school_group, 1), prev_state_w, ability_w, ability_h,t);
                else
                    JOB_OFFER_H = 0;
                    wage_h = 0;
                end 
                %%%%%%%%%%%%%%%%%%%%%%%%   JOB OFFER PROBABILITY + WAGE WIFE     %%%%%%%%%%%%%%%%
                [wage_w, JOB_OFFER_W] = calculate_wage(W, H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, HSD, HSG, SC, CG, PC, WE,...
                    w_draws(draw_f, t, school_group, 1), epsilon_f(draw_f, t, WS, 2), prev_state_w, ability_w, ability_h,t);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%   MAXIMIZATION - MARRIAGE + WORK DESICION  %%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (M == 0 &&  CHOOSE_HUSBAND == 1)
                    BP = 0.5;
                    [U_W, U_H, U_W_S, U_H_S] = calculate_utility_f(N_KIDS, N_KIDS_H, wage_h, wage_w, CHOOSE_HUSBAND, JOB_OFFER_H, JOB_OFFER_W, ...
                            M,  similar_educ, Q, Q_INDEX, HS, WS, t, ability_hi, ability_wi, HE, WE, BP, T_END, 0, age_index);
                    BP = nash(U_W,U_H,U_W_S,U_H_S,BP); % Nash bargaining at first period of marriage  
                    BP_INDEX = round(BP*10)+1;
                    if (BP ~= -1)
                        BP_INITIAL_DISTRIBUTION(1,BP_INDEX) =  BP_INITIAL_DISTRIBUTION(1,BP_INDEX)+1;
                    end
                    if (BP == -1)   % there is no BP that can give both positive surplus
                        CHOOSE_HUSBAND = 0;
                    end 
                end    %  CALCULATE INITIAL BP
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%   at this point the BP IS .5 IF NO MARRIAGE AND NO OFFER, is calculated by nash if offer  and is from previous period if already married           
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%% calculate husbands and wives utility     %%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%% from each option + -999 for unavailable  %%%%%%%%%%%%%%%
                [U_W, U_H, U_W_S, U_H_S] = calculate_utility_f(N_KIDS, N_KIDS_H, wage_h, wage_w, CHOOSE_HUSBAND, JOB_OFFER_H, JOB_OFFER_W, ...
                    M,  similar_educ, Q, Q_INDEX, HS, WS, t, ability_hi, ability_wi, HE, WE, BP, T_END, 0, age_index);

                if (CHOOSE_HUSBAND == 1)% write 1 for testing
                    %U_W
                    %U_H
                    %U_W_S
                    %U_H_S
                end
                if U_W_S(1)>U_W_S(2)
                    outside_option_w_v = U_W_S(1);
                    outside_option_w = 1; %"unemployed"
                else        
                    outside_option_w_v = U_W_S(2);
                    outside_option_w = 2; %employed
                end
                outside_option_h_v = U_H_S;
                outside_option_h = 2; %employed
                
                if (M == 1 || CHOOSE_HUSBAND == 1 )
                    % need optimization - not efficient programming      
                    M_T_minus_1 = M;
                    % marriage decision - outside option value wife
                    [M,prev_state_w,WE,HE,max_weighted_utility_index]=marriage_decision(U_H, U_W, BP, outside_option_h_v,outside_option_w_v,outside_option_w, WE, HE);
                    if (M ==1)
                        marriage_choice(draw_f,t,school_group) = 1;
                    else
                        marriage_choice(draw_f,t,school_group) = 0;
                    end
                    if (prev_state_w == 1)
                        emp_choice_w(draw_f,t+age_index,school_group) = 1;
                    else
                        emp_choice_w(draw_f,t+age_index,school_group) = 0;
                    end
                 elseif ( M==0 && CHOOSE_HUSBAND == 0)
                    M = 0 ;
                    marriage_choice(draw_f,t,school_group) = 0;
                    if (outside_option_w == 1)   %3-unmarried+wife unemployed
                        prev_state_w = 0;
                        WE = WE;
                        emp_choice_w(draw_f,t+age_index,school_group) = 0;
                    else     %3-unmarried+wife employed
                        prev_state_w = 1;
                        WE = WE+1;
                        emp_choice_w(draw_f,t+age_index,school_group) = 1;
                    end    
                end 
                BP_IND = round(BP*10)+1;
                    if (BP ~= -1)
                        BP_DISTRIBUTION(1,BP_IND) =  BP_DISTRIBUTION(1,BP_IND)+1;
                    end
                    if (M == 1)
                        CS_DISTRIBUTION(1,max_weighted_utility_index) = CS_DISTRIBUTION(1,max_weighted_utility_index)+1; 
                        if (max_weighted_utility_index>11)
                            %[wage_h, wage_w, max_weighted_utility_index, BP]
                        end
                        %WAGE_DISTRIBUTION_BY_CS(DRAWf, t, wage_h, wage_w, CS,BP)
                    end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %          FERTILITY EXOGENOUS PROCESS - check for another child + update age of children %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
                %probability of another child parameters:%c1 previous work state - wife   %c2 age wife - HSG   %c3 age square  wife - HSG  %c4 age wife - SC   %c5 age square  wife - SC   %c6 age wife - CG
                %c7 age square  wife - CG   %c8 age wife - PC   %c9 age square  wife - PC   %c10 number of children at household    %c11 schooling - husband  %c12 unmarried
                c_lamda=c1*prev_state_w+c2*HSG*(AGE+t)+c3*HSG*(AGE+t).^2+c4*SC*(AGE+t)+c5*SC*(AGE+t).^2+c6*CG*(AGE+t)+c7*CG*(AGE+t)^2+c8*PC*(AGE+t)+c9*PC*(AGE+t)^2+c10*(N_KIDS)+c11*HS*M+c12*M;
                child_prob = normcdf(c_lamda);
                if (w_draws(draw_f,t,school_group,2) < child_prob) && ((AGE+t) < 40)  %w_draws = rand(DRAW_F,T,3); 1-job offer, 2-new child, 3 - match quality change- new child was born
                    NEW_BORN = 1;
                    if N_KIDS < 3
                        N_KIDS = N_KIDS + 1;
                    end
                    if M == 1
                        N_KIDS_M = N_KIDS_M +1;
                    else
                        N_KIDS_UM = N_KIDS_UM +1;
                    end 
                    if N_KIDS==1
                        count_age1=1;
                    elseif N_KIDS==2   
                        count_age2=1;
                    elseif N_KIDS==3
                        count_age3=1;
                    elseif N_KIDS==4
                        count_age4=1;
                    elseif N_KIDS==5
                        count_age5=1;   
                    end 
                elseif N_KIDS > 0   % no new born, but kids at house so update ages
                    if  count_age1==18 %no new born, just update ages - kids above 18 leaves the household
                        count_age1=count_age2;
                        count_age2=count_age3;
                        count_age3=count_age4;
                        count_age4=count_age5;
                        count_age5=0;
                        N_KIDS=N_KIDS-1;
                        
                    end         
                    count_age1=count_age1+1;
                    if count_age2>0
                        count_age2=count_age2+1;
                    end 
                    if count_age3>0
                        count_age3=count_age3+1;
                    end 
                    if count_age4>0
                        count_age4=count_age4+1;
                    end 
                    if count_age5>0
                        count_age5=count_age5+1;
                    end 
                end 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %  UPDARE T+1 STATE SPACE - match quality 
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                if M == 1    %update the match quality
                    DIVORCE = 0;
                    duration = duration + 1;
                    Q_minus_1 = Q;
                    MATCH_QUALITY_CHANGE_PROBABIITY = h_draws(draw_f,t,school_group,5);
                    if (MATCH_QUALITY_CHANGE_PROBABIITY < MATCH_Q_DECREASE && Q_INDEX > 1)
                        Q_INDEX = Q_INDEX - 1;
                        Q = normal_arr(Q_INDEX)*sigma(5,5);
                    elseif (MATCH_QUALITY_CHANGE_PROBABIITY > MATCH_Q_DECREASE) && (MATCH_QUALITY_CHANGE_PROBABIITY < MATCH_Q_DECREASE + MATCH_Q_INCREASE) && (Q_INDEX < 3)
                        Q_INDEX = Q_INDEX + 1;
                        Q = normal_arr(Q_INDEX)*sigma(5,5);
                    end
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %   CREATE AND SAVE MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if N_KIDS == 0 && M ==1 
                    emp_m_no_kids(draw_f, t+age_index , school_group) = prev_state_w;         % employment married no kids
                    count_emp_m_no_kids(t+age_index,school_group)=count_emp_m_no_kids(t+age_index,school_group)+1;
                elseif N_KIDS == 1 && M ==1
                    emp_m_one_kid(draw_f, t+age_index, school_group) = prev_state_w;          % employment married 1 kid
                    count_emp_m_one_kid(t+age_index,school_group) = count_emp_m_one_kid(t+age_index,school_group)+1;
                elseif N_KIDS == 2 && M ==1
                    emp_m_2_kids(draw_f, t+age_index, school_group) = prev_state_w;          % employment married 2 kid
                    count_emp_m_2_kids(t+age_index,school_group) = count_emp_m_2_kids(t+age_index,school_group)+1;
                elseif N_KIDS == 3 && M ==1
                    emp_m_3_kids(draw_f, t+age_index, school_group) = prev_state_w;          % employment married 3 kid
                    count_emp_m_3_kids(t+age_index,school_group) = count_emp_m_3_kids(t+age_index,school_group)+1;
                elseif N_KIDS > 3  && M ==1
                    emp_m_4plus_kids(draw_f, t+age_index, school_group) = prev_state_w;           % employment married 4  kids
                    count_emp_m_4plus_kids(t+age_index,school_group) = count_emp_m_4plus_kids(t+age_index,school_group)+1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS                       %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if M == 0
                    emp_um(draw_f, t+age_index, school_group) = prev_state_w;         % employment unmarried
                    if (N_KIDS)==0
                        emp_um_no_kids(draw_f, t+age_index, school_group) = prev_state_w;     % employment unmarried and no children
                        count_emp_um_no_kids(t+age_index, school_group) = count_emp_um_no_kids(t+age_index, school_group) + 1;
                    else
                        emp_um_kids(draw_f, t+age_index, school_group) = prev_state_w;            % employment unmarried and children
                        count_emp_um_kids(t+age_index, school_group) = count_emp_um_kids(t+age_index, school_group) + 1;
                    end 
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                 EMPLOYMENT TRANSITION MATRIX                                                 %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if prev_state_w == 1 && prev_state_w_T_minus_1 == 0
                    if M ==1
                        just_found_job_m(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
                        count_just_found_job_m(t+age_index, school_group) = count_just_found_job_m(t+age_index, school_group)+1;
                        if N_KIDS >0
                            just_found_job_mc(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment
                            count_just_found_job_mc(t+age_index, school_group) = count_just_found_job_mc(t+age_index, school_group)+1;							
                        end	
                    else
                        just_found_job_um(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
                        count_just_found_job_um(t+age_index, school_group) = count_just_found_job_um(t+age_index, school_group)+1;
                    end	
                elseif prev_state_w == 0 && prev_state_w_T_minus_1 == 1
                    if M ==1
                        just_got_fired_m(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
                        count_just_got_fired_m(t+age_index, school_group) = count_just_got_fired_m(t+age_index, school_group)+1;
                        if N_KIDS > 0
                            just_got_fired_mc(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
                            count_just_got_fired_mc(t+age_index, school_group) = count_just_got_fired_mc(t+age_index, school_group)+1;

                        end
                    else
                        just_got_fired_um(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment
                        count_just_got_fired_um(t+age_index, school_group) = count_just_got_fired_um(t+age_index, school_group)+1;

                    end	
                elseif prev_state_w == 0 && prev_state_w_T_minus_1 == 0
                    if M ==1
                        count_just_found_job_m(t+age_index, school_group) = count_just_found_job_m(t+age_index, school_group)+1;
                        if N_KIDS >0
                            count_just_found_job_mc(t+age_index, school_group) = count_just_found_job_mc(t+age_index, school_group)+1;							
                        end	
                    else
                        count_just_found_job_um(t+age_index, school_group) = count_just_found_job_um(t+age_index, school_group)+1;
                    end	
                elseif prev_state_w == 1 && prev_state_w_T_minus_1 == 1
                    if M ==1
                        count_just_got_fired_m(t+age_index, school_group) = count_just_got_fired_m(t+age_index, school_group)+1;
                        if N_KIDS > 0
                            count_just_got_fired_mc(t+age_index, school_group) = count_just_got_fired_mc(t+age_index, school_group)+1;
                        end
                    else
                        count_just_got_fired_um(t+age_index, school_group) = count_just_got_fired_um(t+age_index, school_group)+1;
                    end	
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   MARRIED WOMEN EMPLOYMENT + WAGES MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if prev_state_w == 1
                    if wage_w > 0

                        wages_w(WE, school_group)=wages_w(WE, school_group) +wage_w;        % women wages if employed by experience
                        count_wages_w(WE, school_group)=count_wages_w(WE, school_group) +1;  
                    end	
                end 
                if M == 1 
                    if wage_h > 0
                       wages_m_h(HE, HS)=wages_m_h(HE, HS) + wage_h;         % husband always works
                        count_wages_m_h(HE, HS) = count_wages_m_h(HE, HS)+1;
                    end
                    emp_m(draw_f, t+age_index, school_group) = prev_state_w;      % employment married women  
                    if school_group > HS                %women married down, men married up - HS is 1 to 5 while school_group 1 to 4 so to copare: -1
                        emp_m_down(draw_f, t+age_index, school_group) = prev_state_w;         % employment married down
                        count_emp_m_down(t+age_index, school_group) = count_emp_m_down(t+age_index, school_group)+1;
                        if (HE <37 )  && wage_h > wage_moments(HE,5+HS)     %wage_moments(1:36,6:10)
                            emp_m_down_above(draw_f, t+age_index, school_group) = prev_state_w;         % employment married down
                            count_emp_m_down_above(t+age_index, school_group) = count_emp_m_down_above(t+age_index, school_group)+1;
                        else	
                            emp_m_down_below(draw_f, t+age_index, school_group) = prev_state_w;         % employment married down
                            count_emp_m_down_below(t+age_index, school_group) = count_emp_m_down_below(t+age_index, school_group)+1;
                        end
                        wages_m_h_up(draw_f, HE, HS)=wage_h;   % married up men wages 
                        count_wages_m_h_up(HE, HS)=count_wages_m_h_up(HE, HS)+1;
                        if M==1 && M_T_minus_1==0
                            ability_h_up(t+age_index, HS) = ability_h_up(t+age_index, HS) + ability_h;
                            count_ability_h_up(t+age_index, HS) = count_ability_h_up(t+age_index, HS) +1;
                            ability_w_down(t+age_index, school_group) = ability_w_down(t+age_index, school_group) +ability_w;
                            count_ability_w_down(t+age_index, school_group)=count_ability_w_down(t+age_index, school_group)+1;
                            match_w_down(t+age_index, school_group) = match_w_down(t+age_index, school_group) + Q_minus_1;
                            count_match_w_down(t+age_index, school_group)=count_match_w_down(t+age_index, school_group)+1;
                        end
                    elseif school_group < HS            %women married up, men married down
                        emp_m_up(draw_f, t+age_index, school_group) = prev_state_w;   % employment married up women
                        count_emp_m_up(t+age_index, school_group) = count_emp_m_up(t+age_index, school_group)+1;
                        if (HE <37 ) && wage_h > wage_moments(HE,5+HS)     %wage_moments(1:36,6:10)
                            emp_m_up_above(draw_f, t+age_index, school_group) = prev_state_w;         % employment married down
                            count_emp_m_up_above(t+age_index, school_group) = count_emp_m_up_above(t+age_index, school_group)+1;
                        else	
                            emp_m_up_below(draw_f, t+age_index, school_group) = prev_state_w;         % employment married down
                            count_emp_m_up_below(t+age_index, school_group) = count_emp_m_up_below(t+age_index, school_group)+1;
                        end
                        wages_m_h_down(draw_f, HE, HS)=wage_h; % married down men wages
                        count_wages_m_h_down(HE, HS)=count_wages_m_h_down(HE, HS)+1;
                        if M==1 && M_T_minus_1==0
                            ability_h_down(t+age_index, HS) = ability_h_down(t+age_index, HS) + ability_h;
                            count_ability_h_down(t+age_index, HS) = count_ability_h_down(t+age_index, HS) +1;
                            ability_w_up(t+age_index, school_group) = ability_w_up(t+age_index, school_group) +ability_w;
                            count_ability_w_up(t+age_index, school_group)=count_ability_w_up(t+age_index, school_group)+1;
                            match_w_up(t+age_index, school_group) = match_w_up(t+age_index, school_group) + Q_minus_1;
                            count_match_w_up(t+age_index, school_group)=count_match_w_up(t+age_index, school_group)+1;
                        end
                    elseif  school_group == HS         %married equal
                        wages_m_h_eq(draw_f, HE, HS)=wage_h;   % married equal men wages 
                        count_wages_m_h_eq(HE, HS)=count_wages_m_h_eq(HE, HS)+1;
                        emp_m_eq(draw_f, t+age_index, school_group) = prev_state_w;   % employment married equal women
                        count_emp_m_eq(t+age_index, school_group) = count_emp_m_eq(t+age_index, school_group)+1;

                        if (HE <37 )  && wage_h > wage_moments(HE,5+HS)      %wage_moments(1:36,6:10)
                            emp_m_eq_above(draw_f, t+age_index, school_group) = prev_state_w;         % employment married down
                            count_emp_m_eq_above(t+age_index, school_group) = count_emp_m_eq_above(t+age_index, school_group)+1;
                        else	
                            emp_m_eq_below(draw_f, t+age_index, school_group) = prev_state_w;         % employment married down
                            count_emp_m_eq_below(t+age_index, school_group) = count_emp_m_eq_below(t+age_index, school_group)+1;
                        end
                        if M==1 && M_T_minus_1==0
                            ability_h_eq(t+age_index, HS) = ability_h_eq(t+age_index, HS) + ability_h;
                            count_ability_h_eq(t+age_index, HS) = count_ability_h_eq(t+age_index, HS) +1;
                            ability_w_eq(t+age_index, school_group) = ability_w_eq(t+age_index, school_group) +ability_w;
                            count_ability_w_eq(t+age_index, school_group)=count_ability_w_eq(t+age_index, school_group)+1;
                            match_w_eq(t+age_index, school_group) = match_w_eq(t+age_index, school_group) +Q_minus_1;
                            count_match_w_eq(t+age_index, school_group)=count_match_w_eq(t+age_index, school_group)+1;
                        end
                    end
                end
                if M==1 && prev_state_w == 1                              %prev_state_w is actually current state at this point
                    wages_m_w(draw_f, WE, school_group)=wage_w;          % married women wages if employed
                    if school_group < HS
                        wages_m_w_up(draw_f, WE, school_group)=wage_w;   % married up women wages if employed
                        count_wages_m_w_up(WE, school_group)=count_wages_m_w_up(WE, school_group)+1;
                    elseif school_group > HS
                        wages_m_w_down(draw_f, WE, school_group)=wage_w; % married down women wages if employed
                        count_wages_m_w_down(WE, school_group)=count_wages_m_w_down(WE, school_group)+1;
                    elseif school_group == HS
                        wages_m_w_eq(draw_f, WE, school_group)=wage_w; % married equal women wages if employed
                        count_wages_m_w_eq(WE, school_group)=count_wages_m_w_eq(WE, school_group)+1;
                    end
                elseif M==0 && prev_state_w == 1
                    wages_um_w(draw_f, WE, school_group)=wage_w;         % unmarried women wages if employed
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %           FERTILITY AND MARRIED RATE MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                married(draw_f, t+age_index, school_group) = M  ;                   % married yes/no
                %                newborn(draw_f, t+age_index, school_group)=NEW_BORN;                % new born in period t - for probability and distribution
                if M ==1
                    newborn_m(draw_f, t+age_index, school_group)=NEW_BORN;                % new born in period t - for probability and distribution
                    count_newborn_m(t+age_index, school_group) = count_newborn_m(t+age_index, school_group)+1;
                else
                    newborn_um(draw_f, t+age_index, school_group)=NEW_BORN;                % new born in period t - for probability and distribution
                    count_newborn_um(t+age_index, school_group) = count_newborn_um(t+age_index, school_group)+1;
                end
                %duration_of_first_marriage(draw_f, school_group) = D_T_minus_1 ;
                if t == T_END 
                    kids(draw_f, school_group) = N_KIDS ;          % # of children by school group
                    kids_m(draw_f, school_group) = N_KIDS_M;
                    kids_um(draw_f, school_group) = N_KIDS_UM;
                end
                if M==1 && M_T_minus_1==0
                    just_married(draw_f, t+age_index, school_group)=1;          % for transition matrix from single to married
                    count_just_married(t+age_index, school_group) = count_just_married(t+age_index, school_group)+1;

                    if age_at_first_marriage(draw_f, school_group)==0
                        age_at_first_marriage(draw_f, school_group)=AGE+t;
                        assortative_mating(draw_f, school_group) = HS;
                    end 
                elseif (M==0 && M_T_minus_1==1)
                    DIVORCE = 1;
                    just_divorced(draw_f, t+age_index, school_group)=1;         % for transition matrix from married to divorce
                    count_just_divorced(t+age_index, school_group) = count_just_divorced(t+age_index, school_group)+1;

                    if duration_of_first_marriage(draw_f, school_group)==0
                        duration_of_first_marriage(draw_f, school_group) = duration-1 ;                % duration of marriage if divorce 
                        count_dur_of_first_marriage(school_group) = count_dur_of_first_marriage(school_group)+1;
                    end
                elseif (M==0 && M_T_minus_1==0)
                    count_just_married(t+age_index, school_group) = count_just_married(t+age_index, school_group)+1;
                elseif (M==1 && M_T_minus_1==1)
                    count_just_divorced(t+age_index, school_group) = count_just_divorced(t+age_index, school_group)+1;
                end
                divorce(draw_f, t+age_index, school_group)=DIVORCE;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %           END MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end % close the time loop
        end % close the draw_f loop
    end  % close the if school_group>0 at line 1146
end % close the schooling_group loop
toc()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%            CLOSE SOLVING FORWARD      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
BP_DISTRIBUTION(1,1:11)
BP_INITIAL_DISTRIBUTION(1,1:11)
CS_DISTRIBUTION(1,1:11)
CS_DISTRIBUTION(1,12:22)
average_ability_h_up = nansum(ability_h_up./count_ability_h_up)
average_ability_h_eq = nansum(ability_h_eq./count_ability_h_eq)
average_ability_h_down = nansum(ability_h_down./count_ability_h_down)
average_ability_w_up = nansum(ability_w_up./count_ability_w_up)
average_ability_w_eq = nansum(ability_w_eq./count_ability_w_eq)
average_ability_w_down = nansum(ability_w_down./count_ability_w_down)
average_match_w_up = nansum(match_w_up./count_match_w_up)
average_match_w_eq = nansum(match_w_eq./count_match_w_eq)
average_match_w_down = nansum(match_w_down./count_match_w_down)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESULTS SUMMARY - CREATES MOMENTS IN THE SAME FORMAT AS ACTUAL MOMENTS FOR OBJECTIVE SGMM FUNCTION %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%emp_moments - 13 by 28 matrix - 
%first column - age
%column 2-5 - employment rate by education group. start at t+age index
%column 6-9 - married women employment rate by education group. start at t+age index
%column 10-13- unmarried women employment rate by education group. start at t+age index
f_emp_w = [mean(emp_choice_w(:,:,2)); mean(emp_choice_w(:,:,3)); mean(emp_choice_w(:,:,4)); mean(emp_choice_w(:,:,5))]' ;                                 % employment total by education
tmp_married = [sum(married(:,:,2)); sum(married(:,:,3)); sum(married(:,:,4)); sum(married(:,:,5))]';                % married yes/no
f_emp_m = [sum(emp_m(:,:,2)); sum(emp_m(:,:,3)); sum(emp_m(:,:,4)); sum(emp_m(:,:,5))]';                            % employment married by education
f_emp_m  = f_emp_m ./tmp_married;
f_emp_um = [sum(emp_um(:,:,2)); sum(emp_um(:,:,3)); sum(emp_um(:,:,4)); sum(emp_um(:,:,5))]';                       % employment unmarried by education
f_emp_um  = f_emp_um ./[DRAW_F - tmp_married];
emp_moments_fitted_matrix = [f_emp_w  f_emp_m  f_emp_um];
emp_sd = nansum((emp_moments(1:28,2:13) - emp_moments_fitted_matrix).^2);
format short g;
disp('	WOMEN EMPLOYMENT ACTUAL 		   	     WOMEN EMPLOYMENT FITTED  ');
temp = [emp_moments(1:28,2:5)  emp_moments_fitted_matrix(:,1:4)]
disp('	MARRIED WOMEN EMPLOYMENT ACTUAL  	 	 MARRIED WOMEN EMPLOYMENT FITTED  ');
temp = [emp_moments(1:28,6:9)  emp_moments_fitted_matrix(:,5:8)]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%marr_fer_moments - 9 by 28 matrix
%first column - age
%column 2-5 - marriage rate by education group. start at t+age index
%column 6-9 - frtility rate by education group - start at t+age index end at 42
f_married = [mean(married(:,:,2)); mean(married(:,:,3)); mean(married(:,:,4)); mean(married(:,:,5))]'  ; 
f_fertility_m = [mean(newborn_m(:,:,2)); mean(newborn_m(:,:,3)); mean(newborn_m(:,:,4)); mean(newborn_m(:,:,5))]';    
f_divorce = [mean(divorce(:,:,2)); mean(divorce(:,:,3)); mean(divorce(:,:,4)); mean(divorce(:,:,5))]' ;     
marr_fer_moments_fitted_matrix = [ f_married  f_fertility_m  f_divorce];
marr_fer_sd = nansum((marr_fer_moments(1:28,2:13) - marr_fer_moments_fitted_matrix).^2);
disp('	MARRIAGE RATE ACTUAL  		   	   MARRIAGE RATE FITTED  ');
temp = [marr_fer_moments(1:28,2:5)  marr_fer_moments_fitted_matrix(:,1:4)]
disp('	FERTILITY RATE ACTUAL 		 	   FERTILITY RATE FITTED  ');
temp = [marr_fer_moments(1:28,6:9)  marr_fer_moments_fitted_matrix(:,5:8)]
disp('	DIVORCE RATE ACTUAL  		 	   DIVORCE RATE FITTED  ');
temp = [marr_fer_moments(1:28,10:13)  marr_fer_moments_fitted_matrix(:,9:12)]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%wage_moments - 10 by 36 matrix
%first column - potential or real experience
%column 2-5 - annual wage for women by education group - run until 27 for HSG, 25 for SC, 23 for CG and 20 for PC.
%column 6-10 - annual wage for men by education group - run until initial exp+t == 35
%ind_tmp=(wages_m_h>0);    % married men wages
%tmp = wages_m_h.*ind_tmp;
%f_wages_m_h = [sum(wages_m_h(1:36,:,1)); sum; sum(tmp(1:36,:,3))./sum(ind_tmp(1:36,:,3)); sum(tmp(1:36,:,4))./sum(ind_tmp(1:36,:,4)); sum(tmp(1:36,:,5))./sum(ind_tmp(1:36,:,5))]';
%f_wages_m_h = [sum(wages_m_h(:,1:36,1)); sum(wages_m_h(:,1:36,2)); sum(wages_m_h(:,1:36,3)); sum(wages_m_h(:,1:36,4)); sum(wages_m_h(:,1:36,5))]'
%ind_tmp=(wages_w>0);    % women wages
%tmp = wages_w.*ind_tmp;
%f_wages_w = [sum(tmp(:,:,2))./sum(ind_tmp(:,:,2)); sum(tmp(:,:,3))./sum(ind_tmp(:,:,3)); sum(tmp(:,:,4))./sum(ind_tmp(:,:,4)); sum(tmp(:,:,5))./sum(ind_tmp(:,:,5))]';
%wage_moments(1:36,2:10);
f_wages_m_h = wages_m_h(1:36,:)./count_wages_m_h(1:36,:);
f_wages_w = wages_w(:, 2:5)./count_wages_w(:, 2:5);
w_wage_sd = nansum((wage_moments(1:28,2:5) - f_wages_w).^2);
h_wage_sd = nansum((wage_moments(1:36,6:10) - f_wages_m_h(1:36,:)).^2);
format short g;
disp('		WOMEN WAGE ACTUAL 				WOMEN WAGE FITTED ')
%disp('		HSG ACTUAL HSG FITTED SC ACTUAL SC FITTED CG ACTUAL CG FITTED PC ACTUAL PC FITTED ')
temp = [wage_moments(1:28,2:5)  f_wages_w(:,1:4)]% wage_moments(1:28,3)  f_wages_w(:,2) wage_moments(1:28,4)  f_wages_w(:,3) wage_moments(1:28,5)  f_wages_w(:,4) ]
%disp('		HSD ACTUAL HSD FITTED HSG ACTUAL HSG FITTED SC ACTUAL SC FITTED CG ACTUAL CG FITTED PC ACTUAL PC FITTED ')
disp('		MEN WAGE ACTUAL 				MEN WAGE FITTED ')
temp = [wage_moments(1:36,6:10)  f_wages_m_h(1:36,1:5)]% wage_moments(1:36,7)  f_wages_m_h(1:36,2) wage_moments(1:36,8)  f_wages_m_h(1:36,3) wage_moments(1:36,9)  f_wages_m_h(1:36,4) wage_moments(1:36,10)  f_wages_m_h(1:36,5) ]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%general_moments - 4 by 62 matrix - 31 moments - by education group:
% 5 moments: assortative mating - H_HSD %assortative mating - H_HSG %assortative mating - H_SC  %assortative mating - H_CG  %assortative mating - H_PC
as2_1=(assortative_mating(:,2)==1);
sum_1 = sum(as2_1);
as2_2=(assortative_mating(:,2)==2);
sum_2 = sum(as2_2);
as2_3=(assortative_mating(:,2)==3);
sum_3 = sum(as2_3);
as2_4=(assortative_mating(:,2)==4);
sum_4 = sum(as2_4);
as2_5=(assortative_mating(:,2)==5);
sum_5 = sum(as2_5);
sum_all=sum_1+sum_2+sum_3+sum_4+sum_5;
f_assortative_mating2 = [sum_1/sum_all sum_2/sum_all sum_3/sum_all sum_4/sum_all sum_5/sum_all];
as2_1=(assortative_mating(:,3)==1);
sum_1 = sum(as2_1);
as2_2=(assortative_mating(:,3)==2);
sum_2 = sum(as2_2);
as2_3=(assortative_mating(:,3)==3);
sum_3 = sum(as2_3);
as2_4=(assortative_mating(:,3)==4);
sum_4 = sum(as2_4);
as2_5=(assortative_mating(:,3)==5);
sum_5 = sum(as2_5);
sum_all=sum_1+sum_2+sum_3+sum_4+sum_5;
f_assortative_mating3 = [sum_1/sum_all sum_2/sum_all sum_3/sum_all sum_4/sum_all sum_5/sum_all];
as2_1=(assortative_mating(:,4)==1);
sum_1 = sum(as2_1);
as2_2=(assortative_mating(:,4)==2);
sum_2 = sum(as2_2);
as2_3=(assortative_mating(:,4)==3);
sum_3 = sum(as2_3);
as2_4=(assortative_mating(:,4)==4);
sum_4 = sum(as2_4);
as2_5=(assortative_mating(:,4)==5);
sum_5 = sum(as2_5);
sum_all=sum_1+sum_2+sum_3+sum_4+sum_5;
f_assortative_mating4 = [sum_1/sum_all sum_2/sum_all sum_3/sum_all sum_4/sum_all sum_5/sum_all];
as2_1=(assortative_mating(:,5)==1);
sum_1 = sum(as2_1);
as2_2=(assortative_mating(:,5)==2);
sum_2 = sum(as2_2);
as2_3=(assortative_mating(:,5)==3);
sum_3 = sum(as2_3);
as2_4=(assortative_mating(:,5)==4);
sum_4 = sum(as2_4);
as2_5=(assortative_mating(:,5)==5);
sum_5 = sum(as2_5);
sum_all=sum_1+sum_2+sum_3+sum_4+sum_5;
f_assortative_mating5 = [sum_1/sum_all sum_2/sum_all sum_3/sum_all sum_4/sum_all sum_5/sum_all];
f_assortative_mating = [f_assortative_mating2' f_assortative_mating3' f_assortative_mating4' f_assortative_mating5'];
% 3 moments: marriage_duration  %age at first marriage  %total # of kids by 40
f_duration =[mean(nonzeros(duration_of_first_marriage(:,2))); mean(nonzeros(duration_of_first_marriage(:,3))); mean(nonzeros(duration_of_first_marriage(:,4))); mean(nonzeros(duration_of_first_marriage(:,5)))]'  ; % duration of marriage if divorce 
f_age_at_first_marriage =[mean(nonzeros(age_at_first_marriage(:,2))); mean(nonzeros(age_at_first_marriage(:,3))); mean(nonzeros(age_at_first_marriage(:,4))); mean(nonzeros(age_at_first_marriage(:,5)))]';   
f_kids = [mean(kids(:,2)) ;     mean(kids(:,3)); mean(kids(:,4)); mean(kids(:,5))]'     ;    % # of children by school group
%f_kids_m = [sum((kids_m(:,2))./sum(married(:, T_END,2))) ;     sum((kids_m(:,3))./sum(married(:, T_END,3))); sum((kids_m(:,4))./sum(married(:, T_END,4))); sum((kids_m(:,5))./sum(married(:, T_END,5)))]'        % # of children by school group
%f_kids_um = [sum((kids_um(:,2))./sum(married(:, T,2))) ;     mean(kids_um(:,3)); mean(kids_um(:,4)); mean(kids_um(:,5))]'        % # of children by school group
% 3 moments: women wage by match - UP   %women wage by match - EQUAL    %women wage by match - DOWN 
ind_tmp=(wages_m_w_up>0);    % married UP women wages
tmp = wages_m_w_up.*ind_tmp;
f_wages_m_w_up = [sum(tmp(:,:,2)); sum(tmp(:,:,3)); sum(tmp(:,:,4)); sum(tmp(:,:,5)) ]';
f_wages_m_w_up = f_wages_m_w_up./count_wages_m_w_up(:,2:5);
ff_wages_m_w_up = nanmean(f_wages_m_w_up);
ind_tmp=(wages_m_w_eq>0);    % married equal women wages
tmp = wages_m_w_eq.*ind_tmp;
f_wages_m_w_eq = [sum(tmp(:,:,2)); sum(tmp(:,:,3)); sum(tmp(:,:,4)); sum(tmp(:,:,5))]';
f_wages_m_w_eq = f_wages_m_w_eq./count_wages_m_w_eq(:,2:5);
ff_wages_m_w_eq = nanmean(f_wages_m_w_eq);
ind_tmp=(wages_m_w_down>0);    % married DOWN women wages
tmp = wages_m_w_down.*ind_tmp;
f_wages_m_w_down = [sum(tmp(:,:,2)); sum(tmp(:,:,3)); sum(tmp(:,:,4)); sum(tmp(:,:,5))]';
f_wages_m_w_down = f_wages_m_w_down./count_wages_m_w_down(:,2:5);
ff_wages_m_w_down = nanmean(f_wages_m_w_down);
% 3 moments: employment by match - UP   %employment by match - EQUAL    %employment by match - DOWN
f_emp_m_up = [sum(emp_m_up(:,:,2)); sum(emp_m_up(:,:,3)); sum(emp_m_up(:,:,4)); sum(emp_m_up(:,:,5))]';         % employment married up
f_emp_m_up = f_emp_m_up./count_emp_m_up(:,2:5);
ff_emp_m_up = nanmean(f_emp_m_up);
f_emp_m_eq = [sum(emp_m_eq(:,:,2)); sum(emp_m_eq(:,:,3)); sum(emp_m_eq(:,:,4)); sum(emp_m_eq(:,:,5))]'  ;       % employment married equal
f_emp_m_eq = f_emp_m_eq./count_emp_m_eq(:,2:5);
ff_emp_m_eq = nanmean(f_emp_m_eq);
f_emp_m_down = [sum(emp_m_down(:,:,2)); sum(emp_m_down(:,:,3)); sum(emp_m_down(:,:,4)); sum(emp_m_down(:,:,5))]';           % employment married down
f_emp_m_down = f_emp_m_down./count_emp_m_down(:,2:5);
ff_emp_m_down = nanmean(f_emp_m_down);
% 7 moments: emp by children for married : NO KIDS, 1 KIDS, 2 KIDS, 3 KIDS, 4 KIDS, unmarried with kids, unmarried with NO KIDS
f_emp_m_no_kids = [sum(emp_m_no_kids(:,:,2)); sum(emp_m_no_kids(:,:,3)); sum(emp_m_no_kids(:,:,4)); sum(emp_m_no_kids(:,:,5))]'; % employment total by education
f_emp_m_no_kids = nanmean(f_emp_m_no_kids./count_emp_m_no_kids(:,2:5));
f_emp_m_one_kid = [sum(emp_m_one_kid(:,:,2)); sum(emp_m_one_kid(:,:,3)); sum(emp_m_one_kid(:,:,4)); sum(emp_m_one_kid(:,:,5))]'; % employment total by education
f_emp_m_one_kid = nanmean(f_emp_m_one_kid./count_emp_m_one_kid(:,2:5));
f_emp_m_2_kids = [sum(emp_m_2_kids(:,:,2)); sum(emp_m_2_kids(:,:,3)); sum(emp_m_2_kids(:,:,4)); sum(emp_m_2_kids(:,:,5))]'; % employment total by education
f_emp_m_2_kids = nanmean(f_emp_m_2_kids./count_emp_m_2_kids(:,2:5));
f_emp_m_3_kids = [sum(emp_m_3_kids(:,:,2)); sum(emp_m_3_kids(:,:,3)); sum(emp_m_3_kids(:,:,4)); sum(emp_m_3_kids(:,:,5))]'; % employment total by education
f_emp_m_3_kids = nanmean(f_emp_m_3_kids./count_emp_m_3_kids(:,2:5));
f_emp_m_4plus_kids = [sum(emp_m_4plus_kids(:,:,2)); sum(emp_m_4plus_kids(:,:,3)); sum(emp_m_4plus_kids(:,:,4)); sum(emp_m_4plus_kids(:,:,5))]'; % employment total by education
f_emp_m_4plus_kids = nanmean(f_emp_m_4plus_kids./count_emp_m_4plus_kids(:,2:5));
f_emp_um_no_kids= [sum(emp_um_no_kids(:,:,2)); sum(emp_um_no_kids(:,:,3)); sum(emp_um_no_kids(:,:,4)); sum(emp_um_no_kids(:,:,5))]';    % employment unmarried and no children
f_emp_um_no_kids = nanmean(f_emp_um_no_kids./count_emp_um_no_kids(:,2:5));
f_emp_um_kids= [sum(emp_um_kids(:,:,2)); sum(emp_um_kids(:,:,3)); sum(emp_um_kids(:,:,4)); sum(emp_um_kids(:,:,5))]';   % employment unmarried and no children
f_emp_um_kids = nanmean(f_emp_um_kids./count_emp_um_kids(:,2:5));
% 6 moments: emp transition matrix - E to E married, UE to E married, E to E unmarried, UE to E unmarried, E to E married+children, UE to E married+children
f_emp_to_unemp_m = [sum(just_got_fired_m(:, :, 2));    sum(just_got_fired_m(:, :, 3)); sum(just_got_fired_m(:, :, 4)); sum(just_got_fired_m(:, :, 5))]';   % for transition matrix - employment to unemployment
f_emp_to_unemp_m = nanmean(f_emp_to_unemp_m./count_just_got_fired_m(:,2:5));
f_unemp_to_emp_m = [sum(just_found_job_m(:, :, 2));    sum(just_found_job_m(:, :, 3)); sum(just_found_job_m(:, :, 4)); sum(just_found_job_m(:, :, 5))]';   % for transition matrix - unemployment to employment 
f_unemp_to_emp_m = nanmean(f_unemp_to_emp_m./count_just_found_job_m(:,2:5));
f_emp_to_unemp_um = [sum(just_got_fired_um(:, :, 2));    sum(just_got_fired_um(:, :, 3)); sum(just_got_fired_um(:, :, 4)); sum(just_got_fired_um(:, :, 5))]';   % for transition matrix - employment to unemployment
f_emp_to_unemp_um = nanmean(f_emp_to_unemp_um./count_just_got_fired_um(:,2:5));
f_unemp_to_emp_um = [sum(just_found_job_um(:, :, 2));    sum(just_found_job_um(:, :, 3)); sum(just_found_job_um(:, :, 4)); sum(just_found_job_um(:, :, 5))]';   % for transition matrix - unemployment to employment 
f_unemp_to_emp_um = nanmean(f_unemp_to_emp_um./count_just_found_job_um(:,2:5));
f_emp_to_unemp_mc = [sum(just_got_fired_mc(:, :, 2));    sum(just_got_fired_mc(:, :, 3)); sum(just_got_fired_mc(:, :, 4)); sum(just_got_fired_mc(:, :, 5))]';   % for transition matrix - employment to unemployment
f_emp_to_unemp_mc = nanmean(f_emp_to_unemp_mc./count_just_got_fired_mc(:,2:5));
f_unemp_to_emp_mc = [sum(just_found_job_mc(:, :, 2));    sum(just_found_job_mc(:, :, 3)); sum(just_found_job_mc(:, :, 4)); sum(just_found_job_mc(:, :, 5))]';   % for transition matrix - unemployment to employment 
f_unemp_to_emp_mc = nanmean(f_unemp_to_emp_mc./count_just_found_job_mc(:,2:5));
% 2 moments: marriage transition matrix - marriage to divorce, divorce to marriage
f_single_to_married = [sum(just_married(:, :, 2));    sum(just_married(:, :, 3)); sum(just_married(:, :, 4)); sum(just_married(:, :, 5))]';   % for transition matrix - unemployment to employment 
f_single_to_married = nanmean(f_single_to_married./count_just_married(:,2:5));
f_married_to_divorce = [sum(just_divorced(:, :, 2));    sum(just_divorced(:, :, 3)); sum(just_divorced(:, :, 4)); sum(just_divorced(:, :, 5))]';   % for transition matrix - unemployment to employment 
f_married_to_divorce = nanmean(f_married_to_divorce./count_just_divorced(:,2:5));
% 2 moments: sum birth rate unmarried, sum birth rate married
f_birth_rate_um = [sum(newborn_um(:, :, 2));    sum(newborn_um(:, :, 3)); sum(newborn_um(:, :, 4)); sum(newborn_um(:, :, 5))]';   % for transition matrix - unemployment to employment 
f_birth_rate_um = nanmean(f_birth_rate_um./count_newborn_um(:,2:5));
f_birth_rate_m = [sum(newborn_m(:, :, 2));    sum(newborn_m(:, :, 3)); sum(newborn_m(:, :, 4)); sum(newborn_m(:, :, 5))]';   % for transition matrix - unemployment to employment 
f_birth_rate_m = nanmean(f_birth_rate_m./count_newborn_m(:,2:5));
general_moments_fitted = [ f_assortative_mating; f_duration; f_age_at_first_marriage; f_kids; ff_wages_m_w_up; ff_wages_m_w_eq; ff_wages_m_w_down; ff_emp_m_up; ff_emp_m_eq; ff_emp_m_down; f_emp_m_no_kids; f_emp_m_one_kid; f_emp_m_2_kids; f_emp_m_3_kids; f_emp_m_4plus_kids; f_emp_um_no_kids; f_emp_um_kids; f_emp_to_unemp_m; f_unemp_to_emp_m; f_emp_to_unemp_um; f_unemp_to_emp_um; f_emp_to_unemp_mc; f_unemp_to_emp_mc; f_single_to_married; f_married_to_divorce; f_birth_rate_um; f_birth_rate_m];
general_sd = (general_moments(1:31,:) - general_moments_fitted).^2;
format short g;
disp('  ******   GENERAL MOMENTS     *******')
disp('	HSG ACTUAL HSG FITTED SC ACTUAL SC FITTED CG ACTUAL CG FITTED PC ACTUAL PC FITTED ');
disp('  ******   Assortative mating     *******')
temp = [general_moments(1:5,1:4) general_moments_fitted(1:5,1:4)]% general_moments(1:5,2) general_moments_fitted(1:5,2) general_moments(1:5,3) general_moments_fitted(1:5,3) general_moments(1:5,4) general_moments_fitted(1:5,4)]
disp('  ******   marriage_duration  age at first marriage    total # of kids by 40     *******')
temp = [general_moments(6:8,1:4) general_moments_fitted(6:8,1:4)]% general_moments(6:8,2) general_moments_fitted(6:8,2) general_moments(6:8,3) general_moments_fitted(6:8,3) general_moments(6:8,4) general_moments_fitted(6:8,4)]
disp('  ******   women wage by match  UP women wage by match   EQUAL women wage by match   DOWN      *******')
temp = [general_moments(9:11,1:4) general_moments_fitted(9:11,1:4)]% general_moments(9:11,2) general_moments_fitted(9:11,2) general_moments(9:11,3) general_moments_fitted(9:11,3) general_moments(9:11,4) general_moments_fitted(9:11,4)]
disp('  ******   employment by match   UP  employment by match   EQUAL  Employment by match   DOWN      *******')
temp = [general_moments(12:14,1:4) general_moments_fitted(12:14,1:4)]% general_moments(12:14,2) general_moments_fitted(12:14,2) general_moments(12:14,3) general_moments_fitted(12:14,3) general_moments(12:14,4) general_moments_fitted(12:14,4)]
disp('  ******   Emp by children for married - NO KIDS, 1 KIDS,2 KIDS,3 KIDS,4 KIDS,unmarried+KIDS,unmarried - NO KIDS      *******')
temp = [general_moments(15:21,1:4) general_moments_fitted(15:21,1:4)]% general_moments(15:21,2) general_moments_fitted(15:21,2) general_moments(15:21,3) general_moments_fitted(15:21,3) general_moments(15:21,4) general_moments_fitted(15:21,4)]
disp('  ******   emp to unemp   M, unemp to emp   M, emp to unemp   UM, unemp to emp   UM, emp to unemp - M+, unemp to emp - M+      ********')
temp = [general_moments(22:27,1:4) general_moments_fitted(22:27,1:4)]% general_moments(22:27,2) general_moments_fitted(22:27,2) general_moments(22:27,3) general_moments_fitted(22:27,3) general_moments(22:27,4) general_moments_fitted(22:27,4)]
disp('  ******   marriage to divorce, divorce to marriage, mean birth rate for unmarried, mean birth rate for married      ********')
temp = [general_moments(28:31,1:4) general_moments_fitted(28:31,1:4)]% general_moments(28:31,2) general_moments_fitted(28:31,2) general_moments(28:31,3) general_moments_fitted(28:31,3) general_moments(28:31,4) general_moments_fitted(28:31,4)]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           MOMENTS NOT FOR ESTIMATION - JUST FOR COUNTER FACTUALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3 moments: employment by match - UP   %employment by match - EQUAL    %employment by match - DOWN - ABOVE AND BELOW HUSBAND AVERAGE WAGE
f_emp_m_up_above = [sum(emp_m_up_above(:,:,2)); sum(emp_m_up_above(:,:,3)); sum(emp_m_up_above(:,:,4)); sum(emp_m_up_above(:,:,5))]';         % employment married up
f_emp_m_up_above = f_emp_m_up_above./count_emp_m_up_above(:,2:5);
ff_emp_m_up_above = nanmean(f_emp_m_up_above)
f_emp_m_up_below = [sum(emp_m_up_below(:,:,2)); sum(emp_m_up_below(:,:,3)); sum(emp_m_up_below(:,:,4)); sum(emp_m_up_below(:,:,5))]';         % employment married up
f_emp_m_up_below = f_emp_m_up_below./count_emp_m_up_below(:,2:5);
ff_emp_m_up_below = nanmean(f_emp_m_up_below)

f_emp_m_eq_above = [sum(emp_m_eq_above(:,:,2)); sum(emp_m_eq_above(:,:,3)); sum(emp_m_eq_above(:,:,4)); sum(emp_m_eq_above(:,:,5))]'  ;       % employment married equal
f_emp_m_eq_above = f_emp_m_eq_above./count_emp_m_eq_above(:,2:5);
ff_emp_m_eq_above = nanmean(f_emp_m_eq_above)
f_emp_m_eq_below = [sum(emp_m_eq_below(:,:,2)); sum(emp_m_eq_below(:,:,3)); sum(emp_m_eq_below(:,:,4)); sum(emp_m_eq_below(:,:,5))]'  ;       % employment married equal
f_emp_m_eq_below = f_emp_m_eq_below./count_emp_m_eq_below(:,2:5);
ff_emp_m_eq_below = nanmean(f_emp_m_eq_below)

f_emp_m_down_above = [sum(emp_m_down_above(:,:,2)); sum(emp_m_down_above(:,:,3)); sum(emp_m_down_above(:,:,4)); sum(emp_m_down_above(:,:,5))]';           % employment married down
f_emp_m_down_above = f_emp_m_down_above./count_emp_m_down_above(:,2:5);
ff_emp_m_down_above = nanmean(f_emp_m_down_above)
f_emp_m_down_below = [sum(emp_m_down_below(:,:,2)); sum(emp_m_down_below(:,:,3)); sum(emp_m_down_below(:,:,4)); sum(emp_m_down_below(:,:,5))]';           % employment married down
f_emp_m_down_below = f_emp_m_down_below./count_emp_m_down_below(:,2:5);
ff_emp_m_down_below = nanmean(f_emp_m_down_below)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           CLOSE MOMENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

objective_function = 0

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    ESTIMATION PROCESS - SGMM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5 moments matrixes: emp_sd(1, 1:12) marr_fer_sd(1, 1:12)  w_wage_sd(1, 1:4) h_wage_sd(1, 1:5) general_sd(1:31,1:4)
%devide by moment weight
emp_sd = emp_sd./emp_moments(29,2:13);
marr_fer_sd=marr_fer_sd./marr_fer_moments(29,2:13);
w_wage_sd = w_wage_sd./(wage_moments(37,2:5).^2);
h_wage_sd = h_wage_sd./(wage_moments(37,6:10).^2);
general_sd = general_sd./general_moments(32:62,:);
general_sd(21,4) = 0;
general_sd(9:11,:)=general_sd(9:11,:)./general_moments(40:42,:);
general_temp = nansum(general_sd);
objective_function=nansum(emp_sd)+nansum(marr_fer_sd)+nansum(w_wage_sd)+nansum(h_wage_sd)+nansum(general_temp)
end

