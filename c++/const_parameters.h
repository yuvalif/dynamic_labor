#pragma once
#include <array>
#include <boost/range/irange.hpp>

// number of draws backward
// allow to be set as a compilation flag, defaults to 10
#ifndef DRAWS
#define DRAWS 10
#endif

const unsigned DRAW_B = DRAWS;
const unsigned DRAW_F = 1000;

const unsigned NO_KIDS = 0;
const double UNEMP_WOMEN_RATIO = 0.45;

const double beta0 = 0.983;  // discount rate

// use this instead of: std::numeric_limits<double>::lowest()
// so it is more clear when the number is printed
const double MINIMUM_UTILITY = -99999.0;

const auto CS_SIZE = 11;
const unsigned UTILITY_SIZE = CS_SIZE*2;
const std::array<double, CS_SIZE> cs_vector = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};
const std::array<double, CS_SIZE> bp_vector = cs_vector;

// experience - 5 point grid
const int EXP_LEN = 5; const auto EXP_VALUES = boost::irange(0, EXP_LEN);
const std::array<unsigned, EXP_LEN> exp_vector = {0, 2, 4, 8, 16};

// number of children: (0, 1, 2, 3+)
const int KIDS_LEN = 4; const auto KIDS_VALUES = boost::irange(0, KIDS_LEN);

// work status: (unemp, emp)
const unsigned UNEMP = 0;
const unsigned EMP = 1;
const int WORK_LEN = 2; const auto WORK_VALUES = boost::irange(0, WORK_LEN);

// ability wife/husband: (low, medium, high))
const int ABILITY_LEN = 3; const auto ABILITY_VALUES = boost::irange(0, ABILITY_LEN);
const std::array<double, ABILITY_LEN> normal_arr = {-1.150, 0.0, 1.150};

// marital status: (unmarried, married)
const unsigned UNMARRIED = 0;
const unsigned MARRIED = 1;
const int MARITAL_LEN = 2; const auto MARITAL_VALUES = boost::irange(0, MARITAL_LEN);

// school groups
const int SCHOOL_LEN = 5;
const auto SCHOOL_H_VALUES = boost::irange(0, SCHOOL_LEN);
// women does not have the HSD school group
const auto SCHOOL_W_VALUES = boost::irange(1, SCHOOL_LEN);
const std::array<std::string, SCHOOL_LEN> SCHOOL_NAMES = {"HSD", "HSG", "SC", "CG", "PC"};

// match quality: (high, medium, low)
const int MATCH_Q_LEN = 3; const auto MATCH_Q_VALUES = boost::irange(0, MATCH_Q_LEN);

// wife bargening power
const double INITIAL_BP = 0.5;
const double NO_BP = -99.0;
const int BP_W_LEN = 8;
const std::array<double, BP_W_LEN> BP_W_VALUES = {0.0, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8};

// maximum age
const int TERMINAL = 45;
// 28 periods, 45years - 18years
const int T_MAX = 28;
const std::array<unsigned, SCHOOL_LEN> AGE_INDEX_VALUES = {0, 0, 2, 4, 7};
const std::array<unsigned, SCHOOL_LEN> AGE_VALUES = {18, 18, 20, 22, 25};


