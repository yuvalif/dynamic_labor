#include <cxxtest/TestSuite.h>
#include "gross_to_net.h"
#include "parameters.h"
#include "load_files.h"
#include "cpp-text-table/TextTable.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");

class gross_to_net_suite : public CxxTest::TestSuite {
public:
	void test_all_values() {
        TextTable table(' ');
        table.add("Wage Men");
        table.add("Wage Women");
        table.add("Time");
        table.add("Kids");
        table.add("Net S/M");
        table.add("Net S/W");
        table.add("Net Total");
        table.add("Net Total Unemployed");
        table.endOfRow();
        for (auto wage_h = 10000.0; wage_h < 400000.0; wage_h += 40000.0) {
            for (auto wage_w = 0.0; wage_w < 200000.0; wage_w += 40000.0) {
                for (auto t = 0; t < T_MAX; ++t) {
                    for (auto kids : KIDS_VALUES) {
                        for (auto school_group : SCHOOL_W_VALUES) {
                            const auto net = gross_to_net(p, kids, wage_w, wage_h, t, AGE_INDEX_VALUES[school_group]);
                            table.add(std::to_string(wage_h));
                            table.add(std::to_string(wage_w));
                            table.add(std::to_string(t));
                            table.add(std::to_string(kids));
                            table.add(std::to_string(net.net_income_s_h));
                            table.add(std::to_string(net.net_income_s_w));
                            table.add(std::to_string(net.net_income_m));
                            table.add(std::to_string(net.net_income_m_unemp));
                            table.endOfRow();
                        }
                    }
                }
            }
        }
        std::cout  << std::endl << table << std::endl;
    }
};

