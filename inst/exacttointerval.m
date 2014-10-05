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

## -- IEEE 1788 constructor:  exacttointerval (S)
##
## Create an interval from an interval literal.  Fail, if the interval cannot
## exactly represent the input S.
##
## The equation X == exacttointerval (intervaltoexact (X)) holds for all
## intervals.
##
## See also:
##  texttointerval, intervaltoexact, numstointerval
##
## Example:
##  x = exacttointerval ("[2, 3]"); # ok
##  y = exacttointerval ("[2, 3.1]"); # fails, “3.1” is no binary64 number

## Author: Oliver Heimlich
## Keywords: interval constructor
## Created: 2014-10-01

function x = exacttointerval (s)

[x, exactconversion] = texttointerval (s);

if (not (exactconversion))
    error ("rounding occurred during interval construction")
endif

endfunction