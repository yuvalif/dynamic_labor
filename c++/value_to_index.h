#pragma once

// convert values to indexes on their respective grids
void value_to_index(unsigned WE, unsigned HE, double BP, unsigned CS, 
        unsigned& exp_wi, unsigned& exp_hi, unsigned& BPi, unsigned& CSi);

