#include <iostream>
#include <cxxtest/TestSuite.h>
#include "calculate_utility.h"
#include "draw_wife.h"
#include "draw_husband.h"
#include "parameters.h"
#include "load_files.h"
#include "emax.h"
#include "cpp-text-table/TextTable.h"
#include "to_string.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");
const auto empty_w_s_emax = make_emax<SingleWomenEmax>();
const auto empty_m_s_emax = make_emax<SingleMenEmax>();
const auto empty_married_emax = make_emax<MarriedEmax>();

class calculate_utility_suite : public CxxTest::TestSuite {
  public:
    void test_single_women() {
      TextTable table(' ');
      table.add("Schooling");
      table.add("Time");
      table.add("Wage");
      table.add("Kids");
      table.add("Type");
      table.add("Utility");
      table.endOfRow();

      for (auto school_group : SCHOOL_W_VALUES) {
        for (auto t = 0; t < T_MAX-1; ++t) {
          Wife wife;
          const Husband husband;
          if (!update_wife_schooling(school_group, t, wife)) continue;
          for (auto wage_w = 0.0; wage_w < 400000.0; wage_w += 40000.0) {
            for (auto kids : KIDS_VALUES) {
              const auto u = calculate_utility(p, empty_married_emax, empty_married_emax, 
                  empty_w_s_emax, empty_m_s_emax,
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
              table.add(std::to_string(school_group));
              table.add(std::to_string(t));
              table.add(to_string_with_precision(wage_w, 0));
              table.add(std::to_string(kids));
              table.add("S/W");
              std::stringstream ss;
              for (const auto x : u.U_W_S) ss << (x == MINIMUM_UTILITY ? "null" : 
                  to_string_with_precision(x, 0)) << ", ";
              table.add(ss.str());
              table.endOfRow();
            }
          }
        }
      }
      std::cout  << std::endl << table << std::endl;
    }

    void test_single_men() {
      TextTable table(' ');
      table.add("Schooling");
      table.add("Time");
      table.add("Experience");
      table.add("Ability");
      table.add("Wage");
      table.add("Type");
      table.add("Utility");
      table.endOfRow();

      const Wife wife;
      for (auto school_group : SCHOOL_W_VALUES) {
        for (auto t = 0; t < T_MAX-1; ++t) {
          Husband husband;
          if (!update_husband_schooling(school_group, t, husband)) continue;
          for (auto h_exp_i : EXP_VALUES) { 
            husband.HE = exp_vector[h_exp_i];
            for (auto ability_hi : ABILITY_VALUES) {   
              // husband ability - high, medium, low
              update_ability(p, ability_hi, husband);
              for (auto wage_h = 10000.0; wage_h < 700000.0; wage_h += 40000.0) {
                const auto u = calculate_utility(p, empty_married_emax, empty_married_emax,
                    empty_w_s_emax, empty_m_s_emax,
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
                table.add(std::to_string(school_group));
                table.add(std::to_string(t));
                table.add(std::to_string(h_exp_i));
                table.add(std::to_string(ability_hi));
                table.add(to_string_with_precision(wage_h, 0));
                table.add("S/M");
                std::stringstream ss;
                const auto x = u.U_H_S;
                ss << (x == MINIMUM_UTILITY ? "null" : to_string_with_precision(x, 0)) << ", ";
                table.add(ss.str());
                table.endOfRow();
              }
            }
          }
        }
      }
      std::cout  << std::endl << table << std::endl;
    }

    void test_married_couple() {
      TextTable table(' ');
      table.add("Schooling");
      table.add("Time");
      table.add("Experience");
      table.add("Ability");
      table.add("Wife Wage");
      table.add("Husband Wage");
      table.add("Kids");
      table.add("Type");
      table.add("Utility");
      table.endOfRow();

      for (auto school_group : SCHOOL_W_VALUES) {
        for (auto t = 0; t < T_MAX-1; ++t) {
          Husband husband;
          if (!update_husband_schooling(school_group, t, husband)) continue;
          Wife wife;
          if (!update_wife_schooling(school_group, t, wife)) continue;
          for (auto h_exp_i : EXP_VALUES) { 
            husband.HE = exp_vector[h_exp_i];
            for (auto ability_hi : ABILITY_VALUES) {   
              // husband ability - high, medium, low
              update_ability(p, ability_hi, husband);
              for (auto wage_w = 0.0; wage_w < 400000.0; wage_w += 80000.0) {
                for (auto wage_h = 10000.0; wage_h < 700000.0; wage_h += 80000.0) {
                  for (auto kids : KIDS_VALUES) {
                    const auto u = calculate_utility(p, empty_married_emax, empty_married_emax, 
                        empty_w_s_emax, empty_m_s_emax,
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
                    table.add(std::to_string(school_group));
                    table.add(std::to_string(t));
                    table.add(std::to_string(h_exp_i));
                    table.add(std::to_string(ability_hi));
                    table.add(to_string_with_precision(wage_w, 0));
                    table.add(to_string_with_precision(wage_h, 0));
                    table.add(std::to_string(kids));
                    table.add("S/W");
                    {
                      std::stringstream ss;
                      for (const auto x : u.U_W_S) ss << (x == MINIMUM_UTILITY ? "null" : 
                          to_string_with_precision(x, 0)) << ", ";
                      table.add(ss.str());
                    }
                    table.endOfRow();

                    table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");
                    table.add("S/M");
                    {
                      std::stringstream ss;
                      const auto x = u.U_H_S;
                      ss << (x == MINIMUM_UTILITY ? "null" : 
                          to_string_with_precision(x, 0)) << ", ";
                      table.add(ss.str());
                    }
                    table.endOfRow();

                    table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");
                    table.add("M/W");
                    {
                      std::stringstream ss;
                      for (const auto x : u.U_W) ss << (x == MINIMUM_UTILITY ? "null" :
                          to_string_with_precision(x, 0)) << ", ";
                      table.add(ss.str());
                    }
                    table.endOfRow();

                    table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");table.add(" ");
                    table.add("M/M");
                    {
                      std::stringstream ss;
                      for (const auto x : u.U_H) ss << (x == MINIMUM_UTILITY ? "null" : 
                          to_string_with_precision(x, 0)) << ", ";
                      table.add(ss.str());
                    }
                    table.endOfRow();
                  }
                }
              }
            }
          }
        }
      }
      std::cout << std::endl << table << std::endl;
    }
};

