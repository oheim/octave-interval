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
## @deftypefn {Interval Function} {@var{Y} =} atanh (@var{X})
## @cindex IEEE1788 atanh
## 
## Compute the inverse hyperbolic tangent for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 8 ULPs of the exact enclosure.
##
## @example
## @group
## atanh (infsupdec (.5))
##   @result{} [.5493061443340543, .5493061443340553]_com
## @end group
## @end example
## @seealso{tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = atanh (x)

if (isnai (x))
    result = x;
    return
endif

result = atanh (intervalpart (x));
## atanh is continuous everywhere, but defined for [-1, 1] only
if (subset (x, infsup(-1, 1)))
    result = decorateresult (result, {x});
else
    result = decorateresult (result, {x}, "trv");
endif

endfunction