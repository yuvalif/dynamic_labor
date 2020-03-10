#pragma once

#include "matrix.h"
#include "const_parameters.h"

const size_t WAGE_MOM_ROW = 36;
const size_t WAGE_MOM_COL = 10;
const size_t MARR_MOM_ROW = 28;
const size_t MARR_MOM_COL = 13;
const size_t EMP_MOM_ROW = 28;
const size_t EMP_MOM_COL = 13;
const size_t GEN_MOM_ROW = 31;
const size_t GEN_MOM_COL = SCHOOL_LEN-1;

// wage_moments - 10 by 36 matrix
// first column - potential or real experience
// column 2-5   - annual wage for women by education group - run until 27 for HSG, 25 for SC, 23 for CG and 20 for PC
// column 6-10  - annual wage for men by education group - run until initial exp+t == 35
using WageMoments = Matrix<WAGE_MOM_ROW, WAGE_MOM_COL>;
// standard deviation of wage moments over T, one row matrix (no index column)
using WageMomentsStdev = std::array<double, WAGE_MOM_COL-1>;

// marr_fer_moments - 13 by 28 matrix
// first column - age
// column 2-5   - marriage rate by education group. start at t+age index
// column 6-9   - frtility rate by education group. start at t+age index end at 42
// column 10-13 - divorce rate by education group. start at t+age index end at 42
using MarrMoments = Matrix<MARR_MOM_ROW, MARR_MOM_COL>;
// standard deviation of marriage moments over T, one row matrix (no index column)
using MarrMomentsStdev = std::array<double, MARR_MOM_COL-1>;

// emp_moments - 13 by 28 matrix
// first column - age
// column 2-5   - employment rate by education group. start at t+age index
// column 6-9   - married women employment rate by education group. start at t+age index
// column 10-13 - unmarried women employment rate by education group. start at t+age index
using EmpMoments = Matrix<EMP_MOM_ROW, EMP_MOM_COL>;
// standard deviation of employment moments over T, one row matrix (no index column)
using EmpMomentsStdev = std::array<double, EMP_MOM_COL-1>;

// general_moments - 4 by 62 matrix
// 1-5 moments - assortative mating (H_HSD, H_HSG, H_SC, H_CG, H_PC)
// 6 marriage duration
// 7 age of first marriage
// 8 total kids
// 9-11 wage married up/equal/down
// 12-14 emp married up/equal/down
// 15-19 employment by number of children (married)
// 20-21 employment with/without children (unmarried)
// 22-27 transition matrix emp-unemp (m), unemp-emp(m), emp-unemp (um), unemp-emp(um), emp-unemp (m+), unemp-emp(m+)
// 28-39 transition matrix marr-divorce, single-married
// 30-31 birth rate m/um
using GenMoments = Matrix<GEN_MOM_ROW, GEN_MOM_COL>;
// standard deviation of general moments, each moments has its stdev
using GenMomentsStdev = Matrix<GEN_MOM_ROW, GEN_MOM_COL>;

const std::array<std::string, GEN_MOM_ROW> GenMomentsDescription = {
    "Assortative Mating - HSD",
    "Assortative Mating - HSG",
    "Assortative Mating - SC",
    "Assortative Mating - CG",
    "Assortative Mating - PC",
    "Marriage Duration",
    "Age at 1st Marriage",
    "Kids",
    "Wage - Married Up",
    "Wage - Married Equal",
    "Wage - Married Down",
    "Emp - Married Up",
    "Emp - Married Equal",
    "Emp - Married Down",
    "Emp - Married No kids",
    "Emp - Married 1 kid",
    "Emp - Married 2 kids",
    "Emp - Married 3 kids",
    "Emp - Married 4+ kids",
    "Emp - Unmarried No kids",
    "Emp - Unmarried 1+ kid",
    "Emp->Unemp - Married",
    "Unemp->Emp - Married",
    "Emp->Unemp - Unmarried",
    "Unemp->Emp - Unmarried",
    "Emp->Unemp - Married+",
    "Unemp->Emp - Married+",
    "Unmarried->Married",
    "Married->Unmarried",
    "Birth Rate - Married",
    "Birth Rate - Unarried"
};

struct Moments {
    Moments(const WageMoments& _wage_moments,
            const MarrMoments& _marr_fer_moments,
            const EmpMoments& _emp_moments,
            const GenMoments& _general_moments): 
        wage_moments(_wage_moments),
        marr_fer_moments(_marr_fer_moments),
        emp_moments(_emp_moments),
        general_moments(_general_moments) {}

    const WageMoments wage_moments;
    const MarrMoments marr_fer_moments;
    const EmpMoments emp_moments;
    const GenMoments general_moments;
};

struct MomentsStdev {
    MomentsStdev(const WageMomentsStdev& _wage_moments_stdev,
            const MarrMomentsStdev& _marr_fer_moments_stdev,
            const EmpMomentsStdev& _emp_moments_stdev,
            const GenMomentsStdev& _general_moments_stdev): 
        wage_moments_stdev(_wage_moments_stdev),
        marr_fer_moments_stdev(_marr_fer_moments_stdev),
        emp_moments_stdev(_emp_moments_stdev),
        general_moments_stdev(_general_moments_stdev) {}

    const WageMomentsStdev wage_moments_stdev;
    const MarrMomentsStdev marr_fer_moments_stdev;
    const EmpMomentsStdev emp_moments_stdev;
    const GenMomentsStdev general_moments_stdev;
};

using SchoolingMeanMatrix = MeanMatrix<T_MAX, SCHOOL_LEN>;
using SchoolingMeanArray = MeanArray<SCHOOL_LEN>;

using SchoolingMatrix = UMatrix<T_MAX, SCHOOL_LEN>;
using SchoolingArray = std::array<unsigned, SCHOOL_LEN>;

enum UpDownMomentsType {
    ability_h_up = 0,
    ability_h_eq,
    ability_h_down,
    ability_w_up,
    ability_w_eq,
    ability_w_down,
    match_w_up,
    match_w_eq,
    match_w_down,
    wages_m_h_up,
    wages_m_h_eq,
    wages_m_h_down,
    emp_m_up_above,
    emp_m_up_below,
    emp_m_eq_above,
    emp_m_eq_below,
    emp_m_down_above,
    emp_m_down_below,
    n_kids_m_arr,
    n_kids_um_arr,
    UP_DOWN_MOM_ROW
};

using UpDownMoments = MeanMatrix<UP_DOWN_MOM_ROW, SCHOOL_LEN>;

const std::array<std::string, UP_DOWN_MOM_ROW> UpDownMomentsDescription = {
    "Married Up - Men's Ability", 
    "Married Equal - Men's Ability",
    "Married Down - Men's Ability",
    "Married Up - Women's Ability",
    "Married Equal - Women's Ability",
    "Married Down - Women's Ability",
    "Married Up - Match Quality",
    "Married Equal - Match Quality",
    "Married Down - Match Quality",
    "Married Up - Men's Wage",
    "Married Equal - Men's Wage",
    "Married Down - Men's Wage",
    "Emp of Married Up - Men's Wage Above",
    "Emp of Married Up - Men's Wage Below",
    "Emp of Married Equal - Men's Wage Above",
    "Emp of Married Equal - Men's Wage Below",
    "Emp of Married Down - Men's Wage Above",
    "Emp of Married Down - Men's Wage Below",
    "# Kids for Married Women",
    "# Kids for Unmarried Women"
};

using BPDist = std::array<unsigned, CS_SIZE>;
using CSDist = std::array<unsigned, UTILITY_SIZE>;

struct EstimatedMoments {
    // estimated moments
    WageMoments wage_moments;
    MarrMoments marr_fer_moments;
    EmpMoments emp_moments;
    GenMoments general_moments;
    // non estimated moments
    UpDownMoments up_down_moments;
    BPDist bp_initial_dist;
    BPDist bp_dist;
    CSDist cs_dist;
    SchoolingMeanMatrix wages_m_w;      // married women wages if employed
};

