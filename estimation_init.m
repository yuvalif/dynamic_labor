function [husbands_2,husbands_3, husbands_4, husbands_5 , wives, wage_moments, marr_fer_moments, emp_moments, general_moments, epsilon_b, epsilon_f, h_draws_b, w_draws_b, w_ability_draw, h_draws, w_draws] = estimation_init(T_MAX, DRAW_B, DRAW_F, SCHOOL_GROUPS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%														    %
%   estimation_init.m
%   creates normal and uniform draws
%															%	
%	T - number of periods								    %
%	DRAW_B - number of random draws for EMAX		        %
%	DRAW_F - number of random draws for forward             %
%	Author: Osnat Lifshitz								    %
%	Date: 05-sept-12										%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%disp(strcat(strftime('%X',localtime(time)), ': loading files...'));

disp('loading file: husbands_2.out');
husbands_2 = load('husbands_2.out');
disp('loading file: husbands.out');
husbands_3 = load('husbands.out');  %can marry all
disp('loading file: husbands_4.out');
husbands_4 = load('husbands_4.out');
disp('loading file: husbands_5.out');
husbands_5 = load('husbands_5.out');
disp('loading file: wives.out');
wives = load('wives.out');

disp('loading moments files: wage_moments.txt, marr_fer_moments.txt, general_moments.txt');
wage_moments = load('wage_moments.txt'); %
marr_fer_moments = load('marr_fer_moments.txt'); %
emp_moments = load('emp_moments.txt'); %
general_moments = load('general_moments.txt'); %

%disp(strcat(strftime('%X',localtime(time)), ': initializing random shocks...'));

% start with the same random shoks
%rand("state", 1234); 

% random shocks' mean and variance
myu = [0];
sig = 1;

% random draw from normal distribution, for EMAX calculation
for i=1:DRAW_B
	for j=1: T_MAX
		for k =1:SCHOOL_GROUPS
			for s=1:2
				epsilon_b(i,j,k,s)  = mvnrnd(myu, sig);
			end	
		end
	end
end
	
% random draw from normal distribution, for shocks realizations in forward solution
%epsilon_f = mvnrnd(myu, sig, [DRAW_F, T_MAX, SCHOOL_GROUPS+1,2]);
for i=1:DRAW_F
	for j=1: T_MAX
		for k =1:SCHOOL_GROUPS
			for s=1:2
				epsilon_f(i,j,k,s)  = mvnrnd(myu, sig);
			end	
		end
	end
end
% random draw from uniform distribution, for backward solution
h_draws_b = rand(DRAW_B, T_MAX, SCHOOL_GROUPS, 4); %1- HUSBAND; 2-HUSBAND EXP+SCHOOLING; 3-HUSBAND ABILITY; 4 - INITIAL MATCH QUALITY; 
h_draws_b(:,:,:,3)= randi(5, DRAW_B, T_MAX, SCHOOL_GROUPS);
h_draws_b(:,:,:,4)= randi(5, DRAW_B, T_MAX, SCHOOL_GROUPS);
w_draws_b = rand(DRAW_B, T_MAX, SCHOOL_GROUPS, 6);%1- wife; 2-wife EXP+SCHOOLING+PREV_STATE; 3-wife ABILITY; 4 - INITIAL MATCH QUALITY; 5 - JOB OFFER FOR MARRIED MEN AND WOMEN EMAX; 6-JOB OFFER FOR SINGLE MEN EMAX
w_draws_b(:,:,:,3)= randi(5, DRAW_B, T_MAX, SCHOOL_GROUPS);
w_draws_b(:,:,:,4)= randi(5, DRAW_B, T_MAX, SCHOOL_GROUPS);
% random draw from uniform distribution, for forward solution
w_ability_draw = randi(5, DRAW_F,SCHOOL_GROUPS, 1);   %wife ability draw, constant by period
h_draws = rand(DRAW_F, T_MAX, SCHOOL_GROUPS, 6);			 %1- HUSBAND; 2-HUSBAND EXP+SCHOOLING; 3-HUSBAND ABILITY; 4 - INITIAL MATCH QUALITY; 5 - MATCH UALITY CHANGE PROBABILITY; 6 - job offer
h_draws(:,:,:,3)= randi(5, DRAW_F, T_MAX, SCHOOL_GROUPS);
h_draws(:,:,:,4)= randi(5, DRAW_F, T_MAX, SCHOOL_GROUPS);
w_draws = rand(DRAW_F, T_MAX, SCHOOL_GROUPS, 2);			%1 - JOB OFFER, 2 - NEW BORN

%%%%%%%
% DEBUG
%%%%%%%
%w_draws_b(:,:,:,3)  
%w_draws_b(:,:,:,4)  
%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% just for testing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%epsilon_b = zeros(DRAW_B, T_MAX, SCHOOL_GROUPS+1, 2);
%epsilon_f = zeros(DRAW_F, T_MAX, SCHOOL_GROUPS+1, 2);
