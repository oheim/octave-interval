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
## @deftypefn {Function File} {@var{Y} =} nextdown (@var{X})
## 
## Return the greatest floating point number which is smaller than @var{X}.
##
## If @var{X} is -Inf, return -Inf.
## @seealso{nextup}
## @end deftypefn

## Author: Oliver Heimlich
## Created: 2014-09-30

function result = nextdown (x)

assert (isa (x, "double"));

## smallest denormalized number, i. e., smallest delta between two numbers
delta = pow2 (-1074);

fesetround(-inf);
result = x - delta;

## reset standard rounding mode
fesetround(0.5);

result (result == inf) = realmax ();

endfunction