#include <random>
#include <boost/preprocessor/slot/counter.hpp>

// seed values: (BOOST_PP_COUNTER) should be incremented for each new function

double epsilon() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::normal_distribution<> dis(0, 1);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

int h_draw_3() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::uniform_int_distribution<> dis(1, 3);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

int w_draw_2() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::uniform_int_distribution<> dis(1, 2);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

int w_draw_3() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::uniform_int_distribution<> dis(1, 3);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

int h_draw_5() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::uniform_int_distribution<> dis(1, 5);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

int w_draw_5() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::uniform_int_distribution<> dis(1, 5);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

int h_draw_p() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::uniform_real_distribution<> dis(0.0, 1.0);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

int w_draw_p() {
    static std::mt19937 gen(BOOST_PP_COUNTER); // mersenne_twister_engine seeded constant value
    static std::uniform_real_distribution<> dis(0.0, 1.0);
    return dis(gen);
}
#include BOOST_PP_UPDATE_COUNTER()

