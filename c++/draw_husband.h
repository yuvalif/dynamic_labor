#pragma once

class Parameters;

struct Husband {
    Husband();
    unsigned H_HSD;
    unsigned H_HSG;
    unsigned H_SC;
    unsigned H_CG;
    unsigned H_PC;
    unsigned HE;
    unsigned ability_h_value;
    unsigned ability_hi;
    double Q;
    unsigned Q_INDEX;
    double similar_educ;
};

Husband draw_husband(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group, unsigned WS);

