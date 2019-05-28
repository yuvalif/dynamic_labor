#pragma once
#include <array>
#include "emax.h"

const unsigned UTILITY_SIZE = 22;

using UtilityArray = std::array<double, UTILITY_SIZE>;

struct Utility {
    UtilityArray U_W{};
    UtilityArray U_H{};
    UtilityArray U_W_S{};
    double U_H_S{};
};

class Parameters;
class Wife;

Utility calculate_utility(const Parameters& p, const Emax& EMAX_W, const Emax& EMAX_H, unsigned N_KIDS, unsigned N_KIDS_H,
        double wage_h, double wage_w, unsigned CHOOSE_PARTNER, unsigned CHOOSE_WORK_H, unsigned CHOOSE_WORK_W,
        unsigned M, const Wife& wife, unsigned HS, unsigned t, unsigned ability_hi, unsigned HE, double BP, 
        unsigned T_END, unsigned single_men, unsigned age_index);

