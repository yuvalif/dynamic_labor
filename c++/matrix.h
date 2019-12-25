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
            result[i][j] = rhs[j] > 0 ? lhs[i][j]/rhs[j] : 0.0;
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
            result[i][j] = rhs[j] > 0 ? lhs[i][j]/(rhs[j]*rhs[j]) : 0.0;
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

template<size_t ROW, size_t COL> 
std::string to_string(const Matrix<ROW, COL>& m) {
    std::string result;
    for (auto i = 0; i < ROW; ++i) {
        for (auto j = 0; j < COL; ++j) {
            result += std::to_string(m[i][j]);
            result += "\t";
        }
        result += "\n";
    }
    return result;
}

template<size_t ROW, size_t COL>
class MeanMatrix {
    private:
        std::array<std::array<double, COL>, ROW> sum{{{{0}}}};
        UMatrix<ROW, COL> count{{{{0}}}};
    public:
        void accumulate(size_t row, size_t col, double value) {
            sum[row][col] += value;
            ++count[row][col];
        }

        double mean(size_t row, size_t col) const {
            const auto c = count[row][col];
            if (c == 0) return 0.0;
            return sum[row][col]/(double)c; 
        }
        
        double column_mean(size_t col) const {
            unsigned _count = 0;
            double _sum = 0;
            for (auto i = 0; i < ROW; ++i) {
                _count += count[i][col];
                _sum += sum[i][col];
            }
            if (_count == 0) return 0.0;
            return _sum/(double)_count;
        }
};

template<size_t SIZE>
class MeanArray {
    private:
        std::array<double, SIZE> sum{0};
        std::array<unsigned, SIZE> count{0};
    public:
        void accumulate(size_t idx, double value) {
            sum[idx] += value;
            ++count[idx];
        }

        double mean(size_t idx) const {
            const auto c = count[idx];
            if (c == 0) return 0.0;
            return sum[idx]/(double)c; 
        }
};

