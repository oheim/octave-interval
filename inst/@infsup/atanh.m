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
## @deftypefn {Interval Function} {} atanh (@var{X})
## @cindex IEEE1788 atanh
## 
## Compute the inverse hyperbolic tangent for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 8 ULPs of the exact enclosure.
##
## @example
## @group
## atanh (infsup (.5))
##   @result{} [.5493061443340543, .5493061443340553]
## @end group
## @end example
## @seealso{tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = atanh (x)

l = ulpadd (real (atanh (x.inf)), -4);
u = ulpadd (real (atanh (x.sup)), 4);

## Make funtion tightest for x == 0
nonnegative = x.inf >= 0;
l (nonnegative) = max (l (nonnegative), 0);
nonpositive = x.sup <= 0;
u (nonpositive) = min (u (nonpositive), 0);

emptyresult = isempty (x) | x.sup <= -1 | x.inf >= 1;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction