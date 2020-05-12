#include <cxxtest/TestSuite.h>
#include <iostream>
#include "nash.h"

#include "parameters.h"
#include "load_files.h"
#include "calculate_utility.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");

class nash_suite : public CxxTest::TestSuite {
public:
	void testNash( void ) {
        double bp = 0.5;
        Utility utility;
        utility.U_H_S = 0.9;
        utility.U_H = {0.1};
        utility.U_W_S = {0.9, 0.9};
        utility.U_W = {0.1};
        std::cout << nash(p, utility, bp) << std::endl;
    }
};

