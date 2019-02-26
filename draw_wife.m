function [ability_w, ability_wi, Q, Q_INDEX,WS,HSD, HSG, SC, CG, PC,WE, similar_educ, prev_state_w]=draw_wife(wives, t, age_index, draw, h_draws_b,school_group )
global normal_arr; global sigma; global EDUC_MATCH_2; global EDUC_MATCH_3; global EDUC_MATCH_4; global EDUC_MATCH_5;
global WE1;global WE2;global WE3;global WE4;global WE5;  
%h_draws_b = rand(DRAW_F,T,5); %1- HUSBAND; 2-HUSBAND EXP+SCHOOLING; 3-HUSBAND ABILITY; 4 - INITIAL MATCH QUALITY; 5 - MATCH UALITY CHANGE PROBABILITY
			P_HSG_1_UN=wives(t+age_index,2);
			P_HSG_2_UN=wives(t+age_index,3);
			P_HSG_3_UN=wives(t+age_index,4);
			P_HSG_4_UN=wives(t+age_index,5);
			P_HSG_5_UN=wives(t+age_index,6);
            P_HSG_1_EMP=wives(t+age_index,7);
			P_HSG_2_EMP=wives(t+age_index,8);
			P_HSG_3_EMP=wives(t+age_index,9);
			P_HSG_4_EMP=wives(t+age_index,10);	
			P_HSG_5_EMP=wives(t+age_index,11);	
			P_SC_1_UN=wives(t+age_index,12);
			P_SC_2_UN=wives(t+age_index,13);
			P_SC_3_UN=wives(t+age_index,14);
			P_SC_4_UN=wives(t+age_index,15);
			P_SC_5_UN=wives(t+age_index,16);
            P_SC_1_EMP=wives(t+age_index,17);
			P_SC_2_EMP=wives(t+age_index,18);
			P_SC_3_EMP=wives(t+age_index,19);
			P_SC_4_EMP=wives(t+age_index,20);	
			P_SC_5_EMP=wives(t+age_index,21);	
            
 			P_CG_1_UN=wives(t+age_index,22);
			P_CG_2_UN=wives(t+age_index,23);
			P_CG_3_UN=wives(t+age_index,24);
			P_CG_4_UN=wives(t+age_index,25);
			P_CG_5_UN=wives(t+age_index,26);
            P_CG_1_EMP=wives(t+age_index,27);
			P_CG_2_EMP=wives(t+age_index,28);
			P_CG_3_EMP=wives(t+age_index,29);
			P_CG_4_EMP=wives(t+age_index,30);	
			P_CG_5_EMP=wives(t+age_index,31);	
 			P_PC_1_UN=wives(t+age_index,32);
			P_PC_2_UN=wives(t+age_index,33);
			P_PC_3_UN=wives(t+age_index,34);
			P_PC_4_UN=wives(t+age_index,35);
			P_PC_5_UN=wives(t+age_index,36);
            P_PC_1_EMP=wives(t+age_index,37);
			P_PC_2_EMP=wives(t+age_index,38);
			P_PC_3_EMP=wives(t+age_index,39);
			P_PC_4_EMP=wives(t+age_index,40);	
			P_PC_5_EMP=wives(t+age_index,41);	
              
ability_w = normal_arr(h_draws_b(draw,t,school_group,3))*sigma(4,4);
ability_wi = h_draws_b(draw,t,school_group,3);
Q = normal_arr(h_draws_b(draw,t,school_group,4))*sigma(5,5);
Q_INDEX = h_draws_b(draw,t,school_group,4);
HSD = 0; HSG = 1; SC = 0; CG = 0; PC = 0;  WS = 2;WE = WE1;prev_state_w = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if h_draws_b(draw,t,school_group,2)<P_HSG_1_UN %WIFE schooling HSG, wife was unemployed in previous period, no experience
    WS = 2;
    HSG = 1;
    WE = WE1;
    prev_state_w = 0;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_1_UN && h_draws_b(draw,t,school_group,2)<P_HSG_2_UN)
    WS = 2;
    HSG = 1;
    WE = WE2;
    prev_state_w = 0;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_2_UN && h_draws_b(draw,t,school_group,2)<P_HSG_3_UN)
    WS = 2;
    HSG = 1;
    WE = WE3;
    prev_state_w = 0;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_3_UN && h_draws_b(draw,t,school_group,2)<P_HSG_4_UN)
    WS = 2;
    HSG = 1;
    WE = WE4; 
    prev_state_w = 0;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_4_UN && h_draws_b(draw,t,school_group,2)<P_HSG_5_UN)
    WS = 2;
    HSG = 1;
    WE = WE5;     
    prev_state_w = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_5_UN && h_draws_b(draw,t,school_group,2)<P_HSG_1_EMP) %WIFE schooling HSG, wife was unemployed in previous period, no experience
    WS = 2;
    HSG = 1;
    WE = WE1;
    prev_state_w = 1;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_1_EMP && h_draws_b(draw,t,school_group,2)<P_HSG_2_EMP)
    WS = 2;
    HSG = 1;
    WE = WE2;
    prev_state_w = 1;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_2_EMP && h_draws_b(draw,t,school_group,2)<P_HSG_3_EMP)
    WS = 2;
    HSG = 1;
    WE = WE3;
    prev_state_w = 1;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_3_EMP && h_draws_b(draw,t,school_group,2)<P_HSG_4_EMP)
    WS = 2;
    HSG = 1;
    WE = WE4; 
    prev_state_w = 1;
elseif (h_draws_b(draw,t,school_group,2)>P_HSG_4_EMP && h_draws_b(draw,t,school_group,2)<P_HSG_5_EMP)
    WS = 2;
    HSG = 1;
    WE = WE5;     
    prev_state_w = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif h_draws_b(draw,t,school_group,2)>P_HSG_5_EMP && h_draws_b(draw,t,school_group,2)<P_SC_1_UN  %husband schooling SC
    WS = 3;
    SC=1;
    WE = WE1; 
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_SC_1_UN && h_draws_b(draw,t,school_group,2)<P_SC_2_UN
   WS = 3;
    SC=1;
    WE = WE2;  
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_SC_2_UN && h_draws_b(draw,t,school_group,2)<P_SC_3_UN
    WS = 3;
    SC=1;
    WE = WE3;   
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_SC_3_UN && h_draws_b(draw,t,school_group,2)<P_SC_4_UN
   WS = 3;
    SC=1;
    WE = WE4;  
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_SC_4_UN && h_draws_b(draw,t,school_group,2)<P_SC_5_UN
   WS = 3;
    SC=1;
    WE = WE5;      
    prev_state_w = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif h_draws_b(draw,t,school_group,2)>P_SC_5_UN && h_draws_b(draw,t,school_group,2)<P_SC_1_EMP  %husband schooling SC
    WS = 3;
    SC=1;
    WE = WE1; 
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_SC_1_EMP && h_draws_b(draw,t,school_group,2)<P_SC_2_EMP
   WS = 3;
    SC=1;
    WE = WE2;  
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_SC_2_EMP && h_draws_b(draw,t,school_group,2)<P_SC_3_EMP
    WS = 3;
    SC=1;
    WE = WE3;   
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_SC_3_EMP && h_draws_b(draw,t,school_group,2)<P_SC_4_EMP
   WS = 3;
    SC=1;
    WE = WE4;  
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_SC_4_EMP && h_draws_b(draw,t,school_group,2)<P_SC_5_EMP
   WS = 3;
    SC=1;
    WE = WE5;      
    prev_state_w = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif h_draws_b(draw,t,school_group,2)>P_SC_5_EMP && h_draws_b(draw,t,school_group,2)<P_CG_1_UN  %husband schooling CG
    WS = 4;
    CG=1;
    WE = WE1; 
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_CG_1_UN && h_draws_b(draw,t,school_group,2)<P_CG_2_UN
    WS = 4;
    CG=1;
    WE = WE2; 
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_CG_2_UN && h_draws_b(draw,t,school_group,2)<P_CG_3_UN
    WS = 4;
    CG=1;
    WE = WE3; 
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_CG_3_UN && h_draws_b(draw,t,school_group,2)<P_CG_4_UN
     WS = 4;
    CG=1;
    WE = WE4;                     
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_CG_4_UN && h_draws_b(draw,t,school_group,2)<P_CG_5_UN
     WS = 4;
    CG=1;
    WE = WE5; 
    prev_state_w = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif h_draws_b(draw,t,school_group,2)>P_CG_5_UN && h_draws_b(draw,t,school_group,2)<P_CG_1_EMP  %husband schooling CG
    WS = 4;
    CG=1;
    WE = WE1; 
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_CG_1_EMP && h_draws_b(draw,t,school_group,2)<P_CG_2_EMP
    WS = 4;
    CG=1;
    WE = WE2; 
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_CG_2_EMP && h_draws_b(draw,t,school_group,2)<P_CG_3_EMP
    WS = 4;
    CG=1;
    WE = WE3; 
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_CG_3_EMP && h_draws_b(draw,t,school_group,2)<P_CG_4_EMP
     WS = 4;
    CG=1;
    WE = WE4;                     
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_CG_4_EMP && h_draws_b(draw,t,school_group,2)<P_CG_5_EMP
     WS = 4;
    CG=1;
    WE = WE5; 
    prev_state_w = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif h_draws_b(draw,t,school_group,2)>P_CG_5_EMP && h_draws_b(draw,t,school_group,2)<P_PC_1_UN  %husband schooling PC
    WS = 5;
    PC=1;
    WE = WE1; 
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_PC_1_UN && h_draws_b(draw,t,school_group,2)<P_PC_2_UN
    WS = 5;
    PC=1;
    WE = WE2;  
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_PC_2_UN && h_draws_b(draw,t,school_group,2)<P_PC_3_UN
    WS = 5;
    PC=1;
    WE = WE3;  
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_PC_3_UN && h_draws_b(draw,t,school_group,2)<P_PC_4_UN
    WS = 5;
    PC=1;
    WE = WE4;   
    prev_state_w = 0;
elseif h_draws_b(draw,t,school_group,2)>P_PC_4_UN && h_draws_b(draw,t,school_group,2)<P_PC_5_UN
    WS = 5;
    PC=1;
    WE = WE5; 
    prev_state_w = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif h_draws_b(draw,t,school_group,2)>P_PC_5_UN && h_draws_b(draw,t,school_group,2)<P_PC_1_EMP  %husband schooling PC
    WS = 5;
    PC=1;
    WE = WE1; 
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_PC_1_EMP && h_draws_b(draw,t,school_group,2)<P_PC_2_EMP
    WS = 5;
    PC=1;
    WE = WE2;  
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_PC_2_EMP && h_draws_b(draw,t,school_group,2)<P_PC_3_EMP
    WS = 5;
    PC=1;
    WE = WE3;  
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_PC_3_EMP && h_draws_b(draw,t,school_group,2)<P_PC_4_EMP
    WS = 5;
    PC=1;
    WE = WE4;   
    prev_state_w = 1;
elseif h_draws_b(draw,t,school_group,2)>P_PC_4_EMP && h_draws_b(draw,t,school_group,2)<P_PC_5_EMP
    WS = 5;
    PC=1;
    WE = WE5; 
    prev_state_w = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if WS == 1
    HSD = 1; HSG = 0; SC = 0; CG = 0; PC = 0;
elseif WS == 2
    HSG = 1;HSD = 0; SC = 0; CG = 0; PC = 0;
elseif WS == 3
    SC = 1;HSD = 0; HSG = 0;  CG = 0; PC = 0;
elseif WS == 4
    CG = 1;HSD = 0; HSG = 0; SC = 0;  PC = 0;
elseif WS == 5
    PC = 1;HSD = 0; HSG = 0; SC = 0; CG = 0; 
end         
if WS==2 && school_group==2
    similar_educ = EDUC_MATCH_2;
elseif WS==3 && school_group==3	
    similar_educ = EDUC_MATCH_3;
elseif WS==4 && school_group==4	
    similar_educ = EDUC_MATCH_4;
elseif WS==5 && school_group==5	
    similar_educ = EDUC_MATCH_5;
else
    similar_educ = 0;
end	