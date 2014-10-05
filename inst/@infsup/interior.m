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

## -- IEEE 1788 interval comparison:  interior (A, B)
##
## Evaluate interior comparison on intervals.
##
## True, if all numbers from A are also contained in B, but are no boundaries
## of B.  False, if A contains a number which is not a member in B or which is
## a boundary of B.
##
## See also:
##  subset, equal, disjoint
##
## Example:
##  x = infsup (1, 4);
##  y = infsup (2, 3);
##  if (interior (y, x))
##    display ("success")
##  endif

## Author: Oliver Heimlich
## Keywords: interval comparison
## Created: 2014-09-30

function result = interior (a, b)

assert (nargin == 2);

if (isempty (a) || isentire (b))
    result = true ();
    return
endif

if (isempty (b) || isentire (a))
    result = false ();
    return
endif

result = (b.inf < a.inf && a.sup < b.sup);

endfunction