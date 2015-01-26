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
## @documentencoding utf-8
## @deftypefn {Function File} {} acosh (@var{X})
## 
## Compute the inverse hyperbolic cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acosh (infsupdec (2))
##   @result{} [1.3169578969248165, 1.3169578969248168]_com
## @end group
## @end example
## @seealso{@@infsupdec/cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = acosh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (acosh (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);
## acosh is continuous everywhere, but defined for [1, Inf] only
result.dec (not (subset (x, infsup (1, inf)))) = "trv";

endfunction