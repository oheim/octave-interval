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

## -- IEEE 1788 interval comparison:  less (A, B)
##
## Evaluate less comparison on intervals.
##
## True, if all numbers from A are weakly less than any number in B.
## False, if A contains a number which is strictly greater than all numbers
## in B.
##
## See also:
##  subset, interior, disjoint, strictless
##
## Example:
##  x = infsup (1, 3);
##  y = infsup (2, 3);
##  if (less (x, y))
##    display ("success")
##  endif

## Author: Oliver Heimlich
## Keywords: interval comparison
## Created: 2014-10-07

function result = less (a, b)

assert (nargin == 2);

if (isempty (a) && isempty (b))
    result = true ();
    return
endif

if (isempty (a) || isempty (b))
    result = false ();
    return
endif

result = (a.inf <= b.inf && a.sup <= b.sup);

endfunction