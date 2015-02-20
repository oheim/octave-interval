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
## @deftypefn {Function File} {} sum (@var{X})
## @deftypefnx {Function File} {} sum (@var{X}, @var{DIM})
## 
## Sum of elements along dimension @var{DIM}.  If @var{DIM} is omitted, it
## defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sum ([infsupdec(1), pow2(-1074), -1])
##   @result{} [4e-324, 5e-324]_com
## infsupdec (1) + pow2 (-1074) - 1
##   @result{} [0, 2.2204460492503131e-16]_com
## @end group
## @end example
## @seealso{@@infsupdec/plus}
## @end deftypefn

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

if (dim == 1)
    resultsize = [1, size(x.dec, 2)];
elseif (dim == 2)
    resultsize = [size(x.dec, 1), 1];
else
    error ("interval:InvalidOperand", "sum: DIM must be a valid dimension")
endif

result = infsupdec (sum (intervalpart (x), dim));
result.dec = mindec (result.dec, reducedec (x.dec, dim));

endfunction

%!test "from the documentation string";
%! assert (isequal (sum ([infsupdec(1), pow2(-1074), -1]), infsupdec (pow2 (-1074))));
