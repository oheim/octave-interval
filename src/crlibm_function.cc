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
#include "crlibm/crlibm.h"

typedef double (*crlibm_unary_fun)
            (const double op);

// Evaluate an unary crlibm function on a binary64 matrix
void evaluate (
  NDArray &arg1,           // Operand 1 and result
  const crlibm_unary_fun f) // The crlibm function to evaluate (element-wise)
{
  uint64_t old_state = crlibm_init ();

  const octave_idx_type n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      arg1.elem (i) = (*f) (arg1.elem (i));
    }

  crlibm_exit (old_state);
}

DEFUN_DLD (crlibm_function, args, nargout,
  "-*- texinfo -*-\n"
  "@documentencoding UTF-8\n"
  "@defun crlibm_function ('acos', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('asin', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('atan', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('cos', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('cosh', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('exp', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('expm1', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('log', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('log10', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('log1p', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('log2', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('sin', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('sinh', @var{R}, @var{X})\n"
  "@defunx crlibm_function ('tan', @var{R}, @var{X})\n"
  "\n"
  "Evaluate a function in binary64 with correctly rounded result."
  "\n\n"
  "Parameter 1 is the function's name in GNU Octave, Parameter 2 is the "
  "rounding direction (@option{0}: towards zero, @option{0.5}: towards "
  "nearest and ties to even, @option{+inf}: towards positive infinity, "
  "@option{-inf}: towards negative infinity).  "
  "Parameters 3 is the operand to the function."
  "\n\n"
  "Evaluated on matrices, the function will be applied element-wise."
  "\n\n"
  "The result is guaranteed to be correctly rounded.  That is, the function "
  "is evaluated with (virtually) infinite precision and the exact result is "
  "approximated with a binary64 number using the desired rounding direction."
  "@seealso{mpfr_function_d}\n"
  "@end defun"
  )
{
  const int nargin = args.length ();
  if (nargin != 3)
    {
      print_usage ();
      return octave_value_list ();
    }

  const std::string function = args(0).string_value ();
  const double      rnd      = args(1).scalar_value ();
  NDArray           arg1     = args(2).array_value ();

  if (error_state)
    return octave_value_list ();

  if (rnd == INFINITY)
    {
      // Round upwards
      if      (function == "acos")
        evaluate (arg1, &acos_ru);
      else if (function == "asin")
        evaluate (arg1, &asin_ru);
      else if (function == "atan")
        evaluate (arg1, &atan_ru);
      else if (function == "cos")
        evaluate (arg1, &cos_ru);
      else if (function == "cosh")
        evaluate (arg1, &cosh_ru);
      else if (function == "exp")
        evaluate (arg1, &exp_ru);
      else if (function == "expm1")
        evaluate (arg1, &expm1_ru);
      else if (function == "log")
        evaluate (arg1, &log_ru);
      else if (function == "log10")
        evaluate (arg1, &log10_ru);
      else if (function == "log1p")
        evaluate (arg1, &log1p_ru);
      else if (function == "log2")
        evaluate (arg1, &log2_ru);
      else if (function == "sin")
        evaluate (arg1, &sin_ru);
      else if (function == "sinh")
        evaluate (arg1, &sinh_ru);
      else if (function == "tan")
        evaluate (arg1, &tan_ru);
      else
        {
          print_usage();
          return octave_value_list ();
        }
    }
  else if (rnd == -INFINITY)
    {
      // Round downwards
      if      (function == "acos")
        evaluate (arg1, &acos_rd);
      else if (function == "asin")
        evaluate (arg1, &asin_rd);
      else if (function == "atan")
        evaluate (arg1, &atan_rd);
      else if (function == "cos")
        evaluate (arg1, &cos_rd);
      else if (function == "cosh")
        evaluate (arg1, &cosh_rd);
      else if (function == "exp")
        evaluate (arg1, &exp_rd);
      else if (function == "expm1")
        evaluate (arg1, &expm1_rd);
      else if (function == "log")
        evaluate (arg1, &log_rd);
      else if (function == "log10")
        evaluate (arg1, &log10_rd);
      else if (function == "log1p")
        evaluate (arg1, &log1p_rd);
      else if (function == "log2")
        evaluate (arg1, &log2_rd);
      else if (function == "sin")
        evaluate (arg1, &sin_rd);
      else if (function == "sinh")
        evaluate (arg1, &sinh_rd);
      else if (function == "tan")
        evaluate (arg1, &tan_rd);
      else
        {
          print_usage();
          return octave_value_list ();
        }
    }
  else if (rnd == 0.0)
    {
      // Round towards zero
      if      (function == "acos")
        evaluate (arg1, &acos_rz);
      else if (function == "asin")
        evaluate (arg1, &asin_rz);
      else if (function == "atan")
        evaluate (arg1, &atan_rz);
      else if (function == "cos")
        evaluate (arg1, &cos_rz);
      else if (function == "cosh")
        evaluate (arg1, &cosh_rz);
      else if (function == "exp")
        evaluate (arg1, &exp_rz);
      else if (function == "expm1")
        evaluate (arg1, &expm1_rz);
      else if (function == "log")
        evaluate (arg1, &log_rz);
      else if (function == "log10")
        evaluate (arg1, &log10_rz);
      else if (function == "log1p")
        evaluate (arg1, &log1p_rz);
      else if (function == "log2")
        evaluate (arg1, &log2_rz);
      else if (function == "sin")
        evaluate (arg1, &sin_rz);
      else if (function == "sinh")
        evaluate (arg1, &sinh_rz);
      else if (function == "tan")
        evaluate (arg1, &tan_rz);
      else
        {
          print_usage();
          return octave_value_list ();
        }
    }
  else
    {
      // Round to nearest
      if      (function == "acos")
        evaluate (arg1, &acos_rn);
      else if (function == "asin")
        evaluate (arg1, &asin_rn);
      else if (function == "atan")
        evaluate (arg1, &atan_rn);
      else if (function == "cos")
        evaluate (arg1, &cos_rn);
      else if (function == "cosh")
        evaluate (arg1, &cosh_rn);
      else if (function == "exp")
        evaluate (arg1, &exp_rn);
      else if (function == "expm1")
        evaluate (arg1, &expm1_rn);
      else if (function == "log")
        evaluate (arg1, &log_rn);
      else if (function == "log10")
        evaluate (arg1, &log10_rn);
      else if (function == "log1p")
        evaluate (arg1, &log1p_rn);
      else if (function == "log2")
        evaluate (arg1, &log2_rn);
      else if (function == "sin")
        evaluate (arg1, &sin_rn);
      else if (function == "sinh")
        evaluate (arg1, &sinh_rn);
      else if (function == "tan")
        evaluate (arg1, &tan_rn);
      else
        {
          print_usage();
          return octave_value_list ();
        }
    }

  return octave_value (arg1);
}

/*
%!test
%!  for f = {"acos", "asin", "atan", "cos", "cosh", "exp", "expm1", "log", "log10", "log1p", "log2", "sin", "sinh", "tan"}
%!    for rnd = {+inf, -inf, 0, 0.5}
%!      assert (crlibm_function (f{:}, rnd{:}, 0.5), mpfr_function_d (f{:}, rnd{:}, 0.5));
%!    endfor
%!  endfor
*/
