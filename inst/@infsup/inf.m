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

## -- IEEE 1788 numeric function:  inf (X)
##
## Get (greatest) lower boundary for all elements of interval X.
##
## If X is empty, inf (X) is positive infinity.
##
## Example:
##  x = infsup (2, 3);
##  if (inf (x) == 2)
##    display ("success");
##  endif

## Author: Oliver Heimlich
## Keywords: interval numeric function
## Created: 2014-09-27

function infimum = inf (interval)

infimum = interval.inf;
return