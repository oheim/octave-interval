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

## -- IEEE 1788 interval function:  sqr (X)
##
## Square all elements of interval X.
##
## See also:
##  sqrt, pow, pown
##
## Example:
##  x = infsup(-2, 1);
##  sqr (x) # == [0, 4]

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-09-30

function result = sqr (x)

if (isempty (x))
    result = empty ();
    return
endif

if (x.inf < 0 && x.sup > 0)
    square.inf = 0;
    square.sup = mag (x);
    fesetround (inf);
    square.sup = square.sup * square.sup; # no sqr function in GNU octave
else
    square.inf = abs (x.inf);
    square.sup = abs (x.sup);
    if (square.inf > square.sup)
        [square.inf, square.sup] = deal (square.sup, square.inf);
    endif
    fesetround (-inf);
    square.inf = square.inf * square.inf;
    fesetround (inf);
    square.sup = square.sup * square.sup;
endif

fesetround (0.5);
result = infsup (square.inf, square.sup);

endfunction