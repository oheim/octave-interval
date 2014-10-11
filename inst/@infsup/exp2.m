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

## -*- texinfo -*-
## @deftypefn {Interval Function} {@var{Y} =} pow2 (@var{X})
## @cindex IEEE1788 exp2
## 
## Compute @code{2^x} for all numbers in @var{X}.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest when
## interval boundaries are integral.
##
## @example
## @group
## pow2 (infsup (5))
##   @result{} [32]
## @end group
## @end example
## @seealso{log2, pow, pow10, exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = pow2 (x)

if (isempty (x))
    result = empty ();
    return
endif

if (x.inf < -1074)
    p.inf = 0;
elseif (x.inf >= 1024)
    p.inf = realmax();
elseif (fix (x.inf) == x.inf)
    ## x.inf is an integer
    ## This operation is exact
    p.inf = pow2 (x.inf);
else
    ## No directed rounding available
    p.inf = max (0, nextdown (pow2 (x.inf)));
endif

if (x.sup <= -1074)
    p.sup = pow2 (-1074);
elseif (x.sup >= 1024)
    p.sup = inf;
elseif (fix (x.sup) == x.sup)
    ## x.sup is an integer
    ## This operation is exact
    p.sup = pow2 (x.sup);
else
    ## No directed rounding available
    p.sup = nextup (pow2 (x.sup));
endif

result = infsup (p.inf, p.sup);

endfunction