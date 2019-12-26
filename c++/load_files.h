#pragma once

#include "parameters.h"
#include "moments.h"
#include <string>

Parameters load_parameters(const std::string& model_parameters_file_name,
        const std::string& tax_file_name,
        const std::string& ded_file_name,
        const std::string& wives_file_name,
        const std::string& husbands_file_prefix);

Moments load_moments(const std::string& wage_moments_file_name,
        const std::string& marr_fer_moments_file_name,
        const std::string& emp_moments_file_name,
        const std::string& general_moments_file_name);


MomentsStdev load_moments_stdev(const std::string& wage_moments_stdev_file_name,
        const std::string& marr_fer_moments_stdev_file_name,
        const std::string& emp_moments_stdev_file_name,
        const std::string& general_moments_stdev_file_name);

