#pragma once
#include "moments.h"
#include <string>

void print_mean_table(const std::string& table_name, const SchoolingMeanMatrix& m);

void print_mean_array(const std::string& table_name, const SchoolingMeanArray& m);

void print_wage_moments(const WageMoments& estimated, const WageMoments& actual);

void print_emp_moments(const EmpMoments& estimated, const EmpMoments& actual);

void print_marr_moments(const MarrMoments& estimated, const MarrMoments& actual);

void print_gen_moments(const GenMoments& estimated, const GenMoments& actual);

void print_up_down_moments(const UpDownMoments& m);
