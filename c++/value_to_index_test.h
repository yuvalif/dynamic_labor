#include <cxxtest/TestSuite.h>
#include "nash.h"

class value_to_index_suite : public CxxTest::TestSuite {
public:
	void testAddition( void ) {
    	TS_ASSERT( 1 + 1 > 1 );
        TS_ASSERT_EQUALS( 1 + 1, 2 );
    }
};

