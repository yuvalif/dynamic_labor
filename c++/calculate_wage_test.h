#include <cxxtest/TestSuite.h>
#include "calculate_wage.h"
#include "draw_husband.h"
#include "draw_wife.h"
#include "parameters.h"
#include "load_files.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");

class calculate_wage_suite : public CxxTest::TestSuite {
public:

    void loop_over_all_husband_values(Husband husband, double min_wage, double max_wage) {
        for (auto HE : exp_vector) {
            for (auto ability : normal_arr) {
                husband.HE = HE*p.sigma[4];
                husband.ability_h_value = ability;
                const auto wage = calculate_wage_h(p, husband, 1.0);
                TS_ASSERT_LESS_THAN(wage, max_wage);
                TS_ASSERT_LESS_THAN(min_wage, wage);
            }
        }
    }

    void loop_over_all_wife_values(Wife wife, double min_wage, double max_wage) {
        for (auto WE : exp_vector) {
            for (auto ability : normal_arr) {
                wife.WE = WE*p.sigma[3];
                wife.ability_w_value = ability;
                const auto wage = calculate_wage_w(p, wife, 0.0, 1.0);
                TS_ASSERT_LESS_THAN(wage, max_wage);
                TS_ASSERT_LESS_THAN(min_wage, wage);
            }
        }
    }

	void test_empty_husband() {
        print_parameters(p);
        Husband husband;
        loop_over_all_husband_values(husband, 0.0, 10.0);
    }

	void test_husband_hsd() {
        Husband husband;
        husband.H_HSD = 1;
        loop_over_all_husband_values(husband, 10000.0, 200000.0);
    }

	void test_husband_hsg() {
        Husband husband;
        husband.H_HSG = 1;
        loop_over_all_husband_values(husband, 10000.0, 300000.0);
    }

	void test_husband_pc() {
        Husband husband;
        husband.H_PC = 1;
        loop_over_all_husband_values(husband, 10000.0, 700000.0);
    }

	void test_husband_cg() {
        Husband husband;
        husband.H_CG = 1;
        loop_over_all_husband_values(husband, 10000.0, 500000.0);
    }

	void test_husband_sc() {
        Husband husband;
        husband.H_SC = 1;
        loop_over_all_husband_values(husband, 10000.0, 400000.0);
    }

	void test_empty_wife() {
        Wife wife;
        loop_over_all_wife_values(wife, 0.0, 10.0);
    }

	void test_wife_hsg() {
        Wife wife;
        wife.HSG = 1;
        loop_over_all_wife_values(wife, 5000.0, 200000.0);
    }

	void test_wife_pc() {
        Wife wife;
        wife.PC = 1;
        loop_over_all_wife_values(wife, 10000.0, 400000.0);
    }
	
    void test_wife_cg() {
        Wife wife;
        wife.CG = 1;
        loop_over_all_wife_values(wife, 10000.0, 300000.0);
    }
    
    void test_wife_sc() {
        Wife wife;
        wife.SC = 1;
        loop_over_all_wife_values(wife, 10000.0, 200000.0);
    }
};

