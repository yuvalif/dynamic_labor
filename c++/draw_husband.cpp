#include <cassert>
#include <optional>
#include "draw_husband.h"
#include "draw_wife.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

void update_school(unsigned school_group, Husband& husband) {
  husband.HS = school_group;
  husband.age_index = AGE_INDEX_VALUES[school_group];
  husband.T_END = TERMINAL - AGE_VALUES[school_group] - 1;
  // if husband is still at school, experience would be zero
  husband.HE = (husband.AGE >= AGE_VALUES[school_group]) ? husband.AGE - AGE_VALUES[school_group] : 0;

  if (school_group == 0) {
    husband.H_HSD = 1;
    husband.H_HSG = 0; husband.H_SC = 0; husband.H_CG = 0; husband.H_PC = 0;
  } else if (school_group == 1) {
    husband.H_HSG = 1;
    husband.H_HSD = 0; husband.H_SC = 0; husband.H_CG = 0; husband.H_PC = 0;
  } else if (school_group == 2) {
    husband.H_SC = 1;
    husband.H_HSG = 0; husband.H_HSD = 0; husband.H_CG = 0; husband.H_PC = 0;
  } else if (school_group == 3) {
    husband.H_CG = 1;
    husband.H_HSG = 0; husband.H_HSD = 0; husband.H_SC = 0; husband.H_PC = 0;
  } else if (school_group == 4) {
    husband.H_PC = 1;
    husband.H_HSG = 0; husband.H_HSD = 0; husband.H_SC = 0; husband.H_CG = 0;
  } else {
    assert(false);
  }
}

bool update_school_and_age(unsigned school_group, unsigned t, Husband& husband) {
  husband.AGE = AGE_VALUES[school_group] + t;

  update_school(school_group, husband);

  if (t > husband.T_END) {
    return false; 
  }
  return true;
}

void update_school_and_age(unsigned school_group, const Wife& wife, Husband& husband) {
  husband.AGE = wife.AGE;
  update_school(school_group, husband);
}

void update_ability(const Parameters& p, unsigned ability, Husband& husband) {
  husband.ability_hi = ability;
  husband.ability_h_value = normal_arr[ability]*p.sigma[3];
}

Husband draw_husband(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group, unsigned w_school_group) {
  Husband result;
  result.Q_INDEX = draw_3();
  result.Q = normal_arr[result.Q_INDEX]*p.sigma[4];
  update_ability(p, draw_3(), result);

  const Husbands* tmp_husbands;
  if (w_school_group == 1) {
    tmp_husbands = &p.husbands2;
  } else if (w_school_group == 2) {
    tmp_husbands = &p.husbands3;
  } else if (w_school_group == 3) {
    tmp_husbands = &p.husbands4;
  } else {
    tmp_husbands = &p.husbands5;
  }

  const auto& husband_arr = (*tmp_husbands)[t+age_index];

  const auto prob = draw_p();

  // find the first index in the husband array that is not less than the probability
  // note: first column of the husband matrix is skipped since it is just an index, hence the: "+1"
  const auto husband_arr_begin = husband_arr.begin()+1;
  const auto index_iter = std::lower_bound(husband_arr_begin, husband_arr.end(), prob);
  auto index = HUSBANDS_COL-2;
  if (index_iter != husband_arr.end()) {
    index = index_iter - husband_arr_begin;
  }

  // index will be in the range: 0-24 
  assert(index <= HUSBANDS_COL-2);

  // husband schooling is in the range: 0-4
  result.HS = index/5;
  assert(result.HS < 5 && result.HS >= 0);

  return result;
}

#include <iostream>

void print_husband(const Husband& husband) {
  std::cout << "Husband " << std::endl;
  std::cout << "\tSchooling: " << husband.HS << std::endl;
  std::cout << "\tSchooling Map: " << husband.H_HSD << " " << husband.H_HSG << " " << husband.H_SC << " " << husband.H_CG << " " << husband.H_PC << std::endl;
  std::cout << "\tExperience: " << husband.HE << std::endl;
  std::cout << "\tAbility: " << husband.ability_h_value << std::endl;
  std::cout << "\tMatch Quality: " << husband.Q << std::endl;
  std::cout << "\tAge: " << husband.AGE << std::endl;
  std::cout << "\tLast Period: " << husband.T_END << std::endl;
}

