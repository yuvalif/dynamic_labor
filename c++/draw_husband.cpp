#include "draw_husband.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

Husband::Husband() : H_HSD(0), H_HSG(0), H_SC(0), H_CG(0), H_PC(0),
                        HE(0), ability_h_value(0), ability_hi(1),
                        Q(0), Q_INDEX(1), similar_educ(0) {}

bool update_husband_schooling(unsigned HS, unsigned t, Husband& husband) {
    if (HS == 1) {
        husband.H_HSD = 1; husband.AGE = 18;
        husband.T_END = TERMINAL - husband.AGE+1; // TERMINAL = 45, T=28
        husband.age_index = 0;
    } else if (HS == 2) {
        husband.H_HSG = 1; husband.AGE = 18;
        husband.T_END = TERMINAL - husband.AGE+1; // TERMINAL = 45, T=28
        husband.age_index = 0;
    } else if (HS == 3) {
        husband.H_SC = 1; husband.AGE = 20;
        husband.T_END = TERMINAL - husband.AGE+1; // TERMINAL = 45, T=26
        husband.age_index = 2;
        if (t > husband.T_END) {
            return false;
        }
    } else if (HS == 4) {
        husband.H_CG = 1; husband.AGE = 22;
        husband.T_END = TERMINAL - husband.AGE+1; // TERMINAL = 45, T=24
        husband.age_index = 4;
        if (t > husband.T_END) {
            return false;
        }
    } else {
        husband.H_PC = 1; husband.AGE = 25;
        husband.T_END = TERMINAL - husband.AGE+1; // TERMINAL = 45, T=21
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
    result.ability_h_value = normal_arr[result.ability_hi]*p.sigma[4];
    result.Q_INDEX = h_draw_3();
    result.Q = normal_arr[result.Q_INDEX]*p.sigma[5];

    const Husbands* tmp_husbands = nullptr;
    if (WS == 2) {
        tmp_husbands = &p.husbands2;
    } else if (WS == 3) {
        tmp_husbands = &p.husbands3;
    } else if (WS == 4) {
        tmp_husbands = &p.husbands4;
    } else {
        tmp_husbands = &p.husbands5;
    }

    const auto& husband_arr = (*tmp_husbands)[t+age_index];

    const auto prob = h_draw_p();

    const auto index = std::lower_bound(husband_arr.begin()+1, husband_arr.end(), prob) - husband_arr.begin();

    unsigned HS;

    //TODO: replace the switch statement with const array of values
    switch (index) {
        case 1:
            HS = 1; result.H_HSD = 1; result.HE = HE1;
            break;
        case 2:
            HS = 1; result.H_HSD = 1; result.HE = HE2;
            break;
        case 3:
            HS = 1; result.H_HSD = 1; result.HE = HE3;
            break;
        case 4:
            HS = 1; result.H_HSD = 1; result.HE = HE4;
            break;
        case 5:
            HS = 1; result.H_HSD = 1; result.HE = HE5;
            break;
        case 6:
            HS = 2; result.H_HSG = 1; result.HE = HE1;
            break;
        case 7:
            HS = 2; result.H_HSG = 1; result.HE = HE2;
            break;
        case 8:
            HS = 2; result.H_HSG = 1; result.HE = HE3;
            break;
        case 9:
            HS = 2; result.H_HSG = 1; result.HE = HE4;
            break;
        case 10:
            HS = 2; result.H_HSG = 1; result.HE = HE5;
            break;
        case 11:
            HS = 3; result.H_SC = 1; result.HE = HE1;
            break;
        case 12:
            HS = 3; result.H_SC = 1; result.HE = HE2;
            break;
        case 13:
            HS = 3; result.H_SC = 1; result.HE = HE3;
            break;
        case 14:
            HS = 3; result.H_SC = 1; result.HE = HE4;
            break;
        case 15:
            HS = 3; result.H_SC = 1; result.HE = HE5;
            break;
        case 16:
            HS = 4; result.H_CG = 1; result.HE = HE1;
            break;
        case 17:
            HS = 4; result.H_CG = 1; result.HE = HE2;
            break;
        case 18:
            HS = 4; result.H_CG = 1; result.HE = HE3;
            break;
        case 19:
            HS = 4; result.H_CG = 1; result.HE = HE4;
            break;
        case 20:
            HS = 4; result.H_CG = 1; result.HE = HE5;
            break;
        case 21:
            HS = 5; result.H_PC = 1; result.HE = HE1;
            break;
        case 22:
            HS = 5; result.H_PC = 1; result.HE = HE2;
            break;
        case 23:
            HS = 5; result.H_PC = 1; result.HE = HE3;
            break;
        case 24:
            HS = 5; result.H_PC = 1; result.HE = HE4;
            break;
        case 25:
            HS = 5; result.H_PC = 1; result.HE = HE5;
            break;
    }
    // TODO: add exception on default

    if (HS == school_group) {
        result.similar_educ = p.EDUC_MATCH[school_group];
    }

    return result;
}

