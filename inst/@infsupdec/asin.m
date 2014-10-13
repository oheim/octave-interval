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
## @deftypefn {Interval Function} {@var{Y} =} asin (@var{X})
## @cindex IEEE1788 asin
## 
## Compute the inverse sine in radians (arcsine) for each number in
## interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asin (infsupdec (.5))
##   @result{} [.5235987755982988, .523598775598299]_com
## @end group
## @end example
## @seealso{sin}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = asin (x)

result = asin (intervalpart (x));
## asin is continuous everywhere, but defined for [-1, 1] only
if (subset (x, infsup(-1, 1)))
    result = decorateresult (result, {x});
else
    result = decorateresult (result, {x}, "trv");
endif

endfunction