/*
  Copyright 2015 Oliver Heimlich
  
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
#include <mpfr.h>
#include "mpfr_commons.h"

std::pair <Matrix, Matrix> interval_matrix_mul (
  const Matrix matrix_xl, const Matrix matrix_yl,
  const Matrix matrix_xu, const Matrix matrix_yu)
{
  const octave_idx_type n = matrix_xl.rows (),
                        m = matrix_yl.columns (),
                        l = matrix_xl.columns ();
  if (l != matrix_yl.rows () ||
      n != matrix_xu.rows () ||
      m != matrix_yl.columns () ||
      l != matrix_xu.columns () ||
      l != matrix_yu.rows ())
    error ("mpfr_matrix_mul_d: "
           "Matrix dimensions must agree");

  Matrix result_l (dim_vector (n, m));
  Matrix result_u (dim_vector (n, m));

  // Instead of two nested loops (for row = 1 : n / for col = 1 : m), we use
  // a single loop, which can be parallelized more easily.
#if defined (_OPENMP)
  #pragma omp parallel for
#endif
  for (octave_idx_type i = 0; i < n * m; i++)
    {
      mpfr_t accu_l, accu_u;
      mpfr_init2 (accu_l, BINARY64_ACCU_PRECISION);
      mpfr_init2 (accu_u, BINARY64_ACCU_PRECISION);
      mpfr_set_zero (accu_l, 0);
      mpfr_set_zero (accu_u, 0);

      const octave_idx_type row = i % n;
      const octave_idx_type col = i / n;

      RowVector xl;
      RowVector xu;
      ColumnVector yl;
      ColumnVector yu;
#if defined (_OPENMP)
      #pragma omp critical
#endif
      {
        // Access to shared memory is critical
        xl = matrix_xl.row (row);
        xu = matrix_xu.row (row);
        yl = matrix_yl.column (col);
        yu = matrix_yu.column (col);
      }

      exact_interval_dot_product (accu_l, accu_u,
                                  xl, xu,
                                  yl, yu);

      const double accu_l_d = mpfr_get_d (accu_l, MPFR_RNDD);
      const double accu_u_d = mpfr_get_d (accu_u, MPFR_RNDU);
#if defined (_OPENMP)
      #pragma omp critical
#endif
      {
        // Access to shared memory is critical
        result_l.elem (row, col) = accu_l_d;
        result_u.elem (row, col) = accu_u_d;
      }

      mpfr_clear (accu_l);
      mpfr_clear (accu_u);
    }

  std::pair <Matrix, Matrix> result (result_l, result_u);

  return result;
}

DEFUN_DLD (mpfr_matrix_mul_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefun {[@var{L}, @var{U}] =} mpfr_matrix_mul_d (@var{XL}, @var{YL}, @var{XU}, @var{YU})\n"
  "\n"
  "Compute the matrix product with binary64 numbers and correctly rounded "
  "result."
  "\n\n"
  "Compute the lower and upper boundary of the matrix multiplication of "
  "interval matrices [@var{XL}, @var{XU}] and [@var{YL}, @var{YU}]."
  "\n\n"
  "The result is guaranteed to be tight.  That is, the matrix product is "
  "evaluated with (virtually) infinite precision and the exact result is "
  "approximated with binary64 numbers using directed rounding."
  "\n\n"
  "@example\n"
  "@group\n"
  "m = magic (3);\n"
  "[l, u] = mpfr_matrix_mul_d (m, m', m + 1, m' + 1)\n"
  "  @result{} l = \n"
  "     101    71    53\n"
  "      71    83    71\n"
  "      53    71   101\n"
  "    u = \n"
  "     134   104    86\n"
  "     104   116   104\n"
  "      86   104   134\n"
  "@end group\n"
  "@end example\n"
  "@seealso{mtimes}\n"
  "@end deftypefun"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin != 4)
    {
      print_usage ();
      return octave_value_list ();
    }

  Matrix matrix_xl = args (0).matrix_value ();
  Matrix matrix_yl = args (1).matrix_value ();
  Matrix matrix_xu = args (2).matrix_value ();
  Matrix matrix_yu = args (3).matrix_value ();

  std::pair <Matrix, Matrix> result_d = 
    interval_matrix_mul (matrix_xl, matrix_yl, matrix_xu, matrix_yu);
  octave_value_list result;
  result (0) = result_d.first;
  result (1) = result_d.second;
  
  return result;
}

/*
%!test;
%!  [l, u] = mpfr_matrix_mul_d (magic (3), magic (3)', magic (3) + 1, magic (3)' + 1);
%!  assert (l, [101, 71, 53; 71, 83, 71; 53, 71, 101]);
%!  assert (u, [134, 104, 86; 104, 116, 104; 86, 104, 134]);

%!demo
%!  processors = nproc ('overridable');
%!
%!  A = vec (magic (2000));
%!  tic;
%!  for i = 1:processors
%!    mpfr_matrix_mul_d (A', A, A', A);
%!  endfor
%!  printf ('Time for %d vector dot products: %d seconds\n', processors, toc)
%!
%!  B = repmat (A, 1, processors);
%!  tic;
%!  mpfr_matrix_mul_d (B', A, B', A);
%!  printf ('Time for %d vector dot products running in parallel: %d seconds\n', processors, toc)
*/
