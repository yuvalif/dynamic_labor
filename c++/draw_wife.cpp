#include <assert.h>
#include "draw_wife.h"
#include "parameters.h"
#include "const_parameters.h"
#include "random_pools.h"

bool update_wife_schooling(unsigned WS, unsigned t, Wife& wife) {
  // T_END is used together with the t index which get values 0-26
  wife.WS = WS;
  wife.AGE = AGE_VALUES[WS] + t;
  wife.age_index = AGE_INDEX_VALUES[WS];
  wife.T_END = TERMINAL - AGE_VALUES[WS] - 1;
  if (WS == 1) {
    wife.HSG = 1;
    wife.SC = 0; wife.CG = 0; wife.PC = 0;
  } else if (WS == 2) {
    wife.SC = 1;
    wife.HSG = 0; wife.CG = 0; wife.PC = 0;
  } else if (WS == 3) {
    wife.CG = 1;
    wife.HSG = 0; wife.SC = 0; wife.PC = 0;
  } else if (WS == 4) {
    wife.PC = 1;
    wife.HSG = 0; wife.SC = 0; wife.CG = 0;
  } else {
    assert(false);
  }
  if (t > wife.T_END) {
    return false;
  }
  return true;
}

void update_ability(const Parameters& p, unsigned ability, Wife& wife) {
  wife.ability_wi = ability;
  wife.ability_w_value = normal_arr[ability]*p.sigma[3];
}

Wife draw_wife(const Parameters& p, unsigned t, unsigned age_index, unsigned HS) {
  Wife result;
  result.Q_INDEX = draw_3();
  result.Q = normal_arr[result.Q_INDEX]*p.sigma[4];
  update_ability(p, draw_3(), result);

  const auto& wives_arr = p.wives[t+age_index];

  const auto prob = draw_p();

  // find the first index in the wife array that is not less than the probability
  // note: first column of the wife matrix is skipped since it is just an index, hence the: "+1"
  const auto wives_arr_begin = wives_arr.begin()+1;
  const auto index = std::lower_bound(wives_arr_begin, wives_arr.end(), prob) - wives_arr_begin;

  // index will be in the range: 0-39 
  assert(index < 40);

  // wife schooling is in the range: 1-4
  result.WS = index/10 + 1;
  assert(result.WS < 5 && result.WS > 0);

  result.WE = exp_vector[index%5];

  // [0,4]->0, [5,9]->1, [10,14]->0, [15-19]->1, etc.
  result.emp_state = (index/5)%2; 
  assert(result.emp_state == EMP || result.emp_state == UNEMP);

  if (result.WS == HS) {
    result.similar_educ = p.EDUC_MATCH[HS];
  }

  return result;
}

#include <iostream>

void print_wife(const Wife& wife) {
  std::cout << "Wife " << std::endl;
  std::cout << "\tSchooling: " << wife.WS << std::endl;
  std::cout << "\tSchooling Map: " << wife.HSD << " " << wife.HSG << " " << wife.SC << " " << wife.CG << " " << wife.PC << std::endl;
  std::cout << "\tExperience: " << wife.WE << std::endl;
  std::cout << "\tAbility: (" << wife.ability_wi << ", " << wife.ability_w_value << ")" << std::endl;
  std::cout << "\tMatch Quality: (" << wife.Q_INDEX << ", " << wife.Q << ")" << std::endl;
  std::cout << "\tAge: " << wife.AGE << std::endl;
  std::cout << "\tLast Period: " << wife.T_END << std::endl;
}

