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

## -- IEEE 1788 interval function:  cosh (X)
##
## Compute hyperbolic cosine for all elements of interval X.
##
## See also:
##  acosh, sinh, tanh
##

## Author: Oliver Heimlich
## Keywords: accurate interval function
## Created: 2014-10-07

function result = cosh (x)

if (isempty (x))
    result = empty ();
    return
endif

if (x.inf == 0)
    ch.inf = 1;
else
    ch.inf = nextdown (cosh (x.inf));
endif

if (x.sup == 0)
    ch.sup = 1;
else
    ch.sup = nextup (cosh (x.sup));
endif

result = infsup (ch.inf, ch.sup);

endfunction