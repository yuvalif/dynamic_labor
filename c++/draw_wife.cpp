#include <assert.h>
#include "draw_wife.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

bool update_wife_schooling(unsigned WS, unsigned t, Wife& wife) {
    assert(WS > 0);
    wife.WS = WS;
    if (WS == 1) {
        wife.HSG = 1; wife.AGE = 18;
        wife.T_END = TERMINAL - wife.AGE; // TERMINAL = 45, T=27
        wife.age_index = 0;
        wife.HSD = 0; wife.HSG = 1; wife.SC = 0;  wife.CG = 0; wife.PC = 0;
    } else if (WS == 2) {
        wife.SC = 1; wife.AGE = 20;
        wife.T_END = TERMINAL - wife.AGE; // TERMINAL = 45, T=25
        wife.age_index = 2;
        wife.HSD = 0; wife.HSG = 0; wife.SC = 1;  wife.CG = 0; wife.PC = 0;
        if (t > wife.T_END) {
            return false;
        }
    } else if (WS == 3) {
        wife.CG = 1; wife.AGE = 22;
        wife.T_END = TERMINAL - wife.AGE; // TERMINAL = 45, T=23
        wife.age_index = 4;
        wife.HSD = 0; wife.HSG = 0; wife.SC = 0;  wife.CG = 1; wife.PC = 0;
        if (t > wife.T_END) {
            return false;
        }
    } else {
        wife.PC = 1; wife.AGE = 25;
        wife.T_END = TERMINAL - wife.AGE; // TERMINAL = 45, T=20
        wife.age_index = 7;
        wife.HSD = 0; wife.HSG = 0; wife.SC = 0;  wife.CG = 0; wife.PC = 1;
        if (t > wife.T_END) {
            return false;
        }
    }
    return true;
}

Wife draw_wife(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group) {
    Wife result;
    result.ability_wi = h_draw_3();
    result.Q_INDEX = h_draw_3();
    // the 5 sigma values are indexed: 0-4
    result.ability_w_value = normal_arr[result.ability_wi]*p.sigma[3];
    result.Q = normal_arr[result.Q_INDEX]*p.sigma[4];

    const auto& wives_arr = p.wives[t+age_index];

    const auto prob = h_draw_p();

    // find the first index in the wife array that is not less than the probability
    // note: first column of the wife matrix is skipped since it is just an index, hence the: "+1"
    const auto wives_arr_begin = wives_arr.begin()+1;
    const auto index = std::lower_bound(wives_arr_begin, wives_arr.end(), prob) - wives_arr_begin;
  
    // index will be in the range: 0-39 
    assert(index < 40);

    // wife schooling is in the range: 1-4
    result.WS = index/10 + 1;
    assert(result.WS < 5 && result.WS > 0);

    if (index < 10) 
        result.HSG = 1;
    else if (index < 20)
        result.SC = 1;
    else if (index < 30)
        result.CG = 1;
    else
        result.PC = 1;

    result.WE = exp_vector[index%5];

    // [0,4]->0, [5,9]->1, [10,14]->0, [15-19]->1, etc.
    result.prev_state_w = (index/5)%2; 
    
    if (result.WS == school_group) {
        result.similar_educ = p.EDUC_MATCH[school_group];
    }

    return result;
}

