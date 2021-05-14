#include <fstream>
#include <iostream>
#include "emax.h"

template<>
SingleWomenEmax make_emax<SingleWomenEmax>() {
  return SingleWomenEmax(boost::extents[T_MAX][EXP_LEN][KIDS_LEN][WORK_LEN][ABILITY_LEN][SCHOOL_LEN]);
}

template<>
SingleMenEmax make_emax<SingleMenEmax>() {
  return SingleMenEmax(boost::extents[T_MAX][ABILITY_LEN][SCHOOL_LEN]);
}

template<>
MarriedEmax make_emax<MarriedEmax>() {
  return MarriedEmax(boost::extents[T_MAX][EXP_LEN][KIDS_LEN][WORK_LEN][ABILITY_LEN][ABILITY_LEN][SCHOOL_LEN][SCHOOL_LEN][MATCH_Q_LEN][BP_W_LEN]);
}

void dump_emax(const std::string& filename, const MarriedEmax& emax) {
  std::ofstream file(filename);
  if (!file.is_open()) {
    throw std::runtime_error("failed to open: '" + filename + "'");
  }

  std::cout << "dumping emax to: " << filename << std::endl;
  for (auto t = 0U; t < T_MAX; ++t) {
    for (auto w_exp = 0U; w_exp < EXP_LEN; ++w_exp) {
      for (auto kids = 0U; kids < KIDS_LEN; ++kids) {
        for (auto work : {UNEMP, EMP}) {
          for (auto w_ability = 0U; w_ability < ABILITY_LEN; ++w_ability) {
            for (auto h_ability = 0U; h_ability < ABILITY_LEN; ++h_ability) {
              for (auto h_school = 0U; h_school < SCHOOL_LEN; ++h_school) {
                for (auto w_school = 1U; w_school < SCHOOL_LEN; ++w_school) {
                  for (auto match_q = 0U; match_q < MATCH_Q_LEN; ++match_q) {
                    for (auto bp = 0U; bp < BP_W_LEN; ++bp) {
                      file << t << "," << w_exp << "," << kids << "," << work << "," << 
                        w_ability << "," << h_ability << "," << h_school << "," << w_school << "," << match_q << "," << bp << "," <<
                        emax[t][w_exp][kids][work][w_ability][h_ability][h_school][w_school][match_q][bp] << std::endl;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  std::cout << "finished dumping emax" << std::endl;
}

void dump_emax(const std::string& filename, const SingleWomenEmax& emax) {
  std::ofstream file(filename);   
  if (!file.is_open()) {
    throw std::runtime_error("failed to open: '" + filename + "'");
  }

  std::cout << "dumping emax to: " << filename << std::endl;
  for (auto t = 0U; t < T_MAX; ++t) {
    for (auto exp = 0U; exp < EXP_LEN; ++exp) {
      for (auto kids = 0U; kids < KIDS_LEN; ++kids) {
        for (auto work : {UNEMP, EMP}) {
          for (auto ability = 0U; ability < ABILITY_LEN; ++ability) {
            for (auto school = 1U; school < SCHOOL_LEN; ++school) {
              file << t << "," << exp << "," << kids << "," << work << "," <<  
                ability << "," << school << "," <<       
                emax[t][exp][kids][work][ability][school] << std::endl;
            }
          }
        }
      }
    }
  }
  std::cout << "finished dumping emax" << std::endl; 
}

void dump_emax(const std::string& filename, const SingleMenEmax& emax) {
  std::ofstream file(filename);   
  if (!file.is_open()) {
    throw std::runtime_error("failed to open: '" + filename + "'");
  }

  std::cout << "dumping emax to: " << filename << std::endl;
  for (auto t = 0U; t < T_MAX; ++t) {
    for (auto ability = 0U; ability < ABILITY_LEN; ++ability) {
      for (auto school = 0U; school < SCHOOL_LEN; ++school) {
        file << t << "," << ability << "," << school << "," <<       
          emax[t][ability][school] << std::endl;
      }
    }
  }
  std::cout << "finished dumping emax" << std::endl; 
}

