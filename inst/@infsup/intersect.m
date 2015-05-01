## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {} {} intersect (@var{A}, @var{B})
## 
## Intersect two intervals.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (1, 3);
## y = infsup (2, 4);
## intersect (x, y)
##   @result{} [2, 3]
## @end group
## @end example
## @seealso{@@infsup/union, @@infsup/setdiff, @@infsup/setxor}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-02

function result = intersect (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif

## This also works for unbound intervals and empty intervals
l = max (a.inf, b.inf);
u = min (a.sup, b.sup);

## If the intervals do not intersect, the result must be empty.
emptyresult = a.sup < b.inf | b.sup < a.inf;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "Empty interval";
%! assert (intersect (infsup (), infsup ()) == infsup ());
%! assert (intersect (infsup (), infsup (1)) == infsup ());
%! assert (intersect (infsup (0), infsup ()) == infsup ());
%! assert (intersect (infsup (-inf, inf), infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (intersect (infsup (0), infsup (1)) == infsup ());
%! assert (intersect (infsup (0), infsup (0)) == infsup (0));
%!test "Bounded intervals";
%! assert (intersect (infsup (1, 2), infsup (3, 4)) == infsup ());
%! assert (intersect (infsup (1, 2), infsup (2, 3)) == infsup (2));
%! assert (intersect (infsup (1, 2), infsup (1.5, 2.5)) == infsup (1.5, 2));
%! assert (intersect (infsup (1, 2), infsup (1, 2)) == infsup (1, 2));
%!test "Unbounded intervals";
%! assert (intersect (infsup (0, inf), infsup (-inf, 0)) == infsup (0));
%! assert (intersect (infsup (1, inf), infsup (-inf, -1)) == infsup ());
%! assert (intersect (infsup (-1, inf), infsup (-inf, 1)) == infsup (-1, 1));
%! assert (intersect (infsup (-inf, inf), infsup (42)) == infsup (42));
%! assert (intersect (infsup (42), infsup (-inf, inf)) == infsup (42));
%! assert (intersect (infsup (-inf, 0), infsup (-inf, inf)) == infsup (-inf, 0));
%! assert (intersect (infsup (-inf, inf), infsup (-inf, inf)) == infsup (-inf, inf));
%!test "from the documentation string";
%! assert (intersect (infsup (1, 3), infsup (2, 4)) == infsup (2, 3));
