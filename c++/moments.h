#pragma once

#include "matrix.h"
#include "const_parameters.h"

const size_t WAGE_MOM_ROW = 36;
const size_t WAGE_MOM_COL = 10;
const size_t MARR_MOM_ROW = 28;
const size_t MARR_MOM_COL = 9;
const size_t EMP_MOM_ROW = 28;
const size_t EMP_MOM_COL = 13;
const size_t GEN_MOM_ROW = 62;
const size_t GEN_MOM_COL = 4;

// wage_moments - 10 by 36 matrix
// first column - potential or real experience
// column 2-5   - annual wage for women by education group - run until 27 for HSG, 25 for SC, 23 for CG and 20 for PC
// column 6-10  - annual wage for men by education group - run until initial exp+t == 35
using WageMoments = Matrix<WAGE_MOM_ROW, WAGE_MOM_COL>;

// marr_fer_moments - 9 by 28 matrix
// TODO: should be 13 columns?
// first column - age
// column 2-5   - marriage rate by education group. start at t+age index
// column 6-9   - frtility rate by education group. start at t+age index end at 42
using MarrMoments = Matrix<MARR_MOM_ROW, MARR_MOM_COL>;

// emp_moments - 13 by 28 matrix
// first column - age
// column 2-5   - employment rate by education group. start at t+age index
// column 6-9   - married women employment rate by education group. start at t+age index
// column 10-13 - unmarried women employment rate by education group. start at t+age index
using EmpMoments = Matrix<EMP_MOM_ROW, EMP_MOM_COL>;

// general_moments - 4 by 62 matrix (31 moments by education group)
// 5 moments - assortative mating (H_HSD, H_HSG, H_SC, H_CG, H_PC)
using GenMoments = Matrix<GEN_MOM_ROW, GEN_MOM_COL>;

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

struct EstimatedMoments {
    WageMoments wage_moments;
    MarrMoments marr_fer_moments;
    EmpMoments emp_moments;
    GenMoments general_moments;
    
    Matrix<T_MAX, school_h> ability_h_up{0.0};
    Matrix<T_MAX, school_h> ability_h_down{0.0};
    Matrix<T_MAX, school_h> ability_h_eq{0.0};
    Matrix<T_MAX, school_h> ability_w_up{0.0};
    Matrix<T_MAX, school_h> ability_w_down{0.0};
    Matrix<T_MAX, school_h> ability_w_eq{0.0};
    Matrix<T_MAX, school_h> match_w_up{0.0};
    Matrix<T_MAX, school_h> match_w_down{0.0};
    Matrix<T_MAX, school_h> match_w_eq{0.0};
    UMatrix<T_MAX, school_h> count_ability_h_up{0};
    UMatrix<T_MAX, school_h> count_ability_h_down{0};
    UMatrix<T_MAX, school_h> count_ability_h_eq{0};
    UMatrix<T_MAX, school_h> count_ability_w_up{0};
    UMatrix<T_MAX, school_h> count_ability_w_down{0};
    UMatrix<T_MAX, school_h> count_ability_w_eq{0};
    UMatrix<T_MAX, school_h> count_match_w_up{0};
    UMatrix<T_MAX, school_h> count_match_w_down{0};
    UMatrix<T_MAX, school_h> count_match_w_eq{0};
};

