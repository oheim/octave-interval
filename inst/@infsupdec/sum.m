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
## @defmethod {@@infsupdec} sum (@var{X})
## @defmethodx {@@infsupdec} sum (@var{X}, @var{DIM})
## 
## Sum of elements along dimension @var{DIM}.  If @var{DIM} is omitted, it
## defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sum ([infsupdec(1), pow2(-1074), -1])
##   @result{} ans ⊂ [4.9406e-324, 4.9407e-324]_com
## infsupdec (1) + pow2 (-1074) - 1
##   @result{} ans ⊂ [0, 2.2205e-16]_com
## @end group
## @end example
## @seealso{@@infsupdec/plus}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-01-31

function result = sum (x, dim)

if (nargin > 2)
    print_usage ();
    return
endif

if (nargin < 2)
    ## Try to find non-singleton dimension
    dim = find (size (x.dec) > 1, 1);
    if (isempty (dim))
        dim = 1;
    endif
endif

result = newdec (sum (intervalpart (x), dim));
if (not (isempty (x.dec)))
    result.dec = min (result.dec, min (x.dec, [], dim));
endif

endfunction

%!test "from the documentation string";
%! assert (isequal (sum ([infsupdec(1), pow2(-1074), -1]), infsupdec (pow2 (-1074))));
