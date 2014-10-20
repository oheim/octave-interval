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
## @deftypefn {Interval Function} {@var{C} =} @var{A} & @var{B}
## @cindex IEEE1788 intersection
## 
## Intersect two intervals.
##
## Accuracy: The result is exact.
##
## @example
## @group
## x = infsup (1, 3);
## y = infsup (2, 4);
## x & y
##   @result{} [2, 3]
## @end group
## @end example
## @seealso{or}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-02

function result = and(a, b)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (a, "infsup")))
    a = infsup (a);
endif

## Convert second parameter into interval, if necessary
if (not (isa (b, "infsup")))
    b = infsup (b);
endif

if (isempty (a) || isempty (b))
    result = infsup ();
    return
endif

if (isentire (a))
    result = infsup (b.inf, b.sup);
    return
endif

if (isentire (b))
    result = infsup(a.inf, a.sup);
    return
endif

if (a.sup < b.inf || b.sup < a.inf)
    result = infsup ();
    return
endif

result = infsup (max (a.inf, b.inf), min (a.sup, b.sup));

endfunction
%!test "Empty interval";
%! assert (and (infsup (), infsup ()) == infsup ());
%! assert (and (infsup (), infsup (1)) == infsup ());
%! assert (and (infsup (0), infsup ()) == infsup ());
%! assert (and (infsup (-inf, inf), infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (and (infsup (0), infsup (1)) == infsup ());
%! assert (and (infsup (0), infsup (0)) == infsup (0));
%!test "Bounded intervals";
%! assert (and (infsup (1, 2), infsup (3, 4)) == infsup ());
%! assert (and (infsup (1, 2), infsup (2, 3)) == infsup (2));
%! assert (and (infsup (1, 2), infsup (1.5, 2.5)) == infsup (1.5, 2));
%! assert (and (infsup (1, 2), infsup (1, 2)) == infsup (1, 2));
%!test "Unbounded intervals";
%! assert (and (infsup (0, inf), infsup (-inf, 0)) == infsup (0));
%! assert (and (infsup (1, inf), infsup (-inf, -1)) == infsup ());
%! assert (and (infsup (-1, inf), infsup (-inf, 1)) == infsup (-1, 1));
%! assert (and (infsup (-inf, inf), infsup (42)) == infsup (42));
%! assert (and (infsup (42), infsup (-inf, inf)) == infsup (42));
%! assert (and (infsup (-inf, 0), infsup (-inf, inf)) == infsup (-inf, 0));
%! assert (and (infsup (-inf, inf), infsup (-inf, inf)) == infsup (-inf, inf));
