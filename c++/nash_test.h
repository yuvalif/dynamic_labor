#include <cxxtest/TestSuite.h>
#include <iostream>
#include <fstream>
#include "nash.h"

#include "parameters.h"
#include "load_files.h"
#include "calculate_utility.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");

class nash_suite : public CxxTest::TestSuite {
public:
	void test_nash() {
        std::ifstream file("./utility.txt");
        if (!file.is_open()) {
            throw std::runtime_error("failed to open: utility.txt");
        }
        while (file.good()) {
            Utility utility;
            for (auto& u : utility.U_W_S) {
                file >> u;
            }
            file >> utility.U_H_S;
            for (auto& u : utility.U_W) {
                file >> u;
            }
            for (auto& u : utility.U_H) {
                file >> u;
            }
            double bp = 0.5;
            std::cout << "****************************" << std::endl;
            std::cout << to_string(utility);
            std::cout << "BP: " << nash(p, utility, bp) << std::endl;
        }
    }
};

