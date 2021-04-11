#pragma once

#include <optional>

struct Parameters;

struct Wife;

struct Husband {
    unsigned ID = 0;
    unsigned H_HSD = 0;
    unsigned H_HSG = 0;
    unsigned H_SC = 0;
    unsigned H_CG = 0;
    unsigned H_PC = 0;
    // husband schooling, can get values of 0-4
    unsigned HS = 0;
    // husband experience
    unsigned HE = 0;
    double ability_h_value = 0.0;
    unsigned ability_hi = 0;
    double Q = 0.0;
    unsigned Q_INDEX = 0;
    unsigned AGE = 0;
    unsigned age_index = 0;
    unsigned T_END = 0;
};

Husband draw_husband(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group, unsigned WS);

// update the husband based on schooling, time and wife's age
// returns whether further calculation is needed
bool update_husband_schooling(unsigned HS, std::optional<Wife> wife, unsigned t, Husband& husband);

void update_ability(const Parameters& p, unsigned ability, Husband& husband);

void print_husband(const Husband& husband);

