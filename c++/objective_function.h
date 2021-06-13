#pragma once

#include <string>

struct Parameters;
struct Moments;
struct MomentsStdev;

// the objective function is estimating the moments based on the input parameters and compare them to the actual moments
// it return a single value that represent the difference between the estimated and actual moments
// the "no_emax" parameter is used to execute the objective functiona statically (all emax values are zero)
// the "display_moments" parameter indicate whether to print the extual and estimated moments
// the "adjust_bp" parameter indicate whether to try and find a better BP if the initial one does not cause marriage
// "verbose" control the level of printing while doing forward processing
// "verbose_emax" control the level of printing while doing backward processing
double objective_function(const Parameters& p, const Moments& m, const MomentsStdev& m_stdev, 
    bool display_moments, bool no_emax, bool adjust_bp, bool verbose, bool verbose_emax, const std::string& prefix, bool infile, bool outfile);

