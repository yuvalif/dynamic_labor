#include <cassert>
#include <optional>
#include "draw_husband.h"
#include "draw_wife.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

bool update_husband_schooling(unsigned HS, std::optional<Wife> wife, unsigned t, Husband& husband) {
    // T_END is used together with the t index which get values 0-27
    husband.HS = HS;
    if (wife) {
      husband.AGE = wife->AGE;
      husband.age_index = wife->age_index;
    } else {
      husband.AGE = AGE_VALUES[HS];
      husband.age_index = AGE_INDEX_VALUES[HS];
    }
    husband.T_END = TERMINAL - husband.AGE - 1;
    // if husband is still at school, experience would be zero
    husband.HE = (husband.AGE >= AGE_VALUES[HS]) ? husband.AGE - AGE_VALUES[HS] : 0;
    if (t > husband.T_END) {
        return false; 
    }
    if (HS == 0) {
        husband.H_HSD = 1;
        husband.H_HSG = 0; husband.H_SC = 0; husband.H_CG = 0; husband.H_PC = 0;
    } else if (HS == 1) {
        husband.H_HSG = 1;
        husband.H_HSD = 0; husband.H_SC = 0; husband.H_CG = 0; husband.H_PC = 0;
    } else if (HS == 2) {
        husband.H_SC = 1;
        husband.H_HSG = 0; husband.H_HSD = 0; husband.H_CG = 0; husband.H_PC = 0;
    } else if (HS == 3) {
        husband.H_CG = 1;
        husband.H_HSG = 0; husband.H_HSD = 0; husband.H_SC = 0; husband.H_PC = 0;
    } else if (HS == 4) {
        husband.H_PC = 1;
        husband.H_HSG = 0; husband.H_HSD = 0; husband.H_SC = 0; husband.H_CG = 0;
    } else {
        assert(false);
    }

    assert(husband.H_SC + husband.H_HSD + husband.H_HSG + husband.H_CG + husband.H_PC == 1);
    return true;
}

void update_ability(const Parameters& p, unsigned ability, Husband& husband) {
    husband.ability_hi = ability;
    husband.ability_h_value = normal_arr[ability]*p.sigma[3];
}

Husband draw_husband(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group, unsigned WS) {

    static unsigned id = 0;
    Husband result;

    result.ID = ++id;

    update_ability(p, draw_3(), result);
    result.Q_INDEX = draw_3();
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

    const auto prob = draw_p();

    // find the first index in the husband array that is not less than the probability
    // note: first column of the husband matrix is skipped since it is just an index, hence the: "+1"
    const auto husband_arr_begin = husband_arr.begin()+1;
    const auto index_iter = std::lower_bound(husband_arr_begin, husband_arr.end(), prob);
    auto index = HUSBANDS_COL-2;
    if (index_iter != husband_arr.end()) {
        index = index_iter - husband_arr_begin;
    }
 
    // index will be in the range: 0-24 
    assert(index <= HUSBANDS_COL-2);

    // husband schooling is in the range: 0-4
    result.HS = index/5;

    return result;
}

#include <iostream>

void print_husband(const Husband& husband) {
    std::cout << "Husband (" << husband.ID << ")" << std::endl;
    std::cout << "\tSchooling: " << husband.HS << std::endl;
    std::cout << "\tSchooling Map: " << husband.H_HSD << " " << husband.H_HSG << " " << husband.H_SC << " " << husband.H_CG << " " << husband.H_PC << std::endl;
    std::cout << "\tExperience: " << husband.HE << std::endl;
    std::cout << "\tAbility: (" << husband.ability_hi << ", " << husband.ability_h_value << ")" << std::endl;
    std::cout << "\tMatch Quality: (" << husband.Q_INDEX << ", " << husband.Q << ")" << std::endl;
    std::cout << "\tAge: (" << husband.age_index << ", " << husband.AGE << ")" << std::endl;
    std::cout << "\tLast Period: " << husband.T_END << std::endl;
}

