#pragma once

#include <array>
#include "emax.h"

const unsigned UTILITY_SIZE = CS_SIZE*2;

using UtilityArray = std::array<double, UTILITY_SIZE>;

struct Utility {
    Utility(); // ctor
    UtilityArray U_W{};
    UtilityArray U_H{};
    // FIXME: is it 22 or 2 items array?
    std::array<double, 2> U_W_S{};
    double U_H_S{};
};

class Parameters;
class Wife;
class Husband;

Utility calculate_utility(const Parameters& p, const Emax& EMAX_W, const Emax& EMAX_H, unsigned kids,
        double wage_h, double wage_w, unsigned CHOOSE_PARTNER,
        unsigned M, const Wife& wife, const Husband& husband, unsigned t, double BP, bool single_men);

void print_utility(const Utility& u);

