#include "parameters.h"
#include "cpp-text-table/TextTable.h"
#include <iostream>

#define ADD_PARAM(name, description) table.add(#name); table.add(std::to_string(p.name)); table.add(description); table.endOfRow();

void print_parameters(const Parameters& p) {
  TextTable table_headline('-', '|', '+' );
  table_headline.add("Parameters");
  table_headline.endOfRow();

  TextTable table('-', '|', '+');
  // header
  table.add("Name");
  table.add("Value");
  table.add("Description");
  table.endOfRow();
  // rows
  ADD_PARAM(alpha, "CRRA income parameter");
  ADD_PARAM(alpha1_w_m, "women utility from children when married");
  ADD_PARAM(alpha1_w_s, "women utility from children when single");
  ADD_PARAM(alpha1_h_m, "men utility from children when maarried");
  ADD_PARAM(alpha2_w, "utility from leisure as a function of number of children");
  ADD_PARAM(alpha3_w, "utility from leisure");
  ADD_PARAM(beta11_w, "wife wage by experience HSG");
  ADD_PARAM(beta12_w, "wife wage by experience SC");
  ADD_PARAM(beta13_w, "wife wage by experience CG");
  ADD_PARAM(beta14_w, "wife wage by experience PC");
  ADD_PARAM(beta21_w, "wife wage by experience^2 HSG");
  ADD_PARAM(beta22_w, "wife wage by experience^2 SC");
  ADD_PARAM(beta23_w, "wife wage by experience^2 CG");
  ADD_PARAM(beta24_w, "wife wage by experience^2 PC");
  ADD_PARAM(beta10_h, "husband wage by experience HSD");
  ADD_PARAM(beta11_h, "husband wage by experience HSG");
  ADD_PARAM(beta12_h, "husband wage by experience SC");
  ADD_PARAM(beta13_h, "husband wage by experience CG");
  ADD_PARAM(beta14_h, "husband wage by experience PC");
  ADD_PARAM(beta20_h, "husband wage by experience^2 HSD");
  ADD_PARAM(beta21_h, "husband wage by experience^2 HSG");
  ADD_PARAM(beta22_h, "husband wage by experience^2 SC");
  ADD_PARAM(beta23_h, "husband wage by experience^2 CG");
  ADD_PARAM(beta24_h, "husband wage by experience^2 PC");
  std::cout << std::endl;
  std::cout << table_headline;
  std::cout << table;
}

