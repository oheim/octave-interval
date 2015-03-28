## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} cbrt (@var{X})
## 
## Compute the cube root (for all non-negative numbers).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cbrt (infsupdec (-6, 27))
##   @result{} [0, 3]_trv
## @end group
## @end example
## @seealso{@@infsupdec/realsqrt, @@infsupdec/nthroot}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = cbrt (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (cbrt (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

## cbrt is continuous everywhere, but defined for x >= 0 only
defined = subset (x, infsupdec (0, inf));
result.dec (not (defined)) = "trv";

endfunction

%!test "from the documentation string";
%! assert (isequal (cbrt (infsupdec (-6, 27)), infsupdec (0, 3, "trv")));
