#include "load_files.h"
#include "parameters.h"
#include "moments.h"
#include "matrix.h"
#include <string>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <stdexcept>

template <size_t ROW, size_t COL>
Matrix<ROW, COL> load_matrix(const std::string& file_name) {
    std::ifstream file(file_name);
    if (!file.is_open()) {
        throw std::runtime_error("failed to open: '" + file_name + "'");
    }
    Matrix<ROW, COL> m;
    for (size_t i = 0; i < ROW; ++i) {
        for (size_t j = 0; j < COL; ++j) {
            file >> m[i][j];
            if (!file.good()) {
                throw std::runtime_error("parse error in: '" + file_name +
                        "' row: " + std::to_string(i) + " col: " + std::to_string(j));
            }
        }
    }
    return m;
}

template <size_t ROW>
std::array<double, ROW> load_array(const std::string& file_name) {
    std::ifstream file(file_name);
    if (!file.is_open()) {
        throw std::runtime_error("failed to open: " + file_name);
    }
    std::array<double, ROW> arr;
    for (size_t i = 0; i < ROW; ++i) {
        file >> arr[i];
        if (!file.good()) {
            throw std::runtime_error("parse error in: '" + file_name + 
                    "' row: " + std::to_string(i));
        }
    }
    return arr;
}

Parameters load_parameters(const std::string& model_parameters_file_name,
        const std::string& tax_file_name,
        const std::string& ded_file_name,
        const std::string& wives_file_name,
        const std::string& husbands_file_prefix){

    return Parameters(load_array<PARAMETER_LIST_LEN>(model_parameters_file_name),
            load_matrix<TAX_ROW, TAX_COL>(tax_file_name),
            load_matrix<TAX_ROW, DED_COL>(ded_file_name),
            load_matrix<WIVES_ROW, WIVES_COL>(wives_file_name),
            load_matrix<HUSBANDS_ROW, HUSBANDS_COL>(husbands_file_prefix+"_1.out"),
            load_matrix<HUSBANDS_ROW, HUSBANDS_COL>(husbands_file_prefix+"_2.out"),
            load_matrix<HUSBANDS_ROW, HUSBANDS_COL>(husbands_file_prefix+"_3.out"),
            load_matrix<HUSBANDS_ROW, HUSBANDS_COL>(husbands_file_prefix+"_4.out"),
            load_matrix<HUSBANDS_ROW, HUSBANDS_COL>(husbands_file_prefix+"_5.out"));
}

Moments load_moments(const std::string& wage_moments_file_name,
        const std::string& marr_fer_moments_file_name,
        const std::string& emp_moments_file_name,
        const std::string& general_moments_file_name) {
    return Moments(load_matrix<WAGE_MOM_ROW, WAGE_MOM_COL>(wage_moments_file_name),
            load_matrix<MARR_MOM_ROW, MARR_MOM_COL>(marr_fer_moments_file_name),
            load_matrix<EMP_MOM_ROW, EMP_MOM_COL>(emp_moments_file_name),
            load_matrix<GEN_MOM_ROW, GEN_MOM_COL>(general_moments_file_name));
}

