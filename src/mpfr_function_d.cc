/*
  Copyright 2015 Oliver Heimlich
  Copyright 2017 Joel Dahne
  Copyright 2009-2017 Jaroslav Hajek
  Copyright 2009 VZLU Prague

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

typedef int (*mpfr_unary_fun)
            (mpfr_t rop, const mpfr_t op,
                         mpfr_rnd_t rnd);
typedef int (*mpfr_binary_fun)
            (mpfr_t rop, const mpfr_t op1,
                         const mpfr_t op2,
                         mpfr_rnd_t rnd);
typedef int (*mpfr_ternary_fun)
            (mpfr_t rop, const mpfr_t op1,
                         const mpfr_t op2,
                         const mpfr_t op3,
                         mpfr_rnd_t rnd);

// Evaluate an unary MPFR function on a binary64 array
void evaluate (
  NDArray &arg1,          // Operand 1 and result
  const mpfr_rnd_t rnd,   // Rounding direction
  const mpfr_unary_fun f) // The MPFR function to evaluate (element-wise)
{
  mpfr_t mp;
  mpfr_init2 (mp, BINARY64_PRECISION);
  mpfr_exp_t old_emin = mpfr_get_emin ();
  mpfr_set_emin (BINARY64_EMIN);

  const octave_idx_type n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp, arg1.elem (i), MPFR_RNDZ);
      int rnd_error = (*f) (mp, mp, rnd);
      if (rnd == MPFR_RNDN)
        {
          // Prevent double-rounding errors
          mpfr_subnormalize (mp, rnd_error, rnd);
        }
      arg1.elem (i) = mpfr_get_d (mp, rnd);
    }

  mpfr_clear (mp);
  mpfr_set_emin (old_emin);
}

// Evaluate a binary MPFR function on two binary64 arrays
void evaluate (
  NDArray &arg1,           // Operand 1 and result
  const NDArray &arg2,     // Operand 2
  const mpfr_rnd_t rnd,    // Rounding direction
  const mpfr_binary_fun f) // The MPFR function to evaluate (element-wise)
{
  mpfr_t mp1, mp2;
  mpfr_init2 (mp1, BINARY64_PRECISION);
  mpfr_init2 (mp2, BINARY64_PRECISION);
  mpfr_exp_t old_emin = mpfr_get_emin ();
  mpfr_set_emin (BINARY64_EMIN);

  int dimensions = std::max (arg1.ndims (), arg2.ndims ());
  dim_vector arg1_dims = arg1.dims().redim (dimensions);
  dim_vector arg2_dims = arg2.dims().redim (dimensions);
  dim_vector arg1_cdims = arg1_dims.cumulative ();
  dim_vector arg2_cdims = arg2_dims.cumulative ();

  // Create result array of right size
  dim_vector result_dims;
  result_dims.resize (dimensions);

  for (int i = 0; i < dimensions; i ++)
    {
      if (arg1_dims(i) != 1)
        result_dims(i) = arg1_dims(i);
      else
        result_dims(i) = arg2_dims(i);
    }

  NDArray result (result_dims);

  // Find the first dimension that needs broadcasting
  octave_idx_type start;
  octave_idx_type step = 1;
  for (start = 0; start < dimensions; start ++)
  {
    if (arg1_dims(start) != arg2_dims(start))
      break;
    step = arg1_cdims (start);
  }

  // Fix broadcasting along all singleton dimensions
  // Does not work for broadcasting along the first dimension
  for (int i = std::max (start, static_cast <octave_idx_type> (1)); i < dimensions; i ++)
  {
    if (arg1_dims(i) == 1)
      arg1_cdims(i-1) = 0;
    if (arg2_dims(i) == 1)
      arg2_cdims(i-1) = 0;
  }

  // Perform the operation
  octave_idx_type arg1_idx;
  octave_idx_type arg2_idx;
  OCTAVE_LOCAL_BUFFER_INIT (octave_idx_type, idx_base, dimensions, 0);

  octave_idx_type n = result.numel ();

  for (octave_idx_type iter = 0; iter < n; iter += step)
  {
    // Take broadcasting into account
    arg1_idx = arg1_cdims.cum_compute_index (idx_base);
    arg2_idx = arg2_cdims.cum_compute_index (idx_base);
    // Broadcasting along the first dimension needs to be handled
    // separately
    if (start == 0)
      {
        if (arg1_dims(0) == 1)
          arg1_idx -= idx_base[0];
        else
          arg2_idx -= idx_base[0];
      }

    for (octave_idx_type i = 0; i < step; i ++)
      {
        mpfr_set_d (mp1, arg1.elem (arg1_idx + i), MPFR_RNDZ);
        mpfr_set_d (mp2, arg2.elem (arg2_idx + i), MPFR_RNDZ);
        int rnd_error = (*f) (mp1, mp1, mp2, rnd);
        if (rnd == MPFR_RNDN)
          {
            // Prevent double-rounding errors
            mpfr_subnormalize (mp1, rnd_error, rnd);
          }
        result.elem (iter + i) = mpfr_get_d (mp1, rnd);
      }

    result_dims.increment_index (idx_base + start, start);
  }

  arg1 = result;

  mpfr_clear (mp1);
  mpfr_clear (mp2);
  mpfr_set_emin (old_emin);
}

// Evaluate a ternary MPFR function on three binary64 arrays
void evaluate (
  NDArray &arg1,            // Operand 1 and result
  const NDArray &arg2,      // Operand 2
  const NDArray &arg3,      // Operand 3
  const mpfr_rnd_t rnd,     // Rounding direction
  const mpfr_ternary_fun f) // The MPFR function to evaluate (element-wise)
{
  mpfr_t mp1, mp2, mp3;
  mpfr_init2 (mp1, BINARY64_PRECISION);
  mpfr_init2 (mp2, BINARY64_PRECISION);
  mpfr_init2 (mp3, BINARY64_PRECISION);
  mpfr_exp_t old_emin = mpfr_get_emin ();
  mpfr_set_emin (BINARY64_EMIN);

  // Note that no broadcasting is performed here, this is because
  // currently no ternary functions needs broadcasting

  const octave_idx_type n = arg1.numel ();

  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp1, arg1.elem (i), MPFR_RNDZ);
      mpfr_set_d (mp2, arg2.elem (i), MPFR_RNDZ);
      mpfr_set_d (mp3, arg3.elem (i), MPFR_RNDZ);
      int rnd_error = (*f) (mp1, mp1, mp2, mp3, rnd);
      if (rnd == MPFR_RNDN)
        {
          // Prevent double-rounding errors
          mpfr_subnormalize (mp1, rnd_error, rnd);
        }
      arg1.elem (i) = mpfr_get_d (mp1, rnd);
    }

  mpfr_clear (mp1);
  mpfr_clear (mp2);
  mpfr_clear (mp3);
  mpfr_set_emin (old_emin);
}

// Evaluate nthroot
void nthroot (
  NDArray &arg1,       // Operand 1 and result
  const uint64NDArray arg2, // Operand 2
  const mpfr_rnd_t rnd)
{
  mpfr_t mp;
  mpfr_init2 (mp, BINARY64_PRECISION);

  // Note that no broadcasting is performed here, this is because
  // that nthroot performs the broadcasting in the m-file

  const octave_idx_type n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp, arg1.elem (i), MPFR_RNDZ);
      mpfr_rootn_ui (mp, mp, static_cast <uint64_t> (arg2.elem(i)), rnd);
      arg1.elem (i) = mpfr_get_d (mp, rnd);
    }

  mpfr_clear (mp);
}

// Evaluate factorial
void factorial (
  NDArray &arg1, // Operand 1 and result
  const mpfr_rnd_t rnd)
{
  mpfr_t mp;
  mpfr_init2 (mp, BINARY64_PRECISION);

  const octave_idx_type n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      if (std::isnan (arg1.elem (i)))
        continue;

      if (arg1.elem (i) < 2.0)
        {
          arg1.elem (i) = 1.0;
          continue;
        }

      if (arg1.elem (i) >= 171.0)
        {
          // Computation can become hard for large numbers,
          // thus we can short-circuit here.
          switch (rnd)
            {
              case MPFR_RNDZ:
              case MPFR_RNDD:
                arg1.elem (i) = std::numeric_limits <double>::max ();
                continue;
              case MPFR_RNDA:
              case MPFR_RNDU:
              case MPFR_RNDN:
                arg1.elem (i) = +INFINITY;
                continue;
              default:
                break;
            }
        }

      // The factorial function is defined as the product of all positive
      // integers less than or equal to n.
      const double current_arg = floor (arg1.elem (i));

      mpfr_fac_ui (mp, static_cast <unsigned long int> (current_arg), rnd);
      arg1.elem (i) = mpfr_get_d (mp, rnd);
    }

  mpfr_clear (mp);
}

DEFUN_DLD (mpfr_function_d, args, nargout,
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@defun mpfr_function_d ('acos', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('acosh', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('asin', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('asinh', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('atan', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('atan2', @var{R}, @var{Y}, @var{X})\n"
  "@defunx mpfr_function_d ('atanh', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('cbrt', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('cos', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('cosh', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('cot', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('coth', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('csc', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('csch', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('dilog', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('ei', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('erf', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('erfc', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('exp', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('expm1', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('factorial', @var{R}, @var{N})\n"
  "@defunx mpfr_function_d ('fma', @var{R}, @var{X}, @var{Y}, @var{Z})\n"
  "@defunx mpfr_function_d ('gamma', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('gammaln', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('hypot', @var{R}, @var{X}, @var{Y})\n"
  "@defunx mpfr_function_d ('log', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('log2', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('log10', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('log1p', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('minus', @var{R}, @var{X}, @var{Y})\n"
  "@defunx mpfr_function_d ('nthroot', @var{R}, @var{X}, @var{N})\n"
  "@defunx mpfr_function_d ('plus', @var{R}, @var{X}, @var{Y})\n"
  "@defunx mpfr_function_d ('pow', @var{R}, @var{X}, @var{Y})\n"
  "@defunx mpfr_function_d ('pow2', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('pow10', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('psi', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('rdivide', @var{R}, @var{X}, @var{Y})\n"
  "@defunx mpfr_function_d ('realsqrt', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('rem', @var{R}, @var{X}, @var{Y})\n"
  "@defunx mpfr_function_d ('rsqrt', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sec', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sech', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sin', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sinh', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sqr', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('tan', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('tanh', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('times', @var{R}, @var{X}, @var{Y})\n"
  "\n"
  "Evaluate a function in binary64 with correctly rounded result."
  "\n\n"
  "Parameter 1 is the function's name in GNU Octave, Parameter 2 is the "
  "rounding direction (@option{0}: towards zero, @option{0.5}: towards "
  "nearest and ties to even, @option{+inf}: towards positive infinity, "
  "@option{-inf}: towards negative infinity).  "
  "Parameters 3 and (possibly) 4 and 5 are operands to the function."
  "\n\n"
  "Evaluated on arrays, the function will be applied element-wise.  "
  "For binary functions broadcasting is performed where needed.  "
  "For ternary functions no broadcasting is performed.  "
  "\n\n"
  "The result is guaranteed to be correctly rounded.  That is, the function "
  "is evaluated with (virtually) infinite precision and the exact result is "
  "approximated with a binary64 number using the desired rounding direction."
  "\n\n"
  "@example\n"
  "@group\n"
  "mpfr_function_d ('plus', -inf, 1, eps / 2) == 1\n"
  "  @result{} 1\n"
  "mpfr_function_d ('plus', +inf, 1, eps / 2) == 1 + eps\n"
  "  @result{} 1\n"
  "@end group\n"
  "@end example\n"
  "@seealso{crlibm_function}\n"
  "@end defun"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin < 3 || nargin > 5)
    {
      print_usage ();
      return octave_value_list ();
    }

  // Read parameters
  const std::string function = args (0).string_value ();
  const mpfr_rnd_t  rnd      = parse_rounding_mode (args (1).scalar_value ());
  NDArray           arg1     = args (2).array_value ();
  NDArray           arg2;
  NDArray           arg3;
  if (nargin >= 4)
    {
      arg2                   = args (3).array_value ();
      // Check if broadcasting can be performed
      int dimensions = std::max (arg1.ndims (), arg2.ndims ());
      dim_vector arg1_dims = arg1.dims().redim (dimensions);
      dim_vector arg2_dims = arg2.dims().redim (dimensions);
      for (int dim = 0; dim < dimensions; dim ++)
        {
          if (arg1_dims (dim) != 1 && arg2_dims (dim) != 1 &&
              arg1_dims (dim) != arg2_dims (dim))
            error ("mpfr_function_d: Array dimensions must agree!");
        }
    }
  if (nargin >= 5)
    {
      arg3                   = args (4).array_value ();
      // We never perform broadcasting for ternary functions so all
      // dimensions must be equal
      if (arg1.dims () != arg2.dims () || arg2.dims () != arg3.dims ())
        error ("mpfr_function_d: Array dimensions must agree!");
    }

  // Choose the function to evaluate
  switch (nargin - 2)
    {
      case 1: // unary function
        if      (function == "acos")
          evaluate (arg1, rnd, &mpfr_acos);
        else if (function == "acosh")
          evaluate (arg1, rnd, &mpfr_acosh);
        else if (function == "asin")
          evaluate (arg1, rnd, &mpfr_asin);
        else if (function == "asinh")
          evaluate (arg1, rnd, &mpfr_asinh);
        else if (function == "atan")
          evaluate (arg1, rnd, &mpfr_atan);
        else if (function == "atanh")
          evaluate (arg1, rnd, &mpfr_atanh);
        else if (function == "cbrt")
          evaluate (arg1, rnd, &mpfr_cbrt);
        else if (function == "cos")
          evaluate (arg1, rnd, &mpfr_cos);
        else if (function == "cosh")
          evaluate (arg1, rnd, &mpfr_cosh);
        else if (function == "cot")
          evaluate (arg1, rnd, &mpfr_cot);
        else if (function == "coth")
          evaluate (arg1, rnd, &mpfr_coth);
        else if (function == "csc")
          evaluate (arg1, rnd, &mpfr_csc);
        else if (function == "csch")
          evaluate (arg1, rnd, &mpfr_csch);
        else if (function == "dilog")
          evaluate (arg1, rnd, &mpfr_li2);
        else if (function == "ei")
          evaluate (arg1, rnd, &mpfr_eint);
        else if (function == "erf")
          evaluate (arg1, rnd, &mpfr_erf);
        else if (function == "erfc")
          evaluate (arg1, rnd, &mpfr_erfc);
        else if (function == "exp")
          evaluate (arg1, rnd, &mpfr_exp);
        else if (function == "expm1")
          evaluate (arg1, rnd, &mpfr_expm1);
        else if (function == "factorial")
          factorial (arg1, rnd);
        else if (function == "gamma")
          evaluate (arg1, rnd, &mpfr_gamma);
        else if (function == "gammaln")
          evaluate (arg1, rnd, &mpfr_lngamma);
        else if (function == "log")
          evaluate (arg1, rnd, &mpfr_log);
        else if (function == "log2")
          evaluate (arg1, rnd, &mpfr_log2);
        else if (function == "log10")
          evaluate (arg1, rnd, &mpfr_log10);
        else if (function == "log1p")
          evaluate (arg1, rnd, &mpfr_log1p);
        else if (function == "pow2")
          evaluate (arg1, rnd, &mpfr_exp2);
        else if (function == "pow10")
          evaluate (arg1, rnd, &mpfr_exp10);
        else if (function == "psi")
          evaluate (arg1, rnd, &mpfr_digamma);
        else if (function == "realsqrt")
          evaluate (arg1, rnd, &mpfr_sqrt);
        else if (function == "rsqrt")
          evaluate (arg1, rnd, &mpfr_rec_sqrt);
        else if (function == "sec")
          evaluate (arg1, rnd, &mpfr_sec);
        else if (function == "sech")
          evaluate (arg1, rnd, &mpfr_sech);
        else if (function == "sin")
          evaluate (arg1, rnd, &mpfr_sin);
        else if (function == "sinh")
          evaluate (arg1, rnd, &mpfr_sinh);
        else if (function == "sqr")
          evaluate (arg1, rnd, &mpfr_sqr);
        else if (function == "tan")
          evaluate (arg1, rnd, &mpfr_tan);
        else if (function == "tanh")
          evaluate (arg1, rnd, &mpfr_tanh);
        else
          {
            print_usage();
            return octave_value_list ();
          }
        break;

      case 2: // binary function
        if      (function == "atan2")
          evaluate (arg1, arg2, rnd, &mpfr_atan2);
        else if (function == "hypot")
          evaluate (arg1, arg2, rnd, &mpfr_hypot);
        else if (function == "minus")
          evaluate (arg1, arg2, rnd, &mpfr_sub);
        else if (function == "nthroot")
          {
            uint64NDArray n = args (3).uint64_array_value ();
            nthroot (arg1, n, rnd);
          }
        else if (function == "plus")
          evaluate (arg1, arg2, rnd, &mpfr_add);
        else if (function == "pow")
          evaluate (arg1, arg2, rnd, &mpfr_pow);
        else if (function == "rdivide")
          evaluate (arg1, arg2, rnd, &mpfr_div);
        else if (function == "rem")
          evaluate (arg1, arg2, rnd, &mpfr_fmod);
        else if (function == "times")
          evaluate (arg1, arg2, rnd, &mpfr_mul);
        else
          {
            print_usage();
            return octave_value_list ();
          }
        break;

      case 3: // ternary function
        if      (function == "fma")
          evaluate (arg1, arg2, arg3, rnd, &mpfr_fma);
        else
          {
            print_usage();
            return octave_value_list ();
          }
        break;
    }

  return octave_value (arg1);
}

/*
%!assert (mpfr_function_d ('plus', 0, 2, 2), 4);
%!assert (mpfr_function_d ('plus', -inf, 1, eps / 2), 1);
%!assert (mpfr_function_d ('plus', +inf, 1, eps / 2), 1 + eps);
%!error mpfr_function_d ('Krauskefarben', 0, 47, 11);

%!# Cross-check unit tests from crlibm against the MPFR library.
%!# We simulate binary64 floating-point arithmetic in MPFR
%!# with mpfr_function_d and results shall be identical.
%!#
%!shared testdata
%! testdata = load (fullfile (...
%!   fileparts (file_in_loadpath ("__check_crlibm__.m")), ...
%!   "test", ...
%!   "crlibm.mat"));

%!function verify (fname, rnd, data)
%!  assert (mpfr_function_d (fname, rnd, data.input), data.output);
%!endfunction

%!test verify ("acos", -inf, testdata.acos_rd);
%!test verify ("acos", +inf, testdata.acos_ru);
%!test verify ("acos",  0.5, testdata.acos_rn);
%!test verify ("acos",  0,   testdata.acos_rz);

%!test verify ("asin", -inf, testdata.asin_rd);
%!test verify ("asin", +inf, testdata.asin_ru);
%!test verify ("asin",  0.5, testdata.asin_rn);
%!test verify ("asin",  0,   testdata.asin_rz);

%!test verify ("atan", -inf, testdata.atan_rd);
%!test verify ("atan", +inf, testdata.atan_ru);
%!test verify ("atan",  0.5, testdata.atan_rn);
%!test verify ("atan",  0,   testdata.atan_rz);

%!test verify ("cos", -inf, testdata.cos_rd);
%!test verify ("cos", +inf, testdata.cos_ru);
%!test verify ("cos",  0.5, testdata.cos_rn);
%!test verify ("cos",  0,   testdata.cos_rz);

%!test verify ("cosh", -inf, testdata.cosh_rd);
%!test verify ("cosh", +inf, testdata.cosh_ru);
%!test verify ("cosh",  0.5, testdata.cosh_rn);
%!test verify ("cosh",  0,   testdata.cosh_rz);

%!test verify ("exp", -inf, testdata.exp_rd);
%!test verify ("exp", +inf, testdata.exp_ru);
%!test verify ("exp",  0.5, testdata.exp_rn);
%!test verify ("exp",  0,   testdata.exp_rz);

%!test verify ("expm1", -inf, testdata.expm1_rd);
%!test verify ("expm1", +inf, testdata.expm1_ru);
%!test verify ("expm1",  0.5, testdata.expm1_rn);
%!test verify ("expm1",  0,   testdata.expm1_rz);

%!test verify ("log", -inf, testdata.log_rd);
%!test verify ("log", +inf, testdata.log_ru);
%!test verify ("log",  0.5, testdata.log_rn);
%!test verify ("log",  0,   testdata.log_rz);

%!test verify ("log10", -inf, testdata.log10_rd);
%!test verify ("log10", +inf, testdata.log10_ru);
%!test verify ("log10",  0.5, testdata.log10_rn);
%!test verify ("log10",  0,   testdata.log10_rz);

%!test verify ("log1p", -inf, testdata.log1p_rd);
%!test verify ("log1p", +inf, testdata.log1p_ru);
%!test verify ("log1p",  0.5, testdata.log1p_rn);
%!test verify ("log1p",  0,   testdata.log1p_rz);

%!test verify ("log2", -inf, testdata.log2_rd);
%!test verify ("log2", +inf, testdata.log2_ru);
%!test verify ("log2",  0.5, testdata.log2_rn);
%!test verify ("log2",  0,   testdata.log2_rz);

%!test verify ("sin", -inf, testdata.sin_rd);
%!test verify ("sin", +inf, testdata.sin_ru);
%!test verify ("sin",  0.5, testdata.sin_rn);
%!test verify ("sin",  0,   testdata.sin_rz);

%!test verify ("sinh", -inf, testdata.sinh_rd);
%!test verify ("sinh", +inf, testdata.sinh_ru);
%!test verify ("sinh",  0.5, testdata.sinh_rn);
%!test verify ("sinh",  0,   testdata.sinh_rz);

%!test verify ("tan", -inf, testdata.tan_rd);
%!test verify ("tan", +inf, testdata.tan_ru);
%!test verify ("tan",  0.5, testdata.tan_rn);
%!test verify ("tan",  0,   testdata.tan_rz);

*/
