#include <fstream>
#include <iostream>
#include "emax.h"

#ifdef USE_MULTI_ARRAY
Emax make_emax() {
    return Emax(boost::extents[T_MAX][EXP_LEN][EXP_LEN][KIDS_LEN][PREV_WORK_LEN][ABILITY_LEN][ABILITY_LEN][MARITAL_LEN][SCHOOL_LEN][SCHOOL_LEN][MATCH_Q_LEN][BP_W_LEN]);
}
#else
Emax make_emax() {
    return std::make_unique<float[]>(T_MAX*EXP_W_LEN*EXP_H_LEN*KIDS_LEN*PREV_WORK_LEN*ABILITY_LEN*ABILITY_LEN*MARITAL_LEN*SCHOOL_LEN*SCHOOL_LEN*MATCH_Q_LEN*BP_W_LEN);
}

float& get(Emax& e, unsigned t, unsigned _exp_w, unsigned _exp_h, unsigned _kids, unsigned _prev_w, 
	unsigned _ability_w, unsigned _ability_h, unsigned _marr, unsigned _school_h, unsigned _school_w, unsigned _match, unsigned _BP_W) {
	return e[((((((((((t*EXP_W_LEN + _exp_w)*EXP_H_LEN + _exp_h)*KIDS_LEN + _kids)*PREV_WORK_LEN + _prev_w)*ABILITY_LEN + _ability_w)*ABILITY_LEN + _ability_h)*MARITAL_LEN + 
                        _marr)*SCHOOL_LEN + _school_h)*SCHOOL_LEN + _school_w)*MATCH_Q_LEN + _match)*BP_W_LEN + _BP_W];
}

float get(const Emax& e, unsigned t, unsigned _exp_w, unsigned _exp_h, unsigned _kids, unsigned _prev_w, 
	unsigned _ability_w, unsigned _ability_h, unsigned _marr, unsigned _school_h, unsigned _school_w, unsigned _match, unsigned _BP_W) {
	return e[((((((((((t*EXP_W_LEN + _exp_w)*EXP_H_LEN + _exp_h)*KIDS_LEN + _kids)*PREV_WORK_LEN + _prev_w)*ABILITY_LEN + _ability_w)*ABILITY_LEN + _ability_h)*MARITAL_LEN + 
                        _marr)*SCHOOL_LEN + _school_h)*SCHOOL_LEN + _school_w)*MATCH_Q_LEN + _match)*BP_W_LEN + _BP_W];
}
#endif

void dump_emax(const std::string& filename, const Emax& emax) {
  std::ofstream file(filename);
  if (!file.is_open()) {
    throw std::runtime_error("failed to open: '" + filename + "'");
  }

  std::cout << "dumping emax to: " << filename << std::endl;
  for (auto t = 0U; t < T_MAX; ++t) {
    for (auto w_exp = 0U; w_exp < EXP_LEN; ++w_exp) {
      for (auto h_exp = 0U; h_exp < EXP_LEN; ++h_exp) {
        for (auto kids = 0U; kids < KIDS_LEN; ++kids) {
          for (auto work : {UNEMP, EMP}) {
            for (auto w_ability = 0U; w_ability < ABILITY_LEN; ++w_ability) {
              for (auto h_ability = 0U; h_ability < ABILITY_LEN; ++h_ability) {
                for (auto marital : {UNMARRIED, MARRIED}) {
                  for (auto h_school = 0U; h_school < SCHOOL_LEN; ++h_school) {
                    for (auto w_school = 0U; w_school < SCHOOL_LEN; ++w_school) {
                      for (auto match_q = 0U; match_q < MATCH_Q_LEN; ++match_q) {
                        for (auto bp = 0U; bp < BP_W_LEN; ++bp) {
                          file << t << "," << w_exp << "," << h_exp << "," << kids << "," << work << "," << 
                            w_ability << "," << h_ability << "," << marital << "," << h_school << "," << w_school << "," << match_q << "," <<
                            emax[t][w_exp][h_exp][kids][work][w_ability][h_ability][marital][h_school][w_school][match_q][bp] << std::endl;
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
    }
  }
  std:: cout << "finished dumping ema" << std::endl;
}

