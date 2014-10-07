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

## -- IEEE 1788 interval function:  acosh (X)
##
## Compute inverse hyperbolic cosine for all elements of interval X.
##
## See also:
##  cosh, acosh, atanh
##

## Author: Oliver Heimlich
## Keywords: tightest interval function
## Created: 2014-10-07

function result = acosh (x)

if (isempty (x) || x.sup < 1)
    result = empty ();
    return
endif

if (x.inf == 1)
    ach.inf = 0;
else
    fesetround (-inf);
    ach.inf = acosh (x.inf);
endif

if (x.sup == 1)
    ach.sup = 0;
else
    fesetround (inf);
    ach.sup = acosh (x.sup);
endif
fesetround (0.5);

result = infsup (ach.inf, ach.sup);

endfunction