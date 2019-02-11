function [HE_IDX_1,HE_IDX_0,WE_IDX_1,WE_IDX_0, N_Y_arr, N_O_arr,M_IDX, UM_IDX,EMP_IDX,UNEMP_IDX  ] = value_to_index(WE, HE, N_Y, N_O);

HE_IDX_1 = group_exp(HE+1);
HE_IDX_0 = group_exp(HE);
WE_IDX_1 = group_exp(WE+1);
WE_IDX_0 = group_exp(WE);
N_Y_arr = N_Y+1 ;
N_O_arr = N_O+1 ;
M_IDX = 1;
UM_IDX = 2;
EMP_IDX = 1;
UNEMP_IDX = 2;                                               
