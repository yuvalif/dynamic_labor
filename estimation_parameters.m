classdef estimation_parameters
    properties
        WE1;
        WE2;
        WE3;
        WE4;
        WE5;
        HE1;
        HE2;
        HE3;
        HE4;
        HE5;
        beta0;          % discount rate
        normal_arr;     % low, medium, high
        bp_vector; 
        cs_vector; 
        exp_vector;
        epsilon_b;
        w_draws;
        h_draws_b;
        w_draws_b;
        tax;
        ded;
        exp_w;          % (0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
        exp_h;          % (0,1.5 , 3.5 , 7.5, 15) - 5 points grid for experience, use interpulations for the values between
        kids;           % children(0, 1,2, 3+)
        prev_w;         % previous work status(employed/unemployed)
        ability_w;      % ability wife(high,medium,low)
        ability_h;      % ability husband(high,medium,low)
        marr;           % marital status
        school_h;       % only husbands schooling since we solve for a representative women given her education
        school_w;       % only husbands schooling since we solve for a representative women given her education
        match;          % match quality(high,medium,low)
        BP_W;           % wife bargening power(0.2, 0.3, 0.4, 0.5, 0.6, 0.7,0.8)
        sigma           % random shocks variance-covariance matrix
        % utility parameters
        alpha;          % CRRA income parameter 
        alpha1_w_m;     % women utility from children when married
        alpha1_w_s;     % women utility from children when single
        alpha1_h_m;     % men utility from children when maarried
        alpha2_w;       % utility from leisure as a function of number of children
        alpha3_w;       % utility from leisure
        % wage parameters wife
        beta11_w;       % experience 
        beta12_w;       % experience 
        beta13_w;       % experience 
        beta14_w;       % experience 
        beta21_w;       % exp^2  
        beta22_w;       % exp^2  
        beta23_w;       % exp^2  
        beta24_w;       % exp^2  
        beta31_w;       % HSG - schooling    
        beta32_w;       % SC -  schooling    
        beta33_w;       % CG -  schooling    
        beta34_w;       % PC -  schooling
        % wage parameters husband
        beta10_h;       % experience 
        beta11_h;       % experience 
        beta12_h;       % experience 
        beta13_h;       % experience 
        beta14_h;       % experience 
        beta20_h;       % exp^2
        beta21_h;       % exp^2
        beta22_h;       % exp^2
        beta23_h;       % exp^2
        beta24_h;       % exp^2
        beta30_h;       % HSD - schooling    
        beta31_h;       % HSG- schooling 
        beta32_h;       % SC -  schooling    
        beta33_h;       % CG -  schooling    
        beta34_h;       % PC -  schooling    
        % job offer parameters - wife 
        row0_w;         % work in previous period
        row11_w;        % HSG -schooling
        row12_w;        % SC - schooling
        row13_w;        % CG - schooling
        row14_w;        % PC - schooling
        row2_w;         % work experience
        % home production technology - parameters    
        hp;             % sigma CRRA parameter
        % probability of another child parameters    
        c1;             % previous work state - wife
        c2;             % age wife - HSG
        c3;             % age square wife - HSG
        c4;             % age wife - SC
        c5;             % age square wife - SC
        c6;             % age wife - CG
        c7;             % age square wife - CG
        c8;             % age wife - PC
        c9;             % age square wife - PC
        c10;            % number of children at household    
        c11;            % schooling - husband
        c12;            % married - M
        % terminal value parameters
        t1_w;           % schooling wife - HSG
        t2_w;           % schooling wife - SC
        t3_w;           % schooling wife - CG
        t4_w;           % schooling wife - PC
        t5_w;           % exp wife
        t6_w;           % schooling husband if married - HSD
        t7_w;           % schooling husband if married - HSG
        t8_w;           % schooling husband if married - SC
        t9_w;           % schooling husband if married - CG
        t10_w;          % schooling husband if married - PC
        t11_w;          % exp husband if married 
        t12_w;          % martial status
        t13_w;          % number of children
        t14_w;          % match quality if married
        t15_w;          % number of children if married
        t16_w;          % previous work state - wife
        t17_w;          % previous work state - husband if married
        % terminal value Parameters
        t1_h;           % schooling wife if married- HSG
        t2_h;           % schooling wife if married- SC
        t3_h;           % schooling wife if married- CG
        t4_h;           % schooling wife if married- PC
        t5_h;           % exp wife if married
        t6_h;           % schooling husband - HSD
        t7_h;           % schooling husband - HSG
        t8_h;           % schooling husband - SC
        t9_h;           % schooling husband - CG
        t10_h;          % schooling husband - PC
        t11_h;          % exp husband  
        t12_h;          % martial status if married
        t13_h;          % number of children if married
        t14_h;          % match quality if married
        t15_h;          % number of children if married - NO NEED
        t16_h;          % previous work state - wife if married
        t17_h;          % previous work state - husband 
        % match quality parameters
        p0_w;           % probability of meeting a potential husband - wife constant
        p1_w;           % probability of meeting a potential husband - wife age
        p2_w;           % probability of meeting a potential husband - wife age square
        p0_h;           % probability of meeting a potential husband - husband constant
        p1_h;           % probability of meeting a potential husband - husband age
        p2_h;           % probability of meeting a potential husband - husband age square
        MATCH_Q_DECREASE;   % probability of match quality decrease
        MATCH_Q_INCREASE;   % probability of match quality increase
        EDUC_MATCH_2;   % education match parameter
        EDUC_MATCH_3;   % education match parameter
        EDUC_MATCH_4;   % education match parameter
        EDUC_MATCH_5;   % education match parameter
    end
    methods
        function obj = estimation_parameters(global_param, epsilon_b, w_draws, h_draws_b, w_draws_b, tax_brackets, deductions_exemption)
            obj.WE1 = 0;
            obj.WE2 = 2;
            obj.WE3 = 4;
            obj.WE4 = 8;
            obj.WE5 = 16;
            obj.HE1 = 0;
            obj.HE2 = 2;
            obj.HE3 = 4;
            obj.HE4 = 8;
            obj.HE5 = 16;
            obj.beta0 = 0.983;
            obj.normal_arr = [ -1.150, 0 , 1.150];
            obj.bp_vector = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
            obj.cs_vector = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
            obj.exp_vector(1,1:5) = [obj.WE1, obj.WE2, obj.WE3, obj.WE4, obj.WE5];
            obj.epsilon_b = epsilon_b;
            obj.w_draws = w_draws;
            obj.h_draws_b = h_draws_b;
            obj.w_draws_b = w_draws_b;
            obj.tax = tax_brackets;
            obj.ded = deductions_exemption;
            obj.exp_w = 5;
            obj.exp_h = 5;
            obj.kids = 4;
            obj.prev_w = 2;
            obj.ability_w = 3;
            obj.ability_h = 3;
            obj.marr = 2;
            obj.school_h = 5;
            obj.school_w = 4;
            obj.match = 3;
            obj.BP_W = 7;
            obj.sigma = zeros(5,5);
            obj.alpha = global_param(1);
            obj.alpha1_w_m = global_param(2);
            obj.alpha1_w_s = global_param(3);
            obj.alpha1_h_m = global_param(4);
            obj.alpha2_w = global_param(5);
            obj.alpha3_w = global_param(6);
            obj.beta11_w = global_param(7);
            obj.beta12_w = global_param(8);
            obj.beta13_w = global_param(9);
            obj.beta14_w = global_param(10);
            obj.beta21_w = global_param(11);
            obj.beta22_w = global_param(12);
            obj.beta23_w = global_param(13);
            obj.beta24_w = global_param(14);
            obj.beta31_w = global_param(15);
            obj.beta32_w = global_param(16);
            obj.beta33_w = global_param(17);
            obj.beta34_w = global_param(18);
            obj.beta10_h = global_param(19);
            obj.beta11_h = global_param(20);
            obj.beta12_h = global_param(21);
            obj.beta13_h = global_param(22);
            obj.beta14_h = global_param(23);
            obj.beta20_h = global_param(24);
            obj.beta21_h = global_param(25);
            obj.beta22_h = global_param(26);
            obj.beta23_h = global_param(27);
            obj.beta24_h = global_param(28);
            obj.beta30_h = global_param(29);
            obj.beta31_h = global_param(30);
            obj.beta32_h = global_param(31);
            obj.beta33_h = global_param(32);
            obj.beta34_h = global_param(33);
            obj.row0_w = global_param(34);
            obj.row11_w = global_param(35);
            obj.row12_w = global_param(36);
            obj.row13_w = global_param(37);
            obj.row14_w = global_param(38);
            obj.row2_w = global_param(39);
            obj.hp = global_param(40);
            obj.c1 = global_param(41);
            obj.c2 = global_param(42);
            obj.c3 = global_param(43);
            obj.c4 = global_param(44);
            obj.c5= global_param(45); 
            obj.c6 = global_param(46);
            obj.c7 = global_param(47);
            obj.c8 = global_param(48);
            obj.c9 = global_param(49);
            obj.c10 = global_param(50);
            obj.c11 = global_param(51);
            obj.c12 = global_param(52);
            obj.t1_w = global_param(53);
            obj.t2_w = global_param(54);
            obj.t3_w = global_param(55);
            obj.t4_w = global_param(56);
            obj.t5_w = global_param(57);
            obj.t6_w = global_param(58);
            obj.t7_w = global_param(59);
            obj.t8_w = global_param(60);
            obj.t9_w = global_param(61);
            obj.t10_w = global_param(62);
            obj.t11_w = global_param(63);
            obj.t12_w = global_param(64);
            obj.t13_w = global_param(65);
            obj.t14_w = global_param(66);
            obj.t15_w = global_param(67);
            obj.t16_w = global_param(68);
            obj.t17_w = global_param(69);
            obj.t1_h = global_param(70);
            obj.t2_h = global_param(71);
            obj.t3_h = global_param(72);
            obj.t4_h = global_param(73);
            obj.t5_h = global_param(74);
            obj.t6_h = global_param(75);
            obj.t7_h = global_param(76);
            obj.t8_h = global_param(77);
            obj.t9_h = global_param(78);
            obj.t10_h = global_param(79);
            obj.t11_h = global_param(80);
            obj.t12_h = global_param(81);
            obj.t13_h = global_param(82);
            obj.t14_h = global_param(83);
            obj.t15_h = global_param(84);
            obj.t16_h = global_param(85);
            obj.t17_h = global_param(86);
            obj.p0_w = global_param(87);
            obj.p1_w = global_param(88);
            obj.p2_w = global_param(89);
            obj.p0_h = global_param(90);
            obj.p1_h = global_param(91);
            obj.p2_h = global_param(92);
            obj.MATCH_Q_DECREASE = (exp(global_param(93)))/(1+exp(global_param(93)));
            obj.MATCH_Q_INCREASE = (exp(global_param(94)))/(1+exp(global_param(94)));
            obj.EDUC_MATCH_2 = global_param(95);
            obj.EDUC_MATCH_3 = global_param(96);
            obj.EDUC_MATCH_4 = global_param(97);
            obj.EDUC_MATCH_5 = global_param(98);
            obj.sigma = zeros(5,5);
            obj.sigma(1,1) = exp(global_param(99));
            obj.sigma(2,2) = exp(global_param(100));
            obj.sigma(3,3) = exp(global_param(101));
            obj.sigma(4,4) = exp(global_param(102));
            obj.sigma(5,5) = exp(global_param(103));
        end
    end
end

