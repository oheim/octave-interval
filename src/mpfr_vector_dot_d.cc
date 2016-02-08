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

  mpfr_t accu_l, accu_u;
  mpfr_init2 (accu_l, BINARY64_ACCU_PRECISION);
  mpfr_init2 (accu_u, BINARY64_ACCU_PRECISION);
  mpfr_set_zero (accu_l, 0);
  mpfr_set_zero (accu_u, 0);

  exact_interval_dot_product (accu_l, accu_u,
                              vector_xl, vector_xu,
                              vector_yl, vector_yu);

  std::pair <double, double> result (mpfr_get_d (accu_l, MPFR_RNDD),
                                     mpfr_get_d (accu_u, MPFR_RNDU));

  mpfr_clear (accu_l);
  mpfr_clear (accu_u);

  return result;
}

std::pair <double, double> vector_dot (
  mpfr_rnd_t rnd,
  Matrix vector_x, Matrix vector_y,
  const bool compute_error)
{
  if (vector_x.numel () == 1 && vector_y.numel () != 1)
    // Broadcast vector x
    vector_x = Matrix (vector_y.dims (), vector_x.elem (0));
  else if (vector_y.numel () == 1 && vector_x.numel () != 1)
    // Broadcast vector y
    vector_y = Matrix (vector_x.dims (), vector_y.elem (0));
  
  const octave_idx_type n = vector_x.numel ();
  // Compute sum of products in accumulator
  // This is faster than the less accurate mpfr_sum function, because we
  // do not have to instantiate an array of mpfr_t values.
  mpfr_t accu;
  mpfr_init2 (accu, BINARY64_ACCU_PRECISION);
  mpfr_set_zero (accu, 0);
  mpfr_t product;
  mpfr_init2 (product, 2 * BINARY64_PRECISION + 1);
  for (octave_idx_type i = 0; i < n; i++)
    {
      mpfr_set_d (product, vector_x.elem (i), MPFR_RNDZ);
      mpfr_mul_d (product, product, vector_y.elem (i), MPFR_RNDZ);
      
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
      
  mpfr_clear (accu);
  mpfr_clear (product);
  
  return std::pair <double, double> (result, error);
}

DEFUN_DLD (mpfr_vector_dot_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@deftypefun  {[@var{L}, @var{U}] =} mpfr_vector_dot_d (@var{XL}, @var{YL}, @var{XU}, @var{YU})\n"
  "@deftypefunx {[@var{D}, @var{E}] =} mpfr_vector_dot_d (@var{R}, @var{X}, @var{Y})\n"
  "\n"
  "Compute the dot product of binary64 numbers with correctly rounded result."
  "\n\n"
  "Syntax 1: Compute the lower and upper boundary of the dot product of "
  "interval vectors [@var{XL}, @var{XU}] and [@var{YL}, @var{YU}] with "
  "tightest accuracy."
  "\n\n"
  "Syntax 2: Compute the dot product @var{D} of two binary64 vectors with "
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
  "For syntax 2 only: If one element of any vector is NaN, infinities of "
  "both signs or a product of zero and (positive or negative) infinity are "
  "encountered, the result will be NaN.  An @emph{exact} zero is returned as "
  "+0 in all rounding directions, except for rounding towards negative "
  "infinity, where -0 is returned."
  "\n\n"
  "@example\n"
  "@group\n"
  "[l, u] = mpfr_vector_dot_d (-1, -1, 2, 3)\n"
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
  if (nargin < 3 || nargin > 4)
    {
      print_usage ();
      return octave_value_list ();
    }

  octave_value_list result;
  switch (nargin)
    {
      case 4: // Interval version
        {
          Matrix vector_xl = args (0).row_vector_value ();
          Matrix vector_yl = args (1).row_vector_value ();
          Matrix vector_xu = args (2).row_vector_value ();
          Matrix vector_yu = args (3).row_vector_value ();
          if (error_state)
            return octave_value_list ();
      
          std::pair <double, double> result_d = 
            interval_vector_dot (vector_xl, vector_yl, vector_xu, vector_yu);
          result (0) = result_d.first;
          result (1) = result_d.second;
          break;
        }
      case 3: // Non-interval version
        {
          const mpfr_rnd_t rnd = parse_rounding_mode (args (0).scalar_value());
          const Matrix vector_x = args (1).row_vector_value ();
          const Matrix vector_y = args (2).row_vector_value ();
          if (error_state)
            return octave_value_list ();
            
          std::pair <double, double> result_and_error
            = vector_dot (rnd, vector_x, vector_y, nargout >= 2);
          result (0) = result_and_error.first;
          result (1) = result_and_error.second;
          break;
        }
    }
  
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
