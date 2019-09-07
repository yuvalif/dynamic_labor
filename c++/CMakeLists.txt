cmake_minimum_required(VERSION 3.0)

project(dynamic_labor)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Werror -Wno-sign-compare -O3 -ffast-math")
#set(CMAKE_BUILD_TYPE Debug)

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
    marriage_decision.cpp
    single_men.cpp
    single_women.cpp
    married_couple.cpp
    load_files.cpp
    objective_function.cpp
    )

set_target_properties(dynamic_labor PROPERTIES CXX_STANDARD 17)
add_executable (dynamic_labor_run dynamic_labor.cpp)
target_link_libraries (dynamic_labor_run dynamic_labor)

# Add "tags" target and make my_project depending on this target.
set_source_files_properties(tags PROPERTIES GENERATED true)
add_custom_target(tags
    COMMAND ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
add_dependencies(dynamic_labor tags)

# TODO: add dynamic_labor_estimate target for automatic model estimation

