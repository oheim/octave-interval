## Copyright 2014-2016 Oliver Heimlich
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
## @defop Method {@@infsup} power (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} .^ @var{Y}}
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
## Warning: This function is not defined by IEEE Std 1788-2015.  However, it
## has been published as “pow2” in O. Heimlich, M. Nehmeier, J. Wolff von
## Gudenberg. 2013. “Variants of the general interval power function.”
## Soft Computing. Volume 17, Issue 8, pp 1357–1366.
## Springer Berlin Heidelberg. DOI 10.1007/s00500-013-1008-8.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## infsup (-5, 6) .^ infsup (2, 3)
##   @result{} ans = [-125, +216]
## @end group
## @end example
## @seealso{@@infsup/pow, @@infsup/pown, @@infsup/pow2, @@infsup/pow10, @@infsup/exp}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function z = power (x, y)

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
    z = power (x, y);
    return
endif

## Short circuit integral powers, e.g., x.^2
if (not (any (any (y.inf == 0))) && ... # can't use pown, because 0^0 = [Empty]
    all (all (y.inf == y.sup & isfinite (y.inf) & fix (y.inf) == y.inf)))
    z = pown (x, y.inf);
    return
endif

## Resize, if scalar × matrix or vector × matrix or scalar × vector
if (rows (x.inf) ~= rows (y.inf))
    x.inf = ones (rows (y.inf), columns (x.inf)) .* x.inf;
    x.sup = ones (rows (y.inf), columns (x.inf)) .* x.sup;
    y.inf = ones (rows (x.inf), columns (y.inf)) .* y.inf;
    y.sup = ones (rows (x.inf), columns (y.inf)) .* y.sup;
endif
if (columns (x.inf) ~= columns (y.inf))
    x.inf = ones (rows (x.inf), columns (y.inf)) .* x.inf;
    x.sup = ones (rows (x.inf), columns (y.inf)) .* x.sup;
    y.inf = ones (rows (y.inf), columns (x.inf)) .* y.inf;
    y.sup = ones (rows (y.inf), columns (x.inf)) .* y.sup;
endif

idx.type = "()";

emptyresult = x.inf == inf | y.inf == inf | ...
              (x.inf == 0 & x.sup == 0 & y.sup <= 0);

zPlus = pow (x, y); # pow is only defined for x > 0
zContainsZero = y.inf > 0 & x.inf <= 0 & x.sup >= 0;
zMinus = infsup ();
zMinus.inf = zMinus.inf (ones (size (x.inf)));
zMinus.sup = zMinus.sup (ones (size (x.sup)));

xMinusWithIntegerY = not (emptyresult) & x.inf < 0 & ...
                     not (isfinite (y.inf) & isfinite (y.sup) & ...
                          ceil (y.inf) > floor (y.sup));

if (any (any (xMinusWithIntegerY)))
    ySingleInteger = isfinite (y.inf) & isfinite (y.sup) & ...
                     ceil (y.inf) == floor (y.sup);
    
    ## y contains a single integer
    idx.subs = {xMinusWithIntegerY & ySingleInteger};
    if (any (any (idx.subs {1})))
        xMinus = intersect (subsref (x, idx), ... # intersect to 
                            infsup (-inf, 0));    # speed up computation
        zMinus = subsasgn (zMinus, idx, ...
                           pown (xMinus, ceil (subsref (y.inf, idx))));
    endif
    
    ## y contains several integers
    idx.subs = {xMinusWithIntegerY & not(ySingleInteger)};
    if (any (any (idx.subs {1})))
        zMinus = subsasgn (zMinus, idx, ...
                           multipleintegers (subsref (x, idx), ...
                                             subsref (y, idx)));
    endif
endif

z = union (zMinus, zPlus);
idx.subs = {zContainsZero};
z = subsasgn (z, idx, union (subsref (z, idx), 0));
z.inf(emptyresult) = inf;
z.sup(emptyresult) = -inf;

endfunction

function z = multipleintegers (x, y)
## Value of power on NEGATIVE base and multiple integral exponents

## Intersect to simplify computation
x = intersect (x, infsup (-inf, 0));
y = intersect (ceil (y), floor (y));

assert (all (all (y.inf < y.sup & x.inf < 0)));

## Implements Table 3.4 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.
z = infsup ();
z.inf = z.inf(ones (size (x.inf)));
z.sup = z.sup(ones (size (x.sup)));
idx.type = "()";

idx.subs = {(x.sup <= -1 & y.sup <= 0)};
if (any (any (idx.subs {1})))
    xsup_idx = subsref (x.sup, idx);
    y_idx = subsref (y, idx);
    z = subsasgn (z, idx, twointegers (xsup_idx, goe (y_idx), gee (y_idx)));
endif
idx.subs = {(-1 <= x.inf & 0 <= y.inf)};
if (any (any (idx.subs {1})))
    xinf_idx = subsref (x.inf, idx);
    y_idx = subsref (y, idx);
    z = subsasgn (z, idx, twointegers (xinf_idx, loe (y_idx), lee (y_idx)));
endif
idx.subs = {((x.sup <= -1 | (x.inf < -1 & -1 < x.sup)) & ...
             ((0 <= y.inf & not (-1 <= x.inf)) | (y.inf <= -1 & 1 <= y.sup)))};
if (any (any (idx.subs {1})))
    xinf_idx = subsref (x.inf, idx);
    y_idx = subsref (y, idx);
    z = subsasgn (z, idx, twointegers (xinf_idx, goe (y_idx), gee (y_idx)));
endif
idx.subs = {(((x.inf < -1 & -1 < x.sup) | -1 <= x.inf) & ...
             ((y.inf <= -1 & 1 <= y.sup) | (y.sup <= 0 & not (x.sup <= -1))))};
if (any (any (idx.subs {1})))
    xsup_idx = subsref (x.sup, idx);
    y_idx = subsref (y, idx);
    z = subsasgn (z, idx, union (subsref (z, idx), ...
                          twointegers (xsup_idx, loe (y_idx), lee (y_idx))));
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

assert (all (all (oddexponent ~= 0)));
assert (all (all (not (isfinite (oddexponent) & isfinite (evenexponent)) | ...
                  abs (oddexponent - evenexponent) <= 1)));
base = abs (base);
z.inf = z.sup = zeros (size (base));
z.inf(base == 0 & oddexponent < 0) = -inf;
z.sup(base == 0 & evenexponent < 0) = inf;
z.sup(base == 0 & evenexponent == 0) = 1;

z.inf(base == inf & oddexponent > 0) = -inf;
z.sup(base == inf & evenexponent > 0) = inf;
z.sup(base == inf & evenexponent == 0) = 1;

z.sup(base == 1) = 1;
z.sup(0 < base & base < 1 & evenexponent <= 0) = inf;
z.sup(1 < base & base < inf & evenexponent >= 0) = inf;
select = 0 < base & base < inf & isfinite (evenexponent);
if (any (any (select)))
    z.sup(select) = sup (pown (infsup (base(select)), evenexponent(select)));
endif

z.inf(base == 1) = -1;
z.inf(0 < base & base < 1 & oddexponent <= 0) = -inf;
z.inf(1 < base & base < inf & oddexponent >= 0) = -inf;

bigexponent = oddexponent == evenexponent;
select = 0 < base & base < inf & bigexponent;
z.inf(select) = -z.sup(select);

select = 0 < base & base < inf & isfinite (oddexponent) & not (bigexponent);
if (any (any (select)))
    z.inf(select) = -sup (pown (infsup (base(select)), oddexponent(select)));
endif

z = infsup (z.inf, z.sup);
endfunction

function e = goe (y)
## GOE Greatest odd exponent in interval y
e = floor (y.sup);
even = rem (e, 2) == 0;
e(even) = mpfr_function_d ('minus', +inf, e(even), 1);
e(e < y.inf) = nan (); # no odd number in interval
endfunction

function e = gee (y)
## GEE Greatest even exponent in interval y
e = floor (y.sup);
odd = rem (e, 2) ~= 0;
e(odd) = mpfr_function_d ('minus', +inf, e(odd), 1);
e(e < y.inf) = nan (); # no even number in interval
endfunction

function e = loe (y)
## LOE Least odd exponent in interval y
e = ceil (y.inf);
even = rem (e, 2) == 0;
e(even) = mpfr_function_d ('plus', -inf, e(even), 1);
e(e > y.sup) = nan (); # no odd number in interval
endfunction

function e = lee (y)
## LOE Least even exponent in interval y
e = ceil (y.inf);
odd = rem (e, 2) ~= 0;
e(odd) = mpfr_function_d ('plus', -inf, e(odd), 1);
e(e > y.sup) = nan (); # no odd number in interval
endfunction

%!test "from the documentation string";
%! assert (infsup (-5, 6) .^ infsup (2, 3) == infsup (-125, 216));
%!assert (infsup (-10, 0) .^ infsup (0, 1:8) == infsup ([-1e1, -1e1, -1e3, -1e3, -1e5, -1e5, -1e7, -1e7], [1e0, 1e2, 1e2, 1e4, 1e4, 1e6, 1e6, 1e8]));
