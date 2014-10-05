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

## -- IEEE 1788 interval function:  sub (X, Y)
##
## Subtract each element of interval Y from each element of interval X.
##
## See also:
##  add
##
## Example:
##  x = infsup (2, 3);
##  y = infsup (1, 1.5);
##  z = sub (x, y); # == [0.5, 2]

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-09-30

function result = sub (x, y)

assert (nargin == 2);

if (isempty (x) || isempty (y))
    result = empty ();
    return
endif

fesetround (-inf);
dif.inf = x.inf - y.inf;
fesetround (inf);
dif.sup = x.sup - y.sup;
fesetround (0.5);

result = infsup (dif.inf, dif.sup);

endfunction