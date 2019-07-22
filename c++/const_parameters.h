#pragma once
#include <array>

// number of draws backward/forward
const unsigned DRAW_B = 30;
const unsigned DRAW_F = 100;

const unsigned UNEMP = 1;
const unsigned EMP = 2;
const unsigned MARRIED = 1;
const unsigned UNMARRIED = 2;

// experience constants
const double WE1 = 0.0;
const double WE2 = 2.0;
const double WE3 = 4.0;
const double WE4 = 8.0;
const double WE5 = 16.0;
const double HE1 = 0.0;
const double HE2 = 2.0;
const double HE3 = 4.0;
const double HE4 = 8.0;
const double HE5 = 16.0;
const std::array<double, 5> exp_vector = {WE1, WE2, WE3, WE4, WE5};

const double beta0 = 0.983;  // discount rate

const std::array<double, 3> normal_arr = {-1.150, 0.0, 1.150};     // low, medium, high
const std::array<double, 11> bp_vector = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};
const std::array<double, 11> cs_vector = {0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0};

const unsigned TERMINAL = 45;

// emax dimensions:
const unsigned T_MAX     = 28;
const unsigned exp_w_len = 5;
const unsigned exp_h_len = 5;
const unsigned kids      = 4;      // children (0, 1, 2, 3+)
const unsigned prev_w    = 2;      // previous work status (employed/unemployed)
const unsigned ability_w = 3;      // ability wife (high,medium,low)
const unsigned ability_h = 3;      // ability husband (high,medium,low)
const unsigned marr      = 2;      // marital status
const unsigned school_h  = 5;      // only husbands schooling since we solve for a representative women given her education
const unsigned school_w  = 4;      // TODO
const unsigned match     = 3;      // match quality (high,medium,low)
const unsigned BP_W      = 7;      // wife bargening power(0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)

// 5 points grid for experience, use interpulations for the values between
const std::array<double, exp_w_len> exp_w = {0.0, 1.5, 3.5, 7.5, 15.0};
const std::array<double, exp_h_len> exp_h = {0.0, 1.5, 3.5, 7.5, 15.0};

