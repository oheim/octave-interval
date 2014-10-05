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

## -- IEEE 1788 interval function:  neg (x)
##
## Negate all numbers in the interval.
##
## Example:
##  x = infsup (1, 2);
##  y = neg (x); # == [-2, -1]

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-09-30

function result = neg (x)

if (isempty (x))
    result = empty ();
    return
endif

result = infsup (-x.sup, -x.inf);

endfunction