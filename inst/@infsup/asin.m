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
## @deftypefn {Interval Function} {} asin (@var{X})
## @cindex IEEE1788 asin
## 
## Compute the inverse sine in radians (arcsine) for each number in
## interval @var{X}.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## asin (infsup (.5))
##   @result{} [.5235987755982988, .5235987755982991]
## @end group
## @end example
## @seealso{sin}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = asin (x)

l = ulpadd (real (asin (x.inf)), -1);
u = ulpadd (real (asin (x.sup)), 1);

## Make the function tightest for some parameters
pi = infsup ("pi");
l (x.inf <= -1) = inf (-pi) / 2;
nonnegative = (x.inf >= 0);
l (nonnegative) = max (0, l (nonnegative));
u (x.sup >= 1) = sup (pi) / 2;
nonpositive = (x.sup <= 0);
u (nonpositive) = min (0, u (nonpositive));

emptyresult = isempty (x) | x.inf > 1 | x.sup < -1;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction
%!test "Empty interval";
%! assert (asin (infsup ()) == infsup ());
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
