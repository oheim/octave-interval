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
## @deftypefn {Function File} {} fix (@var{X})
## 
## Truncate fractional portion of each number in interval @var{X}.  This is
## equivalent to rounding towards zero.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fix (infsupdec (2.5, 3.5))
##   @result{} [2, 3]_def
## fix (infsupdec (-0.5, 5))
##   @result{} [0, 5]_def
## @end group
## @end example
## @seealso{@@infsupdec/floor, @@infsupdec/ceil, @@infsupdec/round, @@infsupdec/roundb}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = fix (x)

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (fix (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

## Between two integral numbers the function is constant, thus continuous
## At x == 0 the function is continuous.
discontinuous = not (...
    issingleton (result) & ...
    (sup (x) >= 0 | fix (sup (x)) ~= sup (x)) & ...
    (inf (x) <= 0 | fix (inf (x)) ~= inf (x)));
result.dec (discontinuous) = mindec (result.dec (discontinuous), "def");

endfunction