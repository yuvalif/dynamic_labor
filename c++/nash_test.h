#include <cxxtest/TestSuite.h>
#include <iostream>
#include "nash.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include "marriage_emp_decision.h"

#include "parameters.h"
#include "load_files.h"
#include "calculate_utility.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");
const auto empty_emax = make_emax();

class nash_suite : public CxxTest::TestSuite {
public:
	void test_nash() {
    Utility u;
    Wife wife;
    update_wife_schooling(3, 3, wife);
    Husband husband;
    husband.HE = exp_vector[1];
    update_ability(p, 2, husband);
    u = calculate_utility(p, empty_emax, empty_emax,
        0,
        10000,
        10000,
        1, 
        MARRIED,
        wife,
        husband,
        3,
        0.5,
        false);
    std::cout << "****************************" << std::endl;
    std::cout << to_string(u);

    double bp = nash(p, u);
    if (bp != NO_BP) {
      std::cout << "BP: " << bp << std::endl;
      const auto decision = marriage_emp_decision(u, bp, wife, husband, true);

      std::cout << "new BP: " << bp << std::endl;
      std::cout << "M=" << decision.M << std::endl;
      std::cout << "max_weighted_utility_index=" << decision.max_weighted_utility_index << std::endl;
      std::cout << "outside_option_h_v=" << decision.outside_option_h_v << std::endl;
      std::cout << "outside_option_w_v=" << decision.outside_option_w_v << std::endl;
      std::cout << "outside_option_w=" << decision.outside_option_w << std::endl;
    } else {
      std::cout << "no BP" << std::endl;
    }

    /*for (auto school_group : SCHOOL_W_VALUES) {
        for (auto t = 0; t < T_MAX-1; ++t) {
            Husband husband;
            if (!update_husband_schooling(school_group, t, husband)) continue;
            Wife wife;
            if (!update_wife_schooling(school_group, t, wife)) continue;
            for (auto h_exp_i : EXP_H_VALUES) { 
                husband.HE = exp_vector[h_exp_i];
                for (auto ability_hi : ABILITY_VALUES) {   
                    // husband ability - high, medium, low
                    update_ability(p, ability_hi, husband);
                    for (auto wage_w = 0.0; wage_w < 400000.0; wage_w += 80000.0) {
                        for (auto wage_h = 10000.0; wage_h < 700000.0; wage_h += 80000.0) {
                            for (auto kids : KIDS_VALUES) {
                                const auto u = calculate_utility(p, empty_emax, empty_emax, 
                                        kids, 
                                        wage_h,
                                        wage_w,
                                        1,                      // has partner 
                                        MARRIED,
                                        wife, 
                                        husband,
                                        t,
                                        0.5,                        // BP 
                                        false);                     // not single men
                                std::cout << "****************************" << std::endl;
                                std::cout << to_string(u);
                                std::cout << "BP: " << nash(p, u, bp) << std::endl;
                            }
                        }
                    }
                }
            }
        }
    }*/
  }
};

