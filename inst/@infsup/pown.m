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

## -- IEE1788 interval function:  pown (X, P)
##
## Compute the monomial x^P for all elements of X.
##
## See also:
##  pow, exp, exp2, exp10

## Author: Oliver Heimlich
## Keywords: interval function
## Created: 2014-10-04

function result = pown (x, p)

if (fix (p) ~= p)
    error (["exponent is not an integer: " num2str (p)]);
endif

if (isempty (x))
    result = empty ();
    return
endif

switch p
    case -1
        result = recip (x);
        return
    case 0
        result = infsup (1);
        return
    case 1
        result = x;
        return
    case 2
        result = sqr (x)
        return
endswitch

if (rem (p, 2) == 0)
    if (x.sup <= 0)
        base.inf = -x.sup;
        base.sup = -x.inf;
    elseif (x.inf >= 0)
        base.inf = x.inf;
        base.sup = x.sup;
    else
        base.inf = 0;
        base.sup = max (-x.inf, x.sup);
    endif
else
    base.inf = x.inf;
    base.sup = x.sup;
endif

r.inf = nextdown (realpow (base.inf, p));
r.sup = nextup (realpow (base.sup, p));

## Integral powers of integrals are intergrals.
if (fix (base.inf) == base.inf)
    r.inf = ceil (r.inf);
endif
if (fix (base.sup) == base.sup)
    r.sup = floor (r.sup);
endif

result = infsup (r.inf, r.sup);

endfunction