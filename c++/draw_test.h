#include <cxxtest/TestSuite.h>
#include "draw_husband.h"
#include "draw_wife.h"

class draw_h_suite : public CxxTest::TestSuite {
  public:
    void testAddition( void ) {
      TS_ASSERT( 1 + 1 > 1 );
      TS_ASSERT_EQUALS( 1 + 1, 2 );
    }
};

class draw_w_suite : public CxxTest::TestSuite {
  public:
    void testAddition( void ) {
      TS_ASSERT( 1 + 1 > 1 );
      TS_ASSERT_EQUALS( 1 + 1, 2 );
    }
};

