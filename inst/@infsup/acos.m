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
## @deftypefn {Interval Function} {} acos (@var{X})
## @cindex IEEE1788 acos
## 
## Compute the inverse cosine in radians (arccosine) for each number in
## interval @var{X}.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## acos (infsup (.5))
##   @result{} [1.0471975511965976, 1.0471975511965981]
## @end group
## @end example
## @seealso{cos}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = acos (x)

l = ulpadd (real (acos (x.sup)), -1);
u = ulpadd (real (acos (x.inf)), 1);

## Make the function tightest for special parameters
pi = infsup ("pi");
nonpositive = x.sup <= 0;
nonnegative = x.inf >= 0;
l (x.sup >= 1) = 0;
l (nonpositive) = max (l (nonpositive), inf (pi) / 2);
l (x.sup == -1) = inf (pi);
u (x.inf <= -1) = sup (pi);
u (nonnegative) = min (u (nonnegative), sup (pi) / 2);
u (x.inf == 1) = 0;

emptyresult = isempty (x) | x.inf > 1 | x.sup < -1;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction