#pragma once

#include "matrix.h"
#include "const_parameters.h"

const size_t WAGE_MOM_ROW = 36;
const size_t WAGE_MOM_COL = 10;
const size_t MARR_MOM_ROW = 28;
const size_t MARR_MOM_COL = 13; // should be 9
const size_t EMP_MOM_ROW = 28;
const size_t EMP_MOM_COL = 13;
const size_t GEN_MOM_ROW = 31; // FIXME: in the actual general moments file there are 62
const size_t GEN_MOM_COL = SCHOOL_LEN-1;

// wage_moments - 10 by 36 matrix
// first column - potential or real experience
// column 2-5   - annual wage for women by education group - run until 27 for HSG, 25 for SC, 23 for CG and 20 for PC
// column 6-10  - annual wage for men by education group - run until initial exp+t == 35
using WageMoments = Matrix<WAGE_MOM_ROW, WAGE_MOM_COL>;

// marr_fer_moments - 13 by 28 matrix
// first column - age
// column 2-5   - marriage rate by education group. start at t+age index
// column 6-9   - frtility rate by education group. start at t+age index end at 42
// column 10-13 - divorce rate by education group. start at t+age index end at 42
using MarrMoments = Matrix<MARR_MOM_ROW, MARR_MOM_COL>;

// emp_moments - 13 by 28 matrix
// first column - age
// column 2-5   - employment rate by education group. start at t+age index
// column 6-9   - married women employment rate by education group. start at t+age index
// column 10-13 - unmarried women employment rate by education group. start at t+age index
using EmpMoments = Matrix<EMP_MOM_ROW, EMP_MOM_COL>;

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
// 32-33 emp married up with husband wage above/below avg (no estimated moments)
// 34-35 emp married eq with husband wage above/below avg (no estimated moments)
// 36-37 emp married down with husband wage above/below avg (no estimated moments)
// 38-39 standard variage of wage wife/husband (no estimated moments) 
using GenMoments = Matrix<GEN_MOM_ROW, GEN_MOM_COL>;

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

using SchoolingMeanMatrix = MeanMatrix<T_MAX, SCHOOL_LEN>;
using SchoolingMeanArray = MeanArray<SCHOOL_LEN>;

using SchoolingMatrix = UMatrix<T_MAX, SCHOOL_LEN>;
using SchoolingArray = std::array<unsigned, SCHOOL_LEN>;

struct EstimatedMoments {
    WageMoments wage_moments;
    MarrMoments marr_fer_moments;
    EmpMoments emp_moments;
    GenMoments general_moments;
    
    SchoolingMeanMatrix ability_h_up;
    SchoolingMeanMatrix ability_h_down;
    SchoolingMeanMatrix ability_h_eq;
    SchoolingMeanMatrix ability_w_up;
    SchoolingMeanMatrix ability_w_down;
    SchoolingMeanMatrix ability_w_eq;
    SchoolingMeanMatrix match_w_up;
    SchoolingMeanMatrix match_w_down;
    SchoolingMeanMatrix match_w_eq;
};

