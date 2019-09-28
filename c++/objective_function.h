#pragma once

class Parameters;
class Moments;

double objective_function(const Parameters& p, const Moments& m, bool display_moments, bool no_emax);

