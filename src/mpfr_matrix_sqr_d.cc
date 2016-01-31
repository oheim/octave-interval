/*
  Copyright 2016 Oliver Heimlich
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License
  along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

#include <octave/oct.h>
#include <octave/oct-openmp.h>
#include <mpfr.h>
#include "mpfr_commons.cc"

std::pair <Matrix, Matrix> interval_matrix_sqr (
  const Matrix matrix_xl, const Matrix matrix_xu)
{
  const octave_idx_type n = matrix_xl.rows ();
  if (n != matrix_xl.columns ())
    {
      error ("mpfr_matrix_sqr_d: Matrix must be square");
      return std::pair <Matrix, Matrix> (Matrix (), Matrix ());
    }

  Matrix result_l (dim_vector (n, n));
  Matrix result_u (dim_vector (n, n));

  OCTAVE_OMP_PRAGMA (omp parallel for)
  for (octave_idx_type i = 0; i < n; i++)
    {
      mpfr_t accu_l, accu_u;
      mpfr_t mp_temp1, mp_temp2;
      mpfr_init2 (accu_l, BINARY64_ACCU_PRECISION);
      mpfr_init2 (accu_u, BINARY64_ACCU_PRECISION);
      mpfr_init2 (mp_temp1, BINARY64_ACCU_PRECISION);
      mpfr_init2 (mp_temp2, BINARY64_ACCU_PRECISION);

      RowVector xl;
      RowVector xu;
      OCTAVE_OMP_PRAGMA (omp critical)
      {
        // Access to shared memory is critical
        xl = matrix_xl.row (i);
        xu = matrix_xu.row (i);
      }
      
      for (octave_idx_type j = 0; j < n; j++)
        {
          mpfr_set_zero (accu_l, 0);
          mpfr_set_zero (accu_u, 0);

          ColumnVector yl;
          ColumnVector yu;
          OCTAVE_OMP_PRAGMA (omp critical)
          {
            // Access to shared memory is critical
            yl = matrix_xl.column (j);
            yu = matrix_xu.column (j);
          }
          
          // Each entry of the result is defined as
          //   result(i,j) = sum[k != i,j] x(i,k)*x(k,j)
          //                    + x(i,j)*(x(i,i), x(j,j))          for i != j
          // or
          //   result(i,i) = sum[k != i] x(i,k)*x(k,i) 
          //                    + x(i,i)^2
          //
          // We compute result(i,:) by matrix multiplication of x(i,:) with y,
          // where y is a matrix made from x such that no entry of x
          // participates in each entry of the final result more than once.

          // For i != j
          // Combine x(i,j)*x(i,i) and x(j,j)*x(i,j) into
          //    x(i,j)*(x(i,i)+x(j,j)),
          // where x(i,j) would appear twice and introduce dependency errors
          if (i != j)
            {
              // Compute x(i,j)*(x(i,i)+x(j,j)) in the accumulator exactly
              if ((xl.elem (i) == INFINITY && xu.elem (i) == -INFINITY) ||
                  (xl.elem (j) == INFINITY && xu.elem (j) == -INFINITY) ||
                  (yl.elem (j) == INFINITY && yu.elem (j) == -INFINITY))
                {
                  // [Empty] interval detected
                  mpfr_set_inf (accu_l, +1);
                  mpfr_set_inf (accu_u, -1);
                }
              else
                {
                  // Part 1
                  // x(i,i) + x(j,j)
                  mpfr_set_d (accu_l, xl.elem (i), MPFR_RNDD);
                  mpfr_set_d (accu_u, xu.elem (i), MPFR_RNDU);
                  mpfr_add_d (accu_l, accu_l, yl.elem (j), MPFR_RNDD);
                  mpfr_add_d (accu_u, accu_u, yu.elem (j), MPFR_RNDU);
                  
                  // Part 2
                  // Multiply x(i,j) into the accumulator
                  if ((xl.elem (j) == 0.0 && xu.elem (j) == 0.0)
                      ||
                      (mpfr_zero_p (accu_l) && mpfr_zero_p (accu_u)))
                    {
                      // Multiplication with zero detected
                      mpfr_set_zero (accu_l, 0);
                      mpfr_set_zero (accu_u, 0);
                    }
                  else
                    {
                      if ((xl.elem (j) == -INFINITY && xu.elem (j) == INFINITY)
                          ||
                          (mpfr_inf_p (accu_l) && mpfr_inf_p (accu_u)))
                        {
                          // Multiplication with [Entire] detected
                          mpfr_set_inf (accu_l, -1);
                          mpfr_set_inf (accu_u, +1);
                        }
                      else
                        {
                          if (mpfr_sgn (accu_l) >= 0)
                            {
                              if (xl.elem (j) >= 0.0)
                                {
                                  // non-negative × non-negative
                                  mpfr_mul_d (accu_l, accu_l, xl.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xu.elem (j),
                                              MPFR_RNDU);
                                }
                              else if (xu.elem (j) <= 0.0)
                                {
                                  // non-negative × non-positive
                                  mpfr_swap (accu_l, accu_u);
                                  mpfr_mul_d (accu_l, accu_l, xl.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xu.elem (j),
                                              MPFR_RNDU);
                                }
                              else
                                {
                                  // non-negative × inner-zero
                                  mpfr_set (accu_l, accu_u, MPFR_RNDZ);
                                  mpfr_mul_d (accu_l, accu_l, xl.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xu.elem (j),
                                              MPFR_RNDU);
                                }
                            }
                          else if (mpfr_sgn (accu_u) <= 0)
                            {
                              if (xl.elem (j) >= 0.0)
                                {
                                  // non-positive × non-negative
                                  mpfr_mul_d (accu_l, accu_l, xu.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xl.elem (j),
                                              MPFR_RNDU);
                                }
                              else if (xu.elem (j) <= 0.0)
                                {
                                  // non-positive × non-positive
                                  mpfr_swap (accu_l, accu_u);
                                  mpfr_mul_d (accu_l, accu_l, xu.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xl.elem (j),
                                              MPFR_RNDU);
                                }
                              else
                                {
                                  // non-positive × inner-zero
                                  mpfr_set (accu_u, accu_l, MPFR_RNDZ);
                                  mpfr_mul_d (accu_l, accu_l, xu.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xl.elem (j),
                                              MPFR_RNDU);
                                }
                            }
                          else
                            {
                              if (xl.elem (j) >= 0.0)
                                {
                                  // inner-zero × non-negative
                                  mpfr_mul_d (accu_l, accu_l, xu.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xu.elem (j),
                                              MPFR_RNDU);
                                }
                              else if (xu.elem (j) <= 0.0)
                                {
                                  // inner-zero × non-positive
                                  mpfr_mul_d (accu_l, accu_l, xl.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (accu_u, accu_u, xl.elem (j),
                                              MPFR_RNDU);
                                }
                              else
                                {
                                  // inner-zero × inner-zero

                                  // Lower bound
                                  mpfr_mul_d (mp_temp1, accu_l, xu.elem (j),
                                              MPFR_RNDD);
                                  mpfr_mul_d (mp_temp2, accu_u, xl.elem (j),
                                              MPFR_RNDD);
                                  mpfr_min (mp_temp1, mp_temp1, mp_temp2,
                                            MPFR_RNDD);

                                  mpfr_swap (accu_l, mp_temp1);

                                  // Upper bound
                                  mpfr_mul_d (mp_temp1, mp_temp1, xl.elem (j),
                                              MPFR_RNDU);
                                  mpfr_mul_d (mp_temp2, accu_u, xu.elem (j),
                                              MPFR_RNDU);
                                  mpfr_max (accu_u, mp_temp1, mp_temp2,
                                            MPFR_RNDU);
                                }
                            }
                        }
                    }
                }
            }
          
          // For i == j
          // Make sure that x(i,i)^2 can be computed error free as
          //    x(i,i)*x(i,i)
          if (i == j)
            {
              if (xl.elem (i) < 0.0 && xu.elem (i) > 0.0)
                {
                  yl.elem (i) = 0.0;
                  yu.elem (i) = std::max (std::abs (xl.elem (i)),
                                          std::abs (xu.elem (i)));
                }
              exact_interval_dot_product (accu_l, accu_u,
                                          yl.extract_n (i, 1),
                                          yu.extract_n (i, 1),
                                          yl.extract_n (i, 1),
                                          yu.extract_n (i, 1));
            }

          // Elements i and j have already been computed in the accumulator
          // Add remaining products for k != i, j to the accumulator
          yl.elem (i) = 0.0;
          yu.elem (i) = 0.0;
          yl.elem (j) = 0.0;
          yu.elem (j) = 0.0;
          exact_interval_dot_product (accu_l, accu_u,
                                      xl, xu,
                                      yl, yu);

          const double accu_l_d = mpfr_get_d (accu_l, MPFR_RNDD);
          const double accu_u_d = mpfr_get_d (accu_u, MPFR_RNDU);
          OCTAVE_OMP_PRAGMA (omp critical)
          {
            // Access to shared memory is critical
            result_l.elem (i, j) = accu_l_d;
            result_u.elem (i, j) = accu_u_d;
          }
        }

      mpfr_clear (accu_l);
      mpfr_clear (accu_u);
      mpfr_clear (mp_temp1);
      mpfr_clear (mp_temp2);
    }

  std::pair <Matrix, Matrix> result (result_l, result_u);

  return result;
}

DEFUN_DLD (mpfr_matrix_sqr_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefun {[@var{L}, @var{U}] =} mpfr_matrix_sqr_d (@var{XL}, @var{XU})\n"
  "\n"
  "Compute the lower and upper boundary of the matrix square of "
  "interval matrix [@var{XL}, @var{XU}]."
  "\n\n"
  "The result is guaranteed to be tight.  That is, the matrix square is "
  "evaluated with (virtually) infinite precision and the exact result is "
  "approximated with binary64 numbers using directed rounding."
  "\n\n"
  "Unlike @code{@var{X} * @var{X}} this function avoids the dependency "
  "problem during computation and produces a better enclosure.  The algorithm "
  "has been implemented after “Feasible algorithm for computing the square of "
  "an interval matrix” in O. Kosheleva, V. Kreinovich, G. Mayer, and "
  "H. T. Nguyen (2005): Computing the cube of an interval matrix is NP-hard. "
  "In SAC '05: Proc. of the 2005 ACM Symposium on Applied Computing, "
  "pages 1449–1453, 2005."
  "\n\n"
  "@example\n"
  "@group\n"
  "m = magic (3);\n"
  "[l, u] = mpfr_matrix_sqr_d (m, m + 1)\n"
  "  @result{} l = \n"
  "     91   67   67\n"
  "     67   91   67\n"
  "     67   67   91\n"
  "    u = \n"
  "     124   100   100\n"
  "     100   124   100\n"
  "     100   100   124\n"
  "@end group\n"
  "@end example\n"
  "@seealso{mpower}\n"
  "@end deftypefun"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin != 2)
    {
      print_usage ();
      return octave_value_list ();
    }

  Matrix matrix_xl = args (0).matrix_value ();
  Matrix matrix_xu = args (1).matrix_value ();
  if (error_state)
    return octave_value_list ();
  
  std::pair <Matrix, Matrix> result_d = 
    interval_matrix_sqr (matrix_xl, matrix_xu);
  octave_value_list result;
  result (0) = result_d.first;
  result (1) = result_d.second;
  
  return result;
}
