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
## @deftypefn {Interval Function} {@var{Y} =} acosh (@var{X})
## @cindex IEEE1788 acosh
## 
## Compute the inverse hyperbolic cosine for each number in interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acosh (infsupdec (2))
##   @result{} [1.3169578969248165, 1.3169578969248168]_com
## @end group
## @end example
## @seealso{cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = acosh (x)

result = acosh (intervalpart (x));
## acosh is continuous everywhere, but defined for [1, Inf] only
if (subset (x, infsup(1, inf)))
    result = decorateresult (result, {x});
else
    result = decorateresult (result, {x}, "trv");
endif

endfunction