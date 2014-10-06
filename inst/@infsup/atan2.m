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

## -- IEEE 1788 interval function:  atan2 (Y, X)
##
## Compute inverse tangent with two arguments (arctangent 2).
##
## See also:
##  atan

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-10-06

function result = atan2 (y, x)

if (isempty (x) || isempty (y) || ...
    (x.inf == 0 && x.sup == 0 && y.inf == 0 && y.sup == 0))
    result = empty ();
    return
endif

if (x.sup <= 0)
    if (y.inf >= 0)
        if (y.sup == 0)
            ## pi
            at2.inf = 0x6487ED5 * pow2 (-25) + 0x442D180 * pow2 (-55);
        elseif (y.sup == inf || x.sup == 0)
            ## pi / 2
            at2.inf = 0x6487ED5 * pow2 (-26) + 0x442D180 * pow2 (-56);
        else
            fesetround (-inf);
            at2.inf = atan2 (y.sup, x.sup);
            fesetround (0.5);
        endif
        if (x.inf == 0)
            ## pi / 2
            at2.sup = 0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56);
        elseif (x.inf == -inf || y.inf == 0)
            ## pi
            at2.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
        else
            fesetround (inf);
            at2.sup = atan2 (y.inf, x.inf);
            fesetround (0.5);
        endif
    elseif (y.sup <= 0)
        if (x.inf == 0)
            ## -pi / 2
            at2.inf = - (0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56));
        elseif (x.inf == -inf)
            ## -pi
            at2.inf = - (0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55));
        else
            fesetround (-inf);
            at2.inf = atan2 (y.sup, x.inf);
            fesetround (0.5);
        endif
        if (y.inf == -inf || x.sup == 0)
            ## -pi / 2
            at2.sup = - (0x6487ED5 * pow2 (-26) + 0x442D180 * pow2 (-56));
        else
            fesetround (inf);
            at2.sup = atan2 (y.inf, x.sup);
            fesetround (0.5);
        endif
    else
        if (x.inf == 0)
            ## -pi / 2
            at2.inf = - (0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56));
        else
            ## -pi
            at2.inf = - (0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55));
        endif
        if (x.inf == 0)
            ## pi / 2
            at2.sup = 0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56);
        else
            ## pi
            at2.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
        endif
    endif
elseif (x.inf >= 0)
    if (y.inf >= 0)
        if (x.sup == 0)
            ## pi / 2
            at2.inf = 0x6487ED5 * pow2 (-26) + 0x442D180 * pow2 (-56);
        elseif (y.inf == 0)
            at2.inf = 0;
        else
            fesetround (-inf);
            at2.inf = atan2 (y.inf, x.sup);
            fesetround (0.5);
        endif
        if (y.sup == 0)
            at2.sup = 0;
        elseif (x.inf == 0)
            ## pi / 2
            at2.sup = 0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56);
        else
            fesetround (inf)
            at2.sup = atan2 (y.sup, x.inf);
            fesetround (0.5);
        endif
    elseif (y.sup <= 0)
        if (x.inf == 0)
            ## -pi / 2
            at2.inf = - (0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56));
        else
            fesetround (-inf);
            at2.inf = atan2 (y.inf, x.inf);
            fesetround (0.5);
        endif
        if (x.sup == 0)
            ## -pi / 2
            at2.sup = - (0x6487ED5 * pow2 (-26) + 0x442D180 * pow2 (-56));
        elseif (y.sup == 0)
            at2.sup = 0;
        else
            fesetround (inf);
            at2.sup = atan2 (y.sup, x.sup);
            fesetround (0.5);
        endif
    else
        if (x.inf == 0)
            ## -pi / 2
            at2.inf = - (0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56));
            ## pi / 2
            at2.sup = 0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56);
        else
            fesetround (-inf);
            at2.inf = atan2 (y.inf, x.inf);
            fesetround (inf);
            at2.sup = atan2 (y.sup, x.inf);
            fesetround (0.5);
        endif
    endif
else
    if (y.inf == 0)
        at2.inf = 0;
        ## pi
        at2.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
    elseif (y.inf > 0)
        fesetround (-inf);
        at2.inf = atan2 (y.inf, x.sup);
        fesetround (inf);
        at2.sup = atan2 (y.inf, x.inf);
        fesetround (0.5);
    elseif (y.sup >= 0)
        ## -pi
        at2.inf = - (0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55));
        ## pi
        at2.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
    else # y.sup < 0
        fesetround (-inf);
        at2.inf = atan2 (y.sup, x.inf);
        fesetround (inf);
        at2.sup = atan2 (y.sup, x.sup);
        fesetround (0.5);
    endif
endif

result = infsup (at2.inf, at2.sup);

endfunction