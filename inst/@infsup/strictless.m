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

## -- IEEE 1788 interval comparison:  strictless (A, B)
##
## Evaluate strict less comparison on intervals.
##
## True, if all numbers from A are strict less than any number in B.
## False, if A contains a number which is greater than all numbers in B or is
## equal to the greates number of B.
##
## See also:
##  subset, interior, disjoint, less
##
## Example:
##  x = infsup (1, 2);
##  y = infsup (2, 3);
##  if (not (strictless (x, y)))
##    display ("success")
##  endif

## Author: Oliver Heimlich
## Keywords: interval comparison
## Created: 2014-10-07

function result = strictless (a, b)

assert (nargin == 2);

if (isempty (a) && isempty (b))
    result = true ();
    return
endif

if (isempty (a) || isempty (b))
    result = false ();
    return
endif

result = ((a.inf < b.inf || (a.inf == -inf && b.inf == -inf)) && ...
          (a.sup < b.sup || (a.sup == inf && b.sup == inf)));

endfunction