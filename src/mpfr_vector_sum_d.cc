/*
  Copyright 2015-2016 Oliver Heimlich
  
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
  "@documentencoding UTF-8\n"
  "@deftypefun {[@var{S}, @var{E}] =} mpfr_vector_sum_d (@var{R}, @var{X})\n"
  "\n"
  "Compute the sum @var{S} of all numbers in a binary64 vector @var{X} with "
  "correctly rounded result."
  "\n\n"
  "@var{R} is the rounding direction (@option{0}: towards zero, @option{0.5}: "
  "towards nearest and ties to even, @option{+inf}: towards positive "
  "infinity, @option{-inf}: towards negative infinity)."
  "\n\n"
  "The result is guaranteed to be correctly rounded.  That is, the sum is "
  "evaluated with (virtually) infinite precision and the exact result is "
  "approximated with a binary64 number using the desired rounding direction."
  "\n\n"
  "If one element of the vector is NaN or infinities of both signs are "
  "encountered, the result will be NaN.  An @emph{exact} zero is returned as "
  "+0 in all rounding directions, except for rounding towards negative "
  "infinity, where -0 is returned."
  "\n\n"
  "A second output parameter yields an approximation of the error.  The "
  "difference between the exact sum over @var{X} and @var{S} is approximated "
  "by a second binary64 number @var{E} with rounding towards zero."
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
  
  // Read parameters
  const mpfr_rnd_t rnd    = parse_rounding_mode (args (0).scalar_value ());
  const Matrix     vector = args (1).row_vector_value ();
  if (error_state)
    return octave_value_list ();
  
  const octave_idx_type n = vector.numel ();
  // Compute sum in accumulator
  // This is faster than the less accurate mpfr_sum function, because we
  // do not have to instantiate an array of mpfr_t values.
  mpfr_t accu;
  mpfr_init2 (accu, BINARY64_ACCU_PRECISION);
  mpfr_set_zero (accu, 0);
  for (octave_idx_type i = 0; i < n; i++)
    {
      int exact = mpfr_add_d (accu, accu, vector.elem (i), rnd);
      if (exact != 0)
        error ("mpfr_vector_sum_d: Failed to compute exact sum");
      if (mpfr_nan_p (accu))
        // Short-Circtuit if one addend is NAN or if -INF + INF
        break;
    }

  octave_value_list result;
  if (mpfr_nan_p (accu) != 0)
    {
      result (0) = NAN;
      result (1) = NAN;
    }
  else
    if (mpfr_cmp_d (accu, 0.0) == 0)
      {
        // exact zero
        if (rnd == MPFR_RNDD)
          result (0) = -0.0;
        else
          result (0) = +0.0;
        result (1) = 0.0;
      }
    else
      {
        const double sum = mpfr_get_d (accu, rnd);
        result (0) = sum;
        if (nargout >= 2)
          {
            mpfr_sub_d (accu, accu, sum, MPFR_RNDA);
            const double error = mpfr_get_d (accu, MPFR_RNDA);
            result (1) = error;
          }
      }
      
  mpfr_clear (accu);
  
  return result;
}

/*
%!assert (mpfr_vector_sum_d (0, [eps, realmax, realmax, -realmax, -realmax]), eps)
%!assert (mpfr_vector_sum_d (-inf, [eps/2, 1]), 1)
%!assert (mpfr_vector_sum_d (+inf, [eps/2, 1]), 1 + eps)
*/
