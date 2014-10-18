## Copyright 2014 Oliver Heimlich
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Interval Function} {@var{Y} =} abs (@var{X})
## @cindex IEEE1788 abs
## 
## Compute the absolute value of numbers in interval @var{X}.
##
## Accuracy: The result is exact.
##
## @example
## @group
## abs (infsup (2.5, 3.5))
##   @result{} [2.5, 3.5]
## abs (infsup (-0.5, 5.5))
##   @result{} [0, 5.5]
## @end group
## @end example
## @seealso{mag, mig}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = abs (x)

if (isempty (x))
    result = infsup ();
    return
endif

if (x.inf >= 0)
    result = x;
elseif (x.sup <= 0)
    result = infsup (-x.sup, -x.inf);
else
    result = infsup (0, max (-x.inf, x.sup));
endif

endfunction
%!test "Empty interval";
%! assert (abs (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (abs (infsup (1)) == infsup (1));
%! assert (abs (infsup (0)) == infsup (0));
%! assert (abs (infsup (-1)) == infsup (1));
%! assert (abs (infsup (realmax)) == infsup (realmax));
%! assert (abs (infsup (realmin)) == infsup (realmin));
%! assert (abs (infsup (-realmin)) == infsup (realmin));
%! assert (abs (infsup (-realmax)) == infsup (realmax));
%!test "Bounded intervals";
%! assert (abs (infsup (1, 2)) == infsup (1, 2));
%! assert (abs (infsup (0, 1)) == infsup (0, 1));
%! assert (abs (infsup (-1, 1)) == infsup (0, 1));
%! assert (abs (infsup (-1, 0)) == infsup (0, 1));
%! assert (abs (infsup (-2, -1)) == infsup (1, 2));
%!test "Unbounded intervals";
%! assert (abs (infsup (0, inf)) == infsup (0, inf));
%! assert (abs (infsup (-inf, inf)) == infsup (0, inf));
%! assert (abs (infsup (-inf, 0)) == infsup (0, inf));
%! assert (abs (infsup (1, inf)) == infsup (1, inf));
%! assert (abs (infsup (-1, inf)) == infsup (0, inf));
%! assert (abs (infsup (-inf, -1)) == infsup (1, inf));
%! assert (abs (infsup (-inf, 1)) == infsup (0, inf));
