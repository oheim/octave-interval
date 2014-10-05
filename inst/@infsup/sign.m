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

## -- IEE1788 integer function:  sign (X)
##
## Compute the sign of each element of X.
##
## Example:
##  sign (infsup (2, 3))
##   |=> [1]
##  sign (infsup (0, 5))
##   |=> [0, 1]
##  sign (infsup (-17))
##   |=> [-1]

## Author: Oliver Heimlich
## Keywords: interval integer function
## Created: 2014-10-04

function result = sign (x)

if (isempty (x))
    result = empty ();
    return
endif

if (x.inf < 0)
    if (x.sup > 0)
        result = infsup (-1, 1);
    elseif (x.sup == 0)
        result = infsup (-1, 0);
    else
        result = infsup (-1);
    endif
elseif (x.inf == 0)
    if (x.sup == 0)
        result = infsup (0, 0);
    else
        result = infsup (0, 1);
    endif
else
    result = infsup (1);
endif

endfunction