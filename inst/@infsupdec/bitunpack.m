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
## @defmethod {@@infsupdec} bitunpack (@var{X})
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## 
## Encode decorated interval @var{X} in interchange format.
##
## The result is a raw bit pattern of length 136 that derive from two binary64
## numbers plus 8 bit for the decoration.  Bits are in increasing order.
## Byte order depends on the system's endianness.  First 8 bytes come from the
## lower interval boundary, next 8 bytes come from the upper interval boundary,
## last byte comes from the decoration.
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

## The exchange representation of [NaI] is (NaN, NaN, ill).
if (isnai (x))
    result = [bitunpack(zeros (1, 'uint8')), bitunpack(nan (1, 2))];
    return
endif

bare = bitunpack (intervalpart (x));
d = bitunpack (x.dec);

## Initialize result vector
result = zeros (1, length (bare) + length (d), 'logical');
if (not (isrow (bare)))
    result = result';
endif

## Merge alternating 128 bit blocks from bare and 8 bit blocks from d together
## into result.
target_bare = reshape (1 : length (result), 8, length (result) / 8);
target_d = target_bare (:, 17 : 17 : size (target_bare, 2));
target_bare (:, 17 : 17 : size (target_bare, 2)) = [];
result (target_bare) = bare;
result (target_d) = d;

endfunction

%!test;
%!  littleendian = bitunpack (uint16 (1))(1);
%!  b = zeros (1, 136);
%!  if (littleendian)
%!    b([52, 63, 117, 127, 133]) = 1;
%!  else
%!    b([7, 12, 71, 77, 133]) = 1;
%!  endif
%!  assert (bitunpack (infsupdec (3, 4)), logical (b));
