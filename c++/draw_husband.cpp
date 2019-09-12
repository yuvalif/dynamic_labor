#include <cassert>
#include "draw_husband.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

bool update_husband_schooling(unsigned HS, unsigned t, Husband& husband) {
    // T_END is used together with the t index which get values 0-27
    if (HS == 0) {
        husband.H_HSD = 1; husband.AGE = 18;
        husband.T_END = TERMINAL - husband.AGE - 1; // TERMINAL = 45, T=27
        husband.age_index = 0;
    } else if (HS == 1) {
        husband.H_HSG = 1; husband.AGE = 18;
        husband.T_END = TERMINAL - husband.AGE - 1; // TERMINAL = 45, T=27
        husband.age_index = 0;
    } else if (HS == 2) {
        husband.H_SC = 1; husband.AGE = 20;
        husband.T_END = TERMINAL - husband.AGE - 1; // TERMINAL = 45, T=25
        husband.age_index = 2;
        if (t > husband.T_END) {
            return false;
        }
    } else if (HS == 3) {
        husband.H_CG = 1; husband.AGE = 22;
        husband.T_END = TERMINAL - husband.AGE - 1; // TERMINAL = 45, T=23
        husband.age_index = 4;
        if (t > husband.T_END) {
            return false;
        }
    } else {
        husband.H_PC = 1; husband.AGE = 25;
        husband.T_END = TERMINAL - husband.AGE - 1; // TERMINAL = 45, T=20
        husband.age_index = 7;
        if (t > husband.T_END) {
            return false; 
        }
    }
    return true;
}

Husband draw_husband(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group, unsigned WS) {
    Husband result;

    result.ability_hi = h_draw_3();
    result.Q_INDEX = h_draw_3();
    // the 5 sigma values are indexed: 0-4
    result.ability_h_value = normal_arr[result.ability_hi]*p.sigma[3];
    result.Q = normal_arr[result.Q_INDEX]*p.sigma[4];

    assert(WS > 0 && WS < 5);

    const Husbands* tmp_husbands;
    if (WS == 1) {
        tmp_husbands = &p.husbands2;
    } else if (WS == 2) {
        tmp_husbands = &p.husbands3;
    } else if (WS == 3) {
        tmp_husbands = &p.husbands4;
    } else {
        tmp_husbands = &p.husbands5;
    }

    const auto& husband_arr = (*tmp_husbands)[t+age_index];

    const auto prob = h_draw_p();

    // find the first index in the husband array that is not less than the probability
    // note: first column of the husband matrix is skipped since it is just an index, hence the: "+1"
    const auto husband_arr_begin = husband_arr.begin()+1;
    const auto index_iter = std::lower_bound(husband_arr_begin, husband_arr.end(), prob);
    auto index = HUSBANDS_COL - 1;
    if (index_iter != husband_arr.end()) {
        index = index_iter - husband_arr_begin;
    }
  
    // index will be in the range: 1-25 
    //assert(index < HUSBANDS_COL && index > 0);

    // husband schooling is in the range: 0-4
    auto HS = index/5;

    if (index < 5) 
        result.H_HSD = 1;
    else if (index < 10)
        result.H_HSG = 1;
    else if (index < 15)
        result.H_SC = 1;
    else if (index < 20)
        result.H_CG = 1;
    else
        result.H_PC = 1;

    if (HS == school_group) {
        result.similar_educ = p.EDUC_MATCH[school_group];
    }

    return result;
}

