#pragma once

struct Parameters;
struct Wife;
struct Husband;

double calculate_wage_h(const Parameters& p, const Husband& husband, double epsilon);

double calculate_wage_w(const Parameters& p, const Wife& wife, double w_draw, double epsilon);

