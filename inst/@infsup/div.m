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

## -- IEEE 1788 interval function:  div (X, Y)
##
## Divide all elements of interval X by all elements of interval Y.
##
## See also:
##  mul
##
## Example:
##  x = infsup (2, 3);
##  y = infsup (1, 1.5);
##  z = div (x, y); # == [1.33... , 3]

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-09-30

function result = div (x, y)

assert (nargin == 2);

if (isempty (x) || isempty (y))
    result = empty ();
    return
endif

if ((y.inf < 0 && y.sup > 0) || ...
    (x.inf <= 0 && x.sup >= 0 && y.inf == 0 && y.sup == 0))
    result = entire ();
    return
endif

if ((x.sup < 0 || x.inf > 0) && y.inf == 0 && y.sup == 0)
    result = empty ();
endif

if (x.sup <= 0)
    if (y.sup < 0)
        fesetround (-inf);
        quot.inf = x.sup / y.inf;
        fesetround (inf);
        quot.sup = x.inf / y.sup;
    elseif (y.inf > 0)
        fesetround (-inf);
        quot.inf = x.inf / y.inf;
        fesetround (inf);
        quot.sup = x.sup / y.sup;
    elseif (y.sup == 0)
        fesetround (-inf);
        quot.inf = x.sup / y.inf;
        quot.sup = 1;
    else # y.inf == 0
        quot.inf = -1;
        fesetround (inf);
        quot.sup = x.sup / y.sup;
    endif
elseif (x.inf >= 0)
    if (y.sup < 0)
        fesetround (-inf);
        quot.inf = x.sup / y.sup;
        fesetround (inf);
        quot.sup = x.inf / y.inf;
    elseif (y.inf > 0)
        fesetround (-inf);
        quot.inf = x.inf / y.sup;
        fesetround (inf);
        quot.sup = x.sup / y.inf;
    elseif (y.sup == 0)
        quot.inf = -1;
        fesetround (inf);
        quot.sup = x.inf / y.inf;
    else # y.inf == 0
        fesetround (-inf);
        quot.inf = x.inf / y.sup;
        quot.sup = 1;
    endif
else
    if (y.sup < 0)
        fesetround (-inf);
        quot.inf = x.sup / y.sup;
        fesetround (inf);
        quot.sup = x.inf / y.sup;
    else # y.inf > 0
        fesetround (-inf);
        quot.inf = x.inf / y.inf;
        fesetround (inf);
        quot.sup = x.sup / y.inf;
    endif
endif

fesetround (0.5);

result = infsup (quot.inf, quot.sup);

endfunction