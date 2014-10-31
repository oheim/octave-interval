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
## @deftypefn {Interval Function} {} log10 (@var{X})
## @cindex IEEE1788 log10
## 
## Compute the decimal (base-10) logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 7 ULPs of the exact enclosure.  The result is tightest for powers of ten
## between 10^0 and 10^22 (inclusive).
##
## @example
## @group
## log10 (infsup (2))
##   @result{} [.30102999566398097, .30102999566398143]
## @end group
## @end example
## @seealso{pow10, log, log2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log10 (x)

l = u = -ones (size (x));
## Try to compute the exact value for powers 10^n with n in [0, 22].
## If we set the rounding mode, log10 will not compute the exact value.
possiblyexact = x.inf >= 1 & fix (x.inf) == x.inf;
l (possiblyexact) = real (log10 (x.inf (possiblyexact)));
notexact = fix (l) ~= l | l < 0 | l > 22 | realpow (10, l) ~= x.inf;
fesetround (-inf);
l (notexact) = real (log10 (x.inf (notexact)));
fesetround (0.5);
l (notexact) = ulpadd (l (notexact), -3);

possiblyexact = x.sup >= 1 & fix (x.sup) == x.sup;
u (possiblyexact) = real (log10 (x.sup (possiblyexact)));
notexact = fix (u) ~= u | u < 0 | u > 22 | realpow (10, u) ~= x.sup;
fesetround (inf);
u (notexact) = real (log10 (x.sup (notexact)));
fesetround (0.5);
u (notexact) = ulpadd (u (notexact), 3);

l (x.inf <= 0) = -inf;

emptyresult = isempty (x) | x.sup <= 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction