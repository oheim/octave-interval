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
## @deftypefn {Interval Function} {@var{Y} =} tan (@var{X})
## @cindex IEEE1788 tan
## 
## Compute the tangent for each number in interval @var{X} in radians.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## tan (infsup (1))
##   @result{} [1.557407724654902, 1.5574077246549026]
## @end group
## @end example
## @seealso{atan, tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = tan (x)

if (isempty (x))
    result = infsup ();
    return
endif

if (not (isfinite (x.inf) && isfinite (x.sup)))
    result = infsup (-inf, inf);
    return
endif

## Check, if wid (x) is certainly greater than pi.
fesetround (-inf);
width = x.sup - x.inf;
fesetround (0.5);
pi.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
if (width >= pi.sup)
    result = infsup (-inf, inf);
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
    result = infsup (-inf, inf);
    return
else
    ## Now we can be sure that there is no singularity between x.inf and x.sup
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