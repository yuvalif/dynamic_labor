function objective_function = estimation_f(param, f_type, display, global_param, T_MAX, DRAW_B, DRAW_F, SCHOOL_GROUPS, husbands_2,husbands_3,husbands_4,husbands_5, wives, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, h_draws_b, w_draws_b, w_ability_draw, h_draws, w_draws) 
%estimation_f
%   T - number of periods
%   numdraws - number of random draws
%   OBS - number of observations
%   Author: Osnat Lifshitz
%   Date: 12-sept-12
%keyboard();
%debug_on_error();
H = 0;
W = 1;



% set small scale to 1 for running in small scale
small_scale = 0;
DUMP_EMAX = 0;
STATIC = 1;  %only no EMAX
% counter_factuals
COUNTER = 0;
%COUNTER = 1 ; %static model in EMAX, wage, job offer - k+prev_state
%COUNTER = 2 ; % no return for experience in wage


if (small_scale == 1)
    K0 = 0;
    K5 = 0;
    K10 = 0;
    K20 = 0;
    HE0 = 0;
    HE5 = 0;
    HE10 = 0;
    HE20 = 0;
    TERMINAL = 25;
    H_EXP20 = 0;
    EMAX21 = TERMINAL - 18 + 1 + 1;
else
    K0 = 0;
    K5 = 5;
    K10 = 10;
    K20 = 20;
    HE0 = 0;
    HE5 = 5;
    HE10 = 10;
    HE20 = 20;
    TERMINAL = 45;
    H_EXP20 = 20;
    EMAX21 = H_EXP20 + 1;
end
%global fitted_moments_out;
%global actual_moments_out;

x_idx = get_global_param_idx(f_type);
global_param(x_idx) = param;
global sigma = zeros(5,5);
% Utility parameters WIFE:  
global alpha1_w  = global_param(1);        % utility from leisure 
global alpha21_w = global_param(2);        % utility from young children
global alpha22_w = global_param(3);        % utility from old children
global alpha31_w = global_param(4);        % utility from children when married
% Utility parameters HUSBAND: 
global alpha1_h  = global_param(5);        % utility from leisure 
global alpha21_h = global_param(6);        % utility from young children
global alpha22_h = global_param(7);        % utility from old children
global alpha31_h = global_param(8);        % utility from children when married - unidentified since no children when unmarried???
% Wage parameters wife
global beta1_w  = global_param(9);     %experience 
global beta2_w  = global_param(10);     %exp^2  
%beta30_w = global_param();     %HSD - schooling    
global beta31_w = global_param(11);    %HSG - schooling    
global beta32_w = global_param(12);    %SC -  schooling    
global beta33_w = global_param(13);    %CG -  schooling    
global beta34_w = global_param(14);    %PC -  schooling
% Wage parameters husband
global beta1_h  = global_param(15);    %experience 
global beta2_h  = global_param(16);    %exp^2  
global beta30_h = global_param(17);    %HSD - schooling    
global beta31_h = global_param(18);    %HSG- schooling 
global beta32_h = global_param(19);    %SC -  schooling    
global beta33_h = global_param(20);    %CG -  schooling    
global beta34_h = global_param(21);    %PC -  schooling    
% Job offer parameters  wife 
global row_w    = global_param(22);      % constant 
global row0_w   = global_param(23);      % work in previous period
global row11_w  = global_param(24);      % HSG -schooling
global row12_w  = global_param(25);      % SC - schooling
global row13_w  = global_param(26);      % CG - schooling
global row14_w  = global_param(27);      % PC - schooling
global row2_w   = global_param(28);      % work experience
% Job offer parameters  husband 
global row_h    = global_param(29);      % constant 
global row0_h   = global_param(30);      % work in previous period
global row11_h  = global_param(31);      % HSG -schooling
global row12_h  = global_param(32);      % SC - schooling
global row13_h  = global_param(33);      % CG - schooling
global row14_h  = global_param(34);      % PC - schooling
global row2_h   = global_param(35);      % work experience
%home production technology - parameters    
global hp1 = global_param(36);         % # of young children influence on work at home hours
global hp2 = global_param(37);         % # of old children influence on work at home hours
global hp3 = global_param(38);         % husband leisure 
global hp4 = global_param(39);         % wife leisure
global hp5 = global_param(40);         % # of young children influence on consumption  
global hp6 = global_param(41);         % # of old children influence on consumption
global hp7 = global_param(42);         % sigma CRRA parameter
global hp8 = global_param(43);         % CRRA income parameter
%probability of another child parameters    
global c1= global_param(44);           % previous work state - wife
global c2 = global_param(45);          %age wife - HSG
global c3 = global_param(46);          %age square wife - HSG
global c4 = global_param(47);          %age wife - SC
global c5 = global_param(48);          %age square wife - SC
global c6 = global_param(49);          %age wife - CG
global c7 = global_param(50);          %age square wife - CG
global c8 = global_param(51);          %age wife - PC
global c9 = global_param(52);          %age square wife - PC
global c10 = global_param(53);         %number of children at household    
global c11 = global_param(54);         % schooling - husband
global c12 = global_param(55);         % married - M
% terminal value Parameters
%t0 = global_param();           % schooling wife - HSD
global t1_w = global_param(56);        % schooling wife - HSG
global t2_w = global_param(57);        % schooling wife - SC
global t3_w = global_param(58);        % schooling wife - CG
global t4_w = global_param(59);        % schooling wife - PC
global t5_w = global_param(60);        % exp wife
global t6_w = global_param(61);        % schooling husband if married - HSD
global t7_w = global_param(62);        % schooling husband if married - HSG
global t8_w = global_param(63);        % schooling husband if married - SC
global t9_w = global_param(64);        % schooling husband if married - CG
global t10_w = global_param(65);       % schooling husband if married - PC
global t11_w = global_param(66);       % exp husband if married 
global t12_w = global_param(67);       % martial status
global t13_w = global_param(68);       % number of children
global t14_w = global_param(69);       % match quality if married
global t15_w = global_param(70);       % number of children if married
global t16_w = global_param(71);       % previous work state - wife
global t17_w = global_param(72);       % previous work state - husband if married
% terminal value Parameters
%t0 = global_param();           % schooling wife if married - HSD
global t1_h = global_param(73);        % schooling wife if married- HSG
global t2_h = global_param(74);        % schooling wife if married- SC
global t3_h = global_param(75);        % schooling wife if married- CG
global t4_h = global_param(76);        % schooling wife if married- PC
global t5_h = global_param(77);        % exp wife if married
global t6_h = global_param(78);        % schooling husband - HSD
global t7_h = global_param(79);        % schooling husband - HSG
global t8_h = global_param(80);        % schooling husband - SC
global t9_h = global_param(81);        % schooling husband - CG
global t10_h = global_param(82);       % schooling husband - PC
global t11_h = global_param(83);       % exp husband  
global t12_h = global_param(84);       % martial status if married
global t13_h = global_param(85);       % number of children if married
global t14_h = global_param(86);       % match quality if married
global t15_h = global_param(87);        % number of children if married - NO NEED
global t16_h = global_param(88);       % previous work state - wife if married
global t17_h = global_param(89);       % previous work state - husband 

% match quality parameters
global P_HUSBAND =        (exp(global_param(87)))/(1+exp(global_param(87)));   % PROBABILITY OF MEETING A POTENTIAL HUSBAND
global MATCH_Q_DECREASE = (exp(global_param(88)))/(1+exp(global_param(88)));   % probability of match quality decrease
global MATCH_Q_INCREASE = (exp(global_param(89)))/(1+exp(global_param(89)));   % probability of match quality increase
global EDUC_MATCH_2 = global_param(90);  %education match parameter
global EDUC_MATCH_3 = global_param(91);  %education match parameter
global EDUC_MATCH_4 = global_param(92);  %education match parameter
global EDUC_MATCH_5 = global_param(93);  %education match parameter
% random shocks variance-covariance matrix
sigma(1,1) = exp(global_param(94));             %wage error variance husband;
sigma(2,2) = exp(global_param(95));             %wage error variance wife;
sigma(3,3) = exp(global_param(96));             % variance wife ability
sigma(4,4) = exp(global_param(97));             % variance husband ability
sigma(5,5) = exp(global_param(98));             % variance match quality

if COUNTER == 1
	beta = 0; % - static model !!!
end
if COUNTER == 2
	beta1_w  = 0;
	beta2_w  = 0;
	row2 = 0;
end	
	beta = 0.983;       % discount rate
% standart normal distribution array : 5%, 15%, 25%, 35%, 45%, 55%, 65%, 75%, 85%, 95%
%normal_arr = [-1.645, -1.036, -0.674, -0.385, -0.126, 0.126, 0.385, 0.674, 1.036, 1.645];
% standart normal distribution array : 5%, 15%, 25%, 35%, 45%, 55%, 65%, 75%, 85%, 95%

global normal_arr = [-1.2817,  -0.524,  0.000,  0.524, 1.2817];
global bp_vector = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1 ];
%%%%%%%%%%%%%%%%%%
% INITIALIZATION %
%%%%%%%%%%%%%%%%%%
%individual moments:
%employment moments
emp =               zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment total
emp_m =             zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married
emp_um =            zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % employment unmarried
emp_m_up =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married up
emp_m_down =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married down
emp_m_eq =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married equal
emp_m_up_below =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married up
emp_m_down_below =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married down
emp_m_eq_below =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married equal
emp_m_up_above =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married up
emp_m_down_above =        zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married down
emp_m_eq_above =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married equal
count_emp_m_up =    zeros(T_MAX, SCHOOL_GROUPS);                % employment married up
count_emp_m_down =  zeros(T_MAX, SCHOOL_GROUPS);                % employment married down
count_emp_m_eq =    zeros(T_MAX, SCHOOL_GROUPS);                % employment married equal
count_emp_m_up_below =    zeros(T_MAX, SCHOOL_GROUPS);                % employment married up
count_emp_m_down_below =  zeros(T_MAX, SCHOOL_GROUPS);                % employment married down
count_emp_m_eq_below =    zeros(T_MAX, SCHOOL_GROUPS);                % employment married equal
count_emp_m_up_above =    zeros(T_MAX, SCHOOL_GROUPS);                % employment married up
count_emp_m_down_above =  zeros(T_MAX, SCHOOL_GROUPS);                % employment married down
count_emp_m_eq_above =    zeros(T_MAX, SCHOOL_GROUPS);                % employment married equal
emp_m_no_kids =     zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married no kids
emp_m_one_kid =     zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 1 kid
emp_m_2_kids = 		zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 2-3 kids
emp_m_3_kids =    	zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 2-3 kids
emp_m_4plus_kids =  zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);         % employment married 4  kids
count_emp_m_no_kids =  zeros(T_MAX, SCHOOL_GROUPS);   
count_emp_m_one_kid =  zeros(T_MAX, SCHOOL_GROUPS);   
count_emp_m_2_kids =   zeros(T_MAX, SCHOOL_GROUPS);  
count_emp_m_3_kids =   zeros(T_MAX, SCHOOL_GROUPS);  
count_emp_m_4plus_kids = zeros(T_MAX, SCHOOL_GROUPS);
emp_um_no_kids =       zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % employment unmarried and no children
emp_um_kids =          zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % employment unmarried and children
divorce = 			   zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);  
count_emp_um_no_kids = zeros(T_MAX, SCHOOL_GROUPS);
count_emp_um_kids =    zeros(T_MAX, SCHOOL_GROUPS);
just_found_job_m =       zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - unemployment to employment 
just_got_fired_m =       zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - employment to unemployment
just_found_job_um =       zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - unemployment to employment 
just_got_fired_um =       zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - employment to unemployment
just_found_job_mc =       zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - unemployment to employment 
just_got_fired_mc =       zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);          % for transition matrix - employment to unemployment
count_just_got_fired_m  = zeros(T_MAX, SCHOOL_GROUPS);
count_just_found_job_m 	= zeros(T_MAX, SCHOOL_GROUPS);
count_just_got_fired_um = zeros(T_MAX, SCHOOL_GROUPS);
count_just_found_job_um = zeros(T_MAX, SCHOOL_GROUPS);
count_just_got_fired_mc = zeros(T_MAX, SCHOOL_GROUPS);
count_just_found_job_mc = zeros(T_MAX, SCHOOL_GROUPS);
ability_h_up    = zeros(T_MAX, SCHOOL_GROUPS);
ability_h_down  = zeros(T_MAX, SCHOOL_GROUPS);
ability_h_eq    = zeros(T_MAX, SCHOOL_GROUPS);
ability_w_up    = zeros(T_MAX, SCHOOL_GROUPS);
ability_w_down  = zeros(T_MAX, SCHOOL_GROUPS);
ability_w_eq    = zeros(T_MAX, SCHOOL_GROUPS);
match_w_up      = zeros(T_MAX, SCHOOL_GROUPS);
match_w_down    = zeros(T_MAX, SCHOOL_GROUPS);
match_w_eq      = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_h_up    = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_h_down  = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_h_eq    = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_w_up    = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_w_down  = zeros(T_MAX, SCHOOL_GROUPS);
count_ability_w_eq    = zeros(T_MAX, SCHOOL_GROUPS);
count_match_w_up      = zeros(T_MAX, SCHOOL_GROUPS);
count_match_w_down    = zeros(T_MAX, SCHOOL_GROUPS);
count_match_w_eq      = zeros(T_MAX, SCHOOL_GROUPS);
% wages moments
wages_m_h 				= zeros(48, SCHOOL_GROUPS);  % married men wages - 0 until 20+27 years of exp - 36-47 will be ignore in moments  
count_wages_m_h			= zeros(48,SCHOOL_GROUPS); 
wages_w 				= zeros(T_MAX, SCHOOL_GROUPS);  % women wages if employed
count_wages_w			= zeros(T_MAX, SCHOOL_GROUPS);
wages_m_w 				= ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married women wages if employed
wages_m_h_up 			= ones(DRAW_F,48, SCHOOL_GROUPS).*-99999;  % married up men wages 
wages_m_h_down 			= ones(DRAW_F,48, SCHOOL_GROUPS).*-99999;  % married down men wages 
wages_m_h_eq 			= ones(DRAW_F,48, SCHOOL_GROUPS).*-99999;  % married equal men wages 
wages_m_w_up		    = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married up women wages if employed
wages_m_w_down          = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married down women wages if employed
wages_m_w_eq 		    = ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % married equal women wages if employed
count_wages_m_h_up 		= zeros(48, SCHOOL_GROUPS);     % count observation of married up men wages 
count_wages_m_h_down 	= zeros(48, SCHOOL_GROUPS);     % count observation of married down men wages 
count_wages_m_h_eq 		= zeros(48, SCHOOL_GROUPS);       % count observation of married equal men wages 
count_wages_m_w_up 		= zeros(T_MAX, SCHOOL_GROUPS);  % count observation of married up women wages if employed
count_wages_m_w_down 	= zeros(T_MAX, SCHOOL_GROUPS);  % count observation of married down women wages if employed
count_wages_m_w_eq 		= zeros(T_MAX, SCHOOL_GROUPS);  % count observation of married equal women wages if employed
wages_um_w 				= ones(DRAW_F,T_MAX, SCHOOL_GROUPS).*-99999;  % unmarried women wages if employed
% fertilty and marriage rate moments
married               			 = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       % married yes/no
just_married          			 = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       %for transition matrix from single to married
age_at_first_marriage 		     = zeros(DRAW_F, SCHOOL_GROUPS);             %age at first marriage
just_divorced         			 = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       %for transition matrix from married to divorce
newborn_um               		 = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       % new born in period t - for probability and distribution
newborn_m               		 = zeros(DRAW_F,T_MAX, SCHOOL_GROUPS);       % new born in period t - for probability and distribution
duration_of_first_marriage 		 = zeros(DRAW_F, SCHOOL_GROUPS);         % duration of marriage if divorce or 45-age of marriage if still married at 45.
count_duration_of_first_marriage = zeros(SCHOOL_GROUPS,1);
assortative_mating    			 = zeros(DRAW_F, SCHOOL_GROUPS);             % HUSBAND EDUCATION BY WIFE EDUCATION
count_just_married 				 = zeros(T_MAX, SCHOOL_GROUPS);
count_just_divorced 			 = zeros(T_MAX, SCHOOL_GROUPS);
count_newborn_um 				 = zeros(T_MAX, SCHOOL_GROUPS);
count_newborn_m 				 = zeros(T_MAX, SCHOOL_GROUPS);

for school_group=1 : 5       % school_group 1 is only for calculating the emax if single men, other than that, there is a "if school_group>1"
    if (school_group == 1)
        HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        HSD = 1;
        HS = 1; H_HSD = 1;
        AGE = 18;
        T= TERMINAL - AGE+1; 
        age_index = 0;
		husbands = husbands_2;  %only for initialization - no use!
    elseif (school_group == 2)
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        HSG = 1;
        HS = 2; H_HSG = 1;
        AGE = 18;
        T= TERMINAL - AGE+1; 
        age_index = 0;
		husbands = husbands_2;
    elseif (school_group == 3)  
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        SC = 1;
        HS = 3; H_SC = 1;
        AGE = 20;
        T = TERMINAL - AGE+1;
        age_index = 2;
		husbands = husbands_3;
    elseif (school_group == 4)
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        CG = 1;
        HS = 4; H_CG = 1;
        AGE = 22;
        T = TERMINAL - AGE+1;
        age_index = 4;
		husbands = husbands_4;
    else
        HSD = 0; HSG = 0;  SC = 0;  CG = 0; PC = 0;
        H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
        PC = 1;
        HS = 5; H_PC = 1;
        AGE = 25;
        T = TERMINAL - AGE+1;   
        age_index = 7;
		husbands = husbands_5;
    end
	if (STATIC == 0 && COUNTER != 1) 
		% EMAX dimensions are
		%period, experience, # of young children,# of old children,prev_state, wife ability, mar_state,husband exp,husband schooling,match quality, ability_h_index, bp
		EMAX_W = zeros(T,T+1,4,4,2,5,2,EMAX21,5,5,5,3); 
		EMAX_H = zeros(T,T+1,4,4,2,5,2,EMAX21,5,5,5,3); 
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% SOLVING BACKWARDS - FILLING THE EMAX %
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		for t = T : -1 : 1 %TIME
			% % husbands cohort characteristics - P_HUSBAND=husbands(t,1);
			P_HSD_0=husbands(t+age_index,2);
			P_HSD_5=husbands(t+age_index,3);
			P_HSD_10=husbands(t+age_index,4);
			P_HSD_20=husbands(t+age_index,5);
			P_HSG_0=husbands(t+age_index,6);
			P_HSG_5=husbands(t+age_index,7);
			P_HSG_10=husbands(t+age_index,8);
			P_HSG_20=husbands(t+age_index,9);
			P_SC_0=husbands(t+age_index,10);
			P_SC_5=husbands(t+age_index,11);
			P_SC_10=husbands(t+age_index,12);
			P_SC_20=husbands(t+age_index,13);
			P_CG_0=husbands(t+age_index,14);
			P_CG_5=husbands(t+age_index,15);
			P_CG_10=husbands(t+age_index,16);
			P_CG_20=husbands(t+age_index,17);
			P_PC_0=husbands(t+age_index,18);
			P_PC_5=husbands(t+age_index,19);
			P_PC_10=husbands(t+age_index,20);
			P_PC_20=husbands(t+age_index,21);
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   EMAX FOR SINGLE MEN     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% % wife cohort characteristics 
			P_1=wives(t+age_index,2);
			P_2=wives(t+age_index,3);
			P_3=wives(t+age_index,4);
			P_4=wives(t+age_index,5);
			P_5=wives(t+age_index,6);
			P_6=wives(t+age_index,7);
			P_7=wives(t+age_index,8);
			P_8=wives(t+age_index,9);
			P_9=wives(t+age_index,10);
			P_10=wives(t+age_index,11);
			P_11=wives(t+age_index,12);
			P_12=wives(t+age_index,13); 
			P_13=wives(t+age_index,14);
			P_14=wives(t+age_index,15);
			P_15=wives(t+age_index,16);
			P_16=wives(t+age_index,17);
			P_17=wives(t+age_index,18);
			P_18=wives(t+age_index,19);
			P_19=wives(t+age_index,20);
			P_20=wives(t+age_index,21);
			P_21=wives(t+age_index,22);
			P_22=wives(t+age_index,23);
			P_23=wives(t+age_index,24);
			P_24=wives(t+age_index,25); 
			P_25=wives(t+age_index,26);
			P_26=wives(t+age_index,27);
			P_27=wives(t+age_index,28);
			P_28=wives(t+age_index,29);
			P_29=wives(t+age_index,30);
			P_30=wives(t+age_index,31);
			P_31=wives(t+age_index,32);
			P_32=wives(t+age_index,33);
		
			if (t < 21)
				for H_EXP = 0:t-1 %HUSBAND EXPERENCE
					for ability_h_index = 1:5   %husband ability
						ability_h = normal_arr(ability_h_index)*sigma(4,4);
						for draw_b = 1 : DRAW_B
							% DRAW A WIFE 
							WS = 1;
							similar_educ = 0;
							K = 0;
							M = 0;
							D = 0;
							Q = 0;
							N_Y = 0;
							N_O = 0;
							HSD = 0; HSG = 0; SC = 0; CG = 0; PC = 0;
			%w_draws_b = rand(DRAW_B, T_MAX, SCHOOL_GROUPS, 6);%1- wife; 2-wife EXP+SCHOOLING; 3-wife ABILITY; 4 - INITIAL MATCH QUALITY; 5 - JOB OFFER FOR MARRIED MEN AND WOMEN EMAX; 6-JOB OFFER FOR SINGLE MEN EMAX 
							if (w_draws_b(draw_b,t,HS,1) < P_HUSBAND) %THE PROBABILITY TO DRAW A WIFE IS EQUAL TO THE PROBABILITY TO DRAW HUSBAND?!
								CHOOSE_WIFE = 1;
								ability_w = normal_arr(w_draws_b(draw_b,t,HS,3))*sigma(3,3);
								ability_w_index = w_draws_b(draw_b,t,HS,3);
								Q = normal_arr(w_draws_b(draw_b,t,HS,4))*sigma(5,5);
								Q_INDEX = w_draws_b(draw_b,t,HS,4);
								if (w_draws_b(draw_b,t,HS,2) < P_1) %wife schooling - HSG & UNEMPLOYED IN PREVIOUS PERIOD
									HSG=1;  
									K = K0;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2) > P_1 && w_draws_b(draw_b,t,HS,2) < P_2)
									HSG=1;  
									K = K5;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_2 && w_draws_b(draw_b,t,HS,2)<P_3)
									HSG=1;  
									K = K10;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_3 && w_draws_b(draw_b,t,HS,2)<P_4)
									HSG=1;  
									K = K20; 
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_4 && w_draws_b(draw_b,t,HS,2)<P_5) %wife schooling - HSG & EMPLOYED IN PREVIOUS PERIOD
									HSG=1;  
									K = K0;
									prev_state = 1;                                     
								elseif w_draws_b(draw_b,t,HS,2)>P_5 && w_draws_b(draw_b,t,HS,2)<P_6
									HSG=1;  
									K = K5;  
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_6 && w_draws_b(draw_b,t,HS,2)<P_7
									HSG=1;  
									K = K10; 
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_7 && w_draws_b(draw_b,t,HS,2)<P_8
									HSG=1;  
									K = K20; 
									prev_state = 1; 
								elseif (w_draws_b(draw_b,t,HS,2)>P_8 && w_draws_b(draw_b,t,HS,2)<P_9) %wife schooling - SC & UNEMPLOYED IN PREVIOUS PERIOD
									SC=1;  
									K = K0;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_9 && w_draws_b(draw_b,t,HS,2)<P_10) 
									SC=1;  
									K = K5;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_10 && w_draws_b(draw_b,t,HS,2)<P_11)
									SC=1;  
									K = K10;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_11 && w_draws_b(draw_b,t,HS,2)<P_12)
									SC=1;  
									K = K20; 
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_12 && w_draws_b(draw_b,t,HS,2)<P_13) %wife schooling - SC & EMPLOYED IN PREVIOUS PERIOD
									SC=1;  
									K = K0;
									prev_state = 1;                                     
								elseif w_draws_b(draw_b,t,HS,2)>P_13 && w_draws_b(draw_b,t,HS,2)<P_14
									SC=1;  
									K = K5;  
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_14 && w_draws_b(draw_b,t,HS,2)<P_15
									SC=1;  
									K = K10; 
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_15 && w_draws_b(draw_b,t,HS,2)<P_16
									SC=1;  
									K = K20; 
									prev_state = 1; 
								elseif (w_draws_b(draw_b,t,HS,2)>P_16 && w_draws_b(draw_b,t,HS,2)<P_17) %wife schooling - CG & UNEMPLOYED IN PREVIOUS PERIOD
									CG=1;  
									K = K0;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_17 && w_draws_b(draw_b,t,HS,2)<P_18)
									CG=1;  
									K = K5;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_18 && w_draws_b(draw_b,t,HS,2)<P_19)
									CG=1;  
									K = K10;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_19 && w_draws_b(draw_b,t,HS,2)<P_20)
									CG=1;  
									K = K20; 
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_20 && w_draws_b(draw_b,t,HS,2)<P_21) %wife schooling - CG & EMPLOYED IN PREVIOUS PERIOD
									CG=1;  
									K = K0;
									prev_state = 1;                                     
								elseif w_draws_b(draw_b,t,HS,2)>P_21 && w_draws_b(draw_b,t,HS,2)<P_22
									CG=1;  
									K = K5;  
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_22 && w_draws_b(draw_b,t,HS,2)<P_23
									CG=1;  
									K = K10; 
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_23 && w_draws_b(draw_b,t,HS,2)<P_24
									CG=1;  
									K = K20; 
									prev_state = 1; 
								elseif (w_draws_b(draw_b,t,HS,2)>P_24 && w_draws_b(draw_b,t,HS,2)<P_25) %wife schooling - PC & UNEMPLOYED IN PREVIOUS PERIOD
									PC=1;  
									K = K0;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_25 && w_draws_b(draw_b,t,HS,2)<P_26)
									PC=1;  
									K = K5;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_26 && w_draws_b(draw_b,t,HS,2)<P_27)
									PC=1;  
									K = K10;
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_27 && w_draws_b(draw_b,t,HS,2)<P_28)
									PC=1;  
									K = K20; 
									prev_state = 0;
								elseif (w_draws_b(draw_b,t,HS,2)>P_28 && w_draws_b(draw_b,t,HS,2)<P_29) %wife schooling - PC & EMPLOYED IN PREVIOUS PERIOD
									PC=1;  
									K = K0;
									prev_state = 1;                                     
								elseif w_draws_b(draw_b,t,HS,2)>P_29 && w_draws_b(draw_b,t,HS,2)<P_30
									PC=1;  
									K = K5;  
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_30 && w_draws_b(draw_b,t,HS,2)<P_31
									PC=1;  
									K = K10; 
									prev_state = 1; 
								elseif w_draws_b(draw_b,t,HS,2)>P_31 && w_draws_b(draw_b,t,HS,2)<P_32
									PC=1;  
									K = K20; 
									prev_state = 1; 
								end
								if HSG == 1
									WS = 2;
								elseif SC == 1
									WS = 3;
								elseif CG ==1
									WS = 4;
								elseif PC == 1
									WS = 5;
								end	
								if HS==2 && WS==2
									similar_educ = EDUC_MATCH_2;
								elseif HS==3 && WS==3	
									similar_educ = EDUC_MATCH_3;
								elseif HS==4 && WS==4	
									similar_educ = EDUC_MATCH_4;
								elseif HS==5 && WS==5	
									similar_educ = EDUC_MATCH_5;
								else
									similar_educ = 0;
								end	
								% JOB OFFER PROBABILITY + WAGE WIFE
								PROB_TMP=row0*prev_state + row11*HSG +row12*SC +row13*CG +row14*PC + row2*K;
								PROB_W= exp(PROB_TMP) ./ (1+exp(PROB_TMP));
								if PROB_W > w_draws_b(draw_b,t,HS,6)
									CHOOSE_WORK = 1;
									tmp1_w = ability_w + beta1_w*K + beta2_w*K.^2 + beta31_w*HSG+beta32_w*SC+ beta33_w*CG+ beta34_w*PC;
									tmp2_w = (epsilon_b(draw_b, t, HS,2)*sigma(2,2)); %epsilon_b(draw_b, t,school_group, sex)  
									wage_w = exp(tmp1_w + tmp2_w);
								else
									CHOOSE_WORK = 0;
									wage_w = 0;
								end
							else
								ability_w_index = 1;
								Q_INDEX = 1;
								CHOOSE_WIFE = 0;
								CHOOSE_WORK = 0;
								wage_w = 0;
							end 
							tmp1_h = ability_h + beta1_h*(H_EXP)+ beta2_h*(H_EXP).^2+ beta30_h*H_HSD+beta31_h*H_HSG+ beta32_h*H_SC+ beta33_h*H_CG+ beta34_h*H_PC;
							tmp2_h = (epsilon_b(draw_b, t,HS,1)*sigma(1,1)); %epsilon_b(draw_b, t, sex)
							wage_h = exp(tmp1_h + tmp2_h);
							
							% decision making - choose from up to 4 options, according to CHOOSE_HUSBAND and CHOOSE_WORK values
							% utility from each option:
							% home production - equal for both partners:             1-singe+unemployed
											%                                        2-singe+employed
											%                                        3-married+unemployed
											%                                        4-married+eployed
							%home production technology - parameters    
							%   HP(S)=((1+hp1*N_Y+hp2*N_O)*(hp3+hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_w+wage_h)^hp7)^(1/hp7);
							HP(1)=((1+hp1*N_Y+hp2*N_O)*(hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(0)^hp7)^(1/hp7);
							HP(2)=((1+hp1*N_Y+hp2*N_O)*(0)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_w)^hp7)^(1/hp7);%all cancel out but wage_w if no kids
							HP(3)=((1+hp1*N_Y+hp2*N_O)*(hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_h)^hp7)^(1/hp7);
							HP(4)=((1+hp1*N_Y+hp2*N_O)*(0)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_h+wage_w)^hp7)^(1/hp7);
							% wife utility from each option
							% U_W(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;                   
							%scale_w = 1 + M*0.7 + (N_Y+N_O)*0.4;
							UC_W(1)=(((HP(1)/(1+(N_Y+N_O)*0.4))^hp8)/hp8)+alpha1_w+alpha21_w*N_Y+alpha22_w*N_O;
							UC_W(2)=(((HP(2)/(1+(N_Y+N_O)*0.4))^hp8)/hp8)         +alpha21_w*N_Y+alpha22_w*N_O;
							UC_W(3)=(((HP(3)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)+alpha1_w+alpha21_w*N_Y+alpha22_w*N_O+Q+similar_educ+alpha31_w*N_Y+alpha32_w*N_O;
							UC_W(4)=(((HP(4)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)        +alpha21_w*N_Y+alpha22_w*N_O+Q+similar_educ+alpha31_w*N_Y+alpha32_w*N_O;
							if t == T
								%t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
								%t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
								%t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
								%t16 previous work state - wife, 
								U_W(1)=UC_W(1)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*K+t13_w*(N_Y+N_O);     
								U_W(2)=UC_W(2)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(K+1)+t13_w*(N_Y+N_O)+t16_w;       
								U_W(3)=UC_W(3)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*K+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(H_EXP+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O);      
								U_W(4)=UC_W(4)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(K+1)+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(H_EXP+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t16_w;        
							else
								% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX, ability_h_index, bp)
								U_W(1)=UC_W(1)+beta*EMAX_W(t+1, K+1, N_Y+1, N_O+1, 0+1, ability_w_index, 0+1, 1, 1, 1, 1, 1);
								U_W(2)=UC_W(2)+beta*EMAX_W(t+1, K+2, N_Y+1, N_O+1, 1+1, ability_w_index, 0+1, 1, 1, 1, 1, 1);
								U_W(3)=UC_W(3)+beta*EMAX_W(t+1, K+1, N_Y+1, N_O+1, 0+1, ability_w_index, 1+1, (H_EXP+1)+1, HS, Q_INDEX, ability_h_index, 2);
								U_W(4)=UC_W(4)+beta*EMAX_W(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,1+1,(H_EXP+1)+1,HS,Q_INDEX,ability_h_index,2);
							end
						
							if M == 0  &&  CHOOSE_WIFE == 0
								U_W(3)  = -99999;
								U_W(4)  = -99999;
							end
							if CHOOSE_WORK == 0
								U_W(2) = -99999;
								U_W(4) = -99999;
							end
							% husband CURRENT utility from four options
							% U_H(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;       
							UC_H(1)= -99999;
							UC_H(2)=((wage_h^hp8)/hp8);
							UC_H(3)=(((HP(3)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)       +alpha21_h*N_Y+alpha22_h*N_O+Q+similar_educ;
							UC_H(4)=(((HP(4)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)       +alpha21_h*N_Y+alpha22_h*N_O+Q+similar_educ;
							if t == T
								%t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
								%t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
								%t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
								%t16 previous work state - wife, t17 previous work state - husband
								U_H(1)= -99999; 
								U_H(2)=UC_H(2)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(H_EXP+1);        
								U_H(3)=UC_H(3)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*K+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(H_EXP+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ);      
								U_H(4)=UC_H(4)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*(K+1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(H_EXP+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t16_h;        
							else
								% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX, ability_h_index, bp)
								U_H(1)= -99999;
								U_H(2)=UC_H(2)+beta*EMAX_H(t+1,1,1,1,1,1,1,(H_EXP+1)+1,HS,1,ability_h_index,1);
								U_H(3)=UC_H(3)+beta*EMAX_H(t+1,K+1,N_Y+1,N_O+1,0+1,ability_w_index,1+1,(H_EXP+1)+1,HS,Q_INDEX,ability_h_index,2);
								U_H(4)=UC_H(4)+beta*EMAX_H(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,1+1,(H_EXP+1)+1,HS,Q_INDEX,ability_h_index,2);
							end
							if M == 0  &&  CHOOSE_WIFE == 0
								U_H(3)  = -99999;
								U_H(4)  = -99999;
							end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%   MAXIMIZATION - MARRIAGE + WORK DESICION                        %
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
							% marriage decision - outside option value wife
							if U_W(1)>U_W(2)
								outside_option_w_v = U_W(1);
								%outside_option_w = 1; %"unemployed"
							else        
								outside_option_w_v = U_W(2);
								%outside_option_w = 2; %employed
							end
							if U_W(3)> outside_option_w_v && U_W(4)> outside_option_w_v 
								if U_H(3)>U_H(2) && U_H(4)>U_H(2) %WILL GET MARRIE AND CHOOSE MAX
								%%%%%%%%%%%%%%  Nash bergaining at first period of marriage  %%%%%%%%%%%%%%%%%%%%%%%%%%
									nash_value_3 =(U_W(3)-outside_option_w_v)*(U_H(3)-U_H(2)) ;  %value if married and women unemployed
									nash_value_4 =(U_W(4)-outside_option_w_v)*(U_H(4)-U_H(2))  ; %value if married and women unemployed
									if (nash_value_3>nash_value_4)
										M = 1 ;
										tmp_emp = 0;
									elseif (nash_value_4>nash_value_3)
										M = 1 ;
										tmp_emp = 1;
									end 
								elseif U_H(3)>U_H(2) && U_H(4)<U_H(2) %WILL GET MARRIE AND NOT WORK - CHOOSE 3
									M = 1 ;
									tmp_emp = 0;
								elseif U_H(4)>U_H(2) && U_H(3)<U_H(2) %WILL GET MARRIE AND WORK - CHOOSE 4
									M = 1 ;
									tmp_emp = 1;
								elseif U_H(3)<U_H(2) && U_H(4)<U_H(2) %WILL NOT GET MARRIE 
									M = 0 ;
									if U_W(1) == outside_option_w_v      %WILL NOT WORK AND SINGLE, CHOOSE 1
										tmp_emp = 0;
									else                                %WILL WORK AND SINGLE, CHOOSE 2
										tmp_emp = 1;
									end
								end
							elseif  U_W(3)> outside_option_w_v && U_W(4)< outside_option_w_v %WILL NOT WORK IF MARRIED
								if U_H(3)>U_H(2)  %WILL GET MARIED, WILL NOT WORK, CHOOSE 3
									M = 1 ;
									tmp_emp = 0;
								elseif U_H(3)<U_H(2) %WILL NOT GET MARIED
									M = 0 ;
									if U_W(1) == outside_option_w_v  %WILL NOT WORK AND SINGLE, CHOOSE 1
										tmp_emp = 0;
									else                           % WILL WORK AS SINGLE, CHOOSE 2
										tmp_emp = 1;
									end
								end 
							elseif  U_W(4)> outside_option_w_v && U_W(3)< outside_option_w_v %WILL WORK IF MARRIED 
								if U_H(4)>U_H(2) %WILL GET MARIED, WILL WORK, CHOOSE 4
									M = 1 ;
									tmp_emp = 1;
								elseif U_H(4)<U_H(2)  %WILL NOT GET MARIED
									M = 0 ;
									if U_W(1) == outside_option_w_v %WILL NOT WORK AND SINGLE, CHOOSE 1 
										tmp_emp = 0;
									else                          % WILL WORK AS SINGLE, CHOOSE 2
										tmp_emp = 1;
									end
								end 
							elseif  U_W(4)< outside_option_w_v && U_W(3)< outside_option_w_v % WILL NOT MARRIED
								M = 0 ;
								if U_W(1) == outside_option_w_v %WILL NOT WORK AND SINGLE, CHOOSE 1
									tmp_emp = 0;
								else                            % WILL WORK AS SINGLE, CHOOSE 2
									tmp_emp = 1;
								end
							end
							if M == 0 
								emax_draw_h(draw_b) = U_H(2);
							elseif M == 1 && tmp_emp == 0
								emax_draw_h(draw_b) = U_H(3);
							elseif M == 1 && tmp_emp == 1
								emax_draw_h(draw_b) = U_H(4);   
							end
						end % close draw_b loop 
						% emax is the average of emax_draw over the draws
						emax_h = mean(emax_draw_h);
						% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX, ability_h_index, bp)
						EMAX_H(t,1,0+1,0+1,0+1,0+1,0+1,H_EXP+1,HS,0+1,ability_h_index,2)= emax_h;%EMAX of a single men
					end   % close ability loop  
				end  %close H_EXP loop
			end  %close if t<21
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
			if school_group > 1  % do not run all the rest of the EMAX for HSD women
				H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;   %update the schooling since it was destroyed in the single men EMAX
				if school_group == 2
					HSD = 0; HSG = 1;  SC = 0;  CG = 0; PC = 0;
				elseif school_group == 3    
					HSD = 0; HSG = 0;  SC = 1;  CG = 0; PC = 0;
				elseif school_group == 4
					HSD = 0; HSG = 0;  SC = 0; CG = 1; PC = 0;
				elseif school_group == 5
					HSD = 0; HSG = 0;  SC = 0;  CG = 0;     PC = 1;
				end
				for N_Y = 0 : 3 %young children
					for N_O = 0 : 3 % old children
						for prev_state = 0 : 1 % previous state loop
							for ability_w_index = 1:5   %wife ability
								ability_w = normal_arr(ability_w_index)*sigma(3,3);
								for K = 1: t+1
									for M_T_minus_1 = 0 : 1 % martial status - 0 - unmarried, 1 - married
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   EMAX FOR SINGLE WOMEN     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
										if M_T_minus_1 == 0
											for draw_b = 1 : DRAW_B
												similar_educ = 0;
												WS = 1;	
												D = 0;
												Q = 0;
												M = 0;
												HS = 1;
												H_HSD = 0 ; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0; HE = 0;
												if h_draws_b(draw_b,t,school_group,1)<P_HUSBAND
													CHOOSE_HUSBAND = 1;
													ability_h = normal_arr(h_draws_b(draw_b,t,school_group,3))*sigma(4,4);
													ability_h_index = h_draws_b(draw_b,t,school_group,3);
													Q = normal_arr(h_draws_b(draw_b,t,school_group,4))*sigma(5,5);
													Q_INDEX = h_draws_b(draw_b,t,school_group,4);
													if h_draws(draw_b,t,school_group,2)<P_HSD_0%husband schooling HSD
														HS=1;
														H_HSD=1;
														HE = HE0;
													elseif (h_draws(draw_b,t,school_group,2)>P_HSD_0 && h_draws(draw_b,t,school_group,2)<P_HSD_5)
														HS=1;
														H_HSD=1;
														HE = HE5;
													elseif (h_draws(draw_b,t,school_group,2)>P_HSD_5 && h_draws(draw_b,t,school_group,2)<P_HSD_10)
														HS=1;
														H_HSD=1;
														HE = HE10;
													elseif (h_draws(draw_b,t,school_group,2)>P_HSD_10 && h_draws(draw_b,t,school_group,2)<P_HSD_20)
														HS=1;
														H_HSD=1;
														HE = HE20;    
													elseif (h_draws(draw_b,t,school_group,2)>P_HSD_20 && h_draws(draw_b,t,school_group,2)<P_HSG_0) %husband schooling HSG
														HS=2;
														H_HSG=1;
														HE = HE0; 
													elseif h_draws(draw_b,t,school_group,2)>P_HSG_0 && h_draws(draw_b,t,school_group,2)<P_HSG_5
														HS=2;
														H_HSG=1;
														HE = HE5; 
													elseif h_draws(draw_b,t,school_group,2)>P_HSG_5 && h_draws(draw_b,t,school_group,2)<P_HSG_10
														HS=2;
														H_HSG=1;
														HE = HE10;    
													elseif h_draws(draw_b,t,school_group,2)>P_HSG_10 && h_draws(draw_b,t,school_group,2)<P_HSG_20
														HS=2;
														H_HSG=1;
														HE = HE20;    
													elseif h_draws(draw_b,t,school_group,2)>P_HSG_20 && h_draws(draw_b,t,school_group,2)<P_SC_0  %husband schooling SC
														HS=3;
														H_SC=1;
														HE = HE0; 
													elseif h_draws(draw_b,t,school_group,2)>P_SC_0 && h_draws(draw_b,t,school_group,2)<P_SC_5
														HS=3;
														H_SC=1;
														HE = HE5; 
													elseif h_draws(draw_b,t,school_group,2)>P_SC_5 && h_draws(draw_b,t,school_group,2)<P_SC_10
														HS=3;
														H_SC=1;
														HE = HE10;    
													elseif h_draws(draw_b,t,school_group,2)>P_SC_10 && h_draws(draw_b,t,school_group,2)<P_SC_20
														HS = 3;
														H_SC = 1;
														HE = HE20;    
													elseif h_draws(draw_b,t,school_group,2)>P_SC_20 && h_draws(draw_b,t,school_group,2)<P_CG_0  %husband schooling CG
														HS = 4;
														H_CG=1;
														HE = HE0; 
													elseif h_draws(draw_b,t,school_group,2)>P_CG_0 && h_draws(draw_b,t,school_group,2)<P_CG_5
														HS = 4;
														H_CG=1;
														HE = HE5; 
													elseif h_draws(draw_b,t,school_group,2)>P_CG_5 && h_draws(draw_b,t,school_group,2)<P_CG_10
														HS = 4;
														H_CG=1;
														HE = HE10;    
													elseif h_draws(draw_b,t,school_group,2)>P_CG_10 && h_draws(draw_b,t,school_group,2)<P_CG_20
														HS = 4;
														H_CG = 1;
														HE = HE20;                    
													elseif h_draws(draw_b,t,school_group,2)>P_CG_20 && h_draws(draw_b,t,school_group,2)<P_PC_0  %husband schooling PC
														HS = 5;
														H_PC=1;
														HE = HE0; 
													elseif h_draws(draw_b,t,school_group,2)>P_PC_0 && h_draws(draw_b,t,school_group,2)<P_PC_5
														HS = 5;
														H_PC=1;
														HE = HE5; 
													elseif h_draws(draw_b,t,school_group,2)>P_PC_5 && h_draws(draw_b,t,school_group,2)<P_PC_10
														HS = 5;
														H_PC=1;
														HE = HE10;    
													elseif h_draws(draw_b,t,school_group,2)>P_PC_10 && h_draws(draw_b,t,school_group,2)<P_PC_20
														HS = 5;
														H_PC = 1;
														HE = HE20;    
													end
													% POTENTIAL HUSBAND WAGE
													H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
													if HS == 1
														H_HSD = 1;
													elseif HS == 2
														H_HSG = 1;
													elseif HS == 3
														H_SC = 1;
													elseif HS == 4
														H_CG = 1;
													elseif HS == 5
														H_PC = 1;
													end     
													tmp1_h = ability_h + beta1_h*(HE+D)+ beta2_h*(HE+D).^2+ beta30_h*H_HSD+beta31_h*H_HSG+ beta32_h*H_SC+ beta33_h*H_CG+ beta34_h*H_PC;
													tmp2_h = (epsilon_b(draw_b, t,school_group,1)*sigma(1,1)); %epsilon_b(draw_b, t, sex)
													wage_h = exp(tmp1_h + tmp2_h);
													if HSG == 1
														WS = 2;
													elseif SC == 1
														WS = 3;
													elseif CG ==1
														WS = 4;
													elseif PC == 1
														WS = 5;
													end	
													if HS==2 && WS==2
														similar_educ = EDUC_MATCH_2;
													elseif HS==3 && WS==3	
														similar_educ = EDUC_MATCH_3;
													elseif HS==4 && WS==4	
														similar_educ = EDUC_MATCH_4;
													elseif HS==5 && WS==5	
														similar_educ = EDUC_MATCH_5;
													else
														similar_educ = 0;
													end	
												else
													CHOOSE_HUSBAND = 0;
													wage_h = 0;
												end 
												% JOB OFFER PROBABILITY + WAGE WIFE
												%w_draws = rand(DRAW_B,T,2); 1 -job offer, 2-new child, 
												PROB_TMP=row0*prev_state + row11*HSG +row12*SC +row13*CG +row14*PC + row2*K;
												PROB_W= exp(PROB_TMP) ./ (1+exp(PROB_TMP));
												if PROB_W > w_draws_b(draw_b,t,school_group,5)
													CHOOSE_WORK = 1;
													tmp1_w = ability_w + beta1_w*K + beta2_w*K.^2 + beta31_w*HSG+beta32_w*SC+ beta33_w*CG+ beta34_w*PC;
													tmp2_w = (epsilon_b(draw_b, t, school_group,2)*sigma(2,2)); %epsilon_b(draw_b, t, sex)  
													wage_w = exp(tmp1_w + tmp2_w);
												else
													CHOOSE_WORK = 0;
													wage_w = 0;
												end
												% decision making - choose from up to 4 options, according to CHOOSE_HUSBAND and CHOOSE_WORK values
												% utility from each option:
												% home production - equal for both partners:             1-singe+unemployed
																%                                        2-singe+employed
																%                                        3-married+unemployed
																%                                        4-married+eployed
												%home production technology - parameters    
												%   HP(S)=((1+hp1*N_Y+hp2*N_O)*(hp3+hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_w+wage_h)^hp7)^(1/hp7);
												HP(1)=((1+hp1*N_Y+hp2*N_O)*(hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(0)^hp7)^(1/hp7);
												HP(2)=((1+hp1*N_Y+hp2*N_O)*(0)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_w)^hp7)^(1/hp7);%all cancel out but wage_w if no kids
												HP(3)=((1+hp1*N_Y+hp2*N_O)*(hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_h)^hp7)^(1/hp7);
												HP(4)=((1+hp1*N_Y+hp2*N_O)*(0)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_h+wage_w)^hp7)^(1/hp7);
												% wife utility from each option
												% U_W(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;                   
												%scale_w = 1 + M*0.7 + (N_Y+N_O)*0.4;
												UC_W(1)=(((HP(1)/(1+(N_Y+N_O)*0.4))^hp8)/hp8)+alpha1_w+alpha21_w*N_Y+alpha22_w*N_O;
												UC_W(2)=(((HP(2)/(1+(N_Y+N_O)*0.4))^hp8)/hp8)         +alpha21_w*N_Y+alpha22_w*N_O;
												UC_W(3)=(((HP(3)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)+alpha1_w+alpha21_w*N_Y+alpha22_w*N_O+Q+similar_educ+alpha31_w*N_Y+alpha32_w*N_O;
												UC_W(4)=(((HP(4)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)        +alpha21_w*N_Y+alpha22_w*N_O+Q+similar_educ+alpha31_w*N_Y+alpha32_w*N_O;
							
												if t == T
													%t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
													%t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
													%t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
													%t16 previous work state - wife, 
													U_W(1)=UC_W(1)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*K+t13_w*(N_Y+N_O);     
													U_W(2)=UC_W(2)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(K+1)+t13_w*(N_Y+N_O)+t16_w;       
													U_W(3)=UC_W(3)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*K+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+D+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O);       
													U_W(4)=UC_W(4)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(K+1)+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(HE+D+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t16_w;     
												else
                                                    EMAX_HE_D_1 = min([HE+D+1 20]);
													% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX,ability_h_index, bp)
													U_W(1)=UC_W(1)+beta*EMAX_W(t+1,K+1,N_Y+1,N_O+1,0+1,ability_w_index,0+1,1,1,1,1,1);
													U_W(2)=UC_W(2)+beta*EMAX_W(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,0+1,1,1,1,1,1);
													U_W(3)=UC_W(3)+beta*EMAX_W(t+1,K+1,N_Y+1,N_O+1,0+1,ability_w_index,1+1,(HE+D+1)+1,HS,Q_INDEX,ability_h_index,2);
													U_W(4)=UC_W(4)+beta*EMAX_W(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,1+1,(HE+D+1)+1,HS,Q_INDEX,ability_h_index,2);
												end
							
												if M == 0  &&  CHOOSE_HUSBAND == 0
													U_W(3)  = -99999;
													U_W(4)  = -99999;
												end
												if CHOOSE_WORK == 0
													U_W(2) = -99999;
													U_W(4) = -99999;
												end
												% husband CURRENT utility from four options
												% U_H(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;       
												UC_H(1)= -99999;
												UC_H(2)=((wage_h^hp8)/hp8);
												UC_H(3)=(((HP(3)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)       +alpha21_h*N_Y+alpha22_h*N_O+Q+similar_educ;
												UC_H(4)=(((HP(4)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)       +alpha21_h*N_Y+alpha22_h*N_O+Q+similar_educ;
												if t == T
													%t1 schooling wife - HSG, t2 schooling wife - SC, t3 schooling wife - CG, t4 schooling wife - PC, t5 exp wife
													%t6 schooling husband if married - HSD, t7 schooling husband - HSG, t8 Shooling husband - SC, t9 Schooling husband CG, t10 schooling husband- PC
													%t11 exp husband if married, t12 martial status, t13 number of children, t14 match quality if married, t15 number of children if married
													%t16 previous work state - wife, t17 previous work state - husband
													U_H(1)= -99999; 
													U_H(2)=UC_H(2)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+D+1);     
													U_H(3)=UC_H(3)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*K+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+D+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ);       
													U_H(4)=UC_H(4)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*(K+1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(HE+D+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t16_h;     
												else
                                                    EMAX_HE_D_1 = min([HE+D+1 20]);
													% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX, ability_h_index, bp)
													U_H(1)= -99999;
													U_H(2)=UC_H(2)+beta*EMAX_H(t+1,1,1,1,1,1,1,(HE+D+1)+1,HS,1,ability_h_index,1);
													U_H(3)=UC_H(3)+beta*EMAX_H(t+1,K+1,N_Y+1,N_O+1,0+1,ability_w_index,1+1,(HE+D+1)+1,HS,Q_INDEX,ability_h_index,2);
													U_H(4)=UC_H(4)+beta*EMAX_H(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,1+1,(HE+D+1)+1,HS,Q_INDEX,ability_h_index,2);
												end
												if M == 0  &&  CHOOSE_HUSBAND == 0
													U_H(3)  = -99999;
													U_H(4)  = -99999;
												end
												%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
												%   MAXIMIZATION - MARRIAGE + WORK DESICION                        %
												%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
												% need optimization - not efficient programing      
												% marriage decision - outside option value wife
												if U_W(1)>U_W(2)
													outside_option_w_v = U_W(1);
													%outside_option_w = 1; %"unemployed"
												else        
													outside_option_w_v = U_W(2);
													%outside_option_w = 2; %employed
												end
												if U_W(3)> outside_option_w_v && U_W(4)> outside_option_w_v 
													if U_H(3)>U_H(2) && U_H(4)>U_H(2) %WILL GET MARRIE AND CHOOSE MAX
													%%%%%%%%%%%%%%  Nash bergaining at first period of marriage  %%%%%%%%%%%%%%%%%%%%%%%%%%
														nash_value_3 =(U_W(3)-outside_option_w_v)*(U_H(3)-U_H(2)) ;  %value if married and women unemployed
														nash_value_4 =(U_W(4)-outside_option_w_v)*(U_H(4)-U_H(2))  ; %value if married and women unemployed
														if (nash_value_3>nash_value_4)
															M = 1 ;
															tmp_emp = 0;
														elseif (nash_value_4>nash_value_3)
															M = 1 ;
															tmp_emp = 1;
														end 
													elseif U_H(3)>U_H(2) && U_H(4)<U_H(2) %WILL GET MARRIE AND NOT WORK - CHOOSE 3
														M = 1 ;
														tmp_emp = 0;
													elseif U_H(4)>U_H(2) && U_H(3)<U_H(2) %WILL GET MARRIE AND WORK - CHOOSE 4
														M = 1 ;
														tmp_emp = 1;
													elseif U_H(3)<U_H(2) && U_H(4)<U_H(2) %WILL NOT GET MARRIE 
														M = 0 ;
														if U_W(1) == outside_option_w_v      %WILL NOT WORK AND SINGLE, CHOOSE 1
															tmp_emp = 0;
														else                                %WILL WORK AND SINGLE, CHOOSE 2
															tmp_emp = 1;
														end
													end
												elseif  U_W(3)> outside_option_w_v && U_W(4)< outside_option_w_v %WILL NOT WORK IF MARRIED
													if U_H(3)>U_H(2)  %WILL GET MARIED, WILL NOT WORK, CHOOSE 3
														M = 1 ;
														tmp_emp = 0;
													elseif U_H(3)<U_H(2) %WILL NOT GET MARIED
														M = 0 ;
														if U_W(1) == outside_option_w_v  %WILL NOT WORK AND SINGLE, CHOOSE 1
															tmp_emp = 0;
														else                           % WILL WORK AS SINGLE, CHOOSE 2
															tmp_emp = 1;
														end
													end 
												elseif  U_W(4)> outside_option_w_v && U_W(3)< outside_option_w_v %WILL WORK IF MARRIED 
													if U_H(4)>U_H(2) %WILL GET MARIED, WILL WORK, CHOOSE 4
														M = 1 ;
														tmp_emp = 1;
													elseif U_H(4)<U_H(2)  %WILL NOT GET MARIED
														M = 0 ;
														if U_W(1) == outside_option_w_v %WILL NOT WORK AND SINGLE, CHOOSE 1 
															tmp_emp = 0;
														else                          % WILL WORK AS SINGLE, CHOOSE 2
															tmp_emp = 1;
														end
													end 
												elseif  U_W(4)< outside_option_w_v && U_W(3)< outside_option_w_v % WILL NOT MARRIED
													M = 0 ;
													if U_W(1) == outside_option_w_v %WILL NOT WORK AND SINGLE, CHOOSE 1
														tmp_emp = 0;
													else                            % WILL WORK AS SINGLE, CHOOSE 2
														tmp_emp = 1;
													end
												end
												if M == 0 && tmp_emp == 0
													emax_draw_w(draw_b) = U_W(1);
												elseif M == 0 && tmp_emp == 1
													emax_draw_w(draw_b) = U_W(2);
												elseif M == 1 && tmp_emp == 0
													emax_draw_w(draw_b) = U_W(3);
												elseif M == 1 && tmp_emp == 1
													emax_draw_w(draw_b) = U_W(4);   
												end
											end % close draw_b loop 
											% emax is the average of emax_draw over the draws
											emax_w = mean(emax_draw_w);
											% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX, ability_h_index, bp)
											EMAX_W(t,K+1,N_Y+1,N_O+1,prev_state+1,ability_w_index,0+1,1,1,1,1,2) = emax_w;%EMAX of a single women

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   EMAX FOR MARRIED MEN AND WOMEN      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
										elseif M_T_minus_1 == 1
											for HS = 1:5 %husband schooling :HSD,HSG,SC, CG, PC
												for Q_INDEX = 1:5 % Match Quality 
													Q = normal_arr(Q_INDEX)*sigma(5,5);
													if t<21
														for H_EXP = 0:t-1 %HUSBAND EXPERENCE
															for ability_h_index = 1:5   %husband ability
																ability_h = normal_arr(ability_h_index)*sigma(4,4);
																for  bp_dummy = 1 :3   % 0.25, 0.5, 0.75 - bp from previous period
																	for draw_b = 1 : DRAW_B
																		% CURRENT HUSBAND WAGE 
																		H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
																		if HS == 1
																			H_HSD = 1;
																		elseif HS == 2
																			H_HSG = 1;
																		elseif HS == 3
																			H_SC = 1;
																		elseif HS == 4
																			H_CG = 1;
																		elseif HS == 5
																			H_PC = 1;
																		end     
																		tmp1_h = ability_h + beta1_h*(H_EXP)+ beta2_h*(H_EXP).^2+ beta30_h*H_HSD+beta31_h*H_HSG+ beta32_h*H_SC+ beta33_h*H_CG+ beta34_h*H_PC;
																		tmp2_h = (epsilon_b(draw_b, t,school_group,1)*sigma(1,1)); %epsilon_b(draw_b, t, sex)
																		wage_h = exp(tmp1_h + tmp2_h);
																		if HSG == 1
																			WS = 2;
																		elseif SC == 1
																			WS = 3;
																		elseif CG ==1
																			WS = 4;
																		elseif PC == 1
																			WS = 5;
																		end	
																		if HS==2 && WS==2
																			similar_educ = EDUC_MATCH_2;
																		elseif HS==3 && WS==3	
																			similar_educ = EDUC_MATCH_3;
																		elseif HS==4 && WS==4	
																			similar_educ = EDUC_MATCH_4;
																		elseif HS==5 && WS==5	
																			similar_educ = EDUC_MATCH_5;
																		else
																			similar_educ = 0;
																		end	
																		% JOB OFFER PROBABILITY + WAGE WIFE
																		%w_draws = rand(DRAW_F,T,2); 1 -job offer, 2-new child, 
																		PROB_TMP=row0*prev_state + row11*HSG +row12*SC +row13*CG +row14*PC + row2*K;
																		PROB_W= exp(PROB_TMP) ./ (1+exp(PROB_TMP));
																		if PROB_W > w_draws_b(draw_b,t,school_group,5)
																			CHOOSE_WORK = 1;
																			tmp1_w = ability_w + beta1_w*K + beta2_w*K.^2 + beta31_w*HSG+beta32_w*SC+ beta33_w*CG+ beta34_w*PC;
																			tmp2_w = (epsilon_b(draw_b, t, school_group,2)*sigma(2,2)); %epsilon_b(draw_b, t, sex)  
																			wage_w = exp(tmp1_w + tmp2_w);
																		else
																			CHOOSE_WORK = 0;
																			wage_w = 0;
																		end
																		% decision making - choose from up to 4 options, according to CHOOSE_HUSBAND and CHOOSE_WORK values
																		% utility from each option:
																		% home production - equal for both partners:  1-singe+unemployed
																		%                                             2-singe+employed
																		%                                             3-married+unemployed
																		%                                             4-married+eployed
																		%home production technology - parameters    
																		%   HP(S)=((1+hp1*N_Y+hp2*N_O)*(hp3+hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_w+wage_h)^hp7)^(1/hp7);
																		HP(1)=((1+hp1*N_Y+hp2*N_O)*(hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(0)^hp7)^(1/hp7);
																		HP(2)=((1+hp1*N_Y+hp2*N_O)*(0)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_w)^hp7)^(1/hp7);%all cancel out but wage_w if no kids
																		HP(3)=((1+hp1*N_Y+hp2*N_O)*(hp4)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_h)^hp7)^(1/hp7);
																		HP(4)=((1+hp1*N_Y+hp2*N_O)*(0)^hp7+(1+hp5*N_Y+hp6*N_O)*(wage_h+wage_w)^hp7)^(1/hp7);
																		% wife utility from each option
																		% U_W(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;                   
																		%scale_w = 1 + M*0.7 + (N_Y+N_O)*0.4;
																		UC_W(1)=(((HP(1)/(1+(N_Y+N_O)*0.4))^hp8)/hp8)+alpha1_w+alpha21_w*N_Y+alpha22_w*N_O;
																		UC_W(2)=(((HP(2)/(1+(N_Y+N_O)*0.4))^hp8)/hp8)         +alpha21_w*N_Y+alpha22_w*N_O;
																		UC_W(3)=(((HP(3)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)+alpha1_w+alpha21_w*N_Y+alpha22_w*N_O+Q+similar_educ+alpha31_w*N_Y+alpha32_w*N_O;
																		UC_W(4)=(((HP(4)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)        +alpha21_w*N_Y+alpha22_w*N_O+Q+similar_educ+alpha31_w*N_Y+alpha32_w*N_O;
																		if t == T
																			U_W(1)=UC_W(1)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*K+t13_w*(N_Y+N_O);     
																			U_W(2)=UC_W(2)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(K+1)+t13_w*(N_Y+N_O)+t16_w;       
																			U_W(3)=UC_W(3)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*K+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(H_EXP+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O);      
																			U_W(4)=UC_W(4)+t1_w*HSG+t2_w*SC+t3_w*CG+t4_w*PC+t5_w*(K+1)+t6_w*H_HSD+t7_w*H_HSG+t8_w*H_SC+t9_w*H_CG+t10_w*H_PC+t11_w*(H_EXP+1)+t12_w+t13_w*(N_Y+N_O)+t14_w*(Q+similar_educ)+t15_w*(N_Y+N_O)+t16_w;        
																		else
																			% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX,ability_h_index, bp)
																			U_W(1)=UC_W(1)+beta*EMAX_W(t+1,K+1,N_Y+1,N_O+1,0+1,ability_w_index,0+1,1,1,1,1,1);
																			U_W(2)=UC_W(2)+beta*EMAX_W(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,0+1,1,1,1,1,1);
																			U_W(3)=UC_W(3)+beta*EMAX_W(t+1,K+1,N_Y+1,N_O+1,0+1,ability_w_index,1+1,(H_EXP+1)+1,HS,Q_INDEX,ability_h_index,bp_dummy);
																			U_W(4)=UC_W(4)+beta*EMAX_W(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,1+1,(H_EXP+1)+1,HS,Q_INDEX,ability_h_index,bp_dummy);
																		end
																		if CHOOSE_WORK == 0
																			U_W(2) = -99999;
																			U_W(4) = -99999;
																		end
																		% husband CURRENT utility from four options
																		% U_H(S)=HP(S)+alpha1+alpha21*N_Y+alpha22*N_O+alpha3*M*Q+alpha41*M*N_Y+alpha42*M*N_O;       
																		UC_H(1)= -99999;
																		UC_H(2)=((wage_h^hp8)/hp8);
																		UC_H(3)=(((HP(3)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)       +alpha21_h*N_Y+alpha22_h*N_O+Q+similar_educ;
																		UC_H(4)=(((HP(4)/(1.7+(N_Y+N_O)*0.4))^hp8)/hp8)       +alpha21_h*N_Y+alpha22_h*N_O+Q+similar_educ;
																		if t == T
																			U_H(1)= -99999; 
																			U_H(2)=UC_H(2)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(H_EXP+1);        
																			U_H(3)=UC_H(3)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*K+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(H_EXP+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ);      
																			U_H(4)=UC_H(4)+t1_h*HSG+t2_h*SC+t3_h*CG+t4_h*PC+t5_h*(K+1)+t6_h*H_HSD+t7_h*H_HSG+t8_h*H_SC+t9_h*H_CG+t10_h*H_PC+t11_h*(H_EXP+1)+t12_h+t13_h*(N_Y+N_O)+t14_h*(Q+similar_educ)+t16_h;        
																		else
																			% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX, ability_h_index, bp)
																			U_H(1)= -99999;
																			U_H(2)=UC_H(2)+beta*EMAX_H(t+1,1,1,1,1,1,1,(H_EXP+1)+1,HS,1,ability_h_index,1);
																			U_H(3)=UC_H(3)+beta*EMAX_H(t+1,K+1,N_Y+1,N_O+1,0+1,ability_w_index,1+1,(H_EXP+1)+1,HS,Q_INDEX,ability_h_index,bp_dummy);
																			U_H(4)=UC_H(4)+beta*EMAX_H(t+1,K+2,N_Y+1,N_O+1,1+1,ability_w_index,1+1,(H_EXP+1)+1,HS,Q_INDEX,ability_h_index,bp_dummy);
																		end
																		if CHOOSE_WORK == 0
																			U_H(4) = -99999;
																		end
																		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
																		%   MAXIMIZATION - MARRIAGE + WORK DESICION                        %
																		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
																		% need optimization - not efficient programing      
																		% marriage decision - outside option value wife
																		if U_W(1)>U_W(2)
																			outside_option_w_v = U_W(1);
																			%outside_option_w = 1; %"unemployed"
																		else        
																			outside_option_w_v = U_W(2);
																			%outside_option_w = 2; %employed
																		end
																		if U_W(3)> outside_option_w_v && U_W(4)> outside_option_w_v 
																			if U_H(3)>U_H(2) && U_H(4)>U_H(2) %WILL GET MARRIE AND CHOOSE MAX
																			%they are already married, both want to stay married, need to choose 3 or 4 according to bp
																				if bp_dummy ==1
																					bp = 0.25;
																				elseif bp_dummy ==2
																					bp = 0.5;
																				else
																					bp = 0.75;
																				end	
																				if bp*U_H(3)+(1-bp)*U_W(3)>bp*U_H(4)+(1-bp)*U_W(4)  %WILL GET MARRIE AND NOT WORK - CHOOSE 3
																					M = 1 ;
																					tmp_emp = 0;
																				else                  %WILL GET MARRIE AND WORK - CHOOSE 4
																					M = 1 ;
																					tmp_emp = 1;
																				end                                                                      
																			elseif U_H(3)>U_H(2) && U_H(4)<U_H(2) %WILL GET MARRIE AND NOT WORK - CHOOSE 3
																				M = 1 ;
																				tmp_emp = 0;
																			elseif U_H(4)>U_H(2) && U_H(3)<U_H(2) %WILL GET MARRIE AND WORK - CHOOSE 4
																				M = 1 ;
																				tmp_emp = 1;
																			elseif U_H(3)<U_H(2) && U_H(4)<U_H(2) %WILL NOT GET MARRIE 
																				M = 0 ;
																				if U_W(1) == outside_option_w_v      %WILL NOT WORK AND SINGLE, CHOOSE 1
																					tmp_emp = 0;
																				else                                %WILL WORK AND SINGLE, CHOOSE 2
																					tmp_emp = 1;
																				end
																			end
																		elseif  U_W(3)> outside_option_w_v && U_W(4)< outside_option_w_v %WILL NOT WORK IF MARRIED
																			if U_H(3)>U_H(2)  %WILL GET MARIED, WILL NOT WORK, CHOOSE 3
																				M = 1 ;
																				tmp_emp = 0;
																			elseif U_H(3)<U_H(2) %WILL NOT GET MARIED
																				M = 0 ;
																				if U_W(1) == outside_option_w_v  %WILL NOT WORK AND SINGLE, CHOOSE 1
																					tmp_emp = 0;
																				else                           % WILL WORK AS SINGLE, CHOOSE 2
																					tmp_emp = 1;
																				end
																			end 
																		elseif  U_W(4)> outside_option_w_v && U_W(3)< outside_option_w_v %WILL WORK IF MARRIED 
																			if U_H(4)>U_H(2) %WILL GET MARIED, WILL WORK, CHOOSE 4
																				M = 1 ;
																				tmp_emp = 1;
																			elseif U_H(4)<U_H(2)  %WILL NOT GET MARIED
																				M = 0 ;
																				if U_W(1) == outside_option_w_v %WILL NOT WORK AND SINGLE, CHOOSE 1 
																					tmp_emp = 0;
																				else                          % WILL WORK AS SINGLE, CHOOSE 2
																					tmp_emp = 1;
																				end
																			end 
																		elseif  U_W(4)< outside_option_w_v && U_W(3)< outside_option_w_v % WILL NOT MARRIED
																			M = 0 ;
																			if U_W(1) == outside_option_w_v %WILL NOT WORK AND SINGLE, CHOOSE 1
																				tmp_emp = 0;
																			else                            % WILL WORK AS SINGLE, CHOOSE 2
																				tmp_emp = 1;
																			end
																		end
																		if M == 0 && tmp_emp == 0
																			emax_draw_h(draw_b) = U_H(2); %if no marriage, give husband the value of unmarriage - only one option - U_H(2)
																			emax_draw_w(draw_b) = U_W(1);
																		elseif M == 0 && tmp_emp == 1
																			emax_draw_h(draw_b) = U_H(2); %if no marriage, give husband the value of unmarriage - only one option - U_H(2)
																			emax_draw_w(draw_b) = U_W(2);
																		elseif M == 1 && tmp_emp == 0
																			emax_draw_h(draw_b) = U_H(3);
																			emax_draw_w(draw_b) = U_W(3);
																		elseif M == 1 && tmp_emp == 1
																			emax_draw_h(draw_b) = U_H(4);
																			emax_draw_w(draw_b) = U_W(4);   
																		end
																	end % close draw_b loop 
																	% emax is the average of emax_draw over the draws
																	emax_h = mean(emax_draw_h);
																	emax_w = mean(emax_draw_h);
																	% EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+t,HS,Q_INDEX, ability_h_index, bp)
																	EMAX_H(t,K+1,N_Y+1,N_O+1,prev_state+1, ability_w_index,1+1,(H_EXP+1),HS,Q_INDEX,ability_h_index, bp_dummy) = emax_h;
																	EMAX_W(t,K+1,N_Y+1,N_O+1,prev_state+1, ability_w_index,1+1,(H_EXP+1),HS,Q_INDEX,ability_h_index, bp_dummy) = emax_w;
																end  % close bp_dummy loop
															end % close husband bility
														end % close husband experience
													end % close if t<21
												end % close the match quality loop
											end %close the husband schooling loop
										end % close the if T_minus_1 = =
									end %close the  marriage loop
								end % close the exp loop
							end % wife abiity
						end % prev state
					end % close the old children loop
				end % close the young children loop
			end %close the if school_group>1 in line 639!!!!!!!!!!!!!!!!!!!!!!!!!
		end % close the time loop
	end   % if STATIC == 0

    if (DUMP_EMAX == 1)
        disp(strcat(datestr(now), ': saving emax files...'));
        file_name = strcat('octave_emax_h_', num2str(school_group),'.txt');
        save(file_name, 'EMAX_H');
        file_name = strcat('octave_emax_w_', num2str(school_group),'.txt');
        save(file_name, 'EMAX_W')
        disp(strcat(datestr(now), ': emax files saved'));
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%          SOLVING FORWARD      %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize state
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
    % repeat forward DRAW_F times to generalize the result of a specific sample
        for draw_f = 1 : DRAW_F
            WE=0;
            if draw_f < DRAW_F*0.45   % 0.45 proportion of unemployed women
                prev_state = 0;
            else
                prev_state = 1;
            end 
            prev_state_T_minus_1 = 0;
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
            N_Y = 0;
            N_O = 0;
            N_Y_H = 0;
            N_O_H = 0;
            N_TOTAL = 0;
            N_TOTAL_M = 0;
            N_TOTAL_UM = 0;
            D = 0 ;
            D_T_minus_1 = 0;
            Q = 0;
            HS = 1;
            HE = 0;
            BP = 0.5;
			bp_dummy = 2;
			similar_educ = 0;
            %w_ability_draw = rand(DRAW_F);
            ability_w = normal_arr(w_ability_draw(draw_f, school_group))*sigma(3,3);
            ability_w_index = w_ability_draw(draw_f,school_group);
            % Make choices for all periods
            for t = 1 : T
                CHOOSE_HUSBAND = 0;
                prev_state_T_minus_1 = prev_state;
                D_T_minus_1 = D;
                NEW_BORN = 0;
                if M == 0
                    BP = 0.5;
                    D = 0;
                    Q = 0;
					similar_educ = 0;
                    % DRAW A POTENTIAL HUSBAND: EXP, SCHOOLING, MATCH QUALITY, ABILITY
                    if h_draws(draw_f,t,school_group,1)<P_HUSBAND
                        CHOOSE_HUSBAND = 1;
                        [ability_h, ability_h_index, Q, Q_INDEX,HS,H_HSD, H_HSG, H_SC, H_CG, H_PC,HE, similar_educ]=draw_husband(husbands, t, age_index, draw_f, h_draws,school_group );
					else
                        CHOOSE_HUSBAND = 0;
                    end 
                end     
 				if COUNTER == 1 % first counter_factuals - static model
					WE = t-1;
					prev_state_w = 0;
                    prev_state_h = 0;
					HE=HE+t-1% husband experience is already "static" since always work - k=t
				end	
				% POTENTIAL OR CURRENT HUSBAND WAGE:
                if (M == 1 ||  CHOOSE_HUSBAND == 1)
                    [wage_h, JOB_OFFER_H]=calculate_wage(H, H_HSD, H_HSG,H_SC, H_CG, H_PC, HE,HE_D, HSD, HSG, SC, CG, PC, K , h_draws, w_draws, draw_f, t_school_group)
                else
                    JOB_OFFER_H = 0;
                    wage_h = 0;
                end 
                % JOB OFFER PROBABILITY + WAGE WIFE
                [wage_w, JOB_OFFER_W]=calculate_wage(W, H_HSD, H_HSG,H_SC, H_CG, H_PC, HE,HE_D, HSD, HSG, SC, CG, PC, K , h_draws, w_draws, draw_f, t_school_group)
                % calculate husbands and wives utility from each option + -999 for unavailable options
                [U_W,U_H]=calculate_utility(N_Y, N_O,N_Y_H,N_O_H, wage_h, wage_w, CHOOSE_HUSBAND, JOB_OFFER_H, JOB_OFFER_W, M, STATIC, COUNTER, similar_educ) 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   MAXIMIZATION - MARRIAGE + WORK DESICION                        %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (M == 0 &&  CHOOSE_HUSBAND == 1)
                %%%%%%%%%%%%%%  Nash bargaining at first period of marriage  %%%%%%%%%%%%%%%%%%%%%%%%%%
                    % need optimization - not efficient programming      
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
                    looking_for_solution = 1;
                    weighted_utility=U_H(3:6).*BP+U_W(3:6).*(1-BP);  %weighted utility
                    max_weighted_utility=max(weighted_utility);      % max of weighted utility
                    max_weighted_utility_index=find(weighted_utility==max(weighted_utility(:)));  % the index:1-4 of max of weighted utility
                    % leave only positive surplas for both
                    for tmp=1:4
                        if ((U_W(1+2)-outside_option_w_v)>0 && (U_H(1+2)-outside_option_h_v)>0)
                            nash_value(tmp) =(U_W(tmp+2)-outside_option_w_v)*(U_H(tmp+2)-outside_option_h_v) ;  %3-married+wife unemployed+ husband employed
                        else
                            nash_value(tmp)=-9999
                        end
                    end
                    max_nash_value = max(nash_value)
                    max_nash_value_index=find(nash_value==max(nash_value(:)));  % the index:1-4 of max of weighted utility
                    %%%%%   find the value of the bargaining power %%%%%%
                    for tmp=1:4
                        if(max_nash_value_index==tmp && max_nash_value> -999)  %3-married+wife unemployed+ husband employed
                            if ( max_weighted_utility_index== 2+tmp )
                                BP = 0.5;
                            else %need to change the value of alpha - the bargaining power so 3-married+unemployed will be better than 4-married+employed
                                weighted_utility_option(:,1)=U_H(3).*bp_vector+U_W(3).*(1-bp_vector);  %weighted utility
                                weighted_utility_option(:,2)=U_H(4).*bp_vector+U_W(4).*(1-bp_vector);  %weighted utility
                                weighted_utility_option(:,3)=U_H(5).*bp_vector+U_W(5).*(1-bp_vector);  %weighted utility
                                weighted_utility_option(:,4)=U_H(6).*bp_vector+U_W(6).*(1-bp_vector);  %weighted utility
                                posibilities=weighted_utility_option(:,tmp)==max(weighted_utility_option(:,:))  ;     %a 11 elements vector, with 1 for all the alpha-bp where 3 is bigger than 4, all possible alphas
                                ind1 = find(posibilities(1:11), 1, 'first');
                                ind2 = find(posibilities(1:11), 1, 'last');
                                if abs(6-ind1)>abs(6-ind2)
                                    BP=(ind2-1)*0.1;
                                else
                                    BP=(ind1-1)*0.1;    
                                end
                            end 
                        end
                    end      
                end
%%%%%%%%%%%%%%%%%%%%%   at this point the BP IS .5 IF NO MARRIAGE AND NO OFFER, is calculated by nash if offer  and is from previous period if already married                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (M == 1 || CHOOSE_HUSBAND == 1 )
                    % need optimization - not efficient programming      
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
                    looking_for_solution = 1;
                    while (looking_for_solution == 1)
                        weighted_utility=U_H(3:6).*BP+U_W(3:6).*(1-BP);  %weighted utility
                        max_weighted_utility=max(weighted_utility);      % max of weighted utility
                        max_weighted_utility_index=find(weighted_utility==max(weighted_utility(:)));  % the index:1-4 of max of weighted utility
                        if (U_H(max_weighted_utility_index+2)> outside_option_h_v && U_W(max_weighted_utility_index+2)> outside_option_w_v) %the max in married for both is better than outside
                            looking_for_solution = 0;
                            M = 1 ;
                            marriage_choice(draw_f,t,school_group) = 1;
                            if (max_weighted_utility_index+2 == 3)   %3-married+wife unemployed+ husband employed
                                prev_state_w = 0;
                                WE = WE;
                                emp_choice_w(draw_f,t,school_group) = 0;
                                prev_state_h = 1;
                                HE = HE+1;
                                emp_choice_h(draw_f,t,school_group) = 1;
                            elseif (max_weighted_utility_index+2 == 4)   %4-married+wife employed  + husband employed
                                prev_state_w = 1;
                                WE = WE+1;
                                emp_choice_w(draw_f,t,school_group) = 1;
                                prev_state_h = 1;
                                HE = HE+1;
                                emp_choice_h(draw_f,t,school_group) = 1;    
                            elseif (max_weighted_utility_index+2 == 5   %5-married+wife unemployed+ husband unemployed
                                prev_state_w = 0;
                                WE = WE;
                                emp_choice_w(draw_f,t,school_group) = 0;
                                prev_state_h = 0;
                                HE = HE;
                                emp_choice_h(draw_f,t,school_group) = 0;                   
                                elseif (max_weighted_utility_index+2 == 5   %6-married+wife employed  + husband unemployed
                                prev_state_w = 1;
                                WE = WE+1;
                                emp_choice_w(draw_f,t,school_group) = 1;
                                prev_state_h = 0;
                                HE = HE;
                                emp_choice_h(draw_f,t,school_group) = 0;                   
                            else
                                error()
                            end            
                        elseif (U_H(max_weighted_utility_index+2)< outside_option_h_v && U_W(max_weighted_utility_index+2)<outside_option_w_v) %the outside option is better for both - no marriage
                            looking_for_solution = 0;
                            M = 0 ;
                            marriage_choice(draw_f,t,school_group) = 0;
                            if (outside_option_w == 1);   %3-unmarried+wife unemployed
                                prev_state_w = 0;
                                WE = WE;
                                emp_choice_w(draw_f,t,school_group) = 0;
                            else     %3-unmarried+wife employed
                                prev_state_w = 1;
                                WE = WE+1;
                                emp_choice_w(draw_f,t,school_group) = 1;
                            end    
                            if (outside_option_h == 1);   %3-unmarried+husband unemployed
                                prev_state_h = 0;
                                HE = HE;
                                emp_choice_h(draw_f,t,school_group) = 0;
                            else     %3-unmarried+husband employed
                                prev_state_h = 1;
                                HE = HE+1;
                                emp_choice_h(draw_f,t,school_group) = 1;
                            end  
                        elseif (U_H(max_weighted_utility_index+2) > outside_option_h_v && U_W(max_weighted_utility_index+2) < outside_option_w_v) %the outside option is better for women
                        % increase the wife bargaining power
                            BP=BP-0.1;
                            if (BP<0)
                                looking_for_solution = 0;
                                M = 0 ;
                                marriage_choice(draw_f,t,school_group) = 0;
                                if (outside_option_w == 1);   %3-unmarried+wife unemployed
                                    prev_state_w = 0;
                                    WE = WE;
                                    emp_choice_w(draw_f,t,school_group) = 0;
                                else     %3-unmarried+wife employed
                                    prev_state_w = 1;
                                    WE = WE+1;
                                    emp_choice_w(draw_f,t,school_group) = 1;
                                end    
                                if (outside_option_h == 1);   %3-unmarried+husband unemployed
                                    prev_state_h = 0;
                                    HE = HE;
                                    emp_choice_h(draw_f,t,school_group) = 0;
                                else     %3-unmarried+husband employed
                                    prev_state_h = 1;
                                    HE = HE+1;
                                    emp_choice_h(draw_f,t,school_group) = 1;
                                end  
                            end    
                        elseif (U_H(max_weighted_utility_index+2) < outside_option_h_v && U_W(max_weighted_utility_index+2) > outside_option_w_v) %the outside option is better for husband
                        % increase the husband bargaining power
                            BP=BP+0.1;
                            if (BP>1)
                                looking_for_solution = 0;
                                M = 0 ;
                                marriage_choice(draw_f,t,school_group) = 0;
                                if (outside_option_w == 1);   %3-unmarried+wife unemployed
                                    prev_state_w = 0;
                                    WE = WE;
                                    emp_choice_w(draw_f,t,school_group) = 0;
                                else     %3-unmarried+wife employed
                                    prev_state_w = 1;
                                    WE = WE+1;
                                    emp_choice_w(draw_f,t,school_group) = 1;
                                end    
                                if (outside_option_h == 1);   %3-unmarried+husband unemployed
                                    prev_state_h = 0;
                                    HE = HE;
                                    emp_choice_h(draw_f,t,school_group) = 0;
                                else     %3-unmarried+husband employed
                                    prev_state_h = 1;
                                    HE = HE+1;
                                    emp_choice_h(draw_f,t,school_group) = 1;
                                end  
                            end    
                        end
                    endwhile
                elseif ( M==0 && CHOOSE_HUSBAND == 0)
                    M = 0 ;
                    marriage_choice(draw_f,t,school_group) = 0;
                    if (outside_option_w == 1);   %3-unmarried+wife unemployed
                        prev_state_w = 0;
                        WE = WE;
                        emp_choice_w(draw_f,t,school_group) = 0;
                    else     %3-unmarried+wife employed
                        prev_state_w = 1;
                        WE = WE+1;
                        emp_choice_w(draw_f,t,school_group) = 1;
                    end    
                    prev_state_h = 0;
                    HE = 0;
                    emp_choice_h(draw_f,t,school_group) = -999;
                end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%          FERTILITY EXOGENOUS PROCESS - check for another child + update age of children %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
%probability of another child parameters:%c1 previous work state - wife   %c2 age wife - HSG   %c3 age square  wife - HSG  %c4 age wife - SC   %c5 age square  wife - SC   %c6 age wife - CG
          %c7 age square  wife - CG   %c8 age wife - PC   %c9 age square  wife - PC   %c10 number of children at household    %c11 schooling - husband  %c12 unmarried
                c_lamda=c1*prev_state+c2*HSG*(AGE+t)+c3*HSG*(AGE+t)^2+c4*SC*(AGE+t)+c5*SC*(AGE+t)^2+c6*CG*(AGE+t)+c7*CG*(AGE+t)^2+c8*PC*(AGE+t)+c9*PC*(AGE+t)^2+c10*(N_Y+N_O)+c11*HS*M+c12*M;
                child_prob = normcdf(c_lamda);
                if (w_draws(draw_f,t,school_group,2) < child_prob) && ((AGE+t) < 40)  %w_draws = rand(DRAW_F,T,3); 1-job offer, 2-new child, 3 - match quality change- new child was born
                    NEW_BORN = 1;
                    if N_Y < 3
                        N_Y = N_Y + 1;
                    end

                    N_TOTAL = N_TOTAL + 1;
                    if M == 1
                        N_TOTAL_M = N_TOTAL_M +1;
                    else
                        N_TOTAL_UM = N_TOTAL_UM +1;
                    end 
                    if N_Y==1
                        count_age1=1;
                    elseif N_Y==2   
                        count_age2=1;
                    elseif N_Y==3
                        count_age3=1;
                    elseif N_Y==4
                        count_age4=1;
                    elseif N_Y==5
                        count_age5=1;   
                    end 
                elseif N_Y > 0
                    if  count_age1==5 %no new born, just update ages - 5 years old chid
                        count_age1=count_age2;
                        count_age2=count_age3;
                        count_age3=count_age4;
                        count_age4=count_age5;
                        count_age5=0;
                        N_Y=N_Y-1;
                        if N_O<4
                            N_O=N_O+1;
                        end
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
        %  UPDARE T+1 STATE SPACE
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                % EMAX(t,K,N_Y,N_O,prev_state,ability_w_index,M,HE+D,HS,Q_INDEX, ability_h_index)
        % t - by loop
        % K - updated in  MAXIMIZATION - MARRIAGE + WORK DESICION
        % N_Y, N_O, count_age1-4 - updated in   FERTILITY EXOGENOUS PROCESS
        % prev_state -  updated in  MAXIMIZATION - MARRIAGE + WORK DESICION
        % abiity_w, ability_h_index, HE, HS - constants
        % M - updated in  MAXIMIZATION - MARRIAGE + WORK DESICION
        % DURATION + MATCH QUALITY
                if M == 1
					DIVORCE = 0;
                    D = D + 1;
					Q_minus_1 = Q;
                    MATCH_QUALITY_CHANGE_PROBABIITY = h_draws(draw_f,t,school_group,5);
                    if (MATCH_QUALITY_CHANGE_PROBABIITY < MATCH_Q_DECREASE && Q_INDEX > 1)
                        Q_INDEX = Q_INDEX - 1;
                        Q = normal_arr(Q_INDEX)*sigma(5,5);
                    elseif (MATCH_QUALITY_CHANGE_PROBABIITY > MATCH_Q_DECREASE) && (MATCH_QUALITY_CHANGE_PROBABIITY < MATCH_Q_DECREASE + MATCH_Q_INCREASE) && (Q_INDEX < 5)
                        Q_INDEX = Q_INDEX + 1;
                        Q = normal_arr(Q_INDEX)*sigma(5,5);
                    end
                end
				if bp>0.5
					bp_dummy = 3;
				elseif bp < 0.5
					bp_dummy = 1;
				else
					bp_dummy = 2;
				end	       
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %   CREATE AND SAVE MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %individual moments:
                emp(draw_f, t+age_index, school_group)= prev_state;         % employment total - prev_state is actually current state at this point
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   MARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if N_TOTAL == 0 && M ==1 
                    emp_m_no_kids(draw_f, t+age_index , school_group) = prev_state;         % employment married no kids
                    count_emp_m_no_kids(t+age_index,school_group)=count_emp_m_no_kids(t+age_index,school_group)+1;
                elseif N_TOTAL == 1 && M ==1
                    emp_m_one_kid(draw_f, t+age_index, school_group) = prev_state;          % employment married 1 kid
                    count_emp_m_one_kid(t+age_index,school_group) = count_emp_m_one_kid(t+age_index,school_group)+1;
                elseif N_TOTAL == 2 && M ==1
                    emp_m_2_kids(draw_f, t+age_index, school_group) = prev_state;          % employment married 2 kid
                    count_emp_m_2_kids(t+age_index,school_group) = count_emp_m_2_kids(t+age_index,school_group)+1;
				elseif N_TOTAL == 3 && M ==1
                    emp_m_3_kids(draw_f, t+age_index, school_group) = prev_state;          % employment married 3 kid
                    count_emp_m_3_kids(t+age_index,school_group) = count_emp_m_3_kids(t+age_index,school_group)+1;
				elseif N_TOTAL > 3  && M ==1
                    emp_m_4plus_kids(draw_f, t+age_index, school_group) = prev_state;           % employment married 4  kids
                    count_emp_m_4plus_kids(t+age_index,school_group) = count_emp_m_4plus_kids(t+age_index,school_group)+1;
                end
				%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   UNMARRIED WOMEN EMPLOYMENT BY KIDS INDIVIDUAL MOMENTS                       %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if M == 0;
                    emp_um(draw_f, t+age_index, school_group) = prev_state;         % employment unmarried
                    if (N_Y+N_O)==0
                        emp_um_no_kids(draw_f, t+age_index, school_group) = prev_state;     % employment unmarried and no children
                        count_emp_um_no_kids(t+age_index, school_group) = count_emp_um_no_kids(t+age_index, school_group) + 1;
                    else
                        emp_um_kids(draw_f, t+age_index, school_group) = prev_state;            % employment unmarried and children
                        count_emp_um_kids(t+age_index, school_group) = count_emp_um_kids(t+age_index, school_group) + 1;
                    end 
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                 EMPLOYMENT TRANSITION MATRIX                                                 %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if prev_state == 1 && prev_state_T_minus_1 == 0
					if M ==1
						just_found_job_m(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
						count_just_found_job_m(t+age_index, school_group) = count_just_found_job_m(t+age_index, school_group)+1;
						if N_TOTAL >0
							just_found_job_mc(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment
							count_just_found_job_mc(t+age_index, school_group) = count_just_found_job_mc(t+age_index, school_group)+1;							
						end	
					else
						just_found_job_um(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
						count_just_found_job_um(t+age_index, school_group) = count_just_found_job_um(t+age_index, school_group)+1;
					end	
                elseif prev_state == 0 && prev_state_T_minus_1 == 1
					if M ==1
						just_got_fired_m(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
						count_just_got_fired_m(t+age_index, school_group) = count_just_got_fired_m(t+age_index, school_group)+1;
						if N_TOTAL > 0
							just_got_fired_mc(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment 
							count_just_got_fired_mc(t+age_index, school_group) = count_just_got_fired_mc(t+age_index, school_group)+1;

						end
					else
						just_got_fired_um(draw_f, t+age_index, school_group) = 1;              % for transition matrix - unemployment to employment
						count_just_got_fired_um(t+age_index, school_group) = count_just_got_fired_um(t+age_index, school_group)+1;
						
					end	
                elseif prev_state == 0 && prev_state_T_minus_1 == 0
					if M ==1
						count_just_found_job_m(t+age_index, school_group) = count_just_found_job_m(t+age_index, school_group)+1;
						if N_TOTAL >0
							count_just_found_job_mc(t+age_index, school_group) = count_just_found_job_mc(t+age_index, school_group)+1;							
						end	
					else
						count_just_found_job_um(t+age_index, school_group) = count_just_found_job_um(t+age_index, school_group)+1;
					end	
				elseif prev_state == 1 && prev_state_T_minus_1 == 1
					if M ==1
						count_just_got_fired_m(t+age_index, school_group) = count_just_got_fired_m(t+age_index, school_group)+1;
						if N_TOTAL > 0
							count_just_got_fired_mc(t+age_index, school_group) = count_just_got_fired_mc(t+age_index, school_group)+1;
						end
					else
						count_just_got_fired_um(t+age_index, school_group) = count_just_got_fired_um(t+age_index, school_group)+1;
					end	
				end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %                   MARRIED WOMEN EMPLOYMENT + WAGES MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
				if prev_state == 1
					if wage_w > 0
							
						wages_w(K, school_group)=wages_w(K, school_group) +wage_w;        % women wages if employed by experience
						count_wages_w(K, school_group)=count_wages_w(K, school_group) +1;  
					end	
                end 
                if M == 1 
                    if wage_h > 0
						wages_m_h(HE+D, HS)=wages_m_h(HE+D, HS) + wage_h;         % married men wages
						count_wages_m_h(HE+D, HS) = count_wages_m_h(HE+D, HS)+1;
					end	
                    emp_m(draw_f, t+age_index, school_group) = prev_state;      % employment married women  
                    if school_group > HS                %women married down, men married up - HS is 1 to 5 while school_group 1 to 4 so to copare: -1
                        emp_m_down(draw_f, t+age_index, school_group) = prev_state;         % employment married down
                        count_emp_m_down(t+age_index, school_group) = count_emp_m_down(t+age_index, school_group)+1;
						if (HE+D <37 )  && wage_h > wage_moments(HE+D,5+HS)     %wage_moments(1:36,6:10)
							emp_m_down_above(draw_f, t+age_index, school_group) = prev_state;         % employment married down
							count_emp_m_down_above(t+age_index, school_group) = count_emp_m_down_above(t+age_index, school_group)+1;
						else	
							emp_m_down_below(draw_f, t+age_index, school_group) = prev_state;         % employment married down
							count_emp_m_down_below(t+age_index, school_group) = count_emp_m_down_below(t+age_index, school_group)+1;
						end
                        wages_m_h_up(draw_f, HE+D, HS)=wage_h;   % married up men wages 
                        count_wages_m_h_up(HE+D, HS)=count_wages_m_h_up(HE+D, HS)+1;
						if M==1 && M_T_minus_1==0
							ability_h_up(t+age_index, HS) = ability_h_up(t+age_index, HS) + ability_h;
							count_ability_h_up(t+age_index, HS) = count_ability_h_up(t+age_index, HS) +1;
							ability_w_down(t+age_index, school_group) = ability_w_down(t+age_index, school_group) +ability_w;
							count_ability_w_down(t+age_index, school_group)=count_ability_w_down(t+age_index, school_group)+1;
							match_w_down(t+age_index, school_group) = match_w_down(t+age_index, school_group) + Q_minus_1;
							count_match_w_down(t+age_index, school_group)=count_match_w_down(t+age_index, school_group)+1;
						end
                    elseif school_group < HS            %women married up, men married down
                        emp_m_up(draw_f, t+age_index, school_group) = prev_state;   % employment married up women
						count_emp_m_up(t+age_index, school_group) = count_emp_m_up(t+age_index, school_group)+1;
                        if (HE+D <37 ) && wage_h > wage_moments(HE+D,5+HS)     %wage_moments(1:36,6:10)
							emp_m_up_above(draw_f, t+age_index, school_group) = prev_state;         % employment married down
							count_emp_m_up_above(t+age_index, school_group) = count_emp_m_up_above(t+age_index, school_group)+1;
						else	
							emp_m_up_below(draw_f, t+age_index, school_group) = prev_state;         % employment married down
							count_emp_m_up_below(t+age_index, school_group) = count_emp_m_up_below(t+age_index, school_group)+1;
						end
                        wages_m_h_down(draw_f, HE+D, HS)=wage_h; % married down men wages
                        count_wages_m_h_down(HE+D, HS)=count_wages_m_h_down(HE+D, HS)+1;
						if M==1 && M_T_minus_1==0
							ability_h_down(t+age_index, HS) = ability_h_down(t+age_index, HS) + ability_h;
							count_ability_h_down(t+age_index, HS) = count_ability_h_down(t+age_index, HS) +1;
							ability_w_up(t+age_index, school_group) = ability_w_up(t+age_index, school_group) +ability_w;
							count_ability_w_up(t+age_index, school_group)=count_ability_w_up(t+age_index, school_group)+1;
							match_w_up(t+age_index, school_group) = match_w_up(t+age_index, school_group) + Q_minus_1;
							count_match_w_up(t+age_index, school_group)=count_match_w_up(t+age_index, school_group)+1;
						end
                    elseif  school_group == HS         %married equal
                        wages_m_h_eq(draw_f, HE+D, HS)=wage_h;   % married equal men wages 
                        count_wages_m_h_eq(HE+D, HS)=count_wages_m_h_eq(HE+D, HS)+1;
                        emp_m_eq(draw_f, t+age_index, school_group) = prev_state;   % employment married equal women
						count_emp_m_eq(t+age_index, school_group) = count_emp_m_eq(t+age_index, school_group)+1;
						
						if (HE+D <37 )  && wage_h > wage_moments(HE+D,5+HS)      %wage_moments(1:36,6:10)
							emp_m_eq_above(draw_f, t+age_index, school_group) = prev_state;         % employment married down
							count_emp_m_eq_above(t+age_index, school_group) = count_emp_m_eq_above(t+age_index, school_group)+1;
						else	
							emp_m_eq_below(draw_f, t+age_index, school_group) = prev_state;         % employment married down
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
                if M==1 && prev_state == 1                              %prev_state is actually current state at this point
                    wages_m_w(draw_f, K, school_group)=wage_w;          % married women wages if employed
                    if school_group < HS
                        wages_m_w_up(draw_f, K, school_group)=wage_w;   % married up women wages if employed
                        count_wages_m_w_up(K, school_group)=count_wages_m_w_up(K, school_group)+1;
                    elseif school_group > HS
                        wages_m_w_down(draw_f, K, school_group)=wage_w; % married down women wages if employed
                        count_wages_m_w_down(K, school_group)=count_wages_m_w_down(K, school_group)+1;
                    elseif school_group == HS
                        wages_m_w_eq(draw_f, K, school_group)=wage_w; % married equal women wages if employed
                        count_wages_m_w_eq(K, school_group)=count_wages_m_w_eq(K, school_group)+1;
                    end
                elseif M==0 && prev_state == 1
                    wages_um_w(draw_f, K, school_group)=wage_w;         % unmarried women wages if employed
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %           FERTILITY AND MARRIED RATE MOMENTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                married(draw_f, t+age_index, school_group) = M  ;                   % married yes/no
                newborn(draw_f, t+age_index, school_group)=NEW_BORN;                % new born in period t - for probability and distribution
				if M ==1
	                newborn_m(draw_f, t+age_index, school_group)=NEW_BORN;                % new born in period t - for probability and distribution
					count_newborn_m(t+age_index, school_group) = count_newborn_m(t+age_index, school_group)+1;
				else
					newborn_um(draw_f, t+age_index, school_group)=NEW_BORN;                % new born in period t - for probability and distribution
					count_newborn_um(t+age_index, school_group) = count_newborn_um(t+age_index, school_group)+1;
				end
                %duration_of_first_marriage(draw_f, school_group) = D_T_minus_1 ;
                if t == T 
                    kids(draw_f, school_group) = N_TOTAL ;          % # of children by school group
                    kids_m(draw_f, school_group) = N_TOTAL_M;
                    kids_um(draw_f, school_group) = N_TOTAL_UM;
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
                        duration_of_first_marriage(draw_f, school_group) = D_T_minus_1 ;                % duration of marriage if divorce 
                        count_duration_of_first_marriage(school_group) = count_duration_of_first_marriage(school_group)+1;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            CLOSE SOLVING FORWARD           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
f_emp = [mean(emp(:,:,2)); mean(emp(:,:,3)); mean(emp(:,:,4)); mean(emp(:,:,5))]' ;                                 % employment total by education
tmp_married = [sum(married(:,:,2)); sum(married(:,:,3)); sum(married(:,:,4)); sum(married(:,:,5))]';                % married yes/no
f_emp_m = [sum(emp_m(:,:,2)); sum(emp_m(:,:,3)); sum(emp_m(:,:,4)); sum(emp_m(:,:,5))]';                            % employment married by education
f_emp_m  = f_emp_m ./tmp_married;
f_emp_um = [sum(emp_um(:,:,2)); sum(emp_um(:,:,3)); sum(emp_um(:,:,4)); sum(emp_um(:,:,5))]';                       % employment unmarried by education
f_emp_um  = f_emp_um ./[DRAW_F - tmp_married];
emp_moments_fitted_matrix = [f_emp  f_emp_m  f_emp_um];
emp_sd = nansum((emp_moments(1:28,2:13) - emp_moments_fitted_matrix).^2);
format short g;
disp('	WOMEN EMPLOYMENT ACTUAL 		   	     WOMEN EMPLOYMENT FITTED  ');
temp = [emp_moments(1:28,2:5)  emp_moments_fitted_matrix(:,1:4)]
disp('	MARRIED WOMEN EMPLOYMENT ACTUAL  	 	 MARRIED WOMEN EMPLOYMENT FITTED  ');
temp = [emp_moments(1:28,6:9)  emp_moments_fitted_matrix(:,5:8)]
disp('	UNMARRIED WOMEN EMPLOYMENT ACTUAL  	     UNMARRIED WOMEN EMPLOYMENT FITTED  ');
temp = [emp_moments(1:28,10:13)  emp_moments_fitted_matrix(:,9:12)]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%marr_fer_moments - 9 by 28 matrix
%first column - age
%column 2-5 - marriage rate by education group. start at t+age index
%column 6-9 - frtility rate by education group - start at t+age index end at 42
f_married = [mean(married(:,:,2)); mean(married(:,:,3)); mean(married(:,:,4)); mean(married(:,:,5))]'  ; 
f_fertility = [mean(newborn(:,:,2)); mean(newborn(:,:,3)); mean(newborn(:,:,4)); mean(newborn(:,:,5))]';    
f_divorce = [mean(divorce(:,:,2)); mean(divorce(:,:,3)); mean(divorce(:,:,4)); mean(divorce(:,:,5))]' ;     
marr_fer_moments_fitted_matrix = [ f_married  f_fertility  f_divorce];
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
f_kids_m = [sum((kids_m(:,2))./sum(married(:, T,2))) ;     sum((kids_m(:,3))./sum(married(:, T,3))); sum((kids_m(:,4))./sum(married(:, T,4))); sum((kids_m(:,5))./sum(married(:, T,5)))]'        % # of children by school group
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

