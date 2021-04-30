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
const auto empty_w_s_emax = make_emax<SingleWomenEmax>();
const auto empty_m_s_emax = make_emax<SingleMenEmax>();
const auto empty_married_emax = make_emax<MarriedEmax>();

class nash_suite : public CxxTest::TestSuite {
  public:
    void test_nash() {
      Utility u;
      Wife wife;
      update_wife_schooling(3, 3, wife);
      Husband husband;
      husband.HE = exp_vector[1];
      update_ability(p, 2, husband);
      u = calculate_utility(p, empty_married_emax, empty_married_emax,
          empty_w_s_emax, empty_m_s_emax,
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

    }
};

