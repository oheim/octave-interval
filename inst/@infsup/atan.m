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
## @deftypefn {Interval Function} {} atan (@var{X})
## @cindex IEEE1788 atan
## 
## Compute the inverse tangent in radians for each number in interval @var{X}.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## atan (infsup (1))
##   @result{} [.7853981633974481, .7853981633974484]
## @end group
## @end example
## @seealso{tan, atan2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = atan (x)

pi = infsup ("pi");
l = max (ulpadd (atan (x.inf), -1), inf (-pi) / 2);
u = min (ulpadd (atan (x.sup), 1), sup (pi) / 2);

## Make function tightest for x == 0
nonnegative = x.inf >= 0;
l (nonnegative) = max (0, l (nonnegative)); 
nonpositive = x.sup <= 0;
u (nonpositive) = min (0, u (nonpositive));

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction