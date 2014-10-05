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

## -- IEEE 1788 numeric function:  mag (X)
##
## Get the magnitude of elements in interval X, that is the maximum of absolute
## values for each element.
##
## See also:
##  mig
##
## Example:
##  x = infsup(-3, 2);
##  mag (x) # == 3

## Author: Oliver Heimlich
## Keywords: interval numeric function
## Created: 2014-09-30

function result = mag (x)

if (isempty (x))
    result = nan ();
    return
endif

result = max (abs (x.inf), abs (x.sup));

endfunction