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

## -- IEE1788 interval function:  max (X, Y)
##
## Compute the maximum value for each pair of elements from X and Y.
##
## See also:
##  min

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-10-04

function result = max (x, y)

if (isempty (x) || isempty (y))
    result = empty ();
    return
endif

result = infsup (max (x.inf, y.inf), max (x.sup, y.sup));

endfunction