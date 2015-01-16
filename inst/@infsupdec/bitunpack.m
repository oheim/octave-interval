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
## @deftypefn {Function File} {} bitunpack (@var{X})
## 
## Encode decorated interval @var{X} in interchange format.
##
## The result is a raw bit pattern of length 136 that derive from two binary64
## numbers plus 8 bit for the decoration.  Bits are in increasing order.
##
## The result is a row vector if @var{X} is a row vector; otherwise, it is a
## column vector.
##
## For all scalar intervals the following equation holds:
## @code{@var{X} == interval_bitpack (bitunpack (@var{X}))}.
##
## @seealso{interval_bitpack}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-12-23

function result = bitunpack (x)

## The exchange representation of [NaI] is (NaN, NaN, ill).
if (isnai (x))
    result = [bitunpack(zeros (1, 'uint8')), bitunpack(nan (1, 2))];
    return
endif

bare = bitunpack (intervalpart (x));
d = bitunpack (uint8 (...
        strcmp (x.dec, 'trv') * 4 + ...
        strcmp (x.dec, 'def') * 8 + ...
        strcmp (x.dec, 'dac') * 12 + ...
        strcmp (x.dec, 'com') * 16));

## Initialize result vector
result = zeros (1, length (bare) + length (d), 'logical');
if (not (isrow (bare)))
    result = result';
endif

## Merge alternating 128 bit blocks from bare and 8 bit blocks from d together
## into result.  Because of increasing bit order, d comes first.
target_bare = reshape (1 : length (result), 8, length (result) / 8);
target_d = target_bare (:, 1 : 17 : size (target_bare, 2));
target_bare (:, 1 : 17 : size (target_bare, 2)) = [];
result (target_bare) = bare;
result (target_d) = d;

endfunction
