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
##   @result{} [1.3169578969248156, 1.3169578969248175]
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

result = infsup (l, u);

endfunction