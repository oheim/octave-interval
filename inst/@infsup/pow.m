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
## @deftypefn {Interval Function} {@var{Y} =} pow (@var{X}, @var{Y})
## @cindex IEEE1788 pow
## 
## Compute the simple power function on intervals defined by 
## @code{exp (@var{Y} * log (@var{X}))}.
##
## The function is only defined where @var{X} is positive, cf. log function.
## A general power function is implemented by @code{mpower}.
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
## @seealso{pown, pow2, pow10, exp, mpower}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pow (x, y)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Convert second parameter into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

if (isempty (x) || isempty (y) || x.sup <= 0)
    result = infsup ();
    return
endif

## Simple case with no limit values, see Table 3.3 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.
if (0 <= y.inf)
    if (x.sup <= 1)
        if (x.inf > 0)
            p.inf = powrounded (x.inf, y.sup, -inf);
        endif
        p.sup = powrounded (x.sup, y.inf, inf);
    elseif (x.inf < 1 && 1 < x.sup)
        if (x.inf > 0)
            p.inf = powrounded (x.inf, y.sup, -inf);
        endif
        p.sup = powrounded (x.sup, y.sup, inf);
    else # 1 <= x.inf
        p.inf = powrounded (x.inf, y.inf, -inf);
        p.sup = powrounded (x.sup, y.sup, inf);
    endif
elseif (y.inf < 0 && 0 < y.sup)
    if (x.sup <= 1)
        if (x.inf > 0)
            p.inf = powrounded (x.inf, y.sup, -inf);
            p.sup = powrounded (x.inf, y.inf, inf);
        endif
    elseif (x.inf < 1 && 1 < x.sup)
        if (x.inf > 0)
            p.inf = min (powrounded (x.inf, y.sup, -inf), ...
                         powrounded (x.sup, y.inf, -inf));
            p.sup = max (powrounded (x.inf, y.inf, inf), ...
                         powrounded (x.sup, y.sup, inf));
        endif
    else # 1 <= x.inf
        p.inf = powrounded (x.sup, y.inf, -inf);
        p.sup = powrounded (x.sup, y.sup, inf);
    endif
else # y.sup <= 0
    if (x.sup <= 1)
        p.inf = powrounded (x.sup, y.sup, -inf);
        if (x.inf > 0)
            p.sup = powrounded (x.inf, y.inf, inf);
        endif
    elseif (x.inf < 1 && 1 < x.sup)
        p.inf = powrounded (x.sup, y.inf, -inf);
        if (x.inf > 0)
            p.sup = powrounded (x.inf, y.inf, inf);
        endif
    else # 1 <= x.inf
        p.inf = powrounded (x.sup, y.inf, -inf);
        p.sup = powrounded (x.inf, y.sup, inf);
    endif
endif

## Limit values for base zero
if (x.inf <= 0)
    if (y.inf == 0 && 0 == y.sup)
        p.inf = 1;
        p.sup = 1;
    else
        if (0 <= y.inf || (y.inf < 0 && 0 < y.sup))
            p.inf = 0;
        endif
        if (y.sup <= 0 || (y.inf < 0 && 0 < y.sup))
            p.sup = inf;
        endif
    endif
endif

result = infsup (p.inf, p.sup);

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
