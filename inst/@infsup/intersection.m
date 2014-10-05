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

## -- IEEE 1788 interval set operation:  intersection (A, B)
##
## Intersect two intervals.
##
## See also:
##  convexhull
##
## Example:
##  x = infsup (1, 3);
##  y = infsup (2, 4);
##  intersect (x, y) # == [2, 3]

## Author: Oliver Heimlich
## Keywords: interval set operation
## Created: 2014-09-30

function result = intersection (a, b)

if (isempty (a) || isempty (b))
    result = empty ();
    return
endif

if (isentire (a))
    result = b;
    return
endif

if (isentire (b))
    result = a;
    return
endif

if (a.sup < b.inf || b.sup < a.inf)
    result = empty ();
    return
endif

result = infsup (max (a.inf, b.inf), min (a.sup, b.sup));

endfunction