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

## -- IEE1788 integer function:  trunc (X)
##
## Round each element of X towards zero.
##
## Example:
##  trunc (infsup (2.5, 3.5))
##   |=> [2, 3]
##  trunc (infsup (-0.5, 5.5))
##   |=> [0, 5]

## Author: Oliver Heimlich
## Keywords: interval integer function
## Created: 2014-10-04

function result = trunc (x)

if (isempty (x))
    result = empty ();
    return
endif

result = infsup (fix (x.inf), fix (x.sup));

endfunction