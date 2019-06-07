#pragma once

class Parameters;
class Utility;

// return bargaining power based on current bargaining power and utility
double nash(const Parameters& p, const Utility& utility, double BP);

