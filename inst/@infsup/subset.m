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

## -- IEEE 1788 interval comparison:  subset (A, B)
##
## Evaluate subset comparison on intervals.
##
## True, if all numbers from A are also contained in B.
## False, if A contains a number which is not a member in B.
##
## See also:
##  interior, equal, disjoint
##
## Example:
##  x = infsup (1, 3);
##  y = infsup (2, 3);
##  if (subset (y, x))
##    display ("success")
##  endif

## Author: Oliver Heimlich
## Keywords: interval comparison
## Created: 2014-09-30

function result = subset (a, b)

assert (nargin == 2);

if (isempty (a) || isentire (b))
    result = true ();
    return
endif

if (isempty (b) || isentire (a))
    result = false ();
    return
endif

result = (b.inf <= a.inf && a.sup <= b.sup);

endfunction