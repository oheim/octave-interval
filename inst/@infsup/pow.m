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
## Accuracy: The result is a tight enclosure.
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
                l (i) = mpfr_function_d ('pow', -inf, x.inf (i), y.sup (i));
            endif
            u (i) = mpfr_function_d ('pow', +inf, x.sup (i), y.inf (i));
        elseif (x.inf (i) < 1 && 1 < x.sup (i))
            if (x.inf > 0)
                l (i) = mpfr_function_d ('pow', -inf, x.inf (i), y.sup (i));
            endif
            u (i) = mpfr_function_d ('pow', +inf, x.sup (i), y.sup (i));
        else # 1 <= x.inf (i)
            l (i) = mpfr_function_d ('pow', -inf, x.inf (i), y.inf (i));
            u (i) = mpfr_function_d ('pow', +inf, x.sup (i), y.sup (i));
        endif
    elseif (y.inf (i) < 0 && 0 < y.sup (i))
        if (x.sup (i) <= 1)
            if (x.inf (i) > 0)
                l (i) = mpfr_function_d ('pow', -inf, x.inf (i), y.sup (i));
                u (i) = mpfr_function_d ('pow', +inf, x.inf (i), y.inf (i));
            endif
        elseif (x.inf (i) < 1 && 1 < x.sup (i))
            if (x.inf (i) > 0)
                l (i) = min (...
                    mpfr_function_d ('pow', -inf, x.inf (i), y.sup (i)), ...
                    mpfr_function_d ('pow', -inf, x.sup (i), y.inf (i)));
                u (i) = max (...
                    mpfr_function_d ('pow', +inf, x.inf (i), y.inf (i)), ...
                    mpfr_function_d ('pow', +inf, x.sup (i), y.sup (i)));
            endif
        else # 1 <= x.inf (i)
            l (i) = mpfr_function_d ('pow', -inf, x.sup (i), y.inf (i));
            u (i) = mpfr_function_d ('pow', +inf, x.sup (i), y.sup (i));
        endif
    else # y.sup (i) <= 0
        if (x.sup (i) <= 1)
            l (i) = mpfr_function_d ('pow', -inf, x.sup (i), y.sup (i));
            if (x.inf > 0)
                u (i) = mpfr_function_d ('pow', +inf, x.inf (i), y.inf (i));
            endif
        elseif (x.inf (i) < 1 && 1 < x.sup (i))
            l (i) = mpfr_function_d ('pow', -inf, x.sup (i), y.inf (i));
            if (x.inf (i) > 0)
                u (i) = mpfr_function_d ('pow', +inf, x.inf (i), y.inf (i));
            endif
        else # 1 <= x.inf (i)
            l (i) = mpfr_function_d ('pow', -inf, x.sup (i), y.inf (i));
            u (i) = mpfr_function_d ('pow', +inf, x.inf (i), y.sup (i));
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
