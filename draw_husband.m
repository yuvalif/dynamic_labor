function [ability_h, ability_hi, Q, Q_INDEX,HS,H_HSD, H_HSG, H_SC, H_CG, H_PC,HE, similar_educ]=draw_husband(husbands, t, age_index, draw_f, h_draws,school_group )
global normal_arr; global sigma; global EDUC_MATCH_2; global EDUC_MATCH_3; global EDUC_MATCH_4; global EDUC_MATCH_5;
global K0 ; global K5 ; global K10 ; global K20 ;global HE0 ; global HE5; global HE10 ;    global HE20 ;    global TERMINAL ;    global H_EXP20 ;    global EMAX21 ;
%h_draws = rand(DRAW_F,T,5); %1- HUSBAND; 2-HUSBAND EXP+SCHOOLING; 3-HUSBAND ABILITY; 4 - INITIAL MATCH QUALITY; 5 - MATCH UALITY CHANGE PROBABILITY

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
ability_h = normal_arr(h_draws(draw_f,t,school_group,3))*sigma(4,4);
ability_hi = h_draws(draw_f,t,school_group,3);
Q = normal_arr(h_draws(draw_f,t,school_group,4))*sigma(5,5);
Q_INDEX = h_draws(draw_f,t,school_group,4);
H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;  
if h_draws(draw_f,t,school_group,2)<P_HSD_0%husband schooling HSD
    HS = 1;
    H_HSD=1;
    HE = HE0;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_0 && h_draws(draw_f,t,school_group,2)<P_HSD_5)
     HS = 1;
    H_HSD=1;
    HE = HE5;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_5 && h_draws(draw_f,t,school_group,2)<P_HSD_10)
     HS = 1;
    H_HSD=1;
    HE = HE10;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_10 && h_draws(draw_f,t,school_group,2)<P_HSD_20)
     HS = 1;
    H_HSD=1;
    HE = HE20;    
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_20 && h_draws(draw_f,t,school_group,2)<P_HSG_0) %husband schooling HSG
     HS = 2;
    H_HSG=1;
    HE = HE0; 
elseif h_draws(draw_f,t,school_group,2)>P_HSG_0 && h_draws(draw_f,t,school_group,2)<P_HSG_5
     HS = 2;
    H_HSG=1;
    HE = HE5; 
elseif h_draws(draw_f,t,school_group,2)>P_HSG_5 && h_draws(draw_f,t,school_group,2)<P_HSG_10
     HS = 2;
    H_HSG=1;
    HE = HE10;    
elseif h_draws(draw_f,t,school_group,2)>P_HSG_10 && h_draws(draw_f,t,school_group,2)<P_HSG_20
     HS = 2;
    H_HSG=1;
    HE = HE20;    
elseif h_draws(draw_f,t,school_group,2)>P_HSG_20 && h_draws(draw_f,t,school_group,2)<P_SC_0  %husband schooling SC
     HS = 3;
    H_SC=1;
    HE = HE0; 
elseif h_draws(draw_f,t,school_group,2)>P_SC_0 && h_draws(draw_f,t,school_group,2)<P_SC_5
     HS = 3;
    H_SC=1;
    HE = HE5; 
elseif h_draws(draw_f,t,school_group,2)>P_SC_5 && h_draws(draw_f,t,school_group,2)<P_SC_10
     HS = 3;
    H_SC=1;
    HE = HE10;    
elseif h_draws(draw_f,t,school_group,2)>P_SC_10 && h_draws(draw_f,t,school_group,2)<P_SC_20
     HS = 3;
    H_SC = 1;
    HE = HE20;    
elseif h_draws(draw_f,t,school_group,2)>P_SC_20 && h_draws(draw_f,t,school_group,2)<P_CG_0  %husband schooling CG
     HS = 4;
    H_CG=1;
    HE = HE0; 
elseif h_draws(draw_f,t,school_group,2)>P_CG_0 && h_draws(draw_f,t,school_group,2)<P_CG_5
     HS = 4;
    H_CG=1;
    HE = HE5; 
elseif h_draws(draw_f,t,school_group,2)>P_CG_5 && h_draws(draw_f,t,school_group,2)<P_CG_10
     HS = 4;
    H_CG=1;
    HE = HE10;    
elseif h_draws(draw_f,t,school_group,2)>P_CG_10 && h_draws(draw_f,t,school_group,2)<P_CG_20
     HS = 4;
    H_CG = 1;
    HE = HE20;                    
elseif h_draws(draw_f,t,school_group,2)>P_CG_20 && h_draws(draw_f,t,school_group,2)<P_PC_0  %husband schooling PC
     HS = 5;
    H_PC=1;
    HE = HE0; 
elseif h_draws(draw_f,t,school_group,2)>P_PC_0 && h_draws(draw_f,t,school_group,2)<P_PC_5
     HS = 5;
    H_PC=1;
    HE = HE5; 
elseif h_draws(draw_f,t,school_group,2)>P_PC_5 && h_draws(draw_f,t,school_group,2)<P_PC_10
     HS = 5;
    H_PC=1;
    HE = HE10;    
elseif h_draws(draw_f,t,school_group,2)>P_PC_10 && h_draws(draw_f,t,school_group,2)<P_PC_20
     HS = 5;
    H_PC = 1;
    HE = HE20;    
end
if HS == 1
    H_HSD = 1; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0;
elseif HS == 2
    H_HSG = 1;H_HSD = 0; H_SC = 0; H_CG = 0; H_PC = 0;
elseif HS == 3
    H_SC = 1;H_HSD = 0; H_HSG = 0;  H_CG = 0; H_PC = 0;
elseif HS == 4
    H_CG = 1;H_HSD = 0; H_HSG = 0; H_SC = 0;  H_PC = 0;
elseif HS == 5
    H_PC = 1;H_HSD = 0; H_HSG = 0; H_SC = 0; H_CG = 0; 
end         
if HS==2 && school_group==2
    similar_educ = EDUC_MATCH_2;
elseif HS==3 && school_group==3	
    similar_educ = EDUC_MATCH_3;
elseif HS==4 && school_group==4	
    similar_educ = EDUC_MATCH_4;
elseif HS==5 && school_group==5	
    similar_educ = EDUC_MATCH_5;
else
    similar_educ = 0;
end	