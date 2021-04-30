#include <cxxtest/TestSuite.h>
#include "random_pools.h"
#include <cmath>
#include <boost/accumulators/accumulators.hpp>
#include <boost/accumulators/statistics.hpp>

using namespace boost::accumulators;

class random_pools_suite : public CxxTest::TestSuite {
  public:
    constexpr static const auto NUMBER_OR_RUNS = 300000U;
    constexpr static const auto EPS = 0.01;

    void test_epsilon() {
      accumulator_set<double, features<tag::mean, tag::variance>> acc;
      for (auto i = 0U; i < NUMBER_OR_RUNS; ++i) {
        acc(epsilon());
      }
      TS_ASSERT_LESS_THAN(fabs(mean(acc)), EPS);
      TS_ASSERT_LESS_THAN(fabs(variance(acc) - 1.0), EPS);
    }
    void test_draw_3() {
      accumulator_set<double, features<tag::mean, tag::max, tag::min>> acc;
      for (auto i = 0U; i < NUMBER_OR_RUNS; ++i) {
        acc(draw_3());
      }
      TS_ASSERT_LESS_THAN(fabs(mean(acc) - 1.0), EPS);
      TS_ASSERT_EQUALS(max(acc), 2);
      TS_ASSERT_EQUALS(min(acc), 0);
    }
    void test_draw_p() {
      accumulator_set<double, features<tag::mean, tag::max, tag::min>> acc;
      for (auto i = 0U; i < NUMBER_OR_RUNS; ++i) {
        acc(draw_p());
      }
      TS_ASSERT_LESS_THAN(fabs(mean(acc) - 0.5), EPS);
      TS_ASSERT_LESS_THAN(1.0 - max(acc), EPS);
      TS_ASSERT_LESS_THAN(min(acc), EPS);
    }
};

