
class Parameters;
class Wife;

double calculate_wage_h(const Parameters& p, unsigned H_HSD, unsigned H_HSG, unsigned H_SC, unsigned H_CG, unsigned H_PC, 
        unsigned HE, double ability_h_value, double epsilon);

double calculate_wage_w(const Parameters& p, const Wife& wife, double w_draw, double epsilon);

