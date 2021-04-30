#include <cxxtest/TestSuite.h>
#include "calculate_wage.h"
#include "draw_husband.h"
#include "draw_wife.h"
#include "parameters.h"
#include "load_files.h"
#include "cpp-text-table/TextTable.h"
#include "to_string.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");

void set_school_group(Husband& h, int school_group) {
  if (school_group == 0) {
    h.H_HSD = 1;
  } else if (school_group == 1) {
    h.H_HSG = 1;
  } else if (school_group == 2) {
    h.H_SC = 1;
  } else if (school_group == 3) {
    h.H_CG = 1;
  } else if (school_group == 4) {
    h.H_PC = 1;
  }
  assert(false);
}

void set_school_group(Wife& w, int school_group) {
  if (school_group == 0) {
    assert(false);
  } else if (school_group == 1) {
    w.HSG = 1;
  } else if (school_group == 2) {
    w.SC = 1;
  } else if (school_group == 3) {
    w.CG = 1;
  } else if (school_group == 4) {
    w.PC = 1;
  }
  assert(false);
}

static const auto epsilon_for_test = 0.0;
static const auto no_wage_prob = 0.0;

class calculate_wage_suite : public CxxTest::TestSuite {
  public:
    void test_husband() {
      TextTable table(' ');
      table.add("Schooling");
      table.add("Experience");
      table.add("Ability");
      table.add("Wage");
      table.endOfRow();

      for (auto school_group : SCHOOL_H_VALUES) {
        Husband husband;
        set_school_group(husband, school_group);
        for (auto ex : exp_vector) {
          for (auto ability : normal_arr) {
            husband.HE = ex;
            husband.ability_h_value = ability*p.sigma[3];
            const auto wage = calculate_wage_h(p, husband, epsilon_for_test);
            table.add(std::to_string(school_group));
            table.add(std::to_string(ex));
            table.add(to_string_with_precision(ability, 3));
            table.add(to_string_with_precision(wage, 0));
            table.endOfRow();
          }
        }
      }
      std::cout  << std::endl << table << std::endl;
    }

    void test_wife() {
      TextTable table(' ');
      table.add("Schooling");
      table.add("Experience");
      table.add("Ability");
      table.add("Wage");
      table.endOfRow();

      for (auto school_group : SCHOOL_W_VALUES) {
        Wife wife;
        set_school_group(wife, school_group);
        for (auto ex : exp_vector) {
          for (auto ability : normal_arr) {
            wife.WE = ex;
            wife.ability_w_value = ability*p.sigma[3];
            const auto wage = calculate_wage_w(p, wife, no_wage_prob, epsilon_for_test);
            table.add(std::to_string(school_group));
            table.add(std::to_string(ex));
            table.add(to_string_with_precision(ability, 3));
            table.add(to_string_with_precision(wage, 0));
            table.endOfRow();
          }
        }
      }
      std::cout  << std::endl << table << std::endl;
    }
};

