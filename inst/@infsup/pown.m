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

if (p == 1) # x^1
    result = x;
    return
endif

if (isempty (x))
    result = empty ();
    return
endif

if (p == 0) # x^0
    result = infsup (1);
    return
endif

## Special case: x = [0]. The pow function used below would be undefined.
if (x.inf == 0 && x.sup == 0)
    if (p >= 0)
        result = infsup (0);
        return
    else
        ## not in domain
        result = empty ();
    endif
endif

if (x.inf >= 0)
    result = pow (x, infsup (p));
else
    if (rem (p, 2) == 0) # p even
        if (x.sup <= 0)
            result = pow (neg (x), infsup (p));
        else
            result = pow (infsup (0, max (-x.inf, x.sup)), infsup (p));
        endif
    else # p odd
        if (x.sup <= 0)
            result = neg (pow (neg (x), infsup (p)));
        else
            result = convexhull (...
                        pow (x, infsup (p)), ...
                        neg (pow (neg (x), infsup (p))));
        endif
    endif
endif

endfunction