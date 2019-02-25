function [exp_wi   ,exp_hi, kidsi  ,   BPi   , CSi  ]  = value_to_index(WE, HE, N_Y, N_O, BP, CS);

exp_wi = group_exp(WE);
exp_hi = group_exp(HE);
if (N_Y+N_O) == 0
    kidsi = 1;
elseif (N_Y+N_O) == 1
    kidsi = 2;
elseif (N_Y+N_O) == 2
    kidsi = 3;
elseif (N_Y+N_O) > 2
    kidsi = 4;
end
if (BP <0.2)
    BPi = 1;
elseif (BP>0.8)
    BPi = 7;
else
    BPi = round((BP*10)-1);
end
if (CS <0.2)
    CSi = 1;
elseif (CS>0.8)
    CSi = 7;
else
    CSi = round((CS*10)-1);
end
