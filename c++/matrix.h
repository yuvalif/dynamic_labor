#pragma once

#include <array>

// a Matrix is a 2D array of doubles (with static size)
template <size_t ROW, size_t COL> using Matrix = std::array<std::array<double, COL>, ROW>;

// usage example:
// Matrix<3, 4> m;
// m[1][2] = 42.0;
//
