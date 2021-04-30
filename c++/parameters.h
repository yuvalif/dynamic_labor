#pragma once

#include <array>
#include <vector>
#include <cmath>
#include "matrix.h"

// TODO auto-generate these numbers based on the actual files
const size_t PARAMETER_LIST_LEN = 103;
const size_t TAX_ROW = 56;
const size_t TAX_COL = 43;
const size_t DED_COL = 30;
const size_t WIVES_ROW = 47;
const size_t WIVES_COL = 41;
const size_t HUSBANDS_ROW = 33;
const size_t HUSBANDS_COL = 26;


using ParameterList = std::array<double, PARAMETER_LIST_LEN>;
using TaxBrackets = Matrix<TAX_ROW, TAX_COL>;
using DeductionExceptions = Matrix<TAX_ROW, DED_COL>;
using Wives = Matrix<WIVES_ROW, WIVES_COL>;
using Husbands = Matrix<HUSBANDS_ROW, HUSBANDS_COL>;

struct Parameters {
  // utility parameters
  const double alpha;          // CRRA income parameter 
  const double alpha1_w_m;     // women utility from children when married
  const double alpha1_w_s;     // women utility from children when single
  const double alpha1_h_m;     // men utility from children when maarried
  const double alpha2_w;       // utility from leisure as a function of number of children
  const double alpha3_w;       // utility from leisure
  // wage parameters wife
  const double beta11_w;       // experience 
  const double beta12_w;       // experience 
  const double beta13_w;       // experience 
  const double beta14_w;       // experience 
  const double beta21_w;       // exp^2  
  const double beta22_w;       // exp^2  
  const double beta23_w;       // exp^2  
  const double beta24_w;       // exp^2  
  const double beta31_w;       // HSG - schooling    
  const double beta32_w;       // SC -  schooling    
  const double beta33_w;       // CG -  schooling    
  const double beta34_w;       // PC -  schooling
  // wage parameters husband
  const double beta10_h;       // experience 
  const double beta11_h;       // experience 
  const double beta12_h;       // experience 
  const double beta13_h;       // experience 
  const double beta14_h;       // experience 
  const double beta20_h;       // exp^2
  const double beta21_h;       // exp^2
  const double beta22_h;       // exp^2
  const double beta23_h;       // exp^2
  const double beta24_h;       // exp^2
  const double beta30_h;       // HSD - schooling    
  const double beta31_h;       // HSG- schooling 
  const double beta32_h;       // SC -  schooling    
  const double beta33_h;       // CG -  schooling    
  const double beta34_h;       // PC -  schooling    
  // job offer parameters - wife 
  const double row0_w;         // work in previous period
  const double row11_w;        // HSG -schooling
  const double row12_w;        // SC - schooling
  const double row13_w;        // CG - schooling
  const double row14_w;        // PC - schooling
  const double row2_w;         // work experience
  // home production technology - parameters    
  const double hp;             // sigma CRRA parameter
  // probability of another child parameters    
  const double c1;             // previous work state - wife
  const double c2;             // age wife - HSG
  const double c3;             // age square wife - HSG
  const double c4;             // age wife - SC
  const double c5;             // age square wife - SC
  const double c6;             // age wife - CG
  const double c7;             // age square wife - CG
  const double c8;             // age wife - PC
  const double c9;             // age square wife - PC
  const double c10;            // number of children at household    
  const double c11;            // schooling - husband
  const double c12;            // married - M
  // terminal value parameters
  const double t1_w;           // schooling wife - HSG
  const double t2_w;           // schooling wife - SC
  const double t3_w;           // schooling wife - CG
  const double t4_w;           // schooling wife - PC
  const double t5_w;           // exp wife
  const double t6_w;           // schooling husband if married - HSD
  const double t7_w;           // schooling husband if married - HSG
  const double t8_w;           // schooling husband if married - SC
  const double t9_w;           // schooling husband if married - CG
  const double t10_w;          // schooling husband if married - PC
  const double t11_w;          // exp husband if married 
  const double t12_w;          // martial status
  const double t13_w;          // number of children
  const double t14_w;          // match quality if married
  const double t15_w;          // number of children if married
  const double t16_w;          // previous work state - wife
  const double t17_w;          // previous work state - husband if married
  // terminal value Parameters
  const double t1_h;           // schooling wife if married- HSG
  const double t2_h;           // schooling wife if married- SC
  const double t3_h;           // schooling wife if married- CG
  const double t4_h;           // schooling wife if married- PC
  const double t5_h;           // exp wife if married
  const double t6_h;           // schooling husband - HSD
  const double t7_h;           // schooling husband - HSG
  const double t8_h;           // schooling husband - SC
  const double t9_h;           // schooling husband - CG
  const double t10_h;          // schooling husband - PC
  const double t11_h;          // exp husband  
  const double t12_h;          // martial status if married
  const double t13_h;          // number of children if married
  const double t14_h;          // match quality if married
  const double t15_h;          // number of children if married - NO NEED
  const double t16_h;          // previous work state - wife if married
  const double t17_h;          // previous work state - husband 
  // match quality parameters
  const double p0_w;           // probability of meeting a potential husband - wife constant
  const double p1_w;           // probability of meeting a potential husband - wife age
  const double p2_w;           // probability of meeting a potential husband - wife age square
  const double p0_h;           // probability of meeting a potential husband - husband constant
  const double p1_h;           // probability of meeting a potential husband - husband age
  const double p2_h;           // probability of meeting a potential husband - husband age square
  const double MATCH_Q_DECREASE;   // probability of match quality decrease
  const double MATCH_Q_INCREASE;   // probability of match quality increase
  const std::array<double,5> EDUC_MATCH;  // education match parameters
  const std::array<double,5> sigma;       // diagonal of random shocks variance-covariance matrix
  const TaxBrackets tax;
  const DeductionExceptions ded;
  const Wives wives;
  const Husbands husbands1;
  const Husbands husbands2;
  const Husbands husbands3;
  const Husbands husbands4;
  const Husbands husbands5;

  // initialization of parameters from list
  Parameters(const ParameterList& parameter_list, 
      const TaxBrackets& _tax, 
      const DeductionExceptions& _ded, 
      const Wives& _wives,
      const Husbands _husbands1,
      const Husbands _husbands2,
      const Husbands _husbands3,
      const Husbands _husbands4,
      const Husbands _husbands5) : 
    alpha(parameter_list[0]),
    alpha1_w_m(parameter_list[1]),
    alpha1_w_s(parameter_list[2]),
    alpha1_h_m(parameter_list[3]),
    alpha2_w(parameter_list[4]),
    alpha3_w(parameter_list[5]),
    beta11_w(parameter_list[6]),
    beta12_w(parameter_list[7]),
    beta13_w(parameter_list[8]),
    beta14_w(parameter_list[9]),
    beta21_w(parameter_list[10]),
    beta22_w(parameter_list[11]),
    beta23_w(parameter_list[12]),
    beta24_w(parameter_list[13]),
    beta31_w(parameter_list[14]),
    beta32_w(parameter_list[15]),
    beta33_w(parameter_list[16]),
    beta34_w(parameter_list[17]),
    beta10_h(parameter_list[18]),
    beta11_h(parameter_list[19]),
    beta12_h(parameter_list[20]),
    beta13_h(parameter_list[21]),
    beta14_h(parameter_list[22]),
    beta20_h(parameter_list[23]),
    beta21_h(parameter_list[24]),
    beta22_h(parameter_list[25]),
    beta23_h(parameter_list[26]),
    beta24_h(parameter_list[27]),
    beta30_h(parameter_list[28]),
    beta31_h(parameter_list[29]),
    beta32_h(parameter_list[30]),
    beta33_h(parameter_list[31]),
    beta34_h(parameter_list[32]),
    row0_w(parameter_list[33]),
    row11_w(parameter_list[34]),
    row12_w(parameter_list[35]),
    row13_w(parameter_list[36]),
    row14_w(parameter_list[37]),
    row2_w(parameter_list[38]),
    hp(parameter_list[39]),
    c1(parameter_list[40]),
    c2(parameter_list[41]),
    c3(parameter_list[42]),
    c4(parameter_list[43]),
    c5(parameter_list[44]), 
    c6(parameter_list[45]),
    c7(parameter_list[46]),
    c8(parameter_list[47]),
    c9(parameter_list[48]),
    c10(parameter_list[49]),
    c11(parameter_list[50]),
    c12(parameter_list[51]),
    t1_w(parameter_list[52]),
    t2_w(parameter_list[53]),
    t3_w(parameter_list[54]),
    t4_w(parameter_list[55]),
    t5_w(parameter_list[56]),
    t6_w(parameter_list[57]),
    t7_w(parameter_list[58]),
    t8_w(parameter_list[59]),
    t9_w(parameter_list[60]),
    t10_w(parameter_list[61]),
    t11_w(parameter_list[62]),
    t12_w(parameter_list[63]),
    t13_w(parameter_list[64]),
    t14_w(parameter_list[65]),
    t15_w(parameter_list[66]),
    t16_w(parameter_list[67]),
    t17_w(parameter_list[68]),
    t1_h(parameter_list[69]),
    t2_h(parameter_list[70]),
    t3_h(parameter_list[71]),
    t4_h(parameter_list[72]),
    t5_h(parameter_list[73]),
    t6_h(parameter_list[74]),
    t7_h(parameter_list[75]),
    t8_h(parameter_list[76]),
    t9_h(parameter_list[77]),
    t10_h(parameter_list[78]),
    t11_h(parameter_list[77]),
    t12_h(parameter_list[80]),
    t13_h(parameter_list[81]),
    t14_h(parameter_list[82]),
    t15_h(parameter_list[83]),
    t16_h(parameter_list[84]),
    t17_h(parameter_list[85]),
    p0_w(parameter_list[86]),
    p1_w(parameter_list[87]),
    p2_w(parameter_list[88]),
    p0_h(parameter_list[89]),
    p1_h(parameter_list[90]),
    p2_h(parameter_list[91]),
    MATCH_Q_DECREASE(exp(parameter_list[92])/(1.0+exp(parameter_list[92]))),
    MATCH_Q_INCREASE(exp(parameter_list[93])/(1.0+exp(parameter_list[93]))),
    EDUC_MATCH{0.0, parameter_list[94], parameter_list[95], parameter_list[96], parameter_list[97]},
    sigma{exp(parameter_list[98]), exp(parameter_list[99]), exp(parameter_list[100]), exp(parameter_list[101]), exp(parameter_list[102])},
    tax(_tax),
    ded(_ded),
    wives(_wives),
    husbands1(_husbands1),
    husbands2(_husbands2),
    husbands3(_husbands3),
    husbands4(_husbands4),
    husbands5(_husbands5)
    {}
};

void print_parameters(const Parameters& p);

