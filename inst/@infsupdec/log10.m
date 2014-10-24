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
## @deftypefn {Interval Function} {@var{Y} =} log10 (@var{X})
## @cindex IEEE1788 log10
## 
## Compute the decimal (base-10) logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 3.5 ULPs of the tightest enclosure.
##
## @example
## @group
## log10 (infsupdec (2))
##   @result{} [.30102999566398097, .30102999566398143]_com
## @end group
## @end example
## @seealso{pow10, log, log2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = log10 (x)

if (isnai (x))
    result = x;
    return
endif

result = log10 (intervalpart (x));
## log10 is continuous everywhere, but defined for x > 0 only
if (interior (x, infsup(0, inf)))
    result = decorateresult (result, {x});
else
    result = decorateresult (result, {x}, "trv");
endif

endfunction