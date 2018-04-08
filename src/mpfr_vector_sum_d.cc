/*
  Copyright 2015-2017 Oliver Heimlich
  Copyright 2017 Joel Dahne

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

DEFUN_DLD (mpfr_vector_sum_d, args, nargout,
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefun {[@var{S}, @var{E}] =} mpfr_vector_sum_d (@var{R}, @var{X}, "
  "@var{dim})\n\n"
  "Compute the sum @var{S} of all numbers in a binary64 array @var{X} along "
  "dimension @var{dim} with correctly rounded result."
  "\n\n"
  "@var{R} is the rounding direction (@option{0}: towards zero, @option{0.5}: "
  "towards nearest and ties to even, @option{+inf}: towards positive "
  "infinity, @option{-inf}: towards negative infinity)."
  "\n\n"
  "The result is guaranteed to be correctly rounded.  That is, the sum is "
  "evaluated with (virtually) infinite precision and the exact result is "
  "approximated with a binary64 number using the desired rounding direction."
  "\n\n"
  "If one element of the sum is NaN or infinities of both signs are "
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
  "mpfr_vector_sum_d (-inf, [1, eps/2, realmax, -realmax], 2) == 1\n"
  "  @result{} 1\n"
  "mpfr_vector_sum_d (+inf, [1, eps/2, realmax, -realmax], 2) == 1 + eps\n"
  "  @result{} 1\n"
  "@end group\n"
  "@end example\n"
  "@seealso{sum}\n"
  "@end deftypefun"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin != 3)
    {
      print_usage ();
      return octave_value_list ();
    }

  // Read parameters
  const mpfr_rnd_t rnd      = parse_rounding_mode (args (0).scalar_value ());
  const NDArray    array    = args (1).array_value ();
  const octave_idx_type dim = args (2).scalar_value ();
  if (error_state)
    return octave_value_list ();

  if (dim > array.ndims ())
    {
      // Nothing to be done
      return octave_value (array);
    }

  // Determine size for result
  dim_vector array_dims = array.dims ();
  // Inconsistency: sum ([]) = 0
  if (array.ndims () == 2 && array_dims(0) == 0 && array_dims(1) == 0)
      array_dims(1) = 1;
  dim_vector array_cdims = array_dims.cumulative ();
  dim_vector result_dims = array_dims;
  result_dims (dim - 1) = 1;
  result_dims.chop_trailing_singletons ();
  dim_vector result_cdims = result_dims.cumulative ();
  NDArray result_sum (result_dims);
  NDArray result_error (result_dims);

  mpfr_t accu;
  mpfr_init2 (accu, BINARY64_ACCU_PRECISION);

  octave_idx_type step;
  if (dim > 1)
      step = array_cdims (dim - 2);
  else
      step = 1;
  octave_idx_type n = result_dims.numel ();
  octave_idx_type m = array_dims (dim - 1) * step;
  octave_idx_type idx_array;
  octave_idx_type idx_result;

  OCTAVE_LOCAL_BUFFER_INIT (octave_idx_type, idx, array.ndims (), 0);

  for (int i = 0; i < n; i ++)
  {
      idx_array = array_cdims.cum_compute_index (idx);
      idx_result = result_cdims.cum_compute_index (idx);
      mpfr_set_zero (accu, 0);

      // Perform the summation
      for (octave_idx_type j = 0; j < m; j += step)
      {
          int exact = mpfr_add_d (accu, accu, array (idx_array + j), rnd);
          if (exact != 0)
              error ("mpfr_vector_sum_d: Failed to compute exact sum");
          if (mpfr_nan_p (accu))
              // Short-Circtuit if one addend is NAN or if -INF + INF
              break;
      }

      // Check the result
      if (mpfr_nan_p (accu) != 0)
      {
          result_sum.elem (idx_result) = NAN;
          result_error (idx_result) = NAN;
      }
      else
          if (mpfr_cmp_d (accu, 0.0) == 0)
          {
              // exact zero
              if (rnd == MPFR_RNDD)
                  result_sum.elem (idx_result) = -0.0;
              else
                  result_sum.elem (idx_result) = +0.0;
              result_error (idx_result) = 0.0;
          }
          else
          {
              const double sum = mpfr_get_d (accu, rnd);
              result_sum.elem (idx_result) = sum;
              if (nargout >= 2)
              {
                  mpfr_sub_d (accu, accu, sum, MPFR_RNDA);
                  const double error = mpfr_get_d (accu, MPFR_RNDA);
                  result_error.elem (idx_result) = error;
              }
          }
      result_dims.increment_index (idx);
  }

  mpfr_clear (accu);
  octave_value_list result;
  result (0) = octave_value (result_sum);
  result (1) = octave_value (result_error);
  return result;
}

/*
%!assert (mpfr_vector_sum_d (0, [eps, realmax, realmax, -realmax, -realmax], 2), eps)
%!assert (mpfr_vector_sum_d (-inf, [eps/2, 1], 2), 1)
%!assert (mpfr_vector_sum_d (+inf, [eps/2, 1], 2), 1 + eps)
%!test
%!  a = inf (infsup ("0X1.1111111111111P+100"));
%!  b = inf (infsup ("0X1.1111111111111P+1"));
%!  [s, e] = mpfr_vector_sum_d (0.5, [a, b], 2);
%!  assert (s, a);
%!  assert (e, b);
%!test
%!  a = inf (infsup ("0X1.1111111111111P+53"));
%!  b = inf (infsup ("0X1.1111111111111P+1"));
%!  c = inf (infsup ("0X1.1111111111112P+53"));
%!  d = inf (infsup ("0X1.111111111111P-3"));
%!  [s, e] = mpfr_vector_sum_d (0.5, [a, b], 2);
%!  assert (s, c);
%!  assert (e, d);
%!test
%!  a = inf (infsup ("0X1.1111111111111P+2"));
%!  b = inf (infsup ("0X1.1111111111111P+1"));
%!  c = inf (infsup ("0X1.999999999999AP+2"));
%!  d = inf (infsup ("-0X1P-51"));
%!  [s, e] = mpfr_vector_sum_d (0.5, [a, b], 2);
%!  assert (s, c);
%!  assert (e, d);
%!test
%!  for dim = 1:6
%!    assert (mpfr_vector_sum_d (0.5, ones (1, 2, 3, 4, 5), dim), sum (ones (1, 2, 3, 4, 5), dim));
%!  endfor

%!shared testdata
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.double.sum_nearest;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mpfr_vector_sum_d (0.5, testcase.in{1}, 2), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.double.sum_nearest;
%! in1 = vertcat (testcases.in);
%! in1 = cell2mat (cellfun ("postpad", in1, {(max (cellfun ("numel", in1)))}, "UniformOutput", false));
%! out = vertcat (testcases.out);
%! assert (isequaln (mpfr_vector_sum_d (0.5, in1, 2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.double.sum_abs_nearest;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mpfr_vector_sum_d (0.5, abs (testcase.in{1}), 2), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.double.sum_abs_nearest;
%! in1 = vertcat (testcases.in);
%! in1 = cell2mat (cellfun ("postpad", in1, {(max (cellfun ("numel", in1)))}, "UniformOutput", false));
%! out = vertcat (testcases.out);
%! assert (isequaln (mpfr_vector_sum_d (0.5, abs (in1), 2), out));

*/
