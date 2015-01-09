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

#define DOUBLE_PRECISION 53

// Evaluate an unary MPFR function on a double matrix
void evaluate (
  NDArray &arg1,        // Operand 1 and result
  const mpfr_rnd_t rnd, // Rounding direction
  int (*ptr_unary_fun)  // The MPFR function to evaluate (element-wise)
    (mpfr_t rop, const mpfr_t op, mpfr_rnd_t rnd))
{
  mpfr_t mp;
  mpfr_init2 (mp, DOUBLE_PRECISION);
  
  int n = arg1.numel ();
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
  NDArray &arg2,        // Operand 2
  const mpfr_rnd_t rnd, // Rounding direction
  int (*ptr_binary_fun) // The MPFR function to evaluate (element-wise)
    (mpfr_t rop, const mpfr_t op1, const mpfr_t op2, mpfr_rnd_t rnd))
{
  mpfr_t mp1, mp2;
  mpfr_init2 (mp1, DOUBLE_PRECISION);
  mpfr_init2 (mp2, DOUBLE_PRECISION);
  
  int n = arg1.numel ();
  for (octave_idx_type i = 0; i < n; i ++)
    {
      mpfr_set_d (mp1, arg1.elem (i), rnd);
      mpfr_set_d (mp2, arg2.elem (i), rnd);
      (*ptr_binary_fun) (mp1, mp1, mp2, rnd);
      arg1.elem (i) = mpfr_get_d (mp1, rnd);
    }
  
  mpfr_clear (mp1);
  mpfr_clear (mp2);
}

DEFUN_DLD (mpfr_function_d, args, nargout, 
  "-*- texinfo -*-\n"
  "@deftypefn  {Function File} {} mpfr_function_d ('sin', ±inf, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('cos', ±inf, @var{X})\n"
  "@deftypefnx {Function File} {} mpfr_function_d ('tan', ±inf, @var{X})\n"
  "\n"
  "Evaluate a function in double precision with correctly rounded result."
  "\n\n"
  "Parameter 1 is the function's name, Parameter 2 is the rounding "
  "direction.  Parameters 3 and (possibly) 4 are operands to the function."
  "\n"
  "@seealso{fesetround}\n"
  "@end deftypefn"
  )
{
  // Check call syntax
  int nargin = args.length ();
  if (nargin != 3 && nargin != 4)
    {
      print_usage ();
      return octave_value_list ();
    }
  
  // Read parameters
  std::string function = args(0).string_value ();
  NDArray     rnd      = args(1).array_value ();
  NDArray     arg1     = args(2).array_value ();
  NDArray     arg2;
  if (nargin >= 4)
    arg2               = args(3).array_value ();
  if (error_state)
    return octave_value_list ();
  
  // Use rounding mode semantics from the GNU Octave fenv package
  mpfr_rnd_t mp_rnd;
  if (rnd.elem (0) == INFINITY)
    mp_rnd = MPFR_RNDU;
  else if (rnd.elem (0) == -INFINITY)
    mp_rnd = MPFR_RNDD;
  else if (rnd.elem (0) == 0)
    mp_rnd = MPFR_RNDZ;
  else
    // default mode
    mp_rnd = MPFR_RNDN;
  
  // Choose the function to evaluate
  if (function.compare ("sin") == 0)
    evaluate (arg1, mp_rnd, &mpfr_sin);
  else if (function.compare ("cos") == 0)
    evaluate (arg1, mp_rnd, &mpfr_cos);
  else if (function.compare ("tan") == 0)
    evaluate (arg1, mp_rnd, &mpfr_tan);
  else
    error ("mpfr_function_d: unsupported function");

  return octave_value (arg1);
}
