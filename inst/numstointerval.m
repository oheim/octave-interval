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

## -- IEEE 1788 constructor:  numstointerval (L, U)
##
## Create an interval from two numeric boundaries.
##
## [L, U] = { x in reals | L <= x <= U }
##
## See also:
##  infsup
##
## Example:
##  x = numstointerval (2, 3); # interval from 2 to 3 (inclusive)

## Author: Oliver Heimlich
## Keywords: interval constructor
## Created: 2014-09-30

function interval = numstointerval (l, u)

## All the logic in the infsup constructor can be used, except ...
interval = infsup (l, u);

## ... this constructor must not allow construction of an empty interval.
if (isempty (interval))
    error ("empty interval not allowed")
endif

endfunction
