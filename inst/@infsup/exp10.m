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
## @deftypefn {Interval Function} {@var{Y} =} pow10 (@var{X})
## @cindex IEEE1788 exp10
## 
## Compute @code{10^x} for all numbers in @var{X}.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest when
## interval boundaries are integral.
##
## @example
## @group
## pow10 (infsup (5))
##   @result{} [100000]
## @end group
## @end example
## @seealso{log10, pow, pow2, exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pow10 (x)

if (isempty (x))
    result = empty ();
    return
endif

if (x.inf <= -324)
    p.inf = 0;
elseif (x.inf > 308)
    p.inf = realmax ();
elseif (fix (x.inf) == x.inf)
    ## x.inf is an integer, we can compute a tight enclosure
    if (abs (x.inf) <= 22) # powers of 10 are binary64 numbers up to 10^22
        p.inf = realpow (10, abs (x.inf)); # this is exact
        if (x.inf < 0)
            fesetround (-inf);
            p.inf = 1 / p.inf;
            fesetround (0.5);
        endif
    else
        ## infsup constructor can do the decimal arithmetic
        p.inf = ["1e" num2str(x.inf)];
    endif
else
    ## No directed rounding available
    p.inf = max (0, nextdown (realpow (10, x.inf)));
endif

if (x.sup <= -324)
    p.sup = pow2 (-1074);
elseif (x.sup > 308)
    p.sup = inf;
elseif (fix (x.sup) == x.sup)
    ## x.sup is an integer, we can compute a tight enclosure
    if (abs (x.sup) <= 22) # powers of 10 are binary64 numbers up to 10^22
        p.sup = realpow (10, abs (x.sup)); # this is exact
        if (x.sup < 0)
            fesetround (inf);
            p.sup = 1 / p.sup;
            fesetround (0.5);
        endif
    else
        ## infsup constructor can do the decimal arithmetic
        p.sup = ["1e" num2str(x.sup)];
    endif
else
    ## No directed rounding available
    p.sup = nextup (realpow (10, x.sup));
endif

result = infsup (p.inf, p.sup);

endfunction