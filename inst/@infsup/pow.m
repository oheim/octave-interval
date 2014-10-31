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
## @deftypefn {Interval Function} {} pow (@var{X}, @var{Y})
## @cindex IEEE1788 pow
## 
## Compute the simple power function on intervals defined by 
## @code{exp (@var{Y} * log (@var{X}))}.
##
## The function is only defined where @var{X} is positive, cf. log function.
## A general power function is implemented by @code{power}.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest in
## each of the following cases:  @var{X} in @{0, 1, 2, 10@}, or @var{Y} in
## @{-1, 0.5, 0, 1, 2@}, or @var{X} and @var{Y} integral with
## @code{abs (pow (@var{X}, @var{Y})) in [2^-53, 2^53]}
##
## @example
## @group
## pow (infsup (5, 6), infsup (2, 3))
##   @result{} [25, 216]
## @end group
## @end example
## @seealso{pown, pow2, pow10, exp, power}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pow (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (y.inf))
    x.inf = ones (size (y.inf)) .* x.inf;
    x.sup = ones (size (y.inf)) .* x.sup;
    y.inf = ones (size (x.inf)) .* y.inf;
    y.sup = ones (size (x.inf)) .* y.sup;
endif

l = u = nan (size (x.inf));

for i = 1 : numel (x.inf)
    if (x.inf (i) == inf || y.inf (i) == inf || x.sup (i) <= 0)
        l (i) = inf;
        u (i) = -inf;
        continue
    endif
    
    ## Simple case with no limit values, see Table 3.3 in
    ## Heimlich, Oliver. 2011. “The General Interval Power Function.”
    ## Diplomarbeit, Institute for Computer Science, University of Würzburg.
    ## http://exp.ln0.de/heimlich-power-2011.htm.
    if (0 <= y.inf (i))
        if (x.sup (i) <= 1)
            if (x.inf (i) > 0)
                l (i) = powrounded (x.inf (i), y.sup (i), -inf);
            endif
            u (i) = powrounded (x.sup (i), y.inf (i), inf);
        elseif (x.inf (i) < 1 && 1 < x.sup (i))
            if (x.inf > 0)
                l (i) = powrounded (x.inf (i), y.sup (i), -inf);
            endif
            u (i) = powrounded (x.sup (i), y.sup (i), inf);
        else # 1 <= x.inf (i)
            l (i) = powrounded (x.inf (i), y.inf (i), -inf);
            u (i) = powrounded (x.sup (i), y.sup (i), inf);
        endif
    elseif (y.inf (i) < 0 && 0 < y.sup (i))
        if (x.sup (i) <= 1)
            if (x.inf (i) > 0)
                l (i) = powrounded (x.inf (i), y.sup (i), -inf);
                u (i) = powrounded (x.inf (i), y.inf (i), inf);
            endif
        elseif (x.inf (i) < 1 && 1 < x.sup (i))
            if (x.inf (i) > 0)
                l (i) = min (powrounded (x.inf (i), y.sup (i), -inf), ...
                             powrounded (x.sup (i), y.inf (i), -inf));
                u (i) = max (powrounded (x.inf (i), y.inf (i), inf), ...
                             powrounded (x.sup (i), y.sup (i), inf));
            endif
        else # 1 <= x.inf (i)
            l (i) = powrounded (x.sup (i), y.inf (i), -inf);
            u (i) = powrounded (x.sup (i), y.sup (i), inf);
        endif
    else # y.sup (i) <= 0
        if (x.sup (i) <= 1)
            l (i) = powrounded (x.sup (i), y.sup (i), -inf);
            if (x.inf > 0)
                u (i) = powrounded (x.inf (i), y.inf (i), inf);
            endif
        elseif (x.inf (i) < 1 && 1 < x.sup (i))
            l (i) = powrounded (x.sup (i), y.inf (i), -inf);
            if (x.inf (i) > 0)
                u (i) = powrounded (x.inf (i), y.inf (i), inf);
            endif
        else # 1 <= x.inf (i)
            l (i) = powrounded (x.sup (i), y.inf (i), -inf);
            u (i) = powrounded (x.inf (i), y.sup (i), inf);
        endif
    endif
    
    ## Limit values for base zero
    if (x.inf (i) <= 0)
        if (y.inf (i) == 0 && 0 == y.sup (i))
            l (i) = 1;
            u (i) = 1;
        else
            if (0 <= y.inf (i) || (y.inf (i) < 0 && 0 < y.sup (i)))
                l (i) = 0;
            endif
            if (y.sup (i) <= 0 || (y.inf (i) < 0 && 0 < y.sup (i)))
                u (i) = inf;
            endif
        endif
    endif
endfor

result = infsup (l, u);

endfunction

function p = powrounded (x, y, direction)
    assert (x > 0);

    ## We do not have access to a rounded pow or exp function.
    ## First, try to handle special cases that can be computed correctly.
    switch y
        case -1 # x^-1
            fesetround (direction);
            p = 1 / x;
            fesetround (0.5);
            return
        case 0 # x^0
            p = 1;
            return
        case 0.5 # x^0.5
            fesetround (direction);
            p = realsqrt (x);
            fesetround (0.5);
            return
        case 1 # x^1
            p = x;
            return
        case 2 # x^2
            fesetround (direction);
            p = x * x;
            fesetround (0.5);
            return
    endswitch
    switch x
        case 1 # 1^y
            p = 1;
            return
        case 2 # 2^y
            if (y <= -1074)
                if (direction > 0)
                    p = pow2 (-1074);
                else
                    p = 0;
                endif
                return
            elseif (y >= 1024)
                if (direction > 0)
                    p = inf;
                else
                    p = realmax();
                endif
                return
            elseif (fix (y) == y)
                ## y is an integer
                ## This operation is exact
                p = pow2 (y);
                return
            endif
        case 10 # 10^y
            if (y <= -324)
                if (direction > 0)
                    p = pow2 (-1074);
                else
                    p = 0;
                endif
                return
            elseif (y > 308)
                if (direction > 0)
                    p = inf;
                else
                    p = realmax();
                endif
                return
            elseif (fix (y) == y)
                ## y is an integer, we can compute a tight enclosure
                if (abs (y) <= 22) # powers of 10 are binary64 numbers
                                   # up to 10^22
                    p = realpow (10, abs (y)); # this is exact
                    if (y < 0)
                        fesetround (direction);
                        p = 1 / p;
                        fesetround (0.5);
                    endif
                else
                    ## infsup constructor can do the decimal arithmetic
                    p = ["1e" num2str(y)];
                endif
                return
            endif
    endswitch
    
    ## Second, get a rounded-to-nearest value.
    ##
    ## This is better than doing the exp (y * log (x)) computation with
    ## rounded exp, mul and log operations, which will introduce a relative
    ## error of 2^-41, see Lemma 3.6 in
    ## Heimlich, Oliver. 2011. “The General Interval Power Function.”
    ## Diplomarbeit, Institute for Computer Science, University of Würzburg.
    ## http://exp.ln0.de/heimlich-power-2011.htm.
    p = realpow (x, y);
    
    ## Third, consider rounding direction.
    if (direction > 0)
        p = nextup (p);
    else
        p = nextdown (p);
    endif
    
    ## Forth, integral powers of integrals can sometimes be computed exactly.
    if (fix (x) == x && fix (y) == y)
        if (y >= 0)
            ## Non-negative integral powers of intergral numbers are intergrals
            if (direction > 0)
                p = floor (p);
            else
                p = ceil (p);
            endif
        else
            ## Negative integral powers of integral numbers can be computed
            ## with correct rounding inside [2^-53, 1].
            if (pow2 (-53) < abs (p) && abs (p) < 1)
                p = realpow (x, -y); # this is exact
                fesetround (direction);
                p = 1 / p;
                fesetround (0.5);
            endif
        endif
    endif
endfunction
