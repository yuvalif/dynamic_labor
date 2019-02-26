    for WS = 2 : 5 % no need to calclate emax of HSD single women
        for W_EXP_INDEX = 1 : G_exp_w %WIFE EXPERENCE - 5 GRID LEVEL
            for H_EXP_INDEX = 1 : G_exp_h %HUSBAND EXPERENCE - 5 GRID LEVEL
                for TOTAL_N = 1 : G_kids
                    for ability_wi = 1:3   %husband ability - high, medium, low
                        ability_w = normal_arr(ability_wi)*sigma(4,4);
                        for ability_hi = 1:3   %husband ability - high, medium, low
                            ability_h = normal_arr(ability_hi)*sigma(4,4);
                            for prev_state_w = 1 : G_prev_w
                                for HS = 1 : G_school_h %5 levels 
                                    for Q_INDEX = 1 : G_match %3 level
                                        Q = normal_arr(Q_INDEX)*sigma(5,5);
                                        for BPi = 1 : G_BP_W % 7 levels
                                            for CSi = 1 : G_CS_W % 7 levels


                                                ADD_EMAX_W = 0;
                                                ADD_EMAX_H = 0;
                                                for draw_b = 1 : DRAW_B


                                                end   % end draw backward loop
                                               [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ] = value_to_index(WE, 0 , N_KIDS, 1, 1);
                                %               EMAX  (t,G_exp_w, G_exp_h,G_kids, G_prev_w, G_ability_w, G_ability_h, G_marr, G_school_h,G_school_w, G_match, G_BP_W, G_CS_w)  
                                                EMAX_W(t,exp_wi   ,exp_hi, kidsi  ,  1     , 1         ,  ability_hi,UNMARRIED , HS      ,1        , 1      ,  1   , 1   ) = ADD_EMAX/DRAW_B;
                                               [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ] = value_to_index(0, HE, 0, 1, 1);
                                %               EMAX  (t,G_exp_w, G_exp_h,G_kids, G_prev_w, G_ability_w, G_ability_h, G_marr, G_school_h,G_school_w, G_match, G_BP_W, G_CS_w)  
                                                EMAX_H(t,exp_wi   ,exp_hi, kidsi  ,  1     , 1         ,  ability_hi,UNMARRIED , HS      ,1        , 1      ,  1   , 1   ) = ADD_EMAX/DRAW_B;
                                            end   % end CS loop
                                        end   % end BP  loop
                                    end   % end match quality loop
                                end   % end husband schooling loop
                            end   % end prev state w loop
                        end   % end husbands ability loop
                    end   % end wife's ability loop
                end   % end kids loop
           end % end married men experience loop
        end % end married women experience loop
    end %close wife schooling loop     
  