#include <cassert>
#include "draw_husband.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

bool update_husband_schooling(unsigned HS, unsigned t, Husband& husband) {
    // T_END is used together with the t index which get values 0-27
    husband.HS = HS;
    husband.AGE = AGE_VALUES[HS];
    husband.age_index = AGE_INDEX_VALUES[HS];
    husband.T_END = TERMINAL - husband.AGE - 1;
    if (t > husband.T_END) {
        return false; 
    }
    if (HS == 0) {
        husband.H_HSD = 1;
    } else if (HS == 1) {
        husband.H_HSG = 1;
    } else if (HS == 2) {
        husband.H_SC = 1;
    } else if (HS == 3) {
        husband.H_CG = 1;
    } else if (HS == 4) {
        husband.H_PC = 1;
    } else {
        assert(false);
    }

    return true;
}

void update_ability(const Parameters& p, unsigned ability, Husband& husband) {
    husband.ability_hi = ability;
    husband.ability_h_value = normal_arr[ability]*p.sigma[3];
}

Husband draw_husband(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group, unsigned WS) {
    Husband result;

    update_ability(p, h_draw_3(), result);
    result.Q_INDEX = h_draw_3();
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

