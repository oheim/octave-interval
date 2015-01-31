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

DEFUN_DLD (mpfr_vector_sum_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding utf-8\n"
  "@deftypefn  {Loadable Function} {} mpfr_vector_sum_d (@var{R}, @var{X})\n"
  "\n"
  "Compute the sum of all numbers in a vector @var{X} with double precision "
  "and quite accurate result."
  "\n\n"
  "@var{R} is the rounding direction (0: towards zero, 0.5 towards nearest "
  "and ties to even, inf towards positive infinity, -inf towards negative "
  "infinity."
  "\n\n"
  "The result is not guaranteed to be exactly rounded, however the result is "
  "smaller than or larger than the exact result in accordance with the "
  "rounding mode.  The result's accurracy is within about 1.5 ULPs."
  "\n\n"
  "@example\n"
  "@group\n"
  "mpfr_vector_sum_d (-inf, [1, eps/2, realmax, -realmax]) == 1\n"
  "  @result{} 1\n"
  "mpfr_vector_sum_d (+inf, [1, eps/2, realmax, -realmax]) == 1 + eps\n"
  "  @result{} 1\n"
  "@end group\n"
  "@end example\n"
  "@seealso{sum}\n"
  "@end deftypefn"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin != 2)
    {
      print_usage ();
      return octave_value_list ();
    }
  
  // Read parameters
  const mpfr_rnd_t  rnd      = parse_rounding_mode (
                               args (0).array_value ());
  const NDArray     vector   = args (1).array_value ();
  if (error_state)
    return octave_value_list ();
  
  // Prepare parameters for mpfr_sum function
  const unsigned int n = vector.numel ();
  mpfr_t* mp_addend = new mpfr_t [n];
  mpfr_ptr* mp_addend_ptr = new mpfr_ptr [n];
  for (int i = 0; i < n; i++)
    {
      mp_addend_ptr [i] = mp_addend [i];
      mpfr_init2 (mp_addend [i], DOUBLE_PRECISION);
      mpfr_set_d (mp_addend [i], vector.elem (i), rnd);
    }

  // Compute sum
  mpfr_t sum;
  mpfr_init2 (sum, DOUBLE_PRECISION);
  mpfr_sum (sum, mp_addend_ptr, n, rnd);
  const double result = mpfr_get_d (sum, rnd);

  // Cleanup
  mpfr_clear (sum);
  for (int i = 0; i < n; i++)
    mpfr_clear (mp_addend [i]);
  delete[] mp_addend_ptr;
  delete[] mp_addend;
  
  return octave_value (result);
}

/*
%!assert (mpfr_vector_sum_d (0, [eps, realmax, realmax, -realmax, -realmax]), eps)
%!assert (mpfr_vector_sum_d (-inf, [eps/2, 1]), 1)
%!assert (mpfr_vector_sum_d (+inf, [eps/2, 1]), 1 + eps)
*/
