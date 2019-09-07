#pragma once

class Parameters;

struct Husband {
    // following are indicators for the wife's schooling
    // they have values of 0/1 and only one of them could be 1
    unsigned H_HSD = 1;
    unsigned H_HSG = 0;
    unsigned H_SC = 0;
    unsigned H_CG = 0;
    unsigned H_PC = 0;
    // husband experience
    unsigned HE = 0;
    unsigned ability_h_value = 0;
    unsigned ability_hi = 0;
    double Q = 0.0;
    unsigned Q_INDEX = 0;
    double similar_educ = 0;
    unsigned AGE = 0;
    unsigned age_index = 0;
    unsigned T_END = 0;
};

Husband draw_husband(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group, unsigned WS);

// update the jusband based on schooling and time
// returns whether further calculation is needed
bool update_husband_schooling(unsigned HS, unsigned t, Husband& husband);

