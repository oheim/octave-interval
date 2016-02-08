## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} cot (@var{X})
## 
## Compute the cotangent in radians, that is the reciprocal tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cot (infsupdec (1))
##   @result{} ans ⊂ [0.64209, 0.6421]_com
## @end group
## @end example
## @seealso{@@infsupdec/tan, @@infsupdec/csc, @@infsupdec/sec}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = cot (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (cot (intervalpart (x)));
result.dec = min (result.dec, x.dec);

## Because tan (nextdown (pi)) < realmax, we can simple check for
## a singularity by comparing the result with entire for x ~= 0.
domain = not (isentire (result)) | (inf (x) <= 0 & sup (x) >= 0);
result.dec (not (domain)) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (cot (infsupdec (1)), infsupdec ("[0x1.48C05D04E1CFDp-1, 0x1.48C05D04E1CFEp-1]")));
