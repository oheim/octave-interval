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
## @defmethod {@@infsupdec} expm1 (@var{X})
## 
## Compute @code{exp (@var{X} - 1)} accurately in the neighborhood of zero.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## expm1 (infsupdec (eps))
##   @result{} ans ⊂ [2.2204e-16, 2.2205e-16]_com
## @end group
## @end example
## @seealso{@@infsup/exp, @@infsup/log1p}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function result = expm1 (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (expm1 (intervalpart (x)));
## expm1 is defined and continuous everywhere
result.dec = min (result.dec, x.dec);

endfunction

%!test "from the documentation string";
%! assert (isequal (expm1 (infsupdec (eps)), infsupdec ("[0x1p-52, 0x1.0000000000001p-52]")));
