#pragma once

// generate normally distributed values with miu=0, sigma=1
double epsilon();

// following should be used in husband draws to make sure
// that code-reordering produce the same values across runs 

// generate uniformly distributed values in {0, 1, 2}
int h_draw_3();
// generate uniformly distributed values in the range [0,1]
double h_draw_p();

// following should be used in wife draws to make sure
// that code-reordering produce the same values across runs 

// generate uniformly distributed values in {0, 1}
int w_draw_2();
// generate uniformly distributed values in {0, 1, 2}
int w_draw_3();
// generate uniformly distributed values in the range [0,1]
double w_draw_p();
