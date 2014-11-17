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
## @deftypefn {Interval Function} {} asinh (@var{X})
## @cindex IEEE1788 asinh
## 
## Compute the inverse hyperbolic sine for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 14 ULPs of the exact enclosure.
##
## @example
## @group
## asinh (infsup (1))
##   @result{} [.8813735870195422, .8813735870195439]
## @end group
## @end example
## @seealso{sinh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = asinh (x)

## Most implementations should be within 2 ULP, but must guarantee 7 ULP.
l = ulpadd (asinh (x.inf), -7);
u = ulpadd (asinh (x.sup), 7);

## Make the function tightest for x = 0
nonnegative = x.inf >= 0;
l (nonnegative) = max (0, l (nonnegative));
nonpositive = x.sup <= 0;
u (nonpositive) = min (0, u (nonpositive));

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

## The evaluation of log (…) is more accurate than ± 7 ULP for small values
result = infsup (l, u) & log (x + sqrt (sqr (x) + 1));

endfunction