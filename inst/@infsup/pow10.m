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
## @deftypefn {Interval Function} {} pow10 (@var{X})
## @cindex IEEE1788 exp10
## 
## Compute @code{10^x} for all numbers in @var{X}.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest when
## interval boundaries are integral.
##
## @example
## @group
## pow10 (infsup (5))
##   @result{} [100000]
## @end group
## @end example
## @seealso{log10, pow, pow2, exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pow10 (x)

result = pow (10, x);

endfunction