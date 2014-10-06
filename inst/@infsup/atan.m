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

## -- IEEE 1788 interval function:  atan (X)
##
## Compute inverse tangent (arctangent) for all elements of interval X.
##
## See also:
##  asin, acos
##

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-10-06

function result = atan (x)

if (isempty (x))
    result = empty ();
    return
endif

if (x.sup == inf)
    ## pi / 2
    at.sup = 0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56); 
else
    fesetround (inf);
    at.sup = atan (x.sup);
    fesetround (0.5);
endif

if (x.inf == -inf)
    ## - pi / 2
    at.inf = - (0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56));
else
    fesetround (-inf);
    at.inf = atan (x.inf);
    fesetround (0.5);
endif

result = infsup (at.inf, at.sup);

endfunction