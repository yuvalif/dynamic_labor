#include <cmath>

unsigned group_exp(unsigned e) {
	// 5 levels grid: 0, 1-2, 3-4, 5-10, 11+
    if (e == 0)
        return 1;
    else if (e < 3)  // 1 or 2 years
        return 2;
    else if (e < 6)  // 3 or 5 years
        return 3;
    else if (e < 11) // 6 to 10 years
        return 4;
    else // above 11 years of experience
        return 5;
}

void value_to_index(unsigned WE, unsigned HE, unsigned N_KIDS, double BP, unsigned CS, 
        unsigned& exp_wi, unsigned& exp_hi, unsigned& kidsi, unsigned& BPi, unsigned& CSi) {

    exp_wi = group_exp(WE);
    exp_hi = group_exp(HE);

    if (N_KIDS == 0) {
        kidsi = 1;
    } else if (N_KIDS == 1) {
        kidsi = 2;
    } else if (N_KIDS  == 2) {
        kidsi = 3;
    } else {
        kidsi = 4;
    }

    if (BP < 0.2) {
        BPi = 1;
    } else if (BP > 0.8) {
        BPi = 7;
    } else {
        BPi = round((BP*10)-1);
    }

    if (CS < 0.2) {
        CSi = 1;
    } else if (CS > 0.8) {
        CSi = 7;
    } else {
        CSi = round((CS*10)-1);
    }
}

