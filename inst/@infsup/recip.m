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
## @deftypefn {Interval Function} {@var{Z} =} recip (@var{X})
## @cindex IEEE1788 recip
## 
## Compute reciprocal of all numbers of interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (1, 5);
## recip (x)
##   @result{} [.19999999999999998, 1]
## @end group
## @end example
## @seealso{pown, pow, mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = recip (x)

result = infsup (1) / x;

endfunction