#include <cxxtest/TestSuite.h>
#include "nash.h"

class marriage_decision_suite : public CxxTest::TestSuite {
public:
	void testAddition( void ) {
    	TS_ASSERT( 1 + 1 > 1 );
        TS_ASSERT_EQUALS( 1 + 1, 2 );
    }
};

