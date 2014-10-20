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
## @deftypefn {Interval Function} {@var{Y} =} floor (@var{X})
## @cindex IEEE1788 floor
## 
## Round each number in interval @var{X} towards -Inf.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## floor (infsup (2.5, 3.5))
##   @result{} [2, 3]
## floor (infsup (-0.5, 5))
##   @result{} [-1, 5]
## @end group
## @end example
## @seealso{ceil, round, roundb, fix}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = floor (x)

if (isempty (x))
    result = infsup ();
    return
endif

result = infsup (floor (x.inf), floor (x.sup));

endfunction
%!test "Empty interval";
%! assert (floor (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (floor (infsup (0)) == infsup (0));
%! assert (floor (infsup (0.5)) == infsup (0));
%! assert (floor (infsup (-0.5)) == infsup (-1));
%!test "Bounded intervals";
%! assert (floor (infsup (-0.5, 0)) == infsup (-1, 0));
%! assert (floor (infsup (0, 0.5)) == infsup (0));
%! assert (floor (infsup (0.25, 0.5)) == infsup (0));
%! assert (floor (infsup (-1, 0)) == infsup (-1, 0));
%! assert (floor (infsup (-1, 1)) == infsup (-1, 1));
%! assert (floor (infsup (-realmin, realmin)) == infsup (-1, 0));
%! assert (floor (infsup (-realmax, realmax)) == infsup (-realmax, realmax));
%!test "Unbounded intervals";
%! assert (floor (infsup (-realmin, inf)) == infsup (-1, inf));
%! assert (floor (infsup (-realmax, inf)) == infsup (-realmax, inf));
%! assert (floor (infsup (-inf, realmin)) == infsup (-inf, 0));
%! assert (floor (infsup (-inf, realmax)) == infsup (-inf, realmax));
%! assert (floor (infsup (-inf, inf)) == infsup (-inf, inf));
