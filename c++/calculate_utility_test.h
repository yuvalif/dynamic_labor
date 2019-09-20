#include <cxxtest/TestSuite.h>
#include "calculate_utility.h"
#include "draw_wife.h"
#include "parameters.h"
#include "load_files.h"
#include "emax.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");
const auto empty_emax = make_emax();

//Utility calculate_utility(const Parameters& p, const Emax& EMAX_W, const Emax& EMAX_H, unsigned N_KIDS, unsigned N_KIDS_H,
//        double wage_h, double wage_w, unsigned CHOOSE_PARTNER, unsigned CHOOSE_WORK_H, unsigned CHOOSE_WORK_W,
//        unsigned M, const Wife& wife, unsigned HS, unsigned t, unsigned ability_hi, unsigned HE, double BP, 
//        unsigned T_END, unsigned single_men, unsigned age_index);

class calculate_utility_suite : public CxxTest::TestSuite {
public:

	void test_empty_wife() {
        Wife wife;
        const auto utility = calculate_utility(p, empty_emax, empty_emax,
                0, 0, 20000, 20000, 1, 1, 1, 1, wife, 0, 0, 0, 0, 0.5, 25, 0, 0);
        print_utility(utility);
    }

	void test_single_men() {
        Wife wife;
        const auto utility = calculate_utility(p, empty_emax, empty_emax,
                0, 0, 20000, 20000, 1, 1, 1, 1, wife, 0, 0, 0, 0, 0.5, 25, 0, 0);
        print_utility(utility);
    }
};

