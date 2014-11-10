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
## @deftypefn {Interval Function} {} inv (@var{A})
## @cindex IEEE1788 recip
## 
## Compute the inverse of the square matrix @var{A}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## inv (infsup ([2, 1, 1;0, 1, 0; 1, 0, 0]))
##   @result{} 3×3 interval matrix
##      [0]    [0]    [1]
##      [0]    [1]    [0]
##      [1]   [-1]   [-2]
## inv (infsup([1, 2, 3;4, 0, 6;0, 0, 1]))
##   @result{} 3×3 interval matrix
##       [0]     [.25]   [-1.5]
##      [.5]   [-.125]   [-.75]
##       [0]       [0]      [1]
## @end group
## @end example
## @seealso{mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = inv (x)

n = length (x);
if (n <= 1)
    result = 1 ./ x;
    return
endif

result = mldivide (x, eye (n));

endfunction