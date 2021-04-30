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

Utility calculate_utility(const Parameters& p, 
    const MarriedEmax& w_emax, const MarriedEmax& h_emax,
    const SingleWomenEmax& w_s_emax, const SingleMenEmax& h_s_emax, 
    unsigned kids,double wage_h, double wage_w, bool choose_partner,
    unsigned M, const Wife& wife, const Husband& husband, unsigned t, double BP, bool single_men);

std::string to_string(const Utility& u);

std::string to_string(const UtilityArray& a);

