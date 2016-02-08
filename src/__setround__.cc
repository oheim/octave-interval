/*
  Copyright 2015 Kai T. Ohlhus (Original version for C++11)
  Copyright 2015-2016 Oliver Heimlich (Compatibility with C99 and different
                                       parameter semantics for compatibility
                                       with the Octave fenv package)
  
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
#include <fenv.h>

#pragma STDC FENV_ACCESS ON

DEFUN_DLD (__setround__, args, nargout,
  "-*- texinfo -*-\n"
  "@defun __setround__ (@var{rnd})\n"
  "\n"
  "Changes the floating-point rounding direction for the current thread and "
  "any new threads which will be spawned from the current thread.\n"
  "\n"
  "@table @option\n"
  "@item @var{rnd} =  -inf\n"
  "switch rounding downwards (towards -inf)\n"
  "@item @var{rnd} =  0.5\n"
  "switch rounding to nearest (default rounding mode)\n"
  "@item @var{rnd} =  +inf\n"
  "switch rounding upwards (towards +inf)\n"
  "@end table\n"
  "@end defun"
  )
{
  const int nargin = args.length ();
  if (nargin != 1)
    {
      print_usage ();
      return octave_value_list ();
    }
    
  const double rnd = args(0).scalar_value ();
  int mode = 0;
  if (rnd == -INFINITY)
    mode = FE_DOWNWARD;
  else if (rnd == +INFINITY)
    mode = FE_UPWARD;
  else if (rnd == 0.5)
    mode = FE_TONEAREST;
  else
    // No other rounding modes might be supported
    // (depends on the C implementation)
    error ("__setround__: Unsupported rounding mode, please use -inf, +inf "
           "or 0.5");

  if (error_state)
    return octave_value_list ();

  if (fesetround (mode) != 0)
    error ("__setround__: Unable to change rounding mode");

  return octave_value_list ();
}

/*
%!test
%!  __setround__ (+inf);
%!  assert (1 + realmin > 1, true);
%!  assert (1 - realmin == 1, true);
%!  __setround__ (0.5);
%!test
%!  __setround__ (-inf);
%!  assert (1 + realmin == 1, true);
%!  assert (1 - realmin < 1, true);
%!  __setround__ (0.5);
%!test 
%!  __setround__ (0.5);
%!  assert (1 + realmin == 1, true);
%!  assert (1 - realmin == 1, true);
%!shared
%!  __setround__ (0.5);
*/
