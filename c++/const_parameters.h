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

const unsigned UNEMP = 0;
const unsigned EMP = 1;
const unsigned UNMARRIED = 0;
const unsigned MARRIED = 1;

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

const double INITIAL_BP = 0.5;
const double NO_BP = -1.0;


const int TERMINAL = 45;

// emax dimensions:
const int T_MAX = 28; // 28 periods, 45years - 18years
const int EXP_W_LEN = 5; const auto EXP_W_VALUES = boost::irange(0, EXP_W_LEN);
const int EXP_H_LEN = 5; const auto EXP_H_VALUES = boost::irange(0, EXP_H_LEN);
// number of children: (0, 1, 2, 3, 4+)
const int KIDS_LEN = 5; const auto KIDS_VALUES = boost::irange(0, KIDS_LEN);
// previous work status: (employed, unemployed)
const int PREV_WORK_LEN = 2; const auto PREV_WORK_VALUES = boost::irange(0, PREV_WORK_LEN);
// ability wife/husband: (high, medium, low)
const int ABILITY_LEN = 3; const auto ABILITY_VALUES = boost::irange(0, ABILITY_LEN);
// marital status: (married, unmarried)
const int MARITAL_LEN = 2; const auto MARITAL_VALUES = boost::irange(0, MARITAL_LEN);
// only husbands schooling since we solve for a representative women given her education
const int SCHOOL_LEN = 5; 
const auto SCHOOL_H_VALUES = boost::irange(0, SCHOOL_LEN);
const auto SCHOOL_W_VALUES = boost::irange(1, SCHOOL_LEN);
// match quality: (high, medium, low)
const int MATCH_Q_LEN = 3; const auto MATCH_Q_VALUES = boost::irange(0, MATCH_Q_LEN);
// wife bargening power: (0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
const int BP_W_LEN = 7; const auto BP_W_VALUES = boost::irange(0, BP_W_LEN);

// 5 points grid for experience, use interpulations for the values between
const std::array<unsigned, EXP_W_LEN> exp_vector = {0, 2, 4, 8, 16};

const std::array<double, ABILITY_LEN> normal_arr = {-1.150, 0.0, 1.150};     // low, medium, high

const std::array<unsigned, SCHOOL_LEN> AGE_INDEX_VALUES = {0, 0, 2, 4, 7};
const std::array<unsigned, SCHOOL_LEN> AGE_VALUES = {18, 18, 20, 22, 25};

