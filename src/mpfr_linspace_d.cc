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

DEFUN_DLD (mpfr_linspace_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@defun mpfr_linspace_d (@var{R}, @var{BASE}, @var{LIMIT}, @var{N})\n"
  "\n"
  "Return a row vector with @var{N} linearly spaced elements between "
  "@var{BASE} and @var{LIMIT}."
  "\n\n"
  "The result is rounded in the direction @var{R} (@option{+inf}: towards "
  "positive infinity, @option{-inf}: towards negative infinity)."
  "\n\n"
  "The result is not guaranteed to be correctly rounded, but should be within "
  "1 ULP of the correctly rounded result."
  "\n\n"
  "@example\n"
  "@group\n"
  "mpfr_linspace_d (-inf, 0, 10, 3)\n"
  "  @result{} ans = \n"
  "        0    5   10\n"
  "@end group\n"
  "@end example\n"
  "@seealso{linspace}\n"
  "@end defun"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin < 3 || nargin > 4)
    {
      print_usage ();
      return octave_value_list ();
    }

  const mpfr_rnd_t rnd = parse_rounding_mode (args(0).scalar_value ());
  Matrix base = args(1).column_vector_value ();
  Matrix limit = args(2).column_vector_value ();
  int n;
  if (nargin < 4)
    n = 100;
  else
    n = args(3).int_value ();
  if (base.numel () != limit.numel () &&
      base.numel () != 1 && limit.numel () != 1)
    error ("mpfr_linspace_d: vectors must be of equal length");
  if (rnd != MPFR_RNDD && rnd != MPFR_RNDU)
    error ("mpfr_linspace_d: only directed rounding supported");
  if (error_state)
    return octave_value_list ();

  // Result size
  n = std::max (n, 1);
  const int m = std::max (base.numel (), limit.numel ());
  
  // helper variables
  const bool broadcast_base = base.numel () == 1;
  const bool broadcast_limit = limit.numel () == 1;
  const unsigned int n_1 = n - 1;
  
  // Initialize result and temporary variables
  Matrix result_d (m, n);
  mpfr_t tmp1, tmp2;
  mpfr_init2 (tmp1, 2 * BINARY64_PRECISION);
  mpfr_init2 (tmp2, 2 * BINARY64_PRECISION);
  mpfr_t mp_base, mp_limit;
  mpfr_init2 (mp_base, BINARY64_PRECISION);
  mpfr_init2 (mp_limit, BINARY64_PRECISION);
  
  for (octave_idx_type i = 0; i < m; i ++)
    if (n == 1)
      result_d.elem (i, 0) = broadcast_limit ? limit.elem (0) : limit.elem (i);
    else
      {
        mpfr_set_d (mp_base,
                    broadcast_base ? base.elem (0) : base.elem (i),
                    MPFR_RNDZ);
        mpfr_set_d (mp_limit,
                    broadcast_limit ? limit.elem (0) : limit.elem (i),
                    MPFR_RNDZ);
        for (unsigned int j = 0; j <= n_1; j ++)
          {
            if (j == 0 || mpfr_equal_p (mp_base, mp_limit))
              result_d.elem (i, j) = mpfr_get_d (mp_base, MPFR_RNDZ);
            else if (j == n_1)
              result_d.elem (i, j) = mpfr_get_d (mp_limit, MPFR_RNDZ);
            else
              {
                mpfr_mul_ui (tmp1, mp_limit, j, MPFR_RNDZ); // exact
                mpfr_mul_ui (tmp2, mp_base, n_1 - j, MPFR_RNDZ); // exact
                mpfr_add (tmp1, tmp1, tmp2, rnd); // rounded
                mpfr_div_ui (tmp1, tmp1, n_1, rnd); // rounded
                result_d.elem (i, j) = mpfr_get_d (tmp1, rnd);
              }
          }
      }

  octave_value_list result;
  result(0) = result_d;

  // cleanup
  mpfr_clear (tmp1);
  mpfr_clear (tmp2);
  mpfr_clear (mp_base);
  mpfr_clear (mp_limit);

  return result;
}

/*
%!assert (mpfr_linspace_d (-inf, 1, 10, 10), 1 : 10);
%!assert (mpfr_linspace_d (inf, 1, 10, 8) - mpfr_linspace_d (-inf, 1, 10, 8), [0 2 2 4 4 4 8 0] .* eps);
*/
