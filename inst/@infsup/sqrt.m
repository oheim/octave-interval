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

## -- IEEE 1788 interval function:  sqrt (X)
##
## Compute square root of all non-negative elements of interval X.
##
## See also:
##  sqr, pow
##
## Example:
##  x = infsup(-6, 4);
##  sqrt (x) # == [0, 2]

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-10-01

function result = sqrt (x)

if (isempty (x) || x.sup < 0)
    result = empty ();
    return
endif

if (x.inf <= 0)
    root.inf = 0;
else
    fesetround (-inf);
    root.inf = realsqrt (x.inf);
endif
fesetround (inf);
root.sup = realsqrt (x.sup);

fesetround (0.5);
result = infsup (root.inf, root.sup);

endfunction