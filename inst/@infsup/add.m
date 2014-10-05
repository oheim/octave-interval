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

## -- IEEE 1788 interval function:  add (X, Y)
##
## Add all numbers of interval X to all numbers of Y.
##
## See also:
##  sub
##
## Example:
##  x = infsup (2, 3);
##  y = infsup (1, 2);
##  z = add (x, y); # == [3 , 5]

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-09-30

function result = add (x, y)

assert (nargin == 2);

if (isempty (x) || isempty (y))
    result = empty ();
    return
endif

fesetround (-inf);
sum.inf = x.inf + y.inf;
fesetround (inf);
sum.sup = x.sup + y.sup;
fesetround (0.5);

result = infsup (sum.inf, sum.sup);

endfunction