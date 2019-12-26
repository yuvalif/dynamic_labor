#pragma once

#include <array>
#include "emax.h"
#include "const_parameters.h"

using UtilityArray = std::array<double, UTILITY_SIZE>;

struct Utility {
    Utility(); // ctor
    UtilityArray U_W{};
    UtilityArray U_H{};
    std::array<double, 2> U_W_S{};
    double U_H_S{};
};

struct Parameters;
struct Wife;
struct Husband;

Utility calculate_utility(const Parameters& p, const Emax& EMAX_W, const Emax& EMAX_H, unsigned kids,
        double wage_h, double wage_w, bool choose_partner,
        unsigned M, const Wife& wife, const Husband& husband, unsigned t, double BP, bool single_men);

void print_utility(const Utility& u);

