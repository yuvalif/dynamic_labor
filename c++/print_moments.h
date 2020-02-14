#pragma once
#include "moments.h"
#include <string>

void print_mean_table(const std::string& table_name, const SchoolingMeanMatrix& m);

void print_mean_array(const std::string& table_name, const SchoolingMeanArray& m);

void print_wage_moments(const WageMoments& m, bool estimated);

void print_emp_moments(const EmpMoments& m, bool estimated);

void print_marr_moments(const MarrMoments& m, bool estimated);

void print_gen_moments(const GenMoments& m, bool estimated);

void print_up_down_moments(const UpDownMoments& m);
