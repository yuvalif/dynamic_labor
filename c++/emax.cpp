#include "emax.h"

Emax make_emax() {
    return Emax(boost::extents[T_MAX][exp_w_len][exp_h_len][kids][prev_w][ability_w][ability_h][marr][school_h][school_w][match][BP_W]);
}

/*
Emax make_emax() {
    return std::make_unique<float[]>(T_MAX*exp_w_len*exp_h_len*kids*prev_w*ability_w*ability_h*marr*school_h*school_w*match*BP_W);
}

float& get(Emax& e, unsigned t, unsigned _exp_w, unsigned _exp_h, unsigned _kids, unsigned _prev_w, 
	unsigned _ability_w, unsigned _ability_h, unsigned _marr, unsigned _school_h, unsigned _school_w, unsigned _match, unsigned _BP_W) {
	return e[((((((((((t*exp_w_len + _exp_w)*exp_h_len + _exp_h)*kids + _kids)*prev_w + _prev_w)*ability_w + _ability_w)*ability_h + _ability_h)*marr + _marr)*school_h + 
		_school_h)*school_w + _school_w)*match + _match)*BP_W + _BP_W];
}

float get(const Emax& e, unsigned t, unsigned _exp_w, unsigned _exp_h, unsigned _kids, unsigned _prev_w, 
	unsigned _ability_w, unsigned _ability_h, unsigned _marr, unsigned _school_h, unsigned _school_w, unsigned _match, unsigned _BP_W) {
	return e[((((((((((t*exp_w_len + _exp_w)*exp_h_len + _exp_h)*kids + _kids)*prev_w + _prev_w)*ability_w + _ability_w)*ability_h + _ability_h)*marr + _marr)*school_h + 
		_school_h)*school_w + _school_w)*match + _match)*BP_W + _BP_W];
}
*/

