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
## @deftypefn {Interval Function} {@var{R} =} fma (@var{X}, @var{Y}, @var{Z})
## @cindex IEEE1788 fma
## 
## Fused multiply and add @code{@var{X} * @var{Y} + @var{Z}}.  Multiply each
## number of interval @var{X} with each number of interval @var{Y} and add
## each number of interval @var{Z}.
##
## This function is semantically equivalent to evaluating multiplication and
## addition separately, but in addition guarantees a tight enclosure of the
## result.  The fused multiply and add is much slower.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fma (infsup (1+eps), infsup (7), infsup ("0.1"))
##   @result{} [7.1000000000000014, 7.1000000000000024]
## infsup (1+eps) * infsup (7) + infsup ("0.1")
##   @result{} [7.1000000000000005, 7.1000000000000024]
## @end group
## @end example
## @seealso{plus, mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-03

function result = fma (x, y, z)

assert (nargin == 3);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Convert second parameter into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

## Convert third parameter into interval, if necessary
if (not (isa (z, "infsup")))
    z = infsup (z);
endif


if (isempty (x) || isempty (y) || isempty (z))
    result = infsup ();
    return
endif

if ((x.inf == 0 && x.sup == 0) || ...
    (y.inf == 0 && y.sup == 0))
    result = infsup (z.inf, z.sup);
    return
endif

if (isentire (x) || isentire (y) || isentire (z))
    result = infsup (-inf, inf);
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

function result = fmarounded (x, y, z, direction)

## Unfortunately we do not have access to an IEEE 754 fused multiply-add
## operation with directed rounding in GNU Octave's M-files, so we have
## to do the math in detail ourself...

if (isnan (x) || isnan (y) || isnan (z))
    result = nan ();
    return
endif

if (x == 0 || y == 0)
    if (isfinite (x) && isfinite (y))
        result = z;
    else
        result = nan ();
    endif
    return
endif

if (not (isfinite (x) && isfinite (y) && isfinite (z)))
    fesetround (0.5); # otherwise an overflow of x * y could break the result
    result = x * y + z; # == inf, -inf or NaN
    assert (not (isfinite (result)));
    return
endif

accumulator.e = 0;
accumulator.m = [];
accumulator = accuaddproduct (accumulator, x, y);
accumulator = accuadd (accumulator, z);
result = accu2double (accumulator, direction);

endfunction