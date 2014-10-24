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
## @deftypefn {Interval Function} {@var{Z} =} atan2 (@var{Y}, @var{X})
## @cindex IEEE1788 atan2
## 
## Compute the inverse tangent with two arguments for each pair of numbers from
## intervals @var{Y} and @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 2.5 ULPs of the exact enclosure.
##
## @example
## @group
## atan2 (infsup (1), infsup (-1))
##   @result{} [2.3561944901923435, 2.3561944901923462]
## @end group
## @end example
## @seealso{tan}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = atan2 (y, x)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

## Convert second parameter into interval, if necessary
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

if (isempty (x) || isempty (y) || ...
    (x.inf == 0 && x.sup == 0 && y.inf == 0 && y.sup == 0))
    result = infsup ();
    return
endif

pi = infsup ("pi");

if (x.sup <= 0)
    if (y.inf >= 0)
        if (y.sup == 0)
            at2.inf = inf (pi);
        elseif (y.sup == inf || x.sup == 0)
            at2.inf = inf (pi) / 2;
        else
            ## The atan2 should be within 2.5 ULPs of the exact result.
            ## The atan2 with directed rounding is 2 ULPs within tight result.
            fesetround (-inf);
            at2.inf = atan2 (y.sup, x.sup);
            fesetround (0.5);
            at2.inf = ulpadd (at2.inf, -2);
            at2.inf = max (at2.inf, inf (pi) / 2);
        endif
        
        if (x.inf == 0)
            at2.sup = sup (pi) / 2;
        elseif (x.inf == -inf || y.inf == 0)
            at2.sup = sup (pi);
        else
            fesetround (inf);
            at2.sup = atan2 (y.inf, x.inf);
            fesetround (0.5);
            at2.sup = ulpadd (at2.sup, 2);
            at2.sup = min (at2.sup, sup (pi));
        endif
    elseif (y.sup <= 0)
        if (x.inf == 0)
            at2.inf = inf (-pi) / 2;
        elseif (x.inf == -inf)
            at2.inf = inf (-pi);
        else
            fesetround (-inf);
            at2.inf = atan2 (y.sup, x.inf);
            fesetround (0.5);
            at2.inf = ulpadd (at2.inf, -2);
            at2.inf = max (at2.inf, inf (-pi));
        endif
        
        if (y.inf == -inf || x.sup == 0)
            at2.sup = sup (-pi) / 2;
        else
            fesetround (inf);
            at2.sup = atan2 (y.inf, x.sup);
            fesetround (0.5);
            at2.sup = ulpadd (at2.sup, 2);
            at2.sup = min (at2.sup, inf (-pi));
        endif
    else # 0 is inner point of y
        if (x.inf == 0)
            at2.inf = inf (-pi) / 2;
        else
            at2.inf = inf (-pi);
        endif
        if (x.inf == 0)
            at2.sup = sup (pi) / 2;
        else
            at2.sup = sup (pi);
        endif
    endif
elseif (x.inf >= 0)
    if (y.inf >= 0)
        if (x.sup == 0)
            at2.inf = inf (pi) / 2;
        elseif (y.inf == 0)
            at2.inf = 0;
        else
            fesetround (-inf);
            at2.inf = atan2 (y.inf, x.sup);
            fesetround (0.5);
            at2.inf = ulpadd (at2.inf, -2);
            at2.inf = max (at2.inf, 0);
        endif
        
        if (y.sup == 0)
            at2.sup = 0;
        elseif (x.inf == 0)
            at2.sup = sup (pi) / 2;
        else
            fesetround (inf);
            at2.sup = atan2 (y.sup, x.inf);
            fesetround (0.5);
            at2.sup = ulpadd (at2.sup, 2);
            at2.sup = min (at2.sup, sup (pi) / 2);
        endif
    elseif (y.sup <= 0)
        if (x.inf == 0)
            at2.inf = inf (-pi) / 2;
        else
            fesetround (-inf);
            at2.inf = atan2 (y.inf, x.inf);
            fesetround (0.5);
            at2.inf = ulpadd (at2.inf, -2);
            at2.inf = max (at2.inf, inf (-pi) / 2);
        endif
        if (x.sup == 0)
            at2.sup = sup (-pi) / 2;
        elseif (y.sup == 0)
            at2.sup = 0;
        else
            fesetround (inf);
            at2.sup = atan2 (y.sup, x.sup);
            fesetround (0.5);
            at2.sup = ulpadd (at2.sup, 2);
            at2.sup = min (at2.sup, sup (-pi) / 2)
        endif
    else # 0 is inner point of y
        if (x.inf == 0)
            at2.inf = inf (-pi) / 2;
            at2.sup = sup (pi) / 2;
        else
            fesetround (-inf);
            at2.inf = atan2 (y.inf, x.inf);
            fesetround (0.5);
            at2.inf = ulpadd (at2.inf, -2);
            at2.inf = max (at2.inf, inf (-pi) / 2);
            fesetround (inf);
            at2.sup = atan2 (y.sup, x.inf);
            fesetround (0.5);
            at2.sup = ulpadd (at2.sup, 2);
            at2.sup = min (at2.sup, sup (pi) / 2)
        endif
    endif
else # 0 is inner point of x
    if (y.inf == 0)
        at2.inf = 0;
        at2.sup = sup (pi);
    elseif (y.inf > 0)
        fesetround (-inf);
        at2.inf = atan2 (y.inf, x.sup);
        fesetround (0.5);
        at2.inf = ulpadd (at2.inf, -2);
        at2.inf = max (at2.inf, 0);
        fesetround (inf);
        at2.sup = atan2 (y.inf, x.inf);
        fesetround (0.5);
        at2.sup = ulpadd (at2.sup, 2);
        at2.sup = min (at2.sup, sup (pi));
    elseif (y.sup >= 0)
        at2.inf = inf (-pi);
        at2.sup = sup (pi);
    else # y.sup < 0
        fesetround (-inf);
        at2.inf = atan2 (y.sup, x.inf);
        fesetround (0.5);
        at2.inf = ulpadd (at2.inf, -2);
        at2.inf = max (at2.inf, inf (-pi));
        fesetround (inf);
        at2.sup = atan2 (y.sup, x.sup);
        fesetround (0.5);
        at2.sup = ulpadd (at2.sup, 2);
        at2.sup = min (at2.sup, 0);
    endif
endif

result = infsup (at2.inf, at2.sup);

endfunction