/*

Copyright (C) 2015 Kai T. Ohlhus

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#include <octave/oct.h>
#include <cfenv>
#include <cfloat>

#pragma STDC FENV_ACCESS ON

DEFUN_DLD (__setround__, args, argout,
           "-*- texinfo -*-\n\
@deftypefn  {Loadable Function} {[@var{r}] =} __setround__ (@var{rnd})\n\
\n\
Changes the floating-point rounding direction:\n\
\n\
@var{rnd} = -1  switch rounding downwards (towards -inf)\n\
\n\
@var{rnd} =  0  switch rounding to nearest\n\
\n\
@var{rnd} =  1  switch rounding upwards (towards inf)\n\
\n\
@var{rnd} =  2  switch rounding towards zero (chop)\n\
\n\
Returns @var{r} = 0 on success.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();
  if ((nargin != 1) || !args(0).is_scalar_type ())
    {
      print_usage ();
      return retval;
    }

  if (! error_state)
    {
      int rnd = args(0).int_value ();
      int mode = FE_TONEAREST;

      switch (rnd)
        {
          case -1:
            mode = FE_DOWNWARD;
            break;
          case 0:
            mode = FE_TONEAREST;
            break;
          case 1:
            mode = FE_UPWARD;
            break;
          case 2:
            mode = FE_TOWARDZERO;
            break;
          default:
            mode = FE_TONEAREST;
            break;
        }

      int err = std::fesetround (mode);
      if (argout > 0)
        retval(0) = octave_value (err);
    }

    return retval;
}

/*
%!test 
%!  __setround__ (1);
%!  assert (1 + realmin > 1, true);
%!  __setround__ (0);
%!test 
%!  __setround__ (0);
%!  assert (1 + realmin > 1, false); 
%!test 
%!  __setround__ (2);
%!  assert (1 + realmin > 1, false); 
%!  assert (-1 + realmin > -1, true); 
%!  __setround__ (0);
%!shared
%!  __setround__ (0);
*/
