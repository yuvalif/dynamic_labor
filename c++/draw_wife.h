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
    double Q;
    unsigned Q_INDEX;
    double similar_educ;
    unsigned AGE;
    unsigned age_index;
    unsigned T_END;
};

// draw a wife
Wife draw_wife(const Parameters& p, unsigned t, unsigned age_index, unsigned school_group);

// update the wife based on schooling and time
// returns whether further calculation is needed
bool update_wife_schooling(unsigned WS, unsigned t, Wife& wife);

