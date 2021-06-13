cmake_minimum_required(VERSION 3.0)

project(dynamic_labor)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Boost REQUIRED)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if(NOT DRAWS)
    set(DRAWS 10)
endif()

set(CMAKE_CXX_FLAGS_RELEASE "-Wall -Werror -Ofast -flto -DDRAWS=${DRAWS} -march=native -DUSE_MULTI_ARRAY")
set(CMAKE_CXX_FLAGS_DEBUG "-Wall -Werror -g3 -O0 -DDRAWS=${DRAWS} -fsanitize=address -fno-omit-frame-pointer -DUSE_MULTI_ARRAY")
set(CMAKE_LINKER_FLAGS_DEBUG "${CMAKE_LINKER_FLAGS_DEBUG} -fsanitize=address")

add_library(dynamic_labor 
    emax.cpp
    random_pools.cpp 
    nash.cpp 
    draw_wife.cpp 
    draw_husband.cpp 
    gross_to_net.cpp 
    calculate_wage.cpp 
    value_to_index.cpp 
    calculate_utility.cpp
    marriage_emp_decision.cpp
    single_men.cpp
    single_women.cpp
    married_couple.cpp
    load_files.cpp
    objective_function.cpp
    print_moments.cpp
    )

set_target_properties(dynamic_labor PROPERTIES CXX_STANDARD 17)
add_executable (dynamic_labor_run dynamic_labor.cpp)
target_link_libraries (dynamic_labor_run dynamic_labor)

set_source_files_properties(tags PROPERTIES GENERATED true)
add_custom_target(tags
    COMMAND ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_dependencies(dynamic_labor tags)

find_package(CxxTest)
if(CXXTEST_FOUND)
    include_directories(${CXXTEST_INCLUDE_DIR})
    enable_testing()
    CXXTEST_ADD_TEST(unittest_calculate_wage calculate_wage_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/calculate_wage_test.h)
    target_link_libraries (unittest_calculate_wage dynamic_labor)
    CXXTEST_ADD_TEST(unittest_calculate_utility calculate_utility_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/calculate_utility_test.h)
    target_link_libraries (unittest_calculate_utility dynamic_labor)
    CXXTEST_ADD_TEST(unittest_nash nash_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/nash_test.h)
    target_link_libraries (unittest_nash dynamic_labor)
    CXXTEST_ADD_TEST(unittest_draw draw_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/draw_test.h)
    CXXTEST_ADD_TEST(unittest_gross_to_net gross_to_net_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/gross_to_net_test.h)
    target_link_libraries (unittest_gross_to_net dynamic_labor)
    CXXTEST_ADD_TEST(unittest_marriage_emp_decision marriage_emp_decision_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/marriage_emp_decision_test.h)
    CXXTEST_ADD_TEST(unittest_matrix matrix_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/matrix_test.h)
    CXXTEST_ADD_TEST(unittest_value_to_index value_to_index_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/value_to_index_test.h)
    CXXTEST_ADD_TEST(unittest_random_pools random_pools_test.cpp ${CMAKE_CURRENT_SOURCE_DIR}/random_pools_test.h)
    target_link_libraries (unittest_random_pools dynamic_labor)
endif()

# TODO: add dynamic_labor_estimate target for automatic model estimation

