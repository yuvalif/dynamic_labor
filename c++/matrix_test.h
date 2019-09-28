#include <cxxtest/TestSuite.h>
#include "matrix.h"

class matrix_suite : public CxxTest::TestSuite {
public:
	void test_diff() {
    }

	void test_square_diff() {
    }
	
    void test_divide() {
    }
	
    void test_divide_by_square() {
    }

	void test_MeanMatrix() {
        const auto ROWS = 10;
        const auto COLUMNS = 20;
        MeanMatrix<ROWS, COLUMNS> m;
        for (auto i = 0; i < ROWS; ++i) {
            for (auto j = 0; j < COLUMNS; ++j) {
                for (auto k = 0; k < 100; ++k) {
                    m.accumulate(i, j, k);
                }
            }
        }

        for (auto i = 0; i < ROWS; ++i) {
            for (auto j = 0; j < COLUMNS; ++j) {
                TS_ASSERT_EQUALS(m.mean(i, j), 49.5);
            }
        }
    }
};

