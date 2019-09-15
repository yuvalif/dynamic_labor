#include "gross_to_net.h"
#include "parameters.h"
#include <iostream>

// tax matrix
// -----+-------------------+------------------------------------------------------------------------------------------------------------------------------+----------
//      | single                                                                                                                                           | married 
// -----+-------------------------------------------------------------------+------------------------------------------------------------------------------+----------
// year | br1 | br2 | br3 | br4 | br5 | br6 | br7 | br8 | br9 | br10 | br11 | %br1 | %br2 | %br3 | %br4 | %br5 | %br6 | %br7 | %br8 | %br9 | %br10 | %br11 | ...
// -----+-------------------------------------------------------------------+------------------------------------------------------------------------------+----------

const auto TAX_PERCENT_OFFSET = 11;

// deduction matrix
// -----+-------------------------------------------------------------+--------------------------------------------+--------------------------------------------+--------
//      |                                                             | 0 kids                                     | 1 kid                                      | 2 kids
// -----+-------------------------------------------------------------+--------------------------------------------+--------------------------------------------+--------
// year | ded married | ded single | ex married | ex single | ex kids | int1% | int1 | int2# | int3% | int2 | int3 | int1% | int1 | int2# | int3% | int2 | int3 | ...
// -----+-------------------------------------------------------------+--------------------------------------------+--------------------------------------------+--------

const auto DED_OFFSET = 6U;
const auto DED_KIDS_OFFSET = 6U;
const auto DED_INTERVAL1_OFFSET = DED_OFFSET + 1;
const auto DED_INTERVAL2_OFFSET = DED_OFFSET + 4;
const auto DED_INTERVAL3_OFFSET = DED_OFFSET + 5;

double calculate_tax(const Parameters &p, double reduced_income, unsigned row_number) {
    double tax = 0.0;
    if (reduced_income > 0) {
        for (auto i = 2; i <= 11; ++i) {
            const auto lower_bracket = p.tax[row_number][i-1];
            const auto upper_bracket = p.tax[row_number][i];
            const auto percent = p.tax[row_number][i-1+TAX_PERCENT_OFFSET];
            if (reduced_income <= upper_bracket) {
                tax += (reduced_income - lower_bracket)*percent;
                break;
            }
            tax += (upper_bracket - lower_bracket)*percent;
        }
    }
    return tax;
}

double calculate_eict(const Parameters &p, double wage, unsigned row_number, unsigned kids) {
    double EICT = 0.0;

    const auto kids_offset = DED_KIDS_OFFSET*kids;
    if (wage < p.ded[row_number][DED_INTERVAL1_OFFSET+kids_offset]) {
        // first interval  credit rate
        EICT = wage*p.ded[row_number][DED_INTERVAL1_OFFSET-1+kids_offset];
    } else if (wage < p.ded[row_number][DED_INTERVAL2_OFFSET+kids_offset]) {
        // second (flat) interval - max EICT
        EICT = p.ded[row_number][DED_INTERVAL2_OFFSET-2+kids_offset]; 
    } else if (wage < p.ded[row_number][DED_INTERVAL3_OFFSET+kids_offset]) {
        EICT = wage*p.ded[row_number][DED_INTERVAL3_OFFSET-2+kids_offset];
    }

    return EICT;
}

// similar handling for husband and wife in case of singles
double gross_to_net_single(const Parameters &p, unsigned row_number, unsigned kids, double wage, double exemptions, double deductions) {
    if (wage > 0.0) {
        const auto reduced_income = wage - deductions - exemptions;
        double tax = 0.0;
        const auto EICT = calculate_eict(p, wage, row_number, kids);
        if (EICT == 0.0) {
            tax = calculate_tax(p, reduced_income, row_number);
        }

        return wage - tax + EICT;   
    }
    return 0.0;
}

double gross_to_net_married(const Parameters &p, unsigned row_number, unsigned kids, double wage_h, double wage_w, double exemptions, double deductions) {
    if (wage_h > 0.0) {
        const auto reduced_income = wage_h + wage_w - deductions - exemptions;
        double tax = 0.0;
        const auto tot_income = wage_h + wage_w;
        const auto EICT = calculate_eict(p, tot_income, row_number, kids);
        if (EICT == 0.0) {
            tax = calculate_tax(p, reduced_income, row_number);
        }
        return tot_income - tax + EICT;   
    }
    return 0.0;
}

NetIncome gross_to_net(const Parameters &p, unsigned kids, double wage_w, double wage_h, unsigned t, unsigned age_index) {
    // the tax brackets and the deductions and exemptions starts at 1980 and
    // ends at 2035. most of the sample turn 18 at 1980 (NLSY79)
    const auto row_number = t + age_index; // row number on matrix 1980-2035. 

    const auto deductions_m = p.ded[row_number][1];
    const auto deductions_s = p.ded[row_number][2];
    const auto exemptions_m = p.ded[row_number][3] + p.ded[row_number][5]*kids;
    const auto exemptions_s_w = p.ded[row_number][4] + p.ded[row_number][5]*kids;
    const auto exemptions_s_h = p.ded[row_number][4];

    NetIncome result;

    // CALCULATE NET INCOME FOR SINGLE WOMEN
    result.net_income_s_w = gross_to_net_single(p, row_number, kids, wage_w, exemptions_s_w, deductions_s);

    // CALCULATE NET INCOME FOR SINGLE MEN
    result.net_income_s_h = gross_to_net_single(p, row_number, 0 /*no kids*/, wage_h, exemptions_s_h, deductions_s); 

    // CALCULATE NET INCOME FOR MARRIED COUPLE
    result.net_income_m = gross_to_net_married(p, row_number, kids, wage_h, wage_w, exemptions_m, deductions_m);
    result.net_income_m_unemp = gross_to_net_married(p, row_number, kids, wage_h, 0.0 /*no wage_w*/, exemptions_m, deductions_m);

    return result;
}

