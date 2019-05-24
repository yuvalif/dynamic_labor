function [ability_h, ability_hi, Q, Q_INDEX,HS,H_HSD, H_HSG, H_SC, H_CG, H_PC, HE, similar_educ] = draw_husband(const_values, husbands, t, age_index, draw_f, h_draws, school_group)
HE1 = const_values.HE1;
HE2 = const_values.HE2;
HE3 = const_values.HE3;
HE4 = const_values.HE4;
HE5 = const_values.HE5;
%h_draws = rand(DRAW_F,T,5); %1- HUSBAND; 2-HUSBAND EXP+SCHOOLING; 3-HUSBAND ABILITY; 4 - INITIAL MATCH QUALITY; 5 - MATCH UALITY CHANGE PROBABILITY

P_HSD_1=husbands(t+age_index,2);
P_HSD_2=husbands(t+age_index,3);
P_HSD_3=husbands(t+age_index,4);
P_HSD_4=husbands(t+age_index,5);
P_HSD_5=husbands(t+age_index,5);
P_HSG_1=husbands(t+age_index,6);
P_HSG_2=husbands(t+age_index,7);
P_HSG_3=husbands(t+age_index,8);
P_HSG_4=husbands(t+age_index,9);
P_HSG_5=husbands(t+age_index,10);
P_SC_1=husbands(t+age_index,11);
P_SC_2=husbands(t+age_index,12);
P_SC_3=husbands(t+age_index,13);
P_SC_4=husbands(t+age_index,14);
P_SC_5=husbands(t+age_index,15);
P_CG_1=husbands(t+age_index,16);
P_CG_2=husbands(t+age_index,17);
P_CG_3=husbands(t+age_index,18);
P_CG_4=husbands(t+age_index,19);
P_CG_5=husbands(t+age_index,20);
P_PC_1=husbands(t+age_index,21);
P_PC_2=husbands(t+age_index,22);
P_PC_3=husbands(t+age_index,23);
P_PC_4=husbands(t+age_index,24);               
P_PC_5=husbands(t+age_index,25);               
ability_h = const_values.normal_arr(h_draws(draw_f,t,school_group,3))*const_values.sigma(4,4);
ability_hi = h_draws(draw_f,t,school_group,3);
Q = const_values.normal_arr(h_draws(draw_f,t,school_group,4))*const_values.sigma(5,5);
Q_INDEX = h_draws(draw_f,t,school_group,4);
H_HSD = 1; H_HSG = 0; H_SC = 0; H_CG = 0; H_PC = 0; HS = 1; HE = HE1;  HE_INDEX = 1;
if h_draws(draw_f,t,school_group,2)<P_HSD_1     %husband schooling HSD
    HS = 1;
    H_HSD=1;
    HE = HE1;
    HE_INDEX = 1;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_1 && h_draws(draw_f,t,school_group,2)<P_HSD_2)
     HS = 1;
    H_HSD=1;
    HE = HE2;
    HE_INDEX = 2;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_2 && h_draws(draw_f,t,school_group,2)<P_HSD_3)
     HS = 1;
    H_HSD=1;
    HE = HE3;
    HE_INDEX = 3;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_3 && h_draws(draw_f,t,school_group,2)<P_HSD_4)
     HS = 1;
    H_HSD=1;
    HE = HE4; 
    HE_INDEX = 4;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_4 && h_draws(draw_f,t,school_group,2)<P_HSD_5)
     HS = 1;
    H_HSD=1;
    HE = HE5; 
    HE_INDEX = 5;
elseif (h_draws(draw_f,t,school_group,2)>P_HSD_5 && h_draws(draw_f,t,school_group,2)<P_HSG_1) %husband schooling HSG
     HS = 2;
    H_HSG=1;
    HE = HE1; 
    HE_INDEX = 1;
elseif h_draws(draw_f,t,school_group,2)>P_HSG_1 && h_draws(draw_f,t,school_group,2)<P_HSG_2
     HS = 2;
    H_HSG=1;
    HE = HE2; 
    HE_INDEX = 2;
elseif h_draws(draw_f,t,school_group,2)>P_HSG_2 && h_draws(draw_f,t,school_group,2)<P_HSG_3
     HS = 2;
    H_HSG=1;
    HE = HE3;   
    HE_INDEX = 3;
elseif h_draws(draw_f,t,school_group,2)>P_HSG_3 && h_draws(draw_f,t,school_group,2)<P_HSG_4
     HS = 2;
    H_HSG=1;
    HE = HE4;  
    HE_INDEX = 4;
    elseif h_draws(draw_f,t,school_group,2)>P_HSG_4 && h_draws(draw_f,t,school_group,2)<P_HSG_5
     HS = 2;
    H_HSG=1;
    HE = HE5;    
    HE_INDEX = 5;
elseif h_draws(draw_f,t,school_group,2)>P_HSG_5 && h_draws(draw_f,t,school_group,2)<P_SC_1  %husband schooling SC
     HS = 3;
    H_SC=1;
    HE = HE1; 
    HE_INDEX = 1;
elseif h_draws(draw_f,t,school_group,2)>P_SC_1 && h_draws(draw_f,t,school_group,2)<P_SC_2
     HS = 3;
    H_SC=1;
    HE = HE2; 
    HE_INDEX = 2;
elseif h_draws(draw_f,t,school_group,2)>P_SC_2 && h_draws(draw_f,t,school_group,2)<P_SC_3
     HS = 3;
    H_SC=1;
    HE = HE3;   
    HE_INDEX = 3;
elseif h_draws(draw_f,t,school_group,2)>P_SC_3 && h_draws(draw_f,t,school_group,2)<P_SC_4
     HS = 3;
    H_SC = 1;
    HE = HE4;   
    HE_INDEX = 4;
elseif h_draws(draw_f,t,school_group,2)>P_SC_4 && h_draws(draw_f,t,school_group,2)<P_SC_5
     HS = 3;
    H_SC = 1;
    HE = HE5;   
    HE_INDEX = 5;
elseif h_draws(draw_f,t,school_group,2)>P_SC_5 && h_draws(draw_f,t,school_group,2)<P_CG_1  %husband schooling CG
     HS = 4;
    H_CG=1;
    HE = HE1; 
    HE_INDEX = 1;
elseif h_draws(draw_f,t,school_group,2)>P_CG_1 && h_draws(draw_f,t,school_group,2)<P_CG_2
     HS = 4;
    H_CG=1;
    HE = HE2; 
    HE_INDEX = 2;
elseif h_draws(draw_f,t,school_group,2)>P_CG_2 && h_draws(draw_f,t,school_group,2)<P_CG_3
     HS = 4;
    H_CG=1;
    HE = HE3;   
    HE_INDEX = 3;
elseif h_draws(draw_f,t,school_group,2)>P_CG_3 && h_draws(draw_f,t,school_group,2)<P_CG_4
     HS = 4;
    H_CG = 1;
    HE = HE4;   
    HE_INDEX = 4;
elseif h_draws(draw_f,t,school_group,2)>P_CG_4 && h_draws(draw_f,t,school_group,2)<P_CG_5
     HS = 4;
    H_CG = 1;
    HE = HE5; 
    HE_INDEX = 5;
elseif h_draws(draw_f,t,school_group,2)>P_CG_5 && h_draws(draw_f,t,school_group,2)<P_PC_1  %husband schooling PC
     HS = 5;
    H_PC=1;
    HE = HE1; 
    HE_INDEX = 1;
elseif h_draws(draw_f,t,school_group,2)>P_PC_1 && h_draws(draw_f,t,school_group,2)<P_PC_2
     HS = 5;
    H_PC=1;
    HE = HE2; 
    HE_INDEX = 2;
elseif h_draws(draw_f,t,school_group,2)>P_PC_2 && h_draws(draw_f,t,school_group,2)<P_PC_3
     HS = 5;
    H_PC=1;
    HE = HE3;   
    HE_INDEX = 3;
elseif h_draws(draw_f,t,school_group,2)>P_PC_3 && h_draws(draw_f,t,school_group,2)<P_PC_4
     HS = 5;
    H_PC = 1;
    HE = HE4;   
    HE_INDEX = 4;
elseif h_draws(draw_f,t,school_group,2)>P_PC_4 && h_draws(draw_f,t,school_group,2)<P_PC_5
     HS = 5;
    H_PC = 1;
    HE = HE5; 
    HE_INDEX = 5;
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
    similar_educ = const_values.EDUC_MATCH_2;
elseif HS==3 && school_group==3	
    similar_educ = const_values.EDUC_MATCH_3;
elseif HS==4 && school_group==4	
    similar_educ = const_values.EDUC_MATCH_4;
elseif HS==5 && school_group==5	
    similar_educ = const_values.EDUC_MATCH_5;
else
    similar_educ = 0;
end	