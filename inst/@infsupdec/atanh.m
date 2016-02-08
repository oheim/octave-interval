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
## @defmethod {@@infsupdec} atanh (@var{X})
## 
## Compute the inverse hyperbolic tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atanh (infsupdec (.5))
##   @result{} ans ⊂ [0.5493, 0.54931]_com
## @end group
## @end example
## @seealso{@@infsupdec/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = atanh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (atanh (intervalpart (x)));
result.dec = min (result.dec, x.dec);
## atanh is continuous everywhere, but defined for ]-1, 1[ only
result.dec (not (interior (x, infsupdec (-1, 1)))) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (atanh (infsupdec (.5)), infsupdec ("[0x1.193EA7AAD030Ap-1, 0x1.193EA7AAD030Bp-1]")));
