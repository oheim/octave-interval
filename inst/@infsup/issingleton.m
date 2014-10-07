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

## -- IEEE 1788 boolean function:  issingleton (X)
##
## Check if interval X represents the set of a single real.
##
## Example:
##  a = infsup (2, 3);
##  if (not (issingleton (a)))
##    display ("success");
##  endif
##  b = infsup (2);
##  if (issingleton (b))
##    display ("success");
##  endif

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = issingleton (x)

## This check also works for empty intervals (-inf ~= +inf)
result = (interval.inf == interval.sup);
return