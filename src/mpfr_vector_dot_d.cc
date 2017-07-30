/*
  Copyright 2015-2016 Oliver Heimlich
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

std::pair <NDArray, NDArray> interval_vector_dot (
  NDArray array_xl, NDArray array_yl,
  NDArray array_xu, NDArray array_yu,
  octave_idx_type dim)
{
  int dimensions = std::max (array_xl.ndims (), array_yl.ndims ());
  if (dim > dimensions)
    {
      dimensions += 1;
      dim = dimensions;
    }
  dim_vector x_dims = array_xl.dims().redim (dimensions);
  dim_vector y_dims = array_yl.dims().redim (dimensions);
  // Inconsistency: dot ([], []) = 0
  if (array_xl.ndims () == 2 && x_dims(0) == 0 && x_dims(1) == 0 &&
      array_yl.ndims () == 2 && y_dims(0) == 0 && y_dims(1) == 0)
    {
      x_dims(1) = 1;
      y_dims(1) = 1;
    }
  dim_vector x_cdims = x_dims.cumulative ();
  dim_vector y_cdims = y_dims.cumulative ();

  // Check if broadcasting can be performed
  for (int d = 0; d < dimensions; d ++)
    {
      if (x_dims (d) != 1 && y_dims (d) != 1 &&
          x_dims (d) != y_dims (d))
        error ("mpfr_function_d: Array dimensions must agree!");
    }

  // Create result array of right size
  dim_vector result_dims;
  result_dims.resize (dimensions);

  for (int i = 0; i < dimensions; i ++)
    {
      result_dims(i) = std::max (x_dims(i), y_dims(i));
    }

  result_dims(dim - 1) = 1;

  std::pair <NDArray, NDArray> result;
  result.first = NDArray (result_dims);
  result.second = NDArray (result_dims);

  // Find increment for elements along dimension dim
  octave_idx_type x_idx_increment;
  octave_idx_type y_idx_increment;

  if (x_dims (dim - 1) == 1)
    x_idx_increment = 0;
  else if (dim == 1)
    x_idx_increment = 1;
  else
    x_idx_increment = x_cdims(dim - 2);

  if (y_dims (dim - 1) == 1)
    y_idx_increment = 0;
  else if (dim == 1)
    y_idx_increment = 1;
  else
    y_idx_increment = y_cdims(dim - 2);

  // Fix broadcasting along all singleton dimensions
  // Does not work for broadcasting along the first dimension
  for (int i = 1; i < dimensions; i ++)
    {
      if (x_dims(i) == 1)
        x_cdims(i-1) = 0;
      if (y_dims(i) == 1)
        y_cdims(i-1) = 0;
    }

  // Check if broadcasting along the first dimension is needed
  bool broadcast_first = (x_dims(0) == 1 && y_dims(0) != 1)
      || (x_dims(0) != 1 && y_dims(0) == 1);

  // Accumulators
  mpfr_t accu_l, accu_u, mp_addend_l, mp_addend_u, mp_temp;
  mpfr_init2 (accu_l, BINARY64_ACCU_PRECISION);
  mpfr_init2 (accu_u, BINARY64_ACCU_PRECISION);
  mpfr_init2 (mp_addend_l, 2 * BINARY64_PRECISION + 1);
  mpfr_init2 (mp_addend_u, 2 * BINARY64_PRECISION + 1);
  mpfr_init2 (mp_temp,     2 * BINARY64_PRECISION + 1);

  // Loop over all elements in the result
  octave_idx_type x_idx;
  octave_idx_type y_idx;
  OCTAVE_LOCAL_BUFFER_INIT (octave_idx_type, idx, dimensions, 0);

  octave_idx_type n = result.first.numel ();
  octave_idx_type m = std::max (x_dims(dim - 1), y_dims (dim - 1));

  for (octave_idx_type i = 0; i < n; i ++)
    {
      // Take broadcasting into account
      x_idx = x_cdims.cum_compute_index (idx);
      y_idx = y_cdims.cum_compute_index (idx);

      // Broadcasting along the first dimension needs to be handled
      // separately
      if (broadcast_first)
        {
          if (x_dims(0) == 1)
              x_idx -= idx[0];
          else
              y_idx -= idx[0];
        }

      mpfr_set_zero (accu_l, 0);
      mpfr_set_zero (accu_u, 0);

      // Compute result for current element
      for (octave_idx_type j = 0; j < m; j ++)
        {
          const double xl = array_xl.elem (x_idx + x_idx_increment*j);
          const double xu = array_xu.elem (x_idx + x_idx_increment*j);
          const double yl = array_yl.elem (y_idx + y_idx_increment*j);
          const double yu = array_yu.elem (y_idx + y_idx_increment*j);

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
            error ("failed to compute exact dot product");
      }
      result.first(i) = mpfr_get_d (accu_l, MPFR_RNDD);
      result.second(i) = mpfr_get_d (accu_u, MPFR_RNDU);

      result_dims.increment_index (idx);
    }
  mpfr_clear (accu_l);
  mpfr_clear (accu_u);
  mpfr_clear (mp_addend_l);
  mpfr_clear (mp_addend_u);
  mpfr_clear (mp_temp);

  return result;
}

std::pair <NDArray, NDArray> vector_dot (
  mpfr_rnd_t rnd,
  NDArray array_x, NDArray array_y,
  octave_idx_type dim,
  const bool compute_error)
{
    int dimensions = std::max (array_x.ndims (), array_y.ndims ());
    if (dim > dimensions)
      {
        dimensions += 1;
        dim = dimensions;
      }
    dim_vector x_dims = array_x.dims().redim (dimensions);
    dim_vector y_dims = array_y.dims().redim (dimensions);
    // Inconsistency: dot ([], []) = 0
    if (array_x.ndims () == 2 && x_dims(0) == 0 && x_dims(1) == 0 &&
        array_y.ndims () == 2 && y_dims(0) == 0 && y_dims(1) == 0)
      {
        x_dims(1) = 1;
        y_dims(1) = 1;
      }
    dim_vector x_cdims = x_dims.cumulative ();
    dim_vector y_cdims = y_dims.cumulative ();

    // Check if broadcasting can be performed
    for (int d = 0; d < dimensions; d ++)
      {
        if (x_dims (d) != 1 && y_dims (d) != 1 &&
            x_dims (d) != y_dims (d))
          error ("mpfr_function_d: Array dimensions must agree!");
      }

    // Create result array of right size
    dim_vector result_dims;
    result_dims.resize (dimensions);

    for (int i = 0; i < dimensions; i ++)
      {
        result_dims(i) = std::max (x_dims(i), y_dims(i));
      }

    result_dims(dim - 1) = 1;

    std::pair <NDArray, NDArray> result_and_error;
    result_and_error.first = NDArray (result_dims);
    result_and_error.second = NDArray (result_dims);

    // Find increment for elements along dimension dim
    octave_idx_type x_idx_increment;
    octave_idx_type y_idx_increment;

    if (x_dims (dim - 1) == 1)
      x_idx_increment = 0;
    else if (dim == 1)
      x_idx_increment = 1;
    else
      x_idx_increment = x_cdims(dim - 2);

    if (y_dims (dim - 1) == 1)
      y_idx_increment = 0;
    else if (dim == 1)
      y_idx_increment = 1;
    else
      y_idx_increment = y_cdims(dim - 2);

    // Fix broadcasting along all singleton dimensions
    // Does not work for broadcasting along the first dimension
    for (int i = 1; i < dimensions; i ++)
      {
        if (x_dims(i) == 1)
          x_cdims(i-1) = 0;
        if (y_dims(i) == 1)
          y_cdims(i-1) = 0;
      }

    // Check if broadcasting along the first dimension is needed
    bool broadcast_first = (x_dims(0) == 1 && y_dims(0) != 1)
        || (x_dims(0) != 1 && y_dims(0) == 1);

    // Accumulators
    mpfr_t accu, product;
    mpfr_init2 (accu, BINARY64_ACCU_PRECISION);
    mpfr_init2 (product, 2 * BINARY64_PRECISION + 1);

    // Loop over all elements in the result
    octave_idx_type x_idx;
    octave_idx_type y_idx;
    OCTAVE_LOCAL_BUFFER_INIT (octave_idx_type, idx, dimensions, 0);

    octave_idx_type n = result_and_error.first.numel ();
    octave_idx_type m = std::max (x_dims(dim - 1), y_dims (dim - 1));

    for (octave_idx_type i = 0; i < n; i ++)
      {
        // Take broadcasting into account
        x_idx = x_cdims.cum_compute_index (idx);
        y_idx = y_cdims.cum_compute_index (idx);

        // Broadcasting along the first dimension needs to be handled
        // separately
        if (broadcast_first)
          {
            if (x_dims(0) == 1)
              x_idx -= idx[0];
            else
              y_idx -= idx[0];
          }

        mpfr_set_zero (accu, 0);
        // Compute result for element i
        for (octave_idx_type j = 0; j < m; j ++)
          {
            mpfr_set_d (product, array_x.elem (x_idx + x_idx_increment*j),
                        MPFR_RNDZ);
            mpfr_mul_d (product, product,
                        array_y.elem (y_idx + y_idx_increment*j), MPFR_RNDZ);

            int exact = mpfr_add (accu, accu, product, MPFR_RNDZ);
            if (exact != 0)
              error ("mpfr_vector_dot_d: Failed to compute exact dot product");
            if (mpfr_nan_p (accu))
              // Short-Circtuit if one addend is NAN or if -INF + INF
              break;
          }
        double result;
        double error;
        if (mpfr_nan_p (accu) != 0)
          {
            result = NAN;
            error = NAN;
          }
        else
          {
            if (mpfr_cmp_d (accu, 0.0) == 0)
              {
                // exact zero
                if (rnd == MPFR_RNDD)
                  result = -0.0;
                else
                  result = +0.0;
                error = 0.0;
              }
            else
              {
                result = mpfr_get_d (accu, rnd);
                if (compute_error)
                  {
                    mpfr_sub_d (accu, accu, result, MPFR_RNDA);
                    error = mpfr_get_d (accu, MPFR_RNDA);
                  }
                else
                  error = 0.0;
              }
          }
        result_and_error.first(i) = result;
        result_and_error.second(i) = error;

        result_dims.increment_index (idx);
    }
    mpfr_clear (accu);
    mpfr_clear (product);

    return result_and_error;
}

DEFUN_DLD (mpfr_vector_dot_d, args, nargout,
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefun  {[@var{L}, @var{U}] =} mpfr_vector_dot_d (@var{XL}, @var{YL}, @var{XU}, @var{YU}, @var{DIM})\n"
  "@deftypefunx {[@var{D}, @var{E}] =} mpfr_vector_dot_d (@var{R}, @var{X}, @var{Y}, @var{dim})\n"
  "\n"
  "Compute the dot product of arrays of binary 64 numbers along dimension"
  "@var{DIM} with correctly rounded result."
  "\n\n"
  "Syntax 1: Compute the lower and upper boundary of the dot product of "
  "interval arrays [@var{XL}, @var{XU}] and [@var{YL}, @var{YU}] with "
  "tightest accuracy."
  "\n\n"
  "Syntax 2: Compute the dot product @var{D} of two binary64 arrays with "
  "correctly rounded result and rounding direction @var{R} (@option{0}: "
  "towards zero, @option{0.5}: towards nearest and ties to even, "
  "@option{+inf}: towards positive infinity, @option{-inf}: towards negative "
  "infinity).  Output parameter @var{E} yields an approximation of the error, "
  "that is the difference between the exact dot product and @var{D} as a "
  "second binary64 number, rounded towards zero."
  "\n\n"
  "The result is guaranteed to be tight / correctly rounded.  That is, the "
  "dot product is evaluated with (virtually) infinite precision and the exact "
  "result is approximated with a binary64 number using the desired rounding "
  "direction."
  "\n\n"
  "For syntax 2 only: If one element of a dot product is NaN, infinities of "
  "both signs or a product of zero and (positive or negative) infinity are "
  "encountered, the result will be NaN.  An @emph{exact} zero is returned as "
  "+0 in all rounding directions, except for rounding towards negative "
  "infinity, where -0 is returned."
  "\n\n"
  "@example\n"
  "@group\n"
  "[l, u] = mpfr_vector_dot_d (-1, -1, 2, 3, 1)\n"
  "  @result{}\n"
  "    l = -3\n"
  "    u = 6\n"
  "@end group\n"
  "@end example\n"
  "@seealso{dot}\n"
  "@end deftypefun"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin < 4 || nargin > 5)
    {
      print_usage ();
      return octave_value_list ();
    }

  octave_value_list result;
  switch (nargin)
    {
      case 5: // Interval version
        {
          NDArray array_xl = args (0).array_value ();
          NDArray array_yl = args (1).array_value ();
          NDArray array_xu = args (2).array_value ();
          NDArray array_yu = args (3).array_value ();
          octave_idx_type dim = args (4).scalar_value ();
          if (error_state)
            return octave_value_list ();

          std::pair <NDArray, NDArray> result_d =
              interval_vector_dot (array_xl, array_yl, array_xu, array_yu, dim);
          result (0) = result_d.first;
          result (1) = result_d.second;
          break;
        }
      case 4: // Non-interval version
        {
          const mpfr_rnd_t rnd = parse_rounding_mode (args (0).scalar_value());
          const NDArray array_x = args (1).array_value ();
          const NDArray array_y = args (2).array_value ();
          const octave_idx_type dim = args (3).scalar_value ();
          if (error_state)
            return octave_value_list ();

          std::pair <NDArray, NDArray> result_and_error
              = vector_dot (rnd, array_x, array_y, dim, nargout >= 2);
          result (0) = result_and_error.first;
          result (1) = result_and_error.second;
          break;
        }
    }

  return result;
}

/*
%!test;
%!  [l, u] = mpfr_vector_dot_d (-1, -1, 2, 3, 1);
%!  assert (l, -3);
%!  assert (u, 6);
%!test;
%!  x = [realmax, realmax, -realmax, -realmax, 1, eps/2];
%!  y = ones (size (x));
%!  [l, u] = mpfr_vector_dot_d (x, y, x, y, 2);
%!  d = mpfr_vector_dot_d (0.5, x, y, 2);
%!  assert (l, 1);
%!  assert (u, 1 + eps);
%!  assert (ismember (d, infsup (l, u)));
%!test;
%!  [l, u] = mpfr_vector_dot_d (0, 0, inf, inf, 1);
%!  d = mpfr_vector_dot_d (0.5, 0, inf, 1);
%!  assert (l, 0);
%!  assert (u, inf);
%!  assert (isequaln (d, NaN));
%!test;
%!  x = reshape (1:24, 2, 3, 4);
%!  y = 2.*ones (2, 3, 4);
%!  [l u] = mpfr_vector_dot_d (x, y, x, y, 3);
%!  d = mpfr_vector_dot_d (0.5, x, y, 3);
%!  assert (l, [80, 96, 112; 88, 104, 120]);
%!  assert (u, [80, 96, 112; 88, 104, 120]);
%!  assert (d, [80, 96, 112; 88, 104, 120]);

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.double.dot_nearest;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mpfr_vector_dot_d (0.5, testcase.in{1}, testcase.in{2}, 2), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.double.dot_nearest;
%! in1 = vertcat (testcases.in)(:, 1);
%! in1 = cell2mat (cellfun ("postpad", in1, {(max (cellfun ("numel", in1)))}, "UniformOutput", false));
%! in2 = vertcat (testcases.in)(:, 2);
%! in2 = cell2mat (cellfun ("postpad", in2, {(max (cellfun ("numel", in2)))}, "UniformOutput", false));
%! out = vertcat (testcases.out);
%! assert (isequaln (mpfr_vector_dot_d (0.5, in1, in2, 2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.double.sum_sqr_nearest;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mpfr_vector_dot_d (0.5, testcase.in{1}, testcase.in{1}, 2), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.double.sum_sqr_nearest;
%! in1 = vertcat (testcases.in);
%! in1 = cell2mat (cellfun ("postpad", in1, {(max (cellfun ("numel", in1)))}, "UniformOutput", false));
%! out = vertcat (testcases.out);
%! assert (isequaln (mpfr_vector_dot_d (0.5, in1, in1, 2), out));

*/
