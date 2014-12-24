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
## @deftypefn {Interval Function} {} round (@var{X})
## @cindex IEEE1788 roundTiesToAway
## 
## Round each number in interval @var{X} to the nearest integer.  Ties are
## rounded away from zero (towards +Inf or -Inf depending on the sign).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## round (infsup (2.5, 3.5))
##   @result{} [3, 4]
## round (infsup (-0.5, 5))
##   @result{} [-1, 5]
## @end group
## @end example
## @seealso{floor, ceil, roundb, fix}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = round (x)

result = infsup (round (x.inf), round (x.sup));

endfunction
%!test "Empty interval";
%! assert (round (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (round (infsup (0)) == infsup (0));
%! assert (round (infsup (0.5)) == infsup (1));
%! assert (round (infsup (0.25)) == infsup (0));
%! assert (round (infsup (0.75)) == infsup (1));
%! assert (round (infsup (-0.5)) == infsup (-1));
%!test "Bounded intervals";
%! assert (round (infsup (-0.5, 0)) == infsup (-1, 0));
%! assert (round (infsup (0, 0.5)) == infsup (0, 1));
%! assert (round (infsup (0.25, 0.5)) == infsup (0, 1));
%! assert (round (infsup (-1, 0)) == infsup (-1, 0));
%! assert (round (infsup (-1, 1)) == infsup (-1, 1));
%! assert (round (infsup (-realmin, realmin)) == infsup (0));
%! assert (round (infsup (-realmax, realmax)) == infsup (-realmax, realmax));
%!test "Unbounded intervals";
%! assert (round (infsup (-realmin, inf)) == infsup (0, inf));
%! assert (round (infsup (-realmax, inf)) == infsup (-realmax, inf));
%! assert (round (infsup (-inf, realmin)) == infsup (-inf, 0));
%! assert (round (infsup (-inf, realmax)) == infsup (-inf, realmax));
%! assert (round (infsup (-inf, inf)) == infsup (-inf, inf));
