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
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## 
## Encode bare interval @var{X} in interchange format.
##
## The result is a raw bit pattern of length 128 that derive from two binary64
## numbers.  Bits are in increasing order.
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

## The exchange representation of [Empty] is (+inf, -inf).  The exchange
## representation of [0, 0] is (-0, +0). Both is ensured by the infsup
## constructor.

l = bitunpack (x.inf);
u = bitunpack (x.sup);

## Initialize result vector
result = zeros (1, length (l) * 2, 'logical');
if (not (isrow (l)))
    result = result';
endif

## Merge 64 bit blocks from l and u (alternating) together into result.
## Because of increasing bit order, u comes first.
target = reshape (1 : length (result), 64, numel (x.inf) * 2);
target (:, 2 : 2 : size (target, 2)) = [];
result (target) = u;
result (target + 64) = l;

endfunction
