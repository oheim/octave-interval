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
#include "mpfr_commons.cc"

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
  #pragma omp parallel for
  for (octave_idx_type i = 0; i < n; i++)
    {
      // Using accumulators instead of the (less accurate) mpfr_sum function
      // saves us some computation time, because we do not have to instantiate
      // so many mpfr_t values.
      mpfr_t accu_l, accu_u;
      mpfr_init2 (accu_l, BINARY64_ACCU_PRECISION);
      mpfr_init2 (accu_u, BINARY64_ACCU_PRECISION);
      mpfr_t mp_addend_l, mp_addend_u, mp_temp;
      mpfr_init2 (mp_addend_l, 2 * BINARY64_PRECISION + 1);
      mpfr_init2 (mp_addend_u, 2 * BINARY64_PRECISION + 1);
      mpfr_init2 (mp_temp,     2 * BINARY64_PRECISION + 1);
      for (octave_idx_type j = 0; j < m; j++)
        {
          mpfr_set_zero (accu_l, 0);
          mpfr_set_zero (accu_u, 0);
          for (octave_idx_type k = 0; k < l; k++)
            {
              double xl, xu, yl, yu;
              #pragma omp critical
              {
                // Access to shared memory is critical
                xl = matrix_xl.elem (i, k);
                xu = matrix_xu.elem (i, k);
                yl = matrix_yl.elem (k, j);
                yu = matrix_yu.elem (k, j);
              }
            
              if ((xl == INFINITY && xu == -INFINITY)
                  ||
                  (yl == INFINITY && yu == -INFINITY))
                {
                  // [Empty] × Anything = [Empty]
                  // [Empty] + Anything = [Empty]
                  mpfr_set_inf (accu_l, +1);
                  mpfr_set_inf (accu_u, -1);
                  break;
                }
              if (mpfr_inf_p (accu_l) != 0 && mpfr_inf_p (accu_u) != 0)
                // [Entire] + Anything = [Entire]
                continue;
              if ((xl == 0.0 && xu == 0.0)
                  ||
                  (yl == 0.0 && yu == 0.0))
                // [0] × Anything = [0]
                continue;
              if ((xl == -INFINITY && xu == INFINITY)
                  ||
                  (yl == -INFINITY && yu == INFINITY))
                {
                  // [Entire] × Anything = [Entire]
                  mpfr_set_inf (accu_l, -1);
                  mpfr_set_inf (accu_u, +1);
                  continue;
                }
              
              // Both factors can be multiplied within 107 bits exactly!
              mpfr_set_d (mp_addend_l, xl, MPFR_RNDZ);
              mpfr_mul_d (mp_addend_l, mp_addend_l, yl, MPFR_RNDZ);
              mpfr_set (mp_addend_u, mp_addend_l, MPFR_RNDZ);
              
              // We have to compute the remaining 3 Products and
              // determine min/max
              if (yl != yu)
                {
                  mpfr_set_d (mp_temp, xl, MPFR_RNDZ);
                  mpfr_mul_d (mp_temp, mp_temp, yu, MPFR_RNDZ);
                  mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
                  mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
                }
              if (xl != xu)
                {
                  mpfr_set_d (mp_temp, xu, MPFR_RNDZ);
                  mpfr_mul_d (mp_temp, mp_temp, yl, MPFR_RNDZ);
                  mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
                  mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
                }
              if (xl != xu || yl != yu)
                {
                  mpfr_set_d (mp_temp, xu, MPFR_RNDZ);
                  mpfr_mul_d (mp_temp, mp_temp, yu, MPFR_RNDZ);
                  mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
                  mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
                }
              
              // Compute sums
              if (mpfr_add (accu_l, accu_l, mp_addend_l, MPFR_RNDZ) != 0 ||
                  mpfr_add (accu_u, accu_u, mp_addend_u, MPFR_RNDZ) != 0)
                {
                  #pragma omp critical
                  error ("mpfr_matrix_mul_d: "
                         "Failed to compute exact matrix multiplication");
                }
            }
          const double accu_l_d = mpfr_get_d (accu_l, MPFR_RNDD);
          const double accu_u_d = mpfr_get_d (accu_u, MPFR_RNDU);
          #pragma omp critical
          {
            // Access to shared memory is critical
            result_l.elem (i, j) = accu_l_d;
            result_u.elem (i, j) = accu_u_d;
          }
        }
      mpfr_clear (mp_addend_l);
      mpfr_clear (mp_addend_u);
      mpfr_clear (mp_temp);
      mpfr_clear (accu_l);
      mpfr_clear (accu_u);
    }
    
  std::pair <Matrix, Matrix> result (result_l, result_u);

  return result;
}

DEFUN_DLD (mpfr_matrix_mul_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefn  {Loadable Function} {[@var{L}, @var{U}] =} mpfr_matrix_mul_d (@var{XL}, @var{YL}, @var{XU}, @var{YU})\n"
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
  "@end deftypefn"
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
  if (error_state)
    return octave_value_list ();
  
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
*/
