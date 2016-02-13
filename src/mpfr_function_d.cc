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

// Evaluate an unary MPFR function on a binary64 matrix
void evaluate (
  Matrix &arg1,           // Operand 1 and result
  const mpfr_rnd_t rnd,   // Rounding direction
  const mpfr_unary_fun f) // The MPFR function to evaluate (element-wise)
{
  mpfr_t mp;
  mpfr_init2 (mp, BINARY64_PRECISION);
  
  const octave_idx_type n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp, arg1.elem (i), MPFR_RNDZ);
      (*f) (mp, mp, rnd);
      arg1.elem (i) = mpfr_get_d (mp, rnd);
    }
  
  mpfr_clear (mp);
}

// Evaluate a binary MPFR function on two binary64 matrices
void evaluate (
  Matrix &arg1,            // Operand 1 and result
  const Matrix &arg2,      // Operand 2
  const mpfr_rnd_t rnd,    // Rounding direction
  const mpfr_binary_fun f) // The MPFR function to evaluate (element-wise)
{
  mpfr_t mp1, mp2;
  mpfr_init2 (mp1, BINARY64_PRECISION);
  mpfr_init2 (mp2, BINARY64_PRECISION);
  
  // arg1 shall contain the result and must be resized
  if (arg1.rows () == 1 && arg2.rows () != 1)
    arg1 = arg1.index (idx_vector (ColumnVector (arg2.rows (), 1.0)), 
                       idx_vector::colon);
  if (arg1.columns () == 1 && arg2.columns () != 1)
    arg1 = arg1.index (idx_vector::colon,
                       idx_vector (RowVector (arg2.columns (), 1.0)));
  
  const octave_idx_type n = arg1.rows ();
  const octave_idx_type m = arg1.columns ();
  const bool broadcast_r = n != 1 && arg2.rows () == 1;
  const bool broadcast_c = m != 1 && arg2.columns () == 1;
  
  for (octave_idx_type i = 0; i < n; i ++)
    for (octave_idx_type j = 0; j < m; j ++)
      {
        mpfr_set_d (mp1, arg1.elem (i, j), MPFR_RNDZ);
        mpfr_set_d (mp2,
                    (broadcast_r)
                      ? ((broadcast_c) ? arg2.elem (0, 0)
                                       : arg2.elem (0, j))
                      : ((broadcast_c) ? arg2.elem (i, 0)
                                       : arg2.elem (i, j))
                    , MPFR_RNDZ);
        (*f) (mp1, mp1, mp2, rnd);
        arg1.elem (i, j) = mpfr_get_d (mp1, rnd);
      }
  
  mpfr_clear (mp1);
  mpfr_clear (mp2);
}

// Evaluate a ternary MPFR function on three binary64 matrices
void evaluate (
  Matrix &arg1,             // Operand 1 and result
  const Matrix &arg2,       // Operand 2
  const Matrix &arg3,       // Operand 3
  const mpfr_rnd_t rnd,     // Rounding direction
  const mpfr_ternary_fun f) // The MPFR function to evaluate (element-wise)
{
  mpfr_t mp1, mp2, mp3;
  mpfr_init2 (mp1, BINARY64_PRECISION);
  mpfr_init2 (mp2, BINARY64_PRECISION);
  mpfr_init2 (mp3, BINARY64_PRECISION);
  
  bool scalar1 = arg1.numel () == 1;
  bool scalar2 = arg2.numel () == 1;
  bool scalar3 = arg3.numel () == 1;
  
  if (scalar1)
    {
      // arg1 shall contain the result and must possibly be resized
      if (!scalar2)
        {
          arg1 = Matrix (arg2.dims (), arg1.elem (0));
          scalar1 = false;
        }
      else if (!scalar3)
        {
          arg1 = Matrix (arg3.dims (), arg1.elem (0));
          scalar1 = false;
        }
    }

  const octave_idx_type n = std::max (std::max (arg1.numel (), arg2.numel ()),
                                   arg3.numel ());
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp1, arg1.elem (i), MPFR_RNDZ);
      mpfr_set_d (mp2,
                  (scalar2) ? arg2.elem (0) // broadcast
                            : arg2.elem (i),
                  MPFR_RNDZ);
      mpfr_set_d (mp3,
                  (scalar3) ? arg3.elem (0) // broadcast
                            : arg3.elem (i),
                  MPFR_RNDZ);
      (*f) (mp1, mp1, mp2, mp3, rnd);
      arg1.elem (i) = mpfr_get_d (mp1, rnd);
    }
  
  mpfr_clear (mp1);
  mpfr_clear (mp2);
  mpfr_clear (mp3);
}

// Evaluate nthroot
void nthroot (
  Matrix &arg1,             // Operand 1 and result
  const uint64_t arg2, // Operand 2
  const mpfr_rnd_t rnd)
{
  mpfr_t mp;
  mpfr_init2 (mp, BINARY64_PRECISION);
  
  const octave_idx_type n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp, arg1.elem (i), MPFR_RNDZ);
      mpfr_root (mp, mp, arg2, rnd);
      arg1.elem (i) = mpfr_get_d (mp, rnd);
    }
  
  mpfr_clear (mp);
}

// Evaluate factorial
void factorial (
  Matrix &result,          // Result
  const uint64NDArray arg, // Operand
  const mpfr_rnd_t rnd)
{
  mpfr_t mp;
  mpfr_init2 (mp, BINARY64_PRECISION);

  const octave_idx_type n = arg.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      // Compilation on 32-bit systems produces ambiguity errors if the
      // type of arg.elem(i) is not defined explicitly
      const uint64_t current_arg = arg.elem (i);
      mpfr_fac_ui (mp, current_arg, rnd);
      result.elem (i) = mpfr_get_d (mp, rnd);
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
  "@defunx mpfr_function_d ('rsqrt', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sec', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sech', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sin', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sinh', @var{R}, @var{X})\n"
  "@defunx mpfr_function_d ('sinh', @var{R}, @var{X})\n"
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
  "Evaluated on matrices, the function will be applied element-wise.  Scalar "
  "operands do broadcast for functions with more than one operand."
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
  "@seealso{fesetround}\n"
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
  Matrix            arg1     = args (2).matrix_value ();
  Matrix            arg2;
  Matrix            arg3;
  if (nargin >= 4)
    {
      arg2                   = args (3).matrix_value ();
      if (arg1.rows () != 1 && arg2.rows () != 1 &&
          arg1.rows () != arg2.rows ())
        error ("mpfr_function_d: Matrix dimensions must agree!");
      if (arg1.columns () != 1 && arg2.columns () != 1 &&
          arg1.columns () != arg2.columns ())
        error ("mpfr_function_d: Matrix dimensions must agree!");
    }
  if (nargin >= 5)
    {
      arg3                   = args (4).matrix_value ();
      if (arg3.numel () != 1 && (
          (arg1.numel () != 1 && arg1.numel () != arg3.numel ()) ||
          (arg2.numel () != 1 && arg2.numel () != arg3.numel ())))
        error ("mpfr_function_d: Matrix dimensions must agree!");
    }
  if (error_state)
    return octave_value_list ();
  
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
          {
            const uint64NDArray argInt = args (2).uint64_array_value ();
            if (error_state)
              return octave_value_list ();
            factorial (arg1, argInt, rnd);
          }
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
            const uint64_t n = args (3).uint64_array_value ().elem (0);
            if (error_state)
              return octave_value_list ();
            nthroot (arg1, n, rnd);
          }
        else if (function == "plus")
          evaluate (arg1, arg2, rnd, &mpfr_add);
        else if (function == "pow")
          evaluate (arg1, arg2, rnd, &mpfr_pow);
        else if (function == "rdivide")
          evaluate (arg1, arg2, rnd, &mpfr_div);
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
*/
