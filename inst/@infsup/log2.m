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
## @deftypefn {Interval Function} {} log2 (@var{X})
## @cindex IEEE1788 log2
## 
## Compute the binary (base-2) logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest for
## powers of two.
##
## @example
## @group
## log2 (infsup (2))
##   @result{} [1]
## @end group
## @end example
## @seealso{pow2, log, log10}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log2 (x)

l = real (log2 (x.inf));
notexact = fix (l) ~= l | l < -1074 | l > 1023 | pow2 (l) ~= x.inf;
l (notexact) = ulpadd (l (notexact), -1);

u = real (log2 (x.sup));
notexact = fix (u) ~= u | u < -1074 | u > 1023 | pow2 (u) ~= x.sup;
u (notexact) = ulpadd (u (notexact), 1);

l (x.inf <= 0) = -inf;

emptyresult = isempty (x) | x.sup <= 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction