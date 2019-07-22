#pragma once

#include <array>

// a Matrix is a 2D array of doubles (with static size)
template <size_t ROW, size_t COL> using Matrix = std::array<std::array<double, COL>, ROW>;

// usage example:
// Matrix<3, 4> m;
// m[1][2] = 42.0;

// a Matrix is a 2D array of unsigned integers (with static size)
template <size_t ROW, size_t COL> using UMatrix = std::array<std::array<unsigned, COL>, ROW>;

// return: lhs - rhs
template<size_t ROW, size_t COL> 
Matrix<ROW, COL> diff(const Matrix<ROW, COL>& lhs, const Matrix<ROW, COL>& rhs) {
    Matrix<ROW, COL> result;
    for (auto i = 0; i < ROW; ++i) {
        for (auto j = 0; j < COL; ++j) {
            result[i][j] = lhs[i][j] - rhs[i][j];
        }
    }
    return result;
}

// return: (lhs - rhs)^2 (element by element)
template<size_t ROW, size_t COL> 
Matrix<ROW, COL> square_diff(const Matrix<ROW, COL>& lhs, const Matrix<ROW, COL>& rhs) {
    Matrix<ROW, COL> result;
    for (auto i = 0; i < ROW; ++i) {
        for (auto j = 0; j < COL; ++j) {
            auto const d = lhs[i][j] - rhs[i][j];
            result[i][j] = d*d;
        }
    }
    return result;
}

// return lhs/rhs (element by element)
template<size_t ROW, size_t COL> 
Matrix<ROW, COL> divide(const Matrix<ROW, COL>& lhs, const std::array<double, COL>& rhs) {
    Matrix<ROW, COL> result;
    for (auto i = 0; i < ROW; ++i) {
        for (auto j = 0; j < COL; ++j) {
            result[i][j] = lhs[i][j]/rhs[j];
        }
    }
    return result;
}

// return lhs/rhs^2 (element by element)
template<size_t ROW, size_t COL> 
Matrix<ROW, COL> divide_by_square(const Matrix<ROW, COL>& lhs, const std::array<double, COL>& rhs) {
    Matrix<ROW, COL> result;
    for (auto i = 0; i < ROW; ++i) {
        for (auto j = 0; j < COL; ++j) {
            result[i][j] = lhs[i][j]/(rhs[j]*rhs[j]);
        }
    }
    return result;
}

// return sum of all elements of a matrix
template<size_t ROW, size_t COL> 
double total_sum(const Matrix<ROW, COL>& m) {
    double result = 0.0;
    for (auto i = 0; i < ROW; ++i) {
        for (auto j = 0; j < COL; ++j) {
            result += m[i][j];
        }
    }
    return result;
}

