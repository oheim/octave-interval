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
## @deftypefn {Interval Function} {@var{Y} =} sin (@var{X})
## @cindex IEEE1788 sin
## 
## Compute the sine for each number in interval @var{X} in radians.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## sin (infsup (1))
##   @result{} [.8414709848078963, .8414709848078967]
## @end group
## @end example
## @seealso{asin, sinh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-05

function result = sin (x)

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

## We use sign (cos) to know the gradient at the boundaries.
s.inf = sin (x.inf);
s.sup = sin (x.sup);
c.inf = sign (cos (x.inf));
c.sup = sign (cos (x.sup));
## In case of sign (cos) == 0, we conservatively use sign (cos) of nextout.
if (c.inf == 0)
    c.inf = sign (s.inf);
endif
if (c.sup == 0)
    c.sup = (-1) * sign (c.sup);
endif

if (c.inf == c.sup)
    if (width > 4)
        ## Just to be sure...
        result = infsup (-1, 1);
        return
    endif
    result = infsup (-1, 1) & ...
                  nextout (infsup (min (s.inf, s.sup), ...
                                   max (s.inf, s.sup)));
    ## sin (0) == 0
    if ((x.inf == 0 && min (s.inf, s.sup) == s.inf) || ...
        (x.sup == 0 && min (s.inf, s.sup) == s.sup))
        result = infsup (0, 1) & result;
    endif
    if ((x.inf == 0 && max (s.inf, s.sup) == s.inf) || ...
        (x.sup == 0 && max (s.inf, s.sup) == s.sup))
        result = infsup (-1, 0) & result;
    endif
elseif (c.inf == -1 && c.sup == 1)
    result = infsup (-1, min (1, nextup (max (s.inf, s.sup))));
    ## sin (0) == 0
    if ((x.inf == 0 && max (s.inf, s.sup) == s.inf) || ...
        (x.sup == 0 && max (s.inf, s.sup) == s.sup))
        result = infsup (-1, 0) & result;
    endif
elseif (c.inf == 1 && c.sup == -1)
    result = infsup (max (-1, nextdown (min (s.inf, s.sup))), 1);
    ## sin (0) == 0
    if ((x.inf == 0 && min (s.inf, s.sup) == s.inf) || ...
        (x.sup == 0 && min (s.inf, s.sup) == s.sup))
        result = infsup (0, 1) & result;
    endif
endif

endfunction