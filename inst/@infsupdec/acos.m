## Copyright 2014-2015 Oliver Heimlich
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
## @documentencoding utf-8
## @deftypefn {Function File} {} acos (@var{X})
## 
## Compute the inverse cosine in radians (arccosine).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acos (infsupdec (.5))
##   @result{} [1.0471975511965976, 1.0471975511965979]_com
## @end group
## @end example
## @seealso{@@infsupdec/cos}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = acos (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (acos (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);
## acos is continuous everywhere, but defined for [-1, 1] only
result.dec (not (subset (x, infsup (-1, 1)))) = "trv";

endfunction