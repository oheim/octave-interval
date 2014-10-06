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

## -- IEEE 1788 interval function:  tan (X)
##
## Compute tangent for all elements of interval X.
##
## See also:
##  sin, cos
##

## Author: Oliver Heimlich
## Keywords: accurate interval function
## Created: 2014-10-06

function result = tan (x)

if (isempty (x))
    result = empty ();
    return
endif

if (not (isfinite (x.inf) && isfinite (x.sup)))
    result = entire ();
    return
endif

## Check, if wid (x) is certainly greater than pi.
fesetround (-inf);
width = x.sup - x.inf;
fesetround (0.5);
pi.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
if (width >= pi.sup)
    result = entire ();
    return
endif

t.inf = tan (x.inf);
t.sup = tan (x.sup);

if (t.inf > t.sup || ...
    (width > 2 && (
        sign (t.inf) == sign (t.sup) || ... # could only happen within max
                                            # width of pi / 2
        max (abs (t.inf), abs (t.sup)) < 1))) # could only happen within max
                                              # width of pi / 2
    result = entire ();
    return
else
    ## Now we can be sure that there is no singuarity between x.inf and x.sup
endif

if (x.inf ~= 0)
    t.inf = nextdown (t.inf);
else
    ## tan (0) == 0
endif

if (x.sup ~= 0)
    t.sup = nextup (t.sup);
else
    ## tan (0) == 0
endif

result = infsup (t.inf, t.sup);

endfunction