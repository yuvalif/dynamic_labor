#include "emax.h"

#ifdef USE_MULTI_ARRAY
Emax make_emax() {
    return Emax(boost::extents[T_MAX][EXP_W_LEN][EXP_H_LEN][KIDS_LEN][PREV_WORK_LEN][ABILITY_LEN][ABILITY_LEN][MARITAL_LEN][SCHOOL_LEN][SCHOOL_LEN][MATCH_Q_LEN][BP_W_LEN]);
}
#else
Emax make_emax() {
    return std::make_unique<float[]>(T_MAX*EXP_W_LEN*EXP_H_LEN*KIDS_LEN*PREV_WORK_LEN*ABILITY_LEN*ABILITY_LEN*MARITAL_LEN*SCHOOL_LEN*SCHOOL_LEN*MATCH_Q_LEN*BP_W_LEN);
}

float& get(Emax& e, unsigned t, unsigned _exp_w, unsigned _exp_h, unsigned _kids, unsigned _prev_w, 
	unsigned _ability_w, unsigned _ability_h, unsigned _marr, unsigned _school_h, unsigned _school_w, unsigned _match, unsigned _BP_W) {
	return e[((((((((((t*EXP_W_LEN + _exp_w)*EXP_H_LEN + _exp_h)*KIDS_LEN + _kids)*PREV_WORK_LEN + _prev_w)*ABILITY_LEN + _ability_w)*ABILITY_LEN + _ability_h)*MARITAL_LEN + 
                        _marr)*SCHOOL_LEN + _school_h)*SCHOOL_LEN + _school_w)*MATCH_Q_LEN + _match)*BP_W_LEN + _BP_W];
}

float get(const Emax& e, unsigned t, unsigned _exp_w, unsigned _exp_h, unsigned _kids, unsigned _prev_w, 
	unsigned _ability_w, unsigned _ability_h, unsigned _marr, unsigned _school_h, unsigned _school_w, unsigned _match, unsigned _BP_W) {
	return e[((((((((((t*EXP_W_LEN + _exp_w)*EXP_H_LEN + _exp_h)*KIDS_LEN + _kids)*PREV_WORK_LEN + _prev_w)*ABILITY_LEN + _ability_w)*ABILITY_LEN + _ability_h)*MARITAL_LEN + 
                        _marr)*SCHOOL_LEN + _school_h)*SCHOOL_LEN + _school_w)*MATCH_Q_LEN + _match)*BP_W_LEN + _BP_W];
}
#endif

