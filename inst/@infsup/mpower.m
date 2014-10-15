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
## @deftypefn {Interval Function} {@var{Y} =} @var{X} ^ @var{Y}
## 
## Compute the general power function on intervals, which is defined for
## (1) any positive base @var{X}; (2) @code{@var{X} = 0} when @var{Y} is
## positive; (3) negative base @var{X} together with integral exponent @var{Y}.
##
## This definition complies with the common complex valued power function,
## restricted to the domain where results are real.  The complex power function
## is defined by @code{exp (@var{Y} * log (@var{X}))} with initial branch of
## complex logarithm and complex exponential function.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest in
## each of the following cases:  @var{X} in @{0, 1, 2, 10@}, or @var{Y} in
## @{-1, 0.5, 0, 1, 2@}, or @var{X} and @var{Y} integral with
## @code{abs (pow (@var{X}, @var{Y})) in [2^-53, 2^53]}
##
## @example
## @group
## infsup (-5, 6) ^ infsup (2, 3)
##   @result{} [-125, +216]
## @end group
## @end example
## @seealso{pow, pown, pow2, pow10, exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function z = mpower (x, y)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Convert second parameter into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

## Implements Algorithm A.3 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.
if (isempty (x) || isempty (y) || ...
    (x.inf == 0 && x.sup == 0 && y.sup <= 0))
    result = infsup ();
    return
endif

zPlus = pow (x, y); # pow is only defined for x > 0

if (y.sup > 0 && ismember (0, x))
    zZero = infsup (0);
else
    zZero = infsup ();
endif

if (x.inf >= 0)
    ## no negative x
    zMinus = infsup ();
elseif (isfinite (y.inf) && isfinite (y.sup) && ceil (y.inf) > floor (y.sup))
    ## y contains no integer
    zMinus = infsup ();
elseif (isfinite (y.inf) && isfinite (y.sup) && ceil (y.inf) == floor (y.sup))
    ## y contains a single integer
    xMinus = x & infsup (-inf, 0); # speed up computation of pown
    zMinus = pown (xMinus, ceil (y.inf));
else
    ## y contains several integers
    zMinus = multipleintegers (x, y);
endif

z = zMinus | zZero | zPlus;

endfunction

function z = multipleintegers (x, y)
## Value of mpower on NEGATIVE base and multiple integral exponents

x = x & infsup (-inf, 0);
y = ceil (y) & floor (y);
assert (y.inf < y.sup);
assert (not (isempty (x)));
assert (x.inf < 0);

## Implements Table 3.4 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.
if (x.sup <= -1 && y.sup <= 0)
    z = twointegers (x.sup, goe (y), gee (y));
elseif (-1 <= x.inf && 0 <= y.inf)
    z = twointegers (x.inf, loe (y), lee (y));
else
    if ((x.sup <= -1 || (x.inf < -1 && -1 < x.sup)) && ...
        (0 <= y.inf || (y.inf <= -1 && 1 <= y.sup)))
        z = twointegers (x.inf, goe (y), gee (y));
    else
        z = infsup ();
    endif
    if (((x.inf < -1 && -1 < x.sup) || -1 <= x.inf) && ...
        ((y.inf <= -1 && 1 <= y.sup) || y.sup <= 0))
        z = z | twointegers (x.sup, loe (y), lee (y));
    endif
endif
endfunction

function z = twointegers (base, oddexponent, evenexponent)
## Range of mpower on single NEGATIVE base and two integral exponents
##
## twointegers (base, oddexponent, evenexponent) returns the interval
## [-abs(base) ^ oddexponent, abs(base) ^ evenexponent] with correctly
## rounded boundaries.
##
## twointegers (0, oddexponent, evenexponent) returns the limit value of
## [-abs(base) ^ oddexponent, abs(base) ^ evenexponent] for base -> 0.
##
## twointegers (-inf, oddexponent, evenexponent) returns the limit value of
## [-abs(base) ^ oddexponent, abs(base) ^ evenexponent] for base -> -inf.
##
## Note: oddexponent must not necessarily be odd, since it can be an
## overestimation of an actual odd exponent, if its magnitude is > 2^53.

assert (oddexponent ~= 0);
if (isfinite (oddexponent) && isfinite (evenexponent))
    assert (abs (oddexponent - evenexponent) <= 1);
endif
base = abs (base);
if (base == 0)
    if (oddexponent > 0)
        z.inf = 0;
    else # oddexponent < 0
        z.inf = -inf;
    endif
    if (evenexponent > 0)
        z.sup = 0;
    elseif (evenexponent < 0)
        z.sup = inf;
    else # evenexponent == 0
        z.sup = 1;
    endif
elseif (base == inf)
    if (oddexponent > 0)
        z.inf = -inf;
    else # oddexponent < 0
        z.inf = 0;
    endif
    if (evenexponent > 0)
        z.sup = inf;
    elseif (evenexponent < 0)
        z.sup = 0;
    else # evenexponent == 0
        z.sup = 1;
    endif
else # 0 < base < inf
    if (evenexponent == inf)
        z.sup = inf;
    elseif (evenexponent == -inf)
        z.sup = 0
    else
        z.sup = sup (pown (infsup (base), evenexponent));
    endif
    if (oddexponent == evenexponent)
        ## This can happen with big exponents.
        z.inf = -z.sup;
    else
        z.inf = -sup (pown (infsup (base), oddexponent));
    endif
endif
z = infsup (z.inf, z.sup);
endfunction

function e = goe (y)
## GOE Greatest odd exponent in interval y
if (y.sup == inf)
    e = inf;
else
    e = floor (y.sup);
    if (rem (e, 2) == 0)
        fesetround (inf);
        e = e - 1;
        fesetround (0.5);
    endif
    if (e < y.inf)
        ## No odd number in interval
        e = nan ();
    endif
endif
endfunction

function e = gee (y)
## GEE Greatest even exponent in interval y
if (y.sup == inf)
    e = inf;
else
    e = floor (y.sup);
    if (rem (e, 2) ~= 0)
        fesetround (inf);
        e = e - 1;
        fesetround (0.5);
    endif
    if (e < y.inf)
        ## No even number in interval
        e = nan ();
    endif
endif
endfunction

function e = loe (y)
## LOE Least odd exponent in interval y
if (y.inf == -inf)
    e = -inf;
else
    e = ceil (y.inf);
    if (rem (e, 2) == 0)
        fesetround (-inf);
        e = e + 1;
        fesetround (0.5);
    endif
    if (e > y.sup)
        ## No odd number in interval
        e = nan ();
    endif
endif
endfunction

function e = lee (y)
## LOE Least even exponent in interval y
if (y.inf == -inf)
    e = -inf;
else
    e = ceil (y.inf);
    if (rem (e, 2) ~= 0)
        fesetround (-inf);
        e = e + 1;
        fesetround (0.5);
    endif
    if (e > y.sup)
        ## No even number in interval
        e = nan ();
    endif
endif
endfunction
