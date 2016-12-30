/**
 * eigen_boost.cpp
 *
 * Tests the cooperation of Eigen and boost::multiprecision.
 * Based on Eigen's test/boostmultiprec.cpp, Copyright (C) 2016 Gael Guennebaud
 */

#include <iostream>

#include <boost/chrono.hpp>

#include <Eigen/Dense>
#include <Eigen/QR>

#undef min
#undef max
#undef isnan
#undef isinf
#undef isfinite

#include <boost/multiprecision/cpp_dec_float.hpp>
#include <boost/multiprecision/number.hpp>
#include <boost/math/special_functions.hpp>


namespace mp = boost::multiprecision;
typedef mp::number<mp::cpp_dec_float<100>, mp::et_on> Real;
typedef Eigen::Matrix<Real, Eigen::Dynamic, Eigen::Dynamic> MatrixType;

int main(int argc, char **argv)
{
	Eigen::MatrixXd abc;
	const int matrixDimension = 50;
	MatrixType a = MatrixType::Random(matrixDimension, matrixDimension);

	Eigen::ColPivHouseholderQR<MatrixType> qrOfA(a);

	std::cout << "QR decomposition " << (qrOfA.info() == Eigen::Success ? "succeeded" : "failed") << std::endl;
	std::cout << "Matrix is invertible: " << (qrOfA.isInvertible() ? "true" : "false") << std::endl;
	std::cout << "Rank = " << qrOfA.rank() << ", abs(determinant) = " << qrOfA.absDeterminant() << std::endl;
	return 0;
}
