#include "parameters.h"
#include "moments.h"
#include "const_parameters.h"
#include "objective_function.h"
#include "load_files.h"
#include <iostream>
#include <stdexcept>

int main() {
    try {
        const auto p = load_parameters("init_parameters.txt", "tax_brackets.out", "deductions_exemptions.out", "wives.out", "husbands");
        const auto m = load_moments("wage_moments.txt", "marr_fer_moments.txt", "emp_moments.txt", "general_moments.txt");
        const double f = objective_function(p, m, true);
        std::cout << "objective function = " << f << std::endl;
    } catch(const std::runtime_error& e) {
        std::cout << e.what() << std::endl;
    }

    return 0;
}

