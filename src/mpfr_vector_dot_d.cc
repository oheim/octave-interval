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

DEFUN_DLD (mpfr_vector_dot_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding utf-8\n"
  "@deftypefn  {Loadable Function} {[@var{L}, @var{U}] = } mpfr_vector_dot_d (@var{XL}, @var{YL}, @var{XU}, @var{YU})\n"
  "\n"
  "Compute the upper and lower boundary of the dot product of interval "
  "vectors [@var{XL}, @var{XU}] and [@var{YL}, @var{YU}] with double "
  "precision and correctly rounded result."
  "\n\n"
  "Scalar intervals do broadcast."
  "\n\n"
  "The output for empty intervals is undefined.  The output for [0] × [Entire]"
  " is undefined, the function caller has to make sure, that this case does "
  "not occur."
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
  NDArray vector_xl = args (0).array_value ();
  NDArray vector_yl = args (1).array_value ();
  NDArray vector_xu = args (2).array_value ();
  NDArray vector_yu = args (3).array_value ();
  if (error_state)
    return octave_value_list ();
  
  if (vector_xl.numel () == 1 && vector_yl.numel () != 1)
    {
      // Broadcast vector x
      vector_xl.resize (vector_yl.dims (), vector_xl.elem (0));
      vector_xu.resize (vector_yl.dims (), vector_xu.elem (0));
    }
  else if (vector_yl.numel () == 1 && vector_xl.numel () != 1)
    {
      // Broadcast vector y
      vector_yl.resize (vector_xl.dims (), vector_yl.elem (0));
      vector_yu.resize (vector_xl.dims (), vector_yu.elem (0));
    }
  
  // Prepare parameters for mpfr_sum function
  const unsigned int n = vector_xl.numel ();
  mpfr_t* mp_addend_l = new mpfr_t [n];
  mpfr_t* mp_addend_u = new mpfr_t [n];
  mpfr_ptr* mp_addend_l_ptr = new mpfr_ptr [n];
  mpfr_ptr* mp_addend_u_ptr = new mpfr_ptr [n];
  mpfr_t mp_temp; // temporary mp number for comparison of two products
  mpfr_init2 (mp_temp, 2 * DOUBLE_PRECISION + 1);
  for (int i = 0; i < n; i++)
    {
      mp_addend_l_ptr [i] = mp_addend_l [i];
      mp_addend_u_ptr [i] = mp_addend_u [i];
      
      // Both factors can be multiplied within 107 bits exactly!
      mpfr_init2 (mp_addend_l [i], 2 * DOUBLE_PRECISION + 1);
      mpfr_set_d (mp_addend_l [i], vector_xl.elem (i), MPFR_RNDN);
      mpfr_mul_d (mp_addend_l [i], mp_addend_l [i],
                                   vector_yl.elem (i), MPFR_RNDN);
                                   
      mpfr_init2 (mp_addend_u [i], 2 * DOUBLE_PRECISION + 1);
      mpfr_set (mp_addend_u [i], mp_addend_l [i], MPFR_RNDN);
      
      // We have to compute the remaining 3 Products and determine min/max
      mpfr_set_d (mp_temp, vector_xl.elem (i), MPFR_RNDN);
      mpfr_mul_d (mp_temp, mp_temp, vector_yu.elem (i), MPFR_RNDN);
      mpfr_min (mp_addend_l [i], mp_addend_l [i], mp_temp, MPFR_RNDN);
      mpfr_max (mp_addend_u [i], mp_addend_u [i], mp_temp, MPFR_RNDN);
      
      mpfr_set_d (mp_temp, vector_xu.elem (i), MPFR_RNDN);
      mpfr_mul_d (mp_temp, mp_temp, vector_yl.elem (i), MPFR_RNDN);
      mpfr_min (mp_addend_l [i], mp_addend_l [i], mp_temp, MPFR_RNDN);
      mpfr_max (mp_addend_u [i], mp_addend_u [i], mp_temp, MPFR_RNDN);
      
      mpfr_set_d (mp_temp, vector_xu.elem (i), MPFR_RNDN);
      mpfr_mul_d (mp_temp, mp_temp, vector_yu.elem (i), MPFR_RNDN);
      mpfr_min (mp_addend_l [i], mp_addend_l [i], mp_temp, MPFR_RNDN);
      mpfr_max (mp_addend_u [i], mp_addend_u [i], mp_temp, MPFR_RNDN);
    }
  mpfr_clear (mp_temp);

  // Compute sums
  mpfr_t sum;
  mpfr_init2 (sum, DOUBLE_PRECISION);
  mpfr_sum (sum, mp_addend_l_ptr, n, MPFR_RNDD);
  octave_value_list result;
  result (0) = mpfr_get_d (sum, MPFR_RNDD);
  mpfr_sum (sum, mp_addend_u_ptr, n, MPFR_RNDU);
  result (1) = mpfr_get_d (sum, MPFR_RNDU);

  // Cleanup
  mpfr_clear (sum);
  for (int i = 0; i < n; i++)
    {
      mpfr_clear (mp_addend_l [i]);
      mpfr_clear (mp_addend_u [i]);
    }
  delete[] mp_addend_l_ptr;
  delete[] mp_addend_u_ptr;
  delete[] mp_addend_l;
  delete[] mp_addend_u;
  
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
