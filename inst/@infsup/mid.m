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

## -- IEEE 1788 numeric function:  mid (X)
##
## Get midpoint of interval X.
##
## If X is empty, mid (X) is NaN.
## If X is entire, mid (X) is 0.
## If X is unbounded in one direction, mid (X) is +/- realmax ().
## If X is bound, mid (X) is the actual midpoint rounded to nearest.
##
## Example:
##  mid (infsup (2, 3));
##   |=> 2.5

## Author: Oliver Heimlich
## Keywords: interval numeric function
## Created: 2014-10-05

function midpoint = mid (x)

if (isempty (x))
    midpoint = nan ();
elseif (isentire (x))
    midpoint = 0;
elseif (x.sup == inf)
    midpoint = realmax ();
elseif (x.inf == -inf)
    midpoint = -realmax ();
else
    ## First divide by 2 and then add, because this will prevent overflow.
    ## The different rounding modes for division will make errors of 2^-1075
    ## with subnormal numbers cancel each other out, or will make the round
    ## to nearest prefer the side that had a rounding error.
    fesetround (-inf);
    l = x.inf / 2;
    fesetround (inf);
    u = x.sup / 2;
    fesetround (0.5);
    midpoint = l + u;
endif

return