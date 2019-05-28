cmake_minimum_required(VERSION 3.0)

project (dynamic_labor)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(dynamic_labor 
    random_pools.cpp 
    nash.cpp 
    draw_wife.cpp 
    gross_to_net.cpp 
    calculate_wage.cpp 
    value_to_index.cpp 
    calculate_utility.cpp
    marriage_decision.cpp
    single_men.cpp
    )
set_target_properties(dynamic_labor PROPERTIES CXX_STANDARD 17)
add_executable (dynamic_labor_run dynamic_labor.cpp)
target_link_libraries (dynamic_labor_run dynamic_labor)

