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

void print_wage_moments(const WageMoments& estimated, const WageMoments& actual) {
    const auto max_t = std::max((size_t)T_MAX, WAGE_MOM_ROW);
    auto col_offset = 0U;
    {
        TextTable table_headline('-', '|', '+' );
        table_headline.add("Employment Moments - Women");
        table_headline.endOfRow();

        TextTable table('-', '|', '+');
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Experience");
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(school_group));
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < max_t; ++t) {
            table.add(std::to_string((unsigned)actual[t][0]));
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(estimated[t][i+col_offset]));
            }
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl <<  table_headline;
        std::cout << table;
        col_offset += SCHOOL_LEN-1;
    }
    {
        TextTable table_headline('-', '|', '+' );
        table_headline.add("Employment Moments - Married Men");
        table_headline.endOfRow();

        TextTable table('-', '|', '+');
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Experience");
        for (auto school_group : SCHOOL_H_VALUES) {
            table.add(std::to_string(school_group));
        }
        for (auto school_group : SCHOOL_H_VALUES) {
            table.add(std::to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < max_t; ++t) {
            table.add(std::to_string((unsigned)actual[t][0]));
            for (auto i = 0U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(estimated[t][i+col_offset]));
            }
            for (auto i = 0U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl <<  table_headline;
        std::cout << table;
    }
}

void print_emp_moments(const EmpMoments& estimated, const EmpMoments& actual) {
    const std::vector<std::string> moment_name = {"Total", "Married", "Unmarried"};
    auto col_offset = 0U;
    for (const auto& name : moment_name) {
        TextTable table_headline('-', '|', '+' );
        table_headline.add("Employment Moments - " + name);
        table_headline.endOfRow();

        TextTable table('-', '|', '+');
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Age");
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(school_group));
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < EMP_MOM_ROW; ++t) {
            table.add(std::to_string((unsigned)estimated[t][0]));
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(estimated[t][i+col_offset]));
            }
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl <<  table_headline;
        std::cout << table;
        col_offset += SCHOOL_LEN-1;
    }
}

void print_marr_moments(const MarrMoments& estimated, const MarrMoments& actual) {
    const std::vector<std::string> moment_name = {"Marriage", "Fertility", "Divorce"};
    auto col_offset = 0U;
    for (const auto& name : moment_name) {
        TextTable table_headline('-', '|', '+' );
        table_headline.add(name + " Moments");
        table_headline.endOfRow();

        TextTable table('-', '|', '+');
        // header
        table.add("");
        table.add("Estimated");table.add("");table.add("");table.add("");
        table.add("Actual");table.add("");table.add("");table.add("");
        table.endOfRow();
        table.add("Age");
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(school_group));
        }
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(school_group));
        }
        table.endOfRow();

        // rows
        for (auto t = 0U; t < MARR_MOM_ROW; ++t) {
            table.add(std::to_string((unsigned)estimated[t][0]));
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(estimated[t][i+col_offset]));
            }
            for (auto i = 1U; i < SCHOOL_LEN; ++i) {
                table.add(std::to_string(actual[t][i+col_offset]));
            }
            table.endOfRow();
        }
        std::cout << std::endl <<  table_headline;
        std::cout << table;
        col_offset += SCHOOL_LEN-1;
    }
}

void print_gen_moments(const GenMoments& estimated, const GenMoments& actual) {
    TextTable table_headline('-', '|', '+' );
    table_headline.add("General Moments");
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    table.add("");table.add("");
    table.add("Estimated");table.add("");table.add("");table.add("");
    table.add("Actual");table.add("");table.add("");table.add("");
    table.endOfRow();
    table.add("");
    table.add("Moment");
    // estimated and actual columns
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group));
    }
    table.add("");
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group));
    }
    table.endOfRow();

    // rows
    for (auto i = 0U; i < GEN_MOM_ROW; ++i) {
        table.add(std::to_string(i+1));
        table.add(GenMomentsDescription[i]);
        for (auto j = 0U; j < GEN_MOM_COL; ++j) {
            table.add(std::to_string(estimated[i][j]));
        }
        for (auto j = 0U; j < GEN_MOM_COL; ++j) {
            table.add(std::to_string(actual[i][j]));
        }
        table.endOfRow();
    }
    // table alignment
    table.setAlignment(0, TextTable::Alignment::LEFT);
    table.setAlignment(1, TextTable::Alignment::LEFT);
    for (auto school_group : SCHOOL_W_VALUES) {
        table.setAlignment(school_group + 1, TextTable::Alignment::RIGHT);
        table.setAlignment(school_group + 6, TextTable::Alignment::RIGHT);
    }

    std::cout << std::endl <<  table_headline;
    std::cout << table;
}

void print_up_down_moments(const UpDownMoments& m) {
    TextTable table_headline('-', '|', '+' );
    table_headline.add("Married Up/Down/Equal Moments");
    table_headline.endOfRow();

    TextTable table('-', '|', '+');
    // header
    table.add("Moment");
    for (auto school_group : SCHOOL_W_VALUES) {
        table.add(std::to_string(school_group));
        table.setAlignment(school_group, TextTable::Alignment::RIGHT);
    }
    table.endOfRow();

    // rows
    for (auto row = 0U; row < UP_DOWN_MOM_ROW; ++row) {
        table.setAlignment(0, TextTable::Alignment::LEFT);
        table.add(UpDownMomentsDescription[row]);
        table.setAlignment(1, TextTable::Alignment::LEFT);
        for (auto school_group : SCHOOL_W_VALUES) {
            table.add(std::to_string(m.mean(row, school_group)));
        }
        table.endOfRow();
    }
    std::cout << std::endl <<  table_headline;
    std::cout << table;
}

