#include "gross_to_net.h"
#include "parameters.h"

// similar handling for husband and wife in case of singles
double gross_to_net_single(const Parameters &p, unsigned row_number, unsigned N_KIDS, double wage, double exemptions) {
    if (wage > 0) {
        const auto deductions_s = p.ded[row_number][3]; 
        const unsigned shift = 0; // single 2-22, married 23-42
        const auto reduced_income_s_w = wage - deductions_s - exemptions;
        //  CALCULATE INCOME TAX
        double tax = 0.0;
        if (reduced_income_s_w > 0) {
            for (auto i = 2; i <= 10; ++i) {
                if (reduced_income_s_w < p.tax[row_number][i+shift]) {
                    tax += (reduced_income_s_w - p.tax[row_number][(i-1)+shift])*p.tax[row_number][11+(i-1)+shift];
                    break;
                }
                tax += (p.tax[row_number][i+shift] - p.tax[row_number][(i-1)+shift])*p.tax[row_number][11+(i-1)+shift];
            }
        }
        // CALCULATE EICT
        double EICT = 0.0;

        if (wage < p.ded[row_number][8+6*N_KIDS]) { 
            // first interval credit rate
            EICT = wage*p.ded[row_number][7+6*N_KIDS];
            tax = 0.0;
        } else if (wage > p.ded[row_number][8+6*N_KIDS] && wage < p.ded[row_number][11+6*N_KIDS]) {
            // second (flat) interval - max EICT
            EICT = p.ded[row_number][9+6*N_KIDS];
            tax = 0.0;
        } else if (wage > p.ded[row_number][11+6*N_KIDS] && wage < p.ded[row_number][12+6*N_KIDS]) {
            // third interval - phaseout rate
            EICT = wage*p.ded[row_number][10+6*N_KIDS];
            tax = 0.0;
        } else {
            // income too high for EICT
            EICT = 0;                                                       
        }
        return wage - tax + EICT;   
    }
    return 0.0;
}

NetIncome gross_to_net(const Parameters &p, unsigned N_KIDS, double wage_w, double wage_h, unsigned t, unsigned age_index) {
    // the tax brackets and the deductions and exemptions starts at 1980 and
    // ends at 2035. most of the sample turn 18 at 1980 (NLSY79)
    const auto row_number = t + age_index; // row number on matrix 1980-2035. 

    const auto deductions_m = p.ded[row_number][2];
    const auto exemptions_m = p.ded[row_number][4] + p.ded[row_number][6]*N_KIDS;
    const auto exemptions_s_w = p.ded[row_number][5] + p.ded[row_number][6]*N_KIDS;
    const auto exemptions_s_h = p.ded[row_number][5];

    NetIncome result;

    // CALCULATE NET INCOME FOR SINGLE WOMEN
    result.net_income_s_w = gross_to_net_single(p, row_number, N_KIDS, wage_w, exemptions_s_w);

    // CALCULATE NET INCOME FOR SINGLE MEN
    result.net_income_s_h = gross_to_net_single(p, row_number, 0 /*no kids*/, wage_h, exemptions_s_h); 

    // CALCULATE NET INCOME FOR MARRIED COUPLE
    if (wage_h > 0) {
        const unsigned shift = 21; // single 2-22, married 23-42

        // NET SALARY FOR MARRIED COUPLE IF WOMEN CHOOSE TO WORK 
        {
            const auto reduced_income_m = wage_h + wage_w  - deductions_m - exemptions_m;
            // CALCULATE INCOME TAX
            double tax = 0.0;
            if (reduced_income_m > 0) {
                for (auto i = 2; i <= 10; ++i) {
                    if (reduced_income_m < p.tax[row_number][i+shift]) {
                        tax += (reduced_income_m - p.tax[row_number][(i-1)+shift])*p.tax[row_number][11+(i-1)+shift];
                        break;
                    }
                    tax += (p.tax[row_number][i+shift] - p.tax[row_number][(i-1)+shift])*p.tax[row_number][11+(i-1)+shift];
                }
            }  
            // CALCULATE EICT
            double EICT = 0.0;
            const auto tot_inc = wage_h + wage_w;
            if (tot_inc < p.ded[row_number][8+6*N_KIDS]) {
                // first interval  credit rate
                EICT = tot_inc*p.ded[row_number][7+6*N_KIDS];
                tax = 0;
            } else if (tot_inc > p.ded[row_number][8+6*N_KIDS] && tot_inc < p.ded[row_number][11+6*N_KIDS]) {
                // second (flat) interval - max EICT
                EICT = p.ded[row_number][9+6*N_KIDS];
                tax = 0;
            } else if (tot_inc > p.ded[row_number][11+6*N_KIDS] && tot_inc < p.ded[row_number][12+6*N_KIDS]) {
                // third interval - phaseout rate
                EICT = tot_inc*p.ded[row_number][10+6*N_KIDS];
                tax = 0;
            } else {
                // income too high for EICT
                EICT = 0;
            }
            result.net_income_m = tot_inc - tax + EICT;
        }
        // NET SALARY IF MARRIED AND WOMEN CHOOSES NOT TO WORK
        {
            const auto reduced_income_m_unemp = wage_h - deductions_m - exemptions_m;
            // CALCULATE INCOME TAX
            double tax = 0.0;
            if (reduced_income_m_unemp > 0) {
                for (auto i = 2; i <= 10; ++i) {
                    if (reduced_income_m_unemp < p.tax[row_number][i+shift]) {
                        tax += (reduced_income_m_unemp - p.tax[row_number][(i-1)+shift])*p.tax[row_number][11+(i-1)+shift];
                        break;
                    }
                    tax += (p.tax[row_number][i+shift] - p.tax[row_number][(i-1)+shift])*p.tax[row_number][11+(i-1)+shift];
                }
            }   
            // CALCULATE EICT
            double EICT = 0.0;
            const auto tot_inc = wage_h;
            if (tot_inc < p.ded[row_number][8+6*N_KIDS]) {
                // first interval  credit rate
                EICT = tot_inc*p.ded[row_number][7+6*N_KIDS];
                tax = 0;
            } else if (tot_inc > p.ded[row_number][8+6*N_KIDS] && tot_inc < p.ded[row_number][11+6*N_KIDS]) {
                // second (flat) interval - max EICT
                EICT = p.ded[row_number][9+6*N_KIDS];
                tax = 0;
            } else if (tot_inc > p.ded[row_number][11+6*N_KIDS] && tot_inc < p.ded[row_number][12+6*N_KIDS]) {
                // third interval - phaseout rate)
                EICT = tot_inc*p.ded[row_number][10+6*N_KIDS];
                tax = 0;
            } else {
                // income too high for EICT
                EICT = 0;
            }    
            result.net_income_m_unemp =  tot_inc - tax + EICT;
        }
    }
    return result;
}


