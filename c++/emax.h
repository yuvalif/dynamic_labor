#pragma once

#include "const_parameters.h"
#include "boost/multi_array.hpp"

// time | w exp | h exp | kids  | work  | w ability | h ability | h school | w school | match q | bp    |
// 0-27 | 0 - 4 | 0 - 4 | 0 - 3 | 0 - 1 | 0 - 2     | 0 - 2     | 0 - 4    | 0 - 4    | 0 - 2   | 0 - 7 |
using MarriedEmax = boost::multi_array<double, 11>;
// time | exp   | kids  | work  | ability | school |
// 0-27 | 0 - 4 | 0 - 3 | 0 - 1 | 0 - 2   | 1 - 4  |
using SingleWomenEmax = boost::multi_array<double, 6>;
// time | exp   | ability | school |
// 0-27 | 0 - 4 | 0 - 2   | 1 - 4  |
using SingleMenEmax = boost::multi_array<double, 4>;

template<typename EmaxT>
EmaxT make_emax();

void dump_emax(const std::string& file, const SingleWomenEmax& emax);
void dump_emax(const std::string& file, const SingleMenEmax& emax);
void dump_emax(const std::string& file, const MarriedEmax& emax);

