#include <cassert>

unsigned exp_to_index(unsigned exp) {
  // 5 levels grid: 0, 1-2, 3-4, 5-10, 11+
  if (exp == 0)
    return 0;
  else if (exp < 3)  // 1 or 2 years
    return 1;
  else if (exp < 6)  // 3 or 5 years
    return 2;
  else if (exp < 11) // 6 to 10 years
    return 3;
  // above 11 years of experience
  return 4;
}

unsigned bp_to_index(double bp) { 
  assert(bp >=0 && bp <= 1);
  if (bp < 0.2)
    return 0;
  else if (bp < 0.3)
   return 1;
  else if (bp < 0.4)
    return 2;
  else if (bp < 0.5)
    return 3;
  else if (bp < 0.6)
    return 4;
  else if (bp < 0.7)
    return 5;
  else if (bp < 0.8)
    return 6;
 
  // 0.8 <= bp <= 1
  return 7;
}

