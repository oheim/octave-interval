## Copyright 2014-2016 Oliver Heimlich
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
## @documentencoding UTF-8
## @defmethod {@@infsupdec} asinh (@var{X})
## 
## Compute the inverse hyperbolic sine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asinh (infsupdec (1))
##   @result{} ans ⊂ [0.88137, 0.88138]_com
## @end group
## @end example
## @seealso{@@infsupdec/sinh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = asinh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (asinh (intervalpart (x)));
## asinh is defined and continuous everywhere
result.dec = min (result.dec, x.dec);

endfunction

%!test "from the documentation string";
%! assert (isequal (asinh (infsupdec (1)), infsupdec ("[0x1.C34366179D426p-1, 0x1.C34366179D427p-1]")));
