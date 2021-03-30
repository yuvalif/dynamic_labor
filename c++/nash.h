#pragma once

struct Parameters;
struct Utility;

// find the BP value that has the maximum nash value
// this function is used to find the initial BP of the couple
double nash(const Parameters& p, const Utility& utility);

