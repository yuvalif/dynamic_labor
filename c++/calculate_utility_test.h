#include <cxxtest/TestSuite.h>
#include "calculate_utility.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include "parameters.h"
#include "load_files.h"
#include "emax.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");
const auto empty_emax = make_emax();

class calculate_utility_suite : public CxxTest::TestSuite {
public:
	void test_single_women() {
        for (auto school_group : SCHOOL_W_VALUES) {
            for (auto t = 0; t < T_MAX-1; ++t) {
                Wife wife;
                const Husband husband;
                if (!update_wife_schooling(school_group, t, wife)) continue;
                for (auto wage_w = 0.0; wage_w < 400000.0; wage_w += 40000.0) {
                    for (auto kids : KIDS_VALUES) {
                        const auto utility = calculate_utility(p, empty_emax, empty_emax, 
                                kids, 
                                0.0,                        // no husband wage 
                                wage_w, 
                                0,                          // no partner 
                                UNMARRIED,
                                wife, 
                                husband,
                                t,
                                0.5,                        // BP 
                                false);                     // not single men
                        print_utility(utility);
                    }
                }
            }
        }
    }
	
    void test_single_men() {
        const Wife wife;
        for (auto school_group : SCHOOL_W_VALUES) {
            for (auto t = 0; t < T_MAX-1; ++t) {
                Husband husband;
                if (!update_husband_schooling(school_group, t, husband)) continue;
                for (auto h_exp_i : EXP_H_VALUES) { 
                    husband.HE = exp_vector[h_exp_i];
                    for (auto ability_hi : ABILITY_VALUES) {   
                        // husband ability - high, medium, low
                        update_ability(p, ability_hi, husband);
                        for (auto wage_h = 10000.0; wage_h < 700000.0; wage_h += 40000.0) {
                            const auto utility = calculate_utility(p, empty_emax, empty_emax, 
                                NO_KIDS, 
                                wage_h,
                                0.0,                        // no wife wage
                                0,                          // no partner 
                                UNMARRIED,
                                wife, 
                                husband,
                                t,
                                0.5,                        // BP 
                                true);                      // single men
                            print_utility(utility);
                        }
                    }
                }
            }
        }
    }
};

