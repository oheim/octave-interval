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

## -- IEEE 1788 interval set operation:  convexhull (A, B)
##
## Build the interval hull of the union of two intervals.
##
## See also:
##  intersection
##
## Example:
##  x = infsup (1, 2);
##  y = infsup (3, 4);
##  convexhull (x, y) # == [1, 4]

## Author: Oliver Heimlich
## Keywords: interval set operation
## Created: 2014-09-30

function result = convexhull (a, b)

if (isempty (a) || isentire (b))
    result = b;
    return
endif

if (isempty (b) || isentire (a))
    result = a;
    return
endif

result = infsup (min (a.inf, b.inf), max (a.sup, b.sup));

endfunction