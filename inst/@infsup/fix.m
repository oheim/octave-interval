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
## @deftypefn {Interval Function} {@var{Y} =} fix (@var{X})
## @cindex IEEE1788 truc
## 
## Truncate fractional portion of each number in interval @var{X}.  This is
## equivalent to rounding towards zero.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fix (infsup (2.5, 3.5))
##   @result{} [2, 3]
## fix (infsup (-0.5, 5))
##   @result{} [0, 5]
## @end group
## @end example
## @seealso{floor, ceil, round, roundb}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = fix (x)

if (isempty (x))
    result = infsup ();
    return
endif

result = infsup (fix (x.inf), fix (x.sup));

endfunction