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
        std::cout << "\t-v, --verbose\t\tPrint moment matrixes and other output. Should be used when running manually (default to FALSE)" << std::endl;
        std::cout << "\t-s, --static\t\tRun static mode, do not caluclate emax. (default to FALSE)" << std::endl;
        std::cout << "\t-d, --data-dir=DATA_DIR\tLocation of input files. (default to ../../)" << std::endl;
        std::cout << "\t-h, --help\t\tPrint this message" << std::endl;
        return 0;
    }
    const auto verbose = cmdl[{"-v", "--verbose"}];
    const auto no_emax = cmdl[{"-s", "--static"}];
    std::string data_dir("../../");
    if (cmdl[{"-d", "--data-dir"}]) {
        cmdl({"-d", "--data-dir"}) >> data_dir;
    }
    const auto p = load_parameters(data_dir+"init_parameters.txt", data_dir+"tax_brackets.out", data_dir+"deductions_exemptions.out", data_dir+"wives.out", data_dir+"husbands");
    const auto m = load_moments(data_dir+"wage_moments.txt", data_dir+"marr_fer_moments.txt", data_dir+"emp_moments.txt", data_dir+"general_moments.txt");
    const double f = objective_function(p, m, verbose, no_emax);
    std::cout << "objective function = " << f << std::endl;

    return 0;
}

