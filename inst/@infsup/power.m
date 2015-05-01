## Copyright 2014-2015 Oliver Heimlich
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
## @documentencoding UTF-8
## @deftypefn {Function File} {} {} @var{X} .^ @var{Y}
## 
## Compute the general power function on intervals, which is defined for
## (1) any positive base @var{X}; (2) @code{@var{X} = 0} when @var{Y} is
## positive; (3) negative base @var{X} together with integral exponent @var{Y}.
##
## This definition complies with the common complex valued power function,
## restricted to the domain where results are real, plus limit values where
## @var{X} is zero.  The complex power function is defined by
## @code{exp (@var{Y} * log (@var{X}))} with initial branch of complex
## logarithm and complex exponential function.
##
## Warning: This function is not defined by IEEE 1788.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## infsup (-5, 6) .^ infsup (2, 3)
##   @result{} [-125, +216]
## @end group
## @end example
## @seealso{@@infsup/pow, @@infsup/pown, @@infsup/pow2, @@infsup/pow10, @@infsup/exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function result = power (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
elseif (isa (y, "infsupdec"))
    ## Workaround for bug #42735
    result = power (x, y);
    return
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (y.inf))
    x.inf = ones (size (y.inf)) .* x.inf;
    x.sup = ones (size (y.inf)) .* x.sup;
    y.inf = ones (size (x.inf)) .* y.inf;
    y.sup = ones (size (x.inf)) .* y.sup;
endif

l = u = zeros (size (x.inf));

zPlus = pow (x, y); # pow is only defined for x > 0

for i = 1 : numel (x.inf)
    ## Implements Algorithm A.3 in
    ## Heimlich, Oliver. 2011. “The General Interval Power Function.”
    ## Diplomarbeit, Institute for Computer Science, University of Würzburg.
    ## http://exp.ln0.de/heimlich-power-2011.htm.
    if (x.inf (i) == inf || y.inf (i) == inf || ...
        (x.inf (i) == 0 && x.sup (i) == 0 && y.sup (i) <= 0))
        l (i) = inf;
        u (i) = -inf;
        continue
    endif
    
    if (y.sup (i) > 0 && ismember (0, infsup (x.inf (i), x.sup (i))))
        zZero = infsup (0);
    else
        zZero = infsup ();
    endif
    
    if (x.inf (i) >= 0)
        ## no negative x
        zMinus = infsup ();
    elseif (isfinite (y.inf (i)) && isfinite (y.sup (i)) && ceil (y.inf (i)) > floor (y.sup (i)))
        ## y contains no integer
        zMinus = infsup ();
    elseif (isfinite (y.inf (i)) && isfinite (y.sup (i)) && ceil (y.inf (i)) == floor (y.sup (i)))
        ## y contains a single integer
        xMinus = intersect (...
                     infsup (x.inf (i), x.sup (i)), ...
                     infsup (-inf, 0)); # speed up computation of pown
        zMinus = pown (xMinus, ceil (y.inf (i)));
    else
        ## y contains several integers
        zMinus = multipleintegers (infsup (x.inf (i), x.sup (i)), infsup (y.inf (i), y.sup (i)));
    endif
    
    z = union (union (zMinus, zZero), infsup (zPlus.inf (i), zPlus.sup (i)));
    l (i) = z.inf;
    u (i) = z.sup;
endfor

result = infsup (l, u);

endfunction

function z = multipleintegers (x, y)
## Value of power on NEGATIVE base and multiple integral exponents

x = intersect (x, infsup (-inf, 0));
y = intersect (ceil (y), floor (y));
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
        z = union (z, twointegers (x.sup, loe (y), lee (y)));
    endif
endif
endfunction

function z = twointegers (base, oddexponent, evenexponent)
## Range of power on single NEGATIVE base and two integral exponents
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
    if (not (isfinite (evenexponent)))
        if (base == 1)
            z.sup = 1;
        elseif ((base < 1 && evenexponent > 0) || ...
                (base > 1 && evenexponent < 0))
            z.sup = 0;
        else
            z.sup = inf;
        endif
    else
        z.sup = sup (pown (infsup (base), evenexponent));
    endif
    if (oddexponent == evenexponent)
        ## This can happen with big exponents.
        z.inf = -z.sup;
    elseif (not (isfinite (oddexponent)))
        if (base == 1)
            z.inf = -1;
        elseif ((base < 1 && oddexponent > 0) || ...
                (base > 1 && oddexponent < 0))
            z.inf = 0;
        else
            z.inf = -inf;
        endif
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
        e = mpfr_function_d ('minus', +inf, e, 1);
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
        e = mpfr_function_d ('minus', +inf, e, 1);
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
        e = mpfr_function_d ('plus', -inf, e, 1);
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
        e = mpfr_function_d ('plus', -inf, e, 1);
    endif
    if (e > y.sup)
        ## No even number in interval
        e = nan ();
    endif
endif
endfunction

%!test "from the documentation string";
%! assert (infsup (-5, 6) .^ infsup (2, 3) == infsup (-125, 216));
