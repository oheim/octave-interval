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

## -- IEEE 1788 interval function:  fma (X, Y, Z)
##
## Fused multiply and add (X * Y) + Z.
## Multiply each element of interval X with each element of interval Y and add
## each element of Z.
##
## This function is semantically equivalent to add (mul (X, Y), Z)
## but in addition guarantees a tight enclosure of the result.
##
## See also:
##  mul, add
##
## Example:
##  x = infsup (1+eps);
##  fma (x, x, x)
##   |=> [2.0000000000000008, 2.0000000000000009]
##  x * x + x
##   |=> [2.0000000000000004, 2.0000000000000009]

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-10-03

function result = fma (x, y, z)

assert (nargin == 3);

if (isempty (x) || isempty (y) || isempty (z))
    result = empty ();
    return
endif

if ((x.inf == 0 && x.sup == 0) || ...
    (y.inf == 0 && y.sup == 0))
    result = z;
    return
endif

if (isentire (x) || isentire (y) || isentire (z))
    result = entire ();
    return
endif

if (y.sup <= 0)
    if (x.sup <= 0)
        l = fmarounded (x.sup, y.sup, z.inf, -inf);
        u = fmarounded (x.inf, y.inf, z.sup, inf);
    elseif (x.inf >= 0)
        l = fmarounded (x.sup, y.inf, z.inf, -inf);
        u = fmarounded (x.inf, y.sup, z.sup, inf);
    else
        l = fmarounded (x.sup, y.inf, z.inf, -inf);
        u = fmarounded (x.inf, y.inf, z.sup, inf);
    endif
elseif (y.inf >= 0)
    if (x.sup <= 0)
        l = fmarounded (x.inf, y.sup, z.inf, -inf);
        u = fmarounded (x.sup, y.inf, z.sup, inf);
    elseif (x.inf >= 0)
        l = fmarounded (x.inf, y.inf, z.inf, -inf);
        u = fmarounded (x.sup, y.sup, z.sup, inf);
    else
        l = fmarounded (x.inf, y.sup, z.inf, -inf);
        u = fmarounded (x.sup, y.sup, z.sup, inf);
    endif
else
    if (x.sup <= 0)
        l = fmarounded (x.inf, y.sup, z.inf, -inf);
        u = fmarounded (x.inf, y.inf, z.sup, inf);
    elseif (x.inf >= 0)
        l = fmarounded (x.sup, y.inf, z.inf, -inf);
        u = fmarounded (x.sup, y.sup, z.sup, inf);
    else
        l = min (...
            fmarounded (x.inf, y.sup, z.inf, -inf), ...
            fmarounded (x.sup, y.inf, z.inf, -inf));
        u = max (...
            fmarounded (x.inf, y.inf, z.sup, inf), ...
            fmarounded (x.sup, y.sup, z.sup, inf));
    endif
endif

result = infsup (l, u);

endfunction