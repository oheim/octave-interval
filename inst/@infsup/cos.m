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

## -- IEEE 1788 interval function:  cos (X)
##
## Compute cosine for all elements of interval X.
##
## See also:
##  sin, tan
##

## Author: Oliver Heimlich
## Keywords: accurate interval function
## Created: 2014-10-05

function result = cos (x)

if (isempty (x))
    result = empty ();
    return
endif

if (not (isfinite (x.inf) && isfinite (x.sup)))
    result = infsup (-1, 1);
    return
endif

## Check, if wid (x) is certainly greater than 2*pi.
fesetround (-inf);
width = x.sup - x.inf;
fesetround (0.5);
twopi.sup = 0x6487ED5 * pow2 (-24) + 0x442D190 * pow2 (-54);
if (width >= twopi.sup)
    result = infsup (-1, 1);
    return
endif

if (x.inf == 0 && 0 == x.sup)
    ## cos (0) == 1
    result = infsup (1);
    return
endif

## We use sign (-sin) to know the gradient at the boundaries.
c.inf = cos (x.inf);
c.sup = cos (x.sup);
s.inf = sign (-sin (x.inf));
s.sup = sign (-sin (x.sup));
## In case of sign (-sin) == 0, we conservatively use sign (-sin) of nextout.
if (s.inf == 0)
    s.inf = (-1) * sign (c.inf);
endif
if (s.sup == 0)
    s.sup = sign (c.sup);
endif

if (s.inf == s.sup)
    if (width > 4)
        ## Just to be sure...
        result = infsup (-1, 1);
        return
    endif
    result = intersection (infsup (-1, 1), ...
                  nextout (infsup (min (c.inf, c.sup), ...
                                   max (c.inf, c.sup))));
elseif (s.inf == -1 && s.sup == 1)
    result = infsup (-1, min (1, nextup (max (c.inf, c.sup))));
elseif (s.inf == 1 && s.sup == -1)
    result = infsup (max (-1, nextdown (min (c.inf, c.sup))), 1);
endif

endfunction