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

## -- IEEE 1788 interval function:  pow (X, Y)
##
## Power function on intervals: exp (Y * log (X))

## Author: Oliver Heimlich
## Keywords: accurate interval function
## Created: 2014-10-04

function result = pow (x, y)

if (isempty (x) || isempty (y) || x.sup <= 0)
    result = empty ();
    return
endif

## Simple case with no limit values, see Table 3.3 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Wuerzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.
if (0 <= y.inf)
    if (x.sup <= 1)
        if (x.inf > 0)
            p.inf = powrnd (x.inf, y.sup, -inf);
        endif
        p.sup = powrnd (x.sup, y.inf, inf);
    elseif (x.inf < 1 && 1 < x.sup)
        if (x.inf > 0)
            p.inf = powrnd (x.inf, y.sup, -inf);
        endif
        p.sup = powrnd (x.sup, y.sup, inf);
    else # 1 <= x.inf
        p.inf = powrnd (x.inf, y.inf, -inf);
        p.sup = powrnd (x.sup, y.sup, inf);
    endif
elseif (y.inf < 0 && 0 < y.sup)
    if (x.sup <= 1)
        if (x.inf > 0)
            p.inf = powrnd (x.inf, y.sup, -inf);
            p.sup = powrnd (x.inf, y.inf, inf);
        endif
    elseif (x.inf < 1 && 1 < x.sup)
        if (x.inf > 0)
            p.inf = min (powrnd (x.inf, y.sup, -inf), ...
                         powrnd (x.sup, y.inf, -inf));
            p.sup = max (powrnd (x.inf, y.inf, inf), ...
                         powrnd (x.sup, y.sup, inf));
        endif
    else # 1 <= x.inf
        p.inf = powrnd (x.sup, y.inf, -inf);
        p.sup = powrnd (x.sup, y.sup, inf);
    endif
else # y.sup <= 0
    if (x.sup <= 1)
        p.inf = powrnd (x.sup, y.sup, -inf);
        if (x.inf > 0)
            p.sup = powrnd (x.inf, y.inf, inf);
        endif
    elseif (x.inf < 1 && 1 < x.sup)
        p.inf = powrnd (x.sup, y.inf, -inf);
        if (x.inf > 0)
            p.sup = powrnd (x.inf, y.inf, inf);
        endif
    else # 1 <= x.inf
        p.inf = powrnd (x.sup, y.inf, -inf);
        p.sup = powrnd (x.inf, y.sup, inf);
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

function p = powrnd (x, y, direction)
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
                p = pow2 (y)
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
    ## Diplomarbeit, Institute for Computer Science, University of Wuerzburg.
    ## http://exp.ln0.de/heimlich-power-2011.htm.
    p = realpow (x, y);
    
    ## Third, consider rounding direction.
    if (direction > 0)
        p = nextup (p);
    else
        p = nextdown (p);
    endif
    
    ## Forth, integral powers of integrals are intergrals.
    if (fix (x) == x && fix (y) == y)
        if (direction > 0)
            p = floor (p);
        else
            p = ceil (p);
        endif
    endif
endfunction
