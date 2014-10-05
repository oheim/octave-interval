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

## -- IEE1788 integer function:  floor (X)
##
## Round each element of X towards -inf.
##
## Example:
##  floor (infsup (2.5, 3.5))
##   |=> [2, 3]
##  floor (infsup (-0.5, 5))
##   |=> [-1, 5]

## Author: Oliver Heimlich
## Keywords: interval integer function
## Created: 2014-10-04

function result = floor (x)

if (isempty (x))
    result = empty ();
    return
endif

result = infsup (floor (x.inf), floor (x.sup));

endfunction