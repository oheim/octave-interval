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

## -- IEEE 1788 numeric function:  rad (X)
##
## Get radius of interval X.
##
## If X is empty, rad (X) is NaN.
## If X is unbounded in one or two directions, rad (X) is inf.
## If X is bound, rad (X) will make a tight enclosure of the interval together
## with mid (X).
##
## Example:
##  rad (infsup (2, 3));
##   |=> 0.5

## Author: Oliver Heimlich
## Keywords: interval numeric function
## Created: 2014-10-05

function radius = rad (x)

if (isempty (x))
    radius = nan ();
elseif (isentire (x) || not (isfinite (x.inf) && isfinite (x.sup)))
    radius = inf;
else
    m = mid (x);
    ## The midpoint is rounded to nearest and the radius must cover
    ## both boundaries.
    fesetround (inf);
    r1 = m - x.inf;
    r2 = x.sup - m;
    fesetround (0.5);
    radius = max (r1, r2);
endif

return