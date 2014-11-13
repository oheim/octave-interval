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
## @deftypefn {Interval Function} {} acosh (@var{X})
## @cindex IEEE1788 acosh
## 
## Compute the inverse hyperbolic cosine for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 8 ULPs of the exact enclosure.
##
## @example
## @group
## acosh (infsup (2))
##   @result{} [1.3169578969248163, 1.3169578969248171]
## @end group
## @end example
## @seealso{cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = acosh (x)

## Most implementations should be within 2 ULP, but must guarantee 4 ULP.
l = max (0, ulpadd (real (acosh (x.inf)), -4));
u = ulpadd (real (acosh (x.sup)), 4);

## Make the function tightest for some parameters
u (x.sup == 1) = 0;

emptyresult = isempty (x) | x.sup < 1;
l (emptyresult) = inf;
u (emptyresult) = -inf;

## The evaluation of log (…) is more accurate than acosh for some values
result = infsup (l, u) & log (x + sqrt (x + 1) .* sqrt (x - 1));

endfunction
%!test "Empty interval";
%! assert (acosh (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (acosh (infsup (0)) == infsup ());
%! assert (acosh (infsup (1)) == infsup (0));
%! x = infsup (1 : 3 : 100);
%! assert (min (acosh (x) == log (x + sqrt (x + 1) .* sqrt (x - 1))));
%!test "Bounded intervals";
%! assert (acosh (infsup (0, 1)) == infsup (0));
%!test "Unbounded intervals";
%! assert (acosh (infsup (-inf, 0)) == infsup ());
%! assert (acosh (infsup (-inf, 1)) == infsup (0));
%! assert (acosh (infsup (0, inf)) == infsup (0, inf));
%! assert (acosh (infsup (1, inf)) == infsup (0, inf));
%! assert (subset (acosh (infsup (2, inf)), infsup (1, inf)));
