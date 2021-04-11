#pragma once

#include "const_parameters.h"

struct Parameters;

struct Wife {
    // following are indicators for the wife's schooling
    // they have values of 0/1 and only one of them could be 1
    unsigned HSD = 0; // should always remain 0
    unsigned HSG = 0;
    unsigned SC = 0;
    unsigned CG = 0;
    unsigned PC = 0;

    // wife schooling, can get values of 1-4 (value of 0 is not ppossible)
    unsigned WS = 0;
    // wife experience
    unsigned WE = 0;

    unsigned emp_state = UNEMP;
    double ability_w_value = 0;
    unsigned ability_wi = 0;
    double Q = 0.0;
    unsigned Q_INDEX = 0;
    double similar_educ = 0.0;
    unsigned AGE = 0;
    unsigned age_index = 0;
    unsigned T_END = 0;
};

// draw a wife
Wife draw_wife(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group);

// update the wife based on schooling and time
// returns whether further calculation is needed
bool update_wife_schooling(unsigned WS, unsigned t, Wife& wife);

void update_ability(const Parameters& p, unsigned ability, Wife& wife);

void print_wife(const Wife& wife);

