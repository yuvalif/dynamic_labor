#pragma once
struct NetIncome {
    double net_income_s_h{};
    double net_income_s_w{}; 
    double net_income_m{};
    double net_income_m_unemp{};
};

class Parameters;

NetIncome gross_to_net(const Parameters &p, unsigned N_KIDS, double wage_w, double wage_h, unsigned t, unsigned age_index);

