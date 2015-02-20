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
## @documentencoding utf-8
## @deftypefn {Function File} {@var{X} =} pownrev (@var{C}, @var{X}, @var{P})
## @deftypefnx {Function File} {@var{X} =} pownrev (@var{C}, @var{P})
## 
## Compute the reverse monomial @code{x^@var{P}}.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{pown (x, @var{P}) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{P} ≥ -2.  The result also is a tight enclosure if the
## reciprocal of @var{P} can be computed exactly in double-precision.
##
## @seealso{@@infsup/pown}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pownrev (c, x, p)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif
if (nargin < 3)
    p = x;
    x = infsup (-inf, inf);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

if (not (isnumeric (p)) || fix (p) ~= p)
    error ("interval:InvalidOperand", "pownrev: exponent is not an integer");
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (c.inf))
    x.inf = x.inf (ones (size (c.inf)));
    x.sup = x.sup (ones (size (c.inf)));
    c.inf = c.inf (ones (size (x.inf)));
    c.sup = c.sup (ones (size (x.inf)));
endif

even = mod (p, 2) == 0;
if (even)
    c = c & infsup (0, inf);
endif

switch sign (p)
    case +1
        emptyresult = isempty (c) | isempty (x) | (c.sup < 0 & even);
        if (even)
            l = max (0, c.inf);
            u = max (0, c.sup);
            l = mpfr_function_d ('nthroot', -inf, l, p);
            u = mpfr_function_d ('nthroot', +inf, u, p);
            
            l (emptyresult) = inf;
            u (emptyresult) = -inf;
            
            result = infsup (l, u);
            result = (result & x) | (uminus (result) & x);            
        else # uneven
            l = mpfr_function_d ('nthroot', -inf, c.inf, p);
            u = mpfr_function_d ('nthroot', +inf, c.sup, p);
            
            l (emptyresult) = inf;
            u (emptyresult) = -inf;
            
            result = infsup (l, u) & x;
        endif
        
    case -1
        emptyresult = isempty (c) | isempty (x) ...
            | (c.sup <= 0 & (even | c.inf == 0)) | (x.inf == 0 & x.sup == 0);
        
        if (even)
            l = zeros (size (c.inf));
            u = inf (size (c.inf));
            
            select = c.inf > 0 & isfinite (c.inf);
            if (any (any (select)))
                u (select) = invrootrounded (c.inf (select), -p, +inf);
            endif
            select = c.sup > 0 & isfinite (c.sup);
            if (any (any (select)))
                l (select) = invrootrounded (c.sup (select), -p, -inf);
            endif
            
            l (emptyresult) = inf;
            u (emptyresult) = -inf;
            
            result = infsup (l, u);
            
            result = (result & x) | (uminus (result) & x);
        else # uneven
            l = zeros (size (c.inf));
            u = inf (size (c.inf));
            
            select = c.inf > 0 & isfinite (c.inf);
            if (any (any (select)))
                u (select) = invrootrounded (c.inf (select), -p, +inf);
            endif
            select = c.sup > 0 & isfinite (c.sup);
            if (any (any (select)))
                l (select) = invrootrounded (c.sup (select), -p, -inf);
            endif
            
            notpositive = c.sup <= 0;
            l (emptyresult | notpositive) = inf;
            u (emptyresult | notpositive) = -inf;
            
            result = infsup (l, u) & x; # this is only the positive part
            
            l = zeros (size (c.inf));
            u = inf (size (c.inf));
            
            select = c.sup < 0 & isfinite (c.sup);
            if (any (any (select)))
                u (select) = invrootrounded (-c.sup (select), -p, +inf);
            endif
            select = c.inf < 0 & isfinite (c.inf);
            if (any (any (select)))
                l (select) = invrootrounded (-c.inf (select), -p, -inf);
            endif
            
            notnegative = c.inf >= 0;
            l (emptyresult | notnegative) = inf;
            u (emptyresult | notnegative) = -inf;
            
            result = result | (infsup (-u, -l) & x);
        endif
    
    otherwise # p == 0, x^p == 1
        result = x;
        emptyresult = c.inf > 1 | c.sup < 1;
        result.inf (emptyresult) = inf;
        result.sup (emptyresult) = -inf;
endswitch

endfunction

function x = invrootrounded (z, p, direction)
## We cannot compute the inverse of the p-th root of z in a single step.
## Thus, we use three different ways for computation, each of which has an
## intermediate result with possible rounding errors and can't guarantee to
## produce a correctly rounded result.
## When we finally merge the 3 results, it is still not guaranteed to be
## correctly rounded. However, chances are good that one of the three ways
## produced a “relatively good” result.
##
## x1:  z ^ (- 1 / p)
## x2:  1 / root (z, p)
## x3:  root (1 / z, p)

inv_p = 1 ./ infsup (p);
if (direction > 0)
    x1 = z;
    select = z > 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_p.inf);
    select = z < 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_p.sup);
else
    x1 = z;
    select = z > 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_p.sup);
    select = z < 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_p.inf);
endif

if (issingleton (inv_p))
    ## We are lucky: The result is correctly rounded
    x = x1;
    return
endif

x2 = mpfr_function_d ('rdivide', direction, 1, ...
        mpfr_function_d ('nthroot', -direction, z, p));
x3 = mpfr_function_d ('nthroot', direction, ...
        mpfr_function_d ('rdivide', direction, 1, z), p);

## Choose the most accurate result
if (direction > 0)
    x = min (min (x1, x2), x3);
else
    x = max (max (x1, x2), x3);
endif

endfunction

%!assert (pownrev (infsup (25, 36), infsup (0, inf), 2) == infsup (5, 6));
