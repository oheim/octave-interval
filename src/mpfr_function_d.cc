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

// Evaluate an unary MPFR function on a double matrix
void evaluate (
  NDArray &arg1,        // Operand 1 and result
  const mpfr_rnd_t rnd, // Rounding direction
  int (*ptr_unary_fun)  // The MPFR function to evaluate (element-wise)
    (mpfr_t rop, const mpfr_t op, mpfr_rnd_t rnd))
{
  mpfr_t mp;
  mpfr_init2 (mp, DOUBLE_PRECISION);
  
  const int n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp, arg1.elem (i), rnd);
      (*ptr_unary_fun) (mp, mp, rnd);
      arg1.elem (i) = mpfr_get_d (mp, rnd);
    }
  
  mpfr_clear (mp);
}

// Evaluate a binary MPFR function on two double matrices
void evaluate (
  NDArray &arg1,        // Operand 1 and result
  const NDArray &arg2,  // Operand 2
  const mpfr_rnd_t rnd, // Rounding direction
  int (*ptr_binary_fun) // The MPFR function to evaluate (element-wise)
    (mpfr_t rop, const mpfr_t op1, const mpfr_t op2, mpfr_rnd_t rnd))
{
  mpfr_t mp1, mp2;
  mpfr_init2 (mp1, DOUBLE_PRECISION);
  mpfr_init2 (mp2, DOUBLE_PRECISION);
  
  bool scalar1 = arg1.numel () == 1;
  bool scalar2 = arg2.numel () == 1;
  
  if (scalar1 && ! scalar2)
    {
      arg1.resize (arg2.dims (), arg1.elem (0));
      scalar1 = false;
    }
  
  const int n = std::max (arg1.numel (), arg2.numel ());
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp1, arg1.elem (i), rnd);
      mpfr_set_d (mp2,
                  (scalar2) ? arg2.elem (0) // broadcast
                            : arg2.elem (i),
                  rnd);
      (*ptr_binary_fun) (mp1, mp1, mp2, rnd);
      arg1.elem (i) = mpfr_get_d (mp1, rnd);
    }
  
  mpfr_clear (mp1);
  mpfr_clear (mp2);
}

// Evaluate a ternary MPFR function on three double matrices
void evaluate (
  NDArray &arg1,         // Operand 1 and result
  const NDArray &arg2,   // Operand 2
  const NDArray &arg3,   // Operand 3
  const mpfr_rnd_t rnd,  // Rounding direction
  int (*ptr_ternary_fun) // The MPFR function to evaluate (element-wise)
    (mpfr_t rop, const mpfr_t op1, const mpfr_t op2, const mpfr_t op3,
        mpfr_rnd_t rnd))
{
  mpfr_t mp1, mp2, mp3;
  mpfr_init2 (mp1, DOUBLE_PRECISION);
  mpfr_init2 (mp2, DOUBLE_PRECISION);
  mpfr_init2 (mp3, DOUBLE_PRECISION);
  
  bool scalar1 = arg1.numel () == 1;
  bool scalar2 = arg2.numel () == 1;
  bool scalar3 = arg3.numel () == 1;
  
  if (scalar1)
    if (!scalar2)
      {
        arg1.resize (arg2.dims (), arg1.elem (0));
        scalar1 = false;
      }
    else if (!scalar3)
      {
        arg1.resize (arg3.dims (), arg1.elem (0));
        scalar1 = false;
      }

  const int n = std::max (std::max (arg1.numel (), arg2.numel ()),
                          arg3.numel ());
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp1, arg1.elem (i), rnd);
      mpfr_set_d (mp2,
                  (scalar2) ? arg2.elem (0) // broadcast
                            : arg2.elem (i),
                  rnd);
      mpfr_set_d (mp3,
                  (scalar3) ? arg3.elem (0) // broadcast
                            : arg3.elem (i),
                  rnd);
      (*ptr_ternary_fun) (mp1, mp1, mp2, mp3, rnd);
      arg1.elem (i) = mpfr_get_d (mp1, rnd);
    }
  
  mpfr_clear (mp1);
  mpfr_clear (mp2);
  mpfr_clear (mp3);
}

DEFUN_DLD (mpfr_function_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@documentencoding utf-8\n"
  "@deftypefn  {Function File} {} mpfr_function_d ('acos', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('acosh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('asin', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('asinh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('atan', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('atan2', @var{R}, @var{Y}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('atanh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('cos', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('cosh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('exp', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('fma', @var{R}, @var{X}, @var{Y}, @var{Z})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('log', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('log2', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('log10', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('minus', @var{R}, @var{X}, @var{Y})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('plus', @var{R}, @var{X}, @var{Y})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('pow', @var{R}, @var{X}, @var{Y})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('pow2', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('pow10', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('rdivide', @var{R}, @var{X}, @var{Y})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('sin', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('sinh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('sinh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('sinh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('sqr', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('sqrt', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('tan', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('tanh', @var{R}, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('times', @var{R}, @var{X}, @var{Y})\n"
  "\n"
  "Evaluate a function in double precision with correctly rounded result."
  "\n\n"
  "Parameter 1 is the function's name in GNU Octave, Parameter 2 is the "
  "rounding direction (0: towards zero, 0.5 towards nearest and ties to even, "
  "inf towards positive infinity, -inf towards negative infinity.  "
  "Parameters 3 and (possibly) 4 and 5 are operands to the function."
  "\n"
  "@seealso{fesetround}\n"
  "@end deftypefn"
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
  const std::string function = args(0).string_value ();
  const mpfr_rnd_t  rnd      = parse_rounding_mode (
                               args(1).array_value ());
  NDArray           arg1     = args(2).array_value ();
  NDArray           arg2;
  NDArray           arg3;
  if (nargin >= 4)
    arg2                     = args(3).array_value ();
  if (nargin >= 5)
    arg3                     = args(4).array_value ();
  if (error_state)
    return octave_value_list ();
  
  // Choose the function to evaluate
  if      (function.compare ("acos") == 0)
    evaluate (arg1, rnd, &mpfr_acos);
  else if (function.compare ("acosh") == 0)
    evaluate (arg1, rnd, &mpfr_acosh);
  else if (function.compare ("asin") == 0)
    evaluate (arg1, rnd, &mpfr_asin);
  else if (function.compare ("asinh") == 0)
    evaluate (arg1, rnd, &mpfr_asinh);
  else if (function.compare ("atan") == 0)
    evaluate (arg1, rnd, &mpfr_atan);
  else if (function.compare ("atan2") == 0)
    evaluate (arg1, arg2, rnd, &mpfr_atan2);
  else if (function.compare ("atanh") == 0)
    evaluate (arg1, rnd, &mpfr_atanh);
  else if (function.compare ("cos") == 0)
    evaluate (arg1, rnd, &mpfr_cos);
  else if (function.compare ("cosh") == 0)
    evaluate (arg1, rnd, &mpfr_cosh);
  else if (function.compare ("exp") == 0)
    evaluate (arg1, rnd, &mpfr_exp);
  else if (function.compare ("fma") == 0)
    evaluate (arg1, arg2, arg3, rnd, &mpfr_fma);
  else if (function.compare ("log") == 0)
    evaluate (arg1, rnd, &mpfr_log);
  else if (function.compare ("log2") == 0)
    evaluate (arg1, rnd, &mpfr_log2);
  else if (function.compare ("log10") == 0)
    evaluate (arg1, rnd, &mpfr_log10);
  else if (function.compare ("minus") == 0)
    evaluate (arg1, arg2, rnd, &mpfr_sub);
  else if (function.compare ("plus") == 0)
    evaluate (arg1, arg2, rnd, &mpfr_add);
  else if (function.compare ("pow") == 0)
    evaluate (arg1, arg2, rnd, &mpfr_pow);
  else if (function.compare ("pow2") == 0)
    evaluate (arg1, rnd, &mpfr_exp2);
  else if (function.compare ("pow10") == 0)
    evaluate (arg1, rnd, &mpfr_exp10);
  else if (function.compare ("rdivide") == 0)
    evaluate (arg1, arg2, rnd, &mpfr_div);
  else if (function.compare ("sin") == 0)
    evaluate (arg1, rnd, &mpfr_sin);
  else if (function.compare ("sinh") == 0)
    evaluate (arg1, rnd, &mpfr_sinh);
  else if (function.compare ("sqr") == 0)
    evaluate (arg1, rnd, &mpfr_sqr);
  else if (function.compare ("sqrt") == 0)
    evaluate (arg1, rnd, &mpfr_sqrt);
  else if (function.compare ("tan") == 0)
    evaluate (arg1, rnd, &mpfr_tan);
  else if (function.compare ("tanh") == 0)
    evaluate (arg1, rnd, &mpfr_tanh);
  else if (function.compare ("times") == 0)
    evaluate (arg1, arg2, rnd, &mpfr_mul);
  else
    error ("mpfr_function_d: unsupported function");

  return octave_value (arg1);
}
