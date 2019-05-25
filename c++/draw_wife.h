#pragma once

class Parameters;

struct Wife {
    Wife();
    unsigned HSD;
    unsigned HSG;
    unsigned SC;
    unsigned CG;
    unsigned PC;
    unsigned WS;
    unsigned WE;
    unsigned prev_state_w;
    unsigned ability_w_value;
    unsigned ability_wi;
    unsigned Q;
    unsigned Q_INDEX;
    unsigned similar_educ;
};

Wife draw_wife(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group);

