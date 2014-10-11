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
## @deftypefn {Interval Numeric} {@var{Y} =} inf (@var{X})
## @cindex IEEE1788 inf
## 
## Get the (greatest) lower boundary for all numbers of interval @var{X}.
##
## If @var{X} is empty, @code{inf (@var{X})} is positive infinity.
##
## Accuracy: The result is exact.
##
## @example
## @group
## inf (infsup (2.5, 3.5))
##   @result{} 2.5
## @end group
## @end example
## @seealso{sup, mid}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function infimum = inf (interval)

infimum = interval.inf;
return