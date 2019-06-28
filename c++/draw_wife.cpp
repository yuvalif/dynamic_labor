#include "draw_wife.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

Wife::Wife() : 
    HSD(0), HSG(0), SC(0), CG(0), PC(0),
    WS(2), // if no wife, the default is 2, WS goes from 2 to 5, so in martix we use WS-1
    WE(0), prev_state_w(0),
    ability_w_value(0), ability_wi(1), Q(0), Q_INDEX(0), similar_educ(0),
    AGE(0), age_index(0), T_END(0) { }

bool update_wife_schooling(unsigned WS, unsigned t, Wife& wife) {
    wife.WS = WS;
    if (WS == 2) {
        wife.HSG = 1; wife.AGE = 18;
        wife.T_END = TERMINAL - wife.AGE+1; // TERMINAL = 45, T=28
        wife.age_index = 0;
    } else if (WS == 3) {
        wife.SC = 1; wife.AGE = 20;
        wife.T_END = TERMINAL - wife.AGE+1; // TERMINAL = 45, T=26
        wife.age_index = 2;
        if (t > wife.T_END) {
            return false;
        }
    } else if (WS == 4) {
        wife.CG = 1; wife.AGE = 22;
        wife.T_END = TERMINAL - wife.AGE+1; // TERMINAL = 45, T=24
        wife.age_index = 4;
        if (t > wife.T_END) {
            return false;
        }
    } else {
        wife.PC = 1; wife.AGE = 25;
        wife.T_END = TERMINAL - wife.AGE+1; // TERMINAL = 45, T=21
        wife.age_index = 7;
        if (t > wife.T_END) {
            return false;
        }
    }
    return true;
}

Wife draw_wife(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group) {
    Wife result;
    result.ability_wi = h_draw_3();
    result.ability_w_value = normal_arr[result.ability_wi]*p.sigma[4];
    result.Q_INDEX = h_draw_3();
    result.Q = normal_arr[result.Q_INDEX]*p.sigma[5];

    const auto& wives_arr = p.wives[t+age_index];

    const auto prob = h_draw_p();

    const auto index = std::lower_bound(wives_arr.begin()+1, wives_arr.end(), prob) - wives_arr.begin();

    //TODO: replace the switch statement with const array of values
    switch (index) {
        case 1:
            result.WS = 2; result.HSG = 1; result.WE = WE1; result.prev_state_w = 0;
            break;
        case 2:
            result.WS = 2; result.HSG = 1; result.WE = WE2; result.prev_state_w = 0;
            break;
        case 3:
            result.WS = 2; result.HSG = 1; result.WE = WE3; result.prev_state_w = 0;
            break;
        case 4:
            result.WS = 2; result.HSG = 1; result.WE = WE4; result.prev_state_w = 0;
            break;
        case 5:
            result.WS = 2; result.HSG = 1; result.WE = WE5; result.prev_state_w = 0;
            break;
            // WIFE schooling HSG, wife was unemployed in previous period, no experience
        case 6:
            result.WS = 2; result.HSG = 1; result.WE = WE1; result.prev_state_w = 1;
            break;
        case 7:
            result.WS = 2; result.HSG = 1; result.WE = WE2; result.prev_state_w = 1;
            break;
        case 8:
            result.WS = 2; result.HSG = 1; result.WE = WE3; result.prev_state_w = 1;
            break;
        case 9:
            result.WS = 2; result.HSG = 1; result.WE = WE4; result.prev_state_w = 1;
            break;
        case 10:
            result.WS = 2; result.HSG = 1; result.WE = WE5; result.prev_state_w = 1;
            break;
            // husband schooling SC
        case 11:
            result.WS = 3; result.SC = 1; result.WE = WE1; result.prev_state_w = 0;
            break;
        case 12:
            result.WS = 3; result.SC = 1; result.WE = WE2; result.prev_state_w = 0;
            break;
        case 13:
            result.WS = 3; result.SC = 1; result.WE = WE3; result.prev_state_w = 0;
            break;
        case 14:
            result.WS = 3; result.SC = 1; result.WE = WE4; result.prev_state_w = 0;
            break;
        case 15:
            result.WS = 3; result.SC = 1; result.WE = WE5; result.prev_state_w = 0;
            break;
        case 16:
            result.WS = 3; result.SC = 1; result.WE = WE1; result.prev_state_w = 1;
            break;
        case 17:
            result.WS = 3; result.SC = 1; result.WE = WE2; result.prev_state_w = 1;
            break;
        case 18:
            result.WS = 3; result.SC = 1; result.WE = WE3; result.prev_state_w = 1;
            break;
        case 19:
            result.WS = 3; result.SC = 1; result.WE = WE4; result.prev_state_w = 1;
            break;
        case 20:
            result.WS = 3; result.SC = 1; result.WE = WE5; result.prev_state_w = 1;
            break;
            // husband schooling CG
        case 21:
            result.WS = 4; result.CG = 1; result.WE = WE1; result.prev_state_w = 0;
            break;
        case 22:
            result.WS = 4; result.CG = 1; result.WE = WE2; result.prev_state_w = 0;
            break;
        case 23:
            result.WS = 4; result.CG = 1; result.WE = WE3; result.prev_state_w = 0;
            break;
        case 24:
            result.WS = 4; result.CG = 1; result.WE = WE4; result.prev_state_w = 0;
            break;
        case 25:
            result.WS = 4; result.CG = 1; result.WE = WE5; result.prev_state_w = 0;
            break;
        case 26:
            result.WS = 4; result.CG = 1; result.WE = WE1; result.prev_state_w = 1;
            break;
        case 27:
            result.WS = 4; result.CG = 1; result.WE = WE2; result.prev_state_w = 1;
            break;
        case 28:
            result.WS = 4; result.CG = 1; result.WE = WE3; result.prev_state_w = 1;
            break;
        case 29:
            result.WS = 4; result.CG = 1; result.WE = WE4; result.prev_state_w = 1;
            break;
        case 30:
            result.WS = 4; result.CG = 1; result.WE = WE5; result.prev_state_w = 1;
            break;
            // husband schooling PC
        case 31:
            result.WS = 5; result.PC = 1; result.WE = WE1; result.prev_state_w = 0;
            break;
        case 32:
            result.WS = 5; result.PC = 1; result.WE = WE2; result.prev_state_w = 0;
            break;
        case 33:
            result.WS = 5; result.PC = 1; result.WE = WE3; result.prev_state_w = 0;
            break;
        case 34:
            result.WS = 5; result.PC = 1; result.WE = WE4; result.prev_state_w = 0;
            break;
        case 35:
            result.WS = 5; result.PC = 1; result.WE = WE5; result.prev_state_w = 0;
            break;
        case 36:
            result.WS = 5; result.PC = 1; result.WE = WE1; result.prev_state_w = 1;
            break;
        case 37:
            result.WS = 5; result.PC = 1; result.WE = WE2; result.prev_state_w = 1;
            break;
        case 38:
            result.WS = 5; result.PC = 1; result.WE = WE3; result.prev_state_w = 1;
            break;
        case 39:
            result.WS = 5; result.PC = 1; result.WE = WE4; result.prev_state_w = 1;
            break;
        case 40:
            result.WS = 5; result.PC = 1; result.WE = WE5; result.prev_state_w = 1;
            break;
    }
    // TODO: throw exception on default
    
    // TODO: can WS be 1?    

    if (result.WS == school_group) {
        result.similar_educ = p.EDUC_MATCH[school_group];
    }

    return result;
}

