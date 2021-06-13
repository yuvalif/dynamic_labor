#include "parameters.h"
#include "moments.h"
#include "objective_function.h"
#include "load_files.h"
#include <iostream>
#include <stdexcept>
#include "argh/argh.h"

int main(int argc, char* argv[]) {
  argh::parser cmdl(argv);

  if (cmdl[{"-h", "--help"}]) {
    std::cout << "Usage: " << cmdl[0] << " [OPTIONS]" << std::endl;
    std::cout << "\t-m, --moments\t\tPrint moment matrixes and other output. Should be used when running manually (default to FALSE)" << std::endl;
    std::cout << "\t-v, --verbose\t\tPrint verbose information during the execution of the simulation, as well as moment matrixes.  Should be used when running manually (default to FALSE)" << std::endl;
    std::cout << "\t--verbose-emax\t\tPrint verbose information during the emax calcuilation.  Should be used when running manually (default to FALSE)" << std::endl;
    std::cout << "\t-s, --static\t\tRun static mode, do not caluclate emax. (default to FALSE)" << std::endl;
    std::cout << "\t-d, --data-dir=DATA_DIR\tLocation of input files. (default to ../../)" << std::endl;
    std::cout << "\t-a, --adjust\t\tAdjust bargaining power. (default to FALSE)" << std::endl;
    std::cout << "\t-o, --out\t\tDumpt emax to file. File prefix can be given. File names would be '<prefix>_women.csv' and <prefix>_men.csv" << std::endl;
    std::cout << "\t-i, --in\t\tRead emax from file. File prefix can be given. File names would be '<prefix>_women.csv' and <prefix>_men.csv" << std::endl;
    std::cout << "\t-h, --help\t\tPrint this message" << std::endl;
    return 0;
  }
  const auto verbose = cmdl[{"-v", "--verbose"}];
  const auto verbose_emax = cmdl[{"--verbose-emax"}];
  const auto moments = (cmdl[{"-m", "--moments"}] || verbose);
  const auto no_emax = cmdl[{"-s", "--static"}];
  const auto adjust_bp = cmdl[{"-a", "--adjust"}];
  std::string data_dir("../../");
  if (cmdl[{"-d", "--data-dir"}]) {
    cmdl({"-d", "--data-dir"}) >> data_dir;
  }
  const auto infile = cmdl[{"-i", "--in"}];
  const auto outfile = cmdl[{"-o", "--out"}];
  if ((infile || outfile) && no_emax) {
    std::cerr << "static run cannot create or consume emax" << std::endl;
    return 1;
  }
  if (infile && outfile) { 
    std::cerr << "cannot provide both infile and outfile" << std::endl;
    return 1;
  }
  std::string prefix;
  if (infile) {
    cmdl({"-i", "--in"}) >> prefix;
  }
  if (outfile) {
    cmdl({"-o", "--out"}) >> prefix;
  }
  const auto p = load_parameters(data_dir+"init_parameters.txt", 
      data_dir+"tax_brackets.out", 
      data_dir+"deductions_exemptions.out", 
      data_dir+"wives.out", data_dir+"husbands");
  const auto m = load_moments(data_dir+"wage_moments.txt", 
      data_dir+"marr_fer_moments.txt", 
      data_dir+"emp_moments.txt", 
      data_dir+"general_moments.txt");
  const auto m_stdev = load_moments_stdev(data_dir+"wage_moments_stdev.txt", 
      data_dir+"marr_fer_moments_stdev.txt", 
      data_dir+"emp_moments_stdev.txt", 
      data_dir+"general_moments_stdev.txt");
  const double f = objective_function(p, m, m_stdev, moments, no_emax, adjust_bp, verbose, verbose_emax, prefix, infile, outfile);
  std::cout << "state space = " << T_MAX*EXP_LEN*EXP_LEN*KIDS_LEN*WORK_LEN*ABILITY_LEN*ABILITY_LEN*MARITAL_LEN*(SCHOOL_LEN-1)*SCHOOL_LEN*MATCH_Q_LEN*BP_W_LEN*2 << std::endl;
  std::cout << "objective function = " << f << std::endl;

  return 0;
}

