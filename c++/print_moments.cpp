#include "print_moments.h"
#include <iostream>
#include <numeric>
#include "cpp-text-table/TextTable.h"

void print_mean_array(const std::string& table_name, const SchoolingMeanArray& m) {
    TextTable table_headline('-', '|', '+' );
    table_headline.add(table_name);
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group+1, TextTable::Alignment::RIGHT);
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
    TextTable table_headline('-', '|', '+' );
    table_headline.add(table_name);
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    table.add("Time");
    for (auto school_group : SCHOOL_H_VALUES) {
        table.add(std::to_string(school_group));
        table.setAlignment(school_group+1, TextTable::Alignment::RIGHT);
    }
    table.endOfRow();
    // rows
    for (auto t = 0U; t < T_MAX; ++t) {
        table.add(std::to_string(t+1));
        for (auto school_group : SCHOOL_H_VALUES) {
            table.add(std::to_string(m.mean(t, school_group)));
        }
        table.endOfRow();
    }
    std::cout << std::endl << table_headline;
    std::cout << table;
}

void print_wage_moments(const WageMoments& m, bool estimated) {
    TextTable table_headline('-', '|', '+' );
    if (estimated) {
        table_headline.add("Estimated Wage Moments");
    } else {
        table_headline.add("Actual Wage Moments");
    }
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    table.add(" ");
    table.add("Women");table.add(" ");table.add(" ");table.add(" ");
    table.add("Married Men");table.add(" ");table.add(" ");table.add(" ");table.add(" ");
    table.endOfRow();
    table.add("Experience");
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group, TextTable::Alignment::RIGHT);
    }
    for (auto school_group : SCHOOL_H_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group+5, TextTable::Alignment::RIGHT);
    }
    table.endOfRow();
    // rows
    const auto max_t = estimated ? T_MAX : WAGE_MOM_ROW;
    for (auto t = 0U; t < max_t; ++t) {
        table.add(std::to_string(m[t][0]+1));
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(m[t][school_group]));
        }
        for (auto school_group : SCHOOL_H_VALUES) {
            table.add(std::to_string(m[t][school_group+5]));
        }
        table.endOfRow();
    }
    std::cout << std::endl << table_headline;
    std::cout << table;
}

void print_emp_moments(const EmpMoments& m, bool estimated) {
    TextTable table_headline('-', '|', '+' );
    if (estimated) {
        table_headline.add("Estimated Employment Moments");
    } else {
        table_headline.add("Actual Employment Moments");
    }
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    table.add(" ");
    table.add("Total");table.add(" ");table.add(" ");table.add(" ");
    table.add("Married");table.add(" ");table.add(" ");table.add(" ");
    table.add("Unmarried");table.add(" ");table.add(" ");table.add(" ");
    table.endOfRow();
    table.add("Age");
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group, TextTable::Alignment::RIGHT);
    }
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group+4, TextTable::Alignment::RIGHT);
    }
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group+8, TextTable::Alignment::RIGHT);
    }
    table.endOfRow();
    // rows
    for (auto t = 0U; t < EMP_MOM_ROW; ++t) {
        for (auto col_idx = 0U; col_idx < EMP_MOM_COL; ++col_idx) {
            table.add(std::to_string(m[t][col_idx]));
        }
        table.endOfRow();
    }
    std::cout << std::endl << table_headline;
    std::cout << table;
}

void print_marr_moments(const MarrMoments& m, bool estimated) {
    TextTable table_headline('-', '|', '+' );
    if (estimated) {
        table_headline.add("Estimated Marriage/Fertility Moments");
    } else {
        table_headline.add("Actual Marriage/Fertility Moments");
    }
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    table.add(" ");
    table.add("Marriage");table.add(" ");table.add(" ");table.add(" ");
    table.add("Fertility");table.add(" ");table.add(" ");table.add(" ");
    table.add("Divorce");table.add(" ");table.add(" ");table.add(" ");
    table.endOfRow();
    table.add("Age");
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group, TextTable::Alignment::RIGHT);
    }
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group+4, TextTable::Alignment::RIGHT);
    }
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group+1));
        table.setAlignment(school_group+8, TextTable::Alignment::RIGHT);
    }
    table.endOfRow();

    // rows
    for (auto t = 0U; t < MARR_MOM_ROW; ++t) {
        for (auto col_idx = 0U; col_idx < MARR_MOM_COL; ++col_idx) {
            table.add(std::to_string(m[t][col_idx]));
        }
        table.endOfRow();
    }
    std::cout << std::endl <<  table_headline;
    std::cout << table;
}

void print_gen_moments(const GenMoments& m, bool estimated) {
    TextTable table_headline('-', '|', '+' );
    if (estimated) {
        table_headline.add("Estimated General Moments");
    } else {
        table_headline.add("Actual General Moments");
    }
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    table.add("");
    table.add("Moment");
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group));
        table.setAlignment(school_group, TextTable::Alignment::RIGHT);
    }
    table.endOfRow();

    // rows
    for (auto i = 0U; i < GEN_MOM_ROW; ++i) {
        table.add(std::to_string(i+1));
        table.setAlignment(0, TextTable::Alignment::LEFT);
        table.add(GenMomentsDescription[i]);
        table.setAlignment(1, TextTable::Alignment::LEFT);
        for (auto j = 0U; j < GEN_MOM_COL; ++j) {
            table.add(std::to_string(m[i][j]));
        }
        table.endOfRow();
    }
    std::cout << std::endl <<  table_headline;
    std::cout << table;
}

