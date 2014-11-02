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
## @deftypefn {Interval Function} {} pow2 (@var{X})
## @cindex IEEE1788 exp2
## 
## Compute @code{2^x} for all numbers in @var{X}.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest when
## interval boundaries are integral.
##
## @example
## @group
## pow2 (infsupdec (5))
##   @result{} [32]_com
## @end group
## @end example
## @seealso{log2, pow, pow10, exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pow2 (x)

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (pow2 (intervalpart (x)));
## pow2 is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec);

endfunction