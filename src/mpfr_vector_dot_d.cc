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

std::pair <double, double> interval_vector_dot (
  Matrix vector_xl, Matrix vector_yl,
  Matrix vector_xu, Matrix vector_yu)
{
  if (vector_xl.numel () == 1 && vector_yl.numel () != 1)
    {
      // Broadcast vector x
      vector_xl = Matrix (vector_yl.dims (), vector_xl.elem (0));
      vector_xu = Matrix (vector_yl.dims (), vector_xu.elem (0));
    }
  else if (vector_yl.numel () == 1 && vector_xl.numel () != 1)
    {
      // Broadcast vector y
      vector_yl = Matrix (vector_xl.dims (), vector_yl.elem (0));
      vector_yu = Matrix (vector_xl.dims (), vector_yu.elem (0));
    }
    
  const unsigned int n = vector_xl.numel ();
  // Using accumulators instead of the (less accurate) mpfr_sum function saves
  // us some computation time, because we do not have to instantiate so many
  // mpfr_t values.
  mpfr_t accu_l, accu_u;
  mpfr_init2 (accu_l, BINARY64_ACCU_PRECISION);
  mpfr_init2 (accu_u, BINARY64_ACCU_PRECISION);
  mpfr_set_zero (accu_l, 0);
  mpfr_set_zero (accu_u, 0);
  mpfr_t mp_addend_l, mp_addend_u, mp_temp;
  mpfr_init2 (mp_addend_l, 2 * BINARY64_PRECISION + 1);
  mpfr_init2 (mp_addend_u, 2 * BINARY64_PRECISION + 1);
  mpfr_init2 (mp_temp,     2 * BINARY64_PRECISION + 1);
  for (int i = 0; i < n; i++)
    {
      const double xl = vector_xl.elem (i);
      const double xu = vector_xu.elem (i);
      const double yl = vector_yl.elem (i);
      const double yu = vector_yu.elem (i);
    
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
      
      // We have to compute the remaining 3 Products and determine min/max
      mpfr_set_d (mp_temp, xl, MPFR_RNDZ);
      mpfr_mul_d (mp_temp, mp_temp, yu, MPFR_RNDZ);
      mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
      mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
      mpfr_set_d (mp_temp, xu, MPFR_RNDZ);
      mpfr_mul_d (mp_temp, mp_temp, yl, MPFR_RNDZ);
      mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
      mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
      mpfr_set_d (mp_temp, xu, MPFR_RNDZ);
      mpfr_mul_d (mp_temp, mp_temp, yu, MPFR_RNDZ);
      mpfr_min (mp_addend_l, mp_addend_l, mp_temp, MPFR_RNDZ);
      mpfr_max (mp_addend_u, mp_addend_u, mp_temp, MPFR_RNDZ);
      
      // Compute sums
      if (mpfr_add (accu_l, accu_l, mp_addend_l, MPFR_RNDZ) != 0 ||
          mpfr_add (accu_u, accu_u, mp_addend_u, MPFR_RNDZ) != 0)
        error ("mpfr_vector_dot_d: Failed to compute exact dot product");
    }
  std::pair <double, double> result (mpfr_get_d (accu_l, MPFR_RNDD),
                                     mpfr_get_d (accu_u, MPFR_RNDU));

  mpfr_clear (mp_addend_l);
  mpfr_clear (mp_addend_u);
  mpfr_clear (mp_temp);
  mpfr_clear (accu_l);
  mpfr_clear (accu_u);
  
  return result;
}

DEFUN_DLD (mpfr_vector_dot_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding utf-8\n"
  "@deftypefn  {Loadable Function} {[@var{L}, @var{U}] = } mpfr_vector_dot_d (@var{XL}, @var{YL}, @var{XU}, @var{YU})\n"
  "\n"
  "Compute the upper and lower boundary of the dot product of interval "
  "vectors [@var{XL}, @var{XU}] and [@var{YL}, @var{YU}] in binary64 numbers "
  "with correctly rounded result."
  "\n\n"
  "Scalar intervals do broadcast."
  "\n\n"
  "The output for empty intervals is undefined.  The output for [0] × [Entire]"
  " is undefined, the function caller has to make sure, that this case does "
  "not occur."
  "\n\n"
  "The result is guaranteed to be tightest."
  "\n\n"
  "@example\n"
  "@group\n"
  "[l, u] = mpfr_vector_dot_d (-1, -1, 2, 3)\n"
  "  @result{} l = -3\n"
  "  @result{} u = 6\n"
  "@end group\n"
  "@end example\n"
  "@seealso{dot}\n"
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
  
  // Read parameters
  Matrix vector_xl = args (0).matrix_value ();
  Matrix vector_yl = args (1).matrix_value ();
  Matrix vector_xu = args (2).matrix_value ();
  Matrix vector_yu = args (3).matrix_value ();
  if (error_state)
    return octave_value_list ();
  
  std::pair<double, double> result_d = interval_vector_dot (vector_xl, vector_yl, vector_xu, vector_yu);
  octave_value_list result;
  result (0) = result_d.first;
  result (1) = result_d.second;
  
  return result;
}

/*
%!test;
%!  [l, u] = mpfr_vector_dot_d (-1, -1, 2, 3);
%!  assert (l, -3);
%!  assert (u, 6);
%!test;
%!  x = [realmax, realmax, -realmax, -realmax, 1, eps/2];
%!  y = ones (size (x));
%!  [l, u] = mpfr_vector_dot_d (x, y, x, y);
%!  assert (l, 1);
%!  assert (u, 1 + eps);
%!test;
%!  [l, u] = mpfr_vector_dot_d (0, 0, inf, inf);
%!  assert (l, 0);
%!  assert (u, inf);
*/
