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
## @documentencoding utf-8
## @deftypefn {Function File} {} acos (@var{X})
## 
## Compute the inverse cosine in radians (arccosine).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acos (infsup (.5))
##   @result{} [1.0471975511965976, 1.0471975511965979]
## @end group
## @end example
## @seealso{@@infsup/cos}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = acos (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

x = x & infsup (-1, 1);

## acos is monotonically decreasing from (-1, pi) to (+1, 0)
l = mpfr_function_d ('acos', -inf, x.sup);
u = mpfr_function_d ('acos', +inf, x.inf);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction
%!test "Empty interval";
%! assert (acos (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (acos (infsup (-1)) == infsup ("pi"));
%! assert (subset (acos (infsup (-.5)), (infsup ("pi") / 2) | infsup ("pi")));
%! assert (acos (infsup (0)) == infsup ("pi") / 2);
%! assert (subset (acos (infsup (.5)), (infsup ("pi") / 2) | infsup (0)));
%! assert (acos (infsup (1)) == infsup (0));
%!test "Bounded intervals";
%! assert (acos (infsup (-1, 0)) == ((infsup ("pi") / 2) | infsup ("pi")));
%! assert (acos (infsup (0, 1)) == ((infsup ("pi") / 2) | infsup (0)));
%! assert (acos (infsup (-1, 1)) == infsup (0, "pi"));
%! assert (acos (infsup (-2, 2)) == infsup (0, "pi"));
%!test "Unbounded intervals";
%! assert (acos (infsup (0, inf)) == ((infsup ("pi") / 2) | infsup (0)));
%! assert (acos (infsup (-inf, 0)) == ((infsup ("pi") / 2) | infsup ("pi")));
%! assert (acos (infsup (-inf, inf)) == infsup (0, "pi"));
