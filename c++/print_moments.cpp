#include "print_moments.h"
#include <iostream>
#include <numeric>
#include "cpp-text-table/TextTable.h"
#include <sstream>

const std::string& school_to_string(int school_group) {
    return SCHOOL_NAMES[school_group];
}

TextTable make_table() {
    return TextTable(' ');
}


// based on: 
// https://stackoverflow.com/questions/16605967/set-precision-of-stdto-string-when-converting-floating-point-values
std::string to_string_with_precision(double a_value, int n = 3)
{
    std::ostringstream out;
    out.precision(n);
    out << std::fixed << a_value;
    return out.str();
}

void print_mean_array(const std::string& table_name, const SchoolingMeanArray& m) {
    TextTable table_headline;
    table_headline.add(table_name);
    table_headline.endOfRow();

    TextTable table = make_table();
    // header
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(school_to_string(school_group));
    }
    table.endOfRow();
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(m.mean(school_group)));
    }
    table.endOfRow();

    std::cout << std::endl << table_headline;
    std::cout << table;
}

void print_mean_table(const std::string& table_name, const SchoolingMeanMatrix& m) {
    TextTable table_headline;
    table_headline.add(table_name);
    table_headline.endOfRow();

    TextTable table = make_table();
    // header
    table.add("Time");
    for (auto school_group : SCHOOL_H_VALUES) {
        table.add(school_to_string(school_group));
    }
    table.endOfRow();
    // rows
    for (auto t = 0U; t < T_MAX; ++t) {
        table.add(std::to_string(t+1));
        for (auto school_group : SCHOOL_H_VALUES) {
            table.add(to_string_with_precision(m.mean(t, school_group)));
        }
        table.endOfRow();
    }
    std::cout << std::endl << table_headline;
    std::cout << table;
}

void print_wage_moments(const WageMoments& estimated, const WageMoments& actual) {
    const auto max_t = std::max((size_t)T_MAX, WAGE_MOM_ROW);
    auto col_offset = 0U;
    {
        TextTable table_headline;
        table_headline.add("Wage Moments - Women");
        table_headline.endOfRow();

        TextTable table = make_table();
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Experience");
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(school_to_string(school_group));
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(school_to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < max_t; ++t) {
            table.add(std::to_string((unsigned)actual[t][0]));
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(estimated[t][i+col_offset]));
            }
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl <<  table_headline;
        std::cout << table;
        col_offset += SCHOOL_LEN-1;
    }
    {
        TextTable table_headline;
        table_headline.add("Wage Moments - Married Men");
        table_headline.endOfRow();

        TextTable table = make_table();
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Experience");
        for (auto school_group : SCHOOL_H_VALUES) {
            table.add(school_to_string(school_group));
        }
        for (auto school_group : SCHOOL_H_VALUES) {
            table.add(school_to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < max_t; ++t) {
            table.add(std::to_string((unsigned)actual[t][0]));
            for (auto i = 0U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(estimated[t][i+col_offset]));
            }
            for (auto i = 0U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl << table_headline;
        std::cout << table;
    }
}

void print_emp_moments(const EmpMoments& estimated, const EmpMoments& actual) {
    const std::vector<std::string> moment_name = {"Total", "Married", "Unmarried"};
    auto col_offset = 0U;
    for (const auto& name : moment_name) {
        TextTable table_headline;
        table_headline.add("Employment Moments - " + name);
        table_headline.endOfRow();

        TextTable table = make_table();
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Age");
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(school_to_string(school_group));
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(school_to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < EMP_MOM_ROW; ++t) {
            table.add(std::to_string((unsigned)estimated[t][0]));
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(estimated[t][i+col_offset]));
            }
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl << table_headline;
        std::cout << table;
        col_offset += SCHOOL_LEN-1;
    }
}

void print_marr_moments(const MarrMoments& estimated, const MarrMoments& actual) {
    const std::vector<std::string> moment_name = {"Marriage", "Fertility", "Divorce"};
    auto col_offset = 0U;
    for (const auto& name : moment_name) {
        TextTable table_headline;
        table_headline.add(name + " Moments");
        table_headline.endOfRow();

        TextTable table = make_table();
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Age");
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(school_to_string(school_group));
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(school_to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < MARR_MOM_ROW; ++t) {
            table.add(std::to_string((unsigned)estimated[t][0]));
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(estimated[t][i+col_offset]));
            }
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(to_string_with_precision(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl << table_headline;
        std::cout << table;
        col_offset += SCHOOL_LEN-1;
    }
}

void print_gen_moments(const GenMoments& estimated, const GenMoments& actual) {
    TextTable table_headline;
    table_headline.add("General Moments");
    table_headline.endOfRow();

    TextTable table = make_table();
    // header
    table.add("");table.add("");
    table.add("Estimated");table.add("");table.add("");table.add("");
    table.add("Actual");table.add("");table.add("");table.add("");
    table.endOfRow();
    table.add("");
    table.add("Moment");
    // estimated and actual columns
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(school_to_string(school_group));
    }
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(school_to_string(school_group));
    }
    table.endOfRow();

    // rows
    for (auto i = 0U; i < GEN_MOM_ROW; ++i) {
        table.add(std::to_string(i+1));
        table.add(GenMomentsDescription[i]);
        for (auto j = 0U; j < GEN_MOM_COL; ++j) {
            table.add(to_string_with_precision(estimated[i][j]));
        }
        for (auto j = 0U; j < GEN_MOM_COL; ++j) {
            table.add(to_string_with_precision(actual[i][j]));
        }
        table.endOfRow();
    }

    std::cout << std::endl << table_headline;
    std::cout << table;
}

void print_up_down_moments(const UpDownMoments& m) {
    TextTable table_headline;
    table_headline.add("Married Up/Down/Equal Moments");
    table_headline.endOfRow();

    TextTable table = make_table();
    // header
    table.add("Moment");
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(school_to_string(school_group));
    }
    table.endOfRow();

    // rows
    for (auto row = 0U; row < UP_DOWN_MOM_ROW; ++row) {
        table.add(UpDownMomentsDescription[row]);
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(to_string_with_precision(m.mean(row, school_group)));
        }
        table.endOfRow();
    }
    std::cout << std::endl << table_headline;
    std::cout << table;
}

