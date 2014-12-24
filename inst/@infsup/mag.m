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
## @deftypefn {Interval Numeric} {} mag (@var{X})
## @cindex IEEE1788 mag
## 
## Get the magnitude of numbers in interval @var{X}, that is the maximum of
## absolute values for each element.
##
## If @var{X} is empty, @code{mag (@var{X})} is NaN.
##
## Accuracy: The result is exact.
##
## @example
## @group
## mag (infsup (-3, 2))
##   @result{} 3
## @end group
## @end example
## @seealso{mig, inf, sup}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = mag (x)

result = max (abs (x.inf), abs (x.sup));
result (isempty (x)) = nan ();

endfunction