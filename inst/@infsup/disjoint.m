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

## -- IEEE 1788 interval comparison:  disjoint (A, B)
##
## Evaluate disjoint comparison on intervals.
##
## True, if all numbers from A are not contained in B and vice versa.
## False, if A and B have at least one element in common.
##
## See also:
##  subset, equal, interior
##
## Example:
##  x = infsup (1, 2);
##  y = infsup (3, 4);
##  if (disjoint (x, y))
##    display ("success")
##  endif

## Author: Oliver Heimlich
## Keywords: interval comparison
## Created: 2014-09-30

function result = disjoint (a, b)

assert (nargin == 2);

if (isempty (a) || isempty (b))
    result = true ();
    return
endif

if (isentire (a) || isentire (b))
    result = false ();
    return
endif

result = (a.sup < b.inf || b.sup < a.inf);

endfunction