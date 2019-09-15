#include <cxxtest/TestSuite.h>
#include "gross_to_net.h"
#include "parameters.h"
#include "load_files.h"

const auto p = load_parameters("../../init_parameters.txt", "../../tax_brackets.out", "../../deductions_exemptions.out", "../../wives.out", "../../husbands");

class gross_to_net_suite : public CxxTest::TestSuite {
public:
	void test_all_values() {

        for (auto wage_h = 10000.0; wage_h < 700000.0; wage_h += 40000.0) {
            for (auto wage_w = 0.0; wage_w < 400000.0; wage_w += 40000.0) {
                const auto tot_income = wage_w + wage_h;
                for (auto t = 0; t < T_MAX; ++t) {
                    for (auto kids : KIDS_VALUES) {
                        for (auto school_group : SCHOOL_W_VALUES) {
                            const auto net = gross_to_net(p, kids, wage_w, wage_h, t, AGE_INDEX_VALUES[school_group]);
                            TS_ASSERT_LESS_THAN_EQUALS(net.net_income_s_w, wage_w*1.4); // net income not more than 40% over income
                            TS_ASSERT_LESS_THAN_EQUALS(net.net_income_s_h, wage_h*1.1); // net income not more than 10% over income
                            TS_ASSERT_LESS_THAN_EQUALS(net.net_income_m, tot_income*1.45); // net income not more than 45% over income
                            TS_ASSERT_LESS_THAN_EQUALS(net.net_income_m_unemp, wage_h*1.45); // net income not more than 45% over income
                            TS_ASSERT_LESS_THAN_EQUALS(wage_w*0.40, net.net_income_s_w); // net income not less than 60% below income
                            TS_ASSERT_LESS_THAN_EQUALS(wage_h*0.25, net.net_income_s_h); // net income not less than 75% below income
                            TS_ASSERT_LESS_THAN_EQUALS(tot_income*0.30, net.net_income_m); // net income not less than 70% below income
                            TS_ASSERT_LESS_THAN_EQUALS(wage_h*0.30, net.net_income_m_unemp); // net income not less than 70% below income
                        }
                    }
                }
            }
        }
    }
};

