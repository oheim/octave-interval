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

## -- IEEE 1788 numeric function:  wid (X)
##
## Get width of interval X.
##
## If X is empty, wid (X) is NaN.
## If X is unbounded in one or two directions, wid (X) is inf.
## If X is bound, wid (X) will make a tight enclosure of the interval's actual
## width.
##
## Example:
##  wid (infsup (2, 3));
##   |=> 1

## Author: Oliver Heimlich
## Keywords: interval numeric function
## Created: 2014-10-05

function width = wid (x)

if (isempty (x))
    width = nan ();
elseif (isentire (x) || not (isfinite (x.inf) && isfinite (x.sup)))
    width = inf;
else
    fesetround (inf);
    width = x.sup - x.inf;
    fesetround (0.5);
endif

return