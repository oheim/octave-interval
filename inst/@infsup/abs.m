## Copyright 2014-2016 Oliver Heimlich
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
## @documentencoding UTF-8
## @defmethod {@@infsup} abs (@var{X})
## 
## Compute the absolute value of numbers.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## abs (infsup (2.5, 3.5))
##   @result{} ans = [2.5, 3.5]
## abs (infsup (-0.5, 5.5))
##   @result{} ans = [0, 5.5]
## @end group
## @end example
## @seealso{@@infsup/mag, @@infsup/mig}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = abs (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## This is already correct, if the interval(s) are non-negative.
l = x.inf;
u = x.sup;

## This is even correct, if the interval(s) are empty.
notpositive = x.sup <= 0;
l (notpositive) = -x.sup (notpositive);
u (notpositive) = -x.inf (notpositive);

zerointerior = x.inf < 0 & not (notpositive);
l (zerointerior) = 0;
u (zerointerior) = max (-x.inf (zerointerior), x.sup (zerointerior));

result = infsup (l, u);

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
%!test "from the documentation string";
%! assert (abs (infsup (2.5, 3.5)) == infsup (2.5, 3.5));
%! assert (abs (infsup (-0.5, 5.5)) == infsup (0, 5.5));
