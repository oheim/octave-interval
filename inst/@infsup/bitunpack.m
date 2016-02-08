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
## @defmethod {@@infsup} bitunpack (@var{X})
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## 
## Encode bare interval @var{X} in interchange format.
##
## The result is a raw bit pattern of length 128 that derive from two binary64
## numbers.  Bits are in increasing order.  Byte order depends on the system's
## endianness.  First 8 bytes come from the lower interval boundary, last
## 8 bytes come from the upper interval boundary.
##
## The result is a row vector if @var{X} is a row vector; otherwise, it is a
## column vector.
##
## For all scalar intervals the following equation holds:
## @code{@var{X} == interval_bitpack (bitunpack (@var{X}))}.
##
## @seealso{interval_bitpack}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-12-23

function result = bitunpack (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## The exchange representation of [Empty] is (+inf, -inf).  The exchange
## representation of [0, 0] is (-0, +0). Both is guaranteed by the infsup
## constructor.

l = bitunpack (x.inf);
u = bitunpack (x.sup);

## Initialize result vector
result = zeros (1, length (l) + length (u), 'logical');
if (not (isrow (l)))
    result = result';
endif

## Merge 64 bit blocks from l and u (alternating) together into result.
target = reshape (1 : length (result), 64, numel (x.inf) + numel (x.sup));
target (:, 2 : 2 : size (target, 2)) = [];
result (target) = l;
result (target + 64) = u;

endfunction

%!test;
%!  littleendian = bitunpack (uint16 (1))(1);
%!  b = zeros (1, 128);
%!  if (littleendian)
%!    b([52, 63, 117, 127]) = 1;
%!  else
%!    b([7, 12, 71, 77]) = 1;
%!  endif
%!  assert (bitunpack (infsup (3, 4)), logical (b));
