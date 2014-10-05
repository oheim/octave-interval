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

## -- IEEE 1788 accessory function:  nextout (X)
##
## Increases the interval's boundaries in each direction to the next number.
##
## This is the equivalent function to IEEE 754's nextdown and nextup.
##
## Example:
##  x = infsup (1);
##  y = nextout (x); # == [1-eps, 1+eps]

## Author: Oliver Heimlich
## Keywords: interval function
## Created: 2014-09-30

function result = nextout (x)

if (isempty (x))
    result = empty ();
    return
endif

result = infsup (nextdown (x.inf), nextup (x.sup));

endfunction