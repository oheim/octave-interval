## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} nthroot (@var{X}, @var{N})
## 
## Compute the real n-th root of @var{X}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{n} ≥ -2.  The result also is a tight enclosure if the
## reciprocal of @var{n} can be computed exactly in double-precision.
## @seealso{@@infsup/pown, @@infsup/pownrev, @@infsup/realsqrt, @@infsup/cbrt}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function result = nthroot (x, n)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

if (not (isnumeric (n)) || fix (n) ~= n)
    error ("interval:InvalidOperand", "nthroot: degree is not an integer");
endif

even = mod (n, 2) == 0;
if (even)
    x = intersect (x, infsup (0, inf));
endif

switch sign (n)
    case +1
        emptyresult = isempty (x);
        l = mpfr_function_d ('nthroot', -inf, x.inf, n);
        u = mpfr_function_d ('nthroot', +inf, x.sup, n);
        
        l (emptyresult) = inf;
        u (emptyresult) = -inf;
        
        result = infsup (l, u);
        
    case -1
        emptyresult = isempty (x) ...
            | (x.sup <= 0 & even) | (x.inf == 0 & x.sup == 0);
        
        if (even)
            l = zeros (size (x.inf));
            u = inf (size (x.inf));
            
            select = x.inf > 0 & isfinite (x.inf);
            if (any (any (select)))
                u (select) = invrootrounded (x.inf (select), -n, +inf);
            endif
            select = x.sup > 0 & isfinite (x.sup);
            if (any (any (select)))
                l (select) = invrootrounded (x.sup (select), -n, -inf);
            endif
            
            l (emptyresult) = inf;
            u (emptyresult) = -inf;
            
            result = infsup (l, u);
        else # uneven
            l = zeros (size (x.inf));
            u = inf (size (x.inf));
            
            select = x.inf > 0 & isfinite (x.inf);
            if (any (any (select)))
                u (select) = invrootrounded (x.inf (select), -n, +inf);
            endif
            select = x.sup > 0 & isfinite (x.sup);
            if (any (any (select)))
                l (select) = invrootrounded (x.sup (select), -n, -inf);
            endif
            
            notpositive = x.sup <= 0;
            l (emptyresult | notpositive) = inf;
            u (emptyresult | notpositive) = -inf;
            
            result = infsup (l, u); # this is only the positive part
            
            l = zeros (size (x.inf));
            u = inf (size (x.inf));
            
            select = x.sup < 0 & isfinite (x.sup);
            if (any (any (select)))
                u (select) = invrootrounded (-x.sup (select), -n, +inf);
            endif
            select = x.inf < 0 & isfinite (x.inf);
            if (any (any (select)))
                l (select) = invrootrounded (-x.inf (select), -n, -inf);
            endif
            
            notnegative = x.inf >= 0;
            l (emptyresult | notnegative) = inf;
            u (emptyresult | notnegative) = -inf;
            
            result = union (result, infsup (-u, -l));
        endif
    
    otherwise
        error ("interval:InvalidOperand", "nthroot: degree must not be zero");
endswitch

endfunction

function x = invrootrounded (z, n, direction)
## We cannot compute the inverse of the n-th root of z in a single step.
## Thus, we use three different ways for computation, each of which has an
## intermediate result with possible rounding errors and can't guarantee to
## produce a correctly rounded result.
## When we finally merge the 3 results, it is still not guaranteed to be
## correctly rounded. However, chances are good that one of the three ways
## produced a “relatively good” result.
##
## x1:  z ^ (- 1 / n)
## x2:  1 / root (z, n)
## x3:  root (1 / z, n)

inv_n = 1 ./ infsup (n);
if (direction > 0)
    x1 = z;
    select = z > 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_n.inf);
    select = z < 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_n.sup);
else
    x1 = z;
    select = z > 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_n.sup);
    select = z < 1;
    x1 (select) = mpfr_function_d ('pow', direction, z (select), -inv_n.inf);
endif

if (issingleton (inv_n))
    ## We are lucky: The result is correctly rounded
    x = x1;
    return
endif

x2 = mpfr_function_d ('rdivide', direction, 1, ...
        mpfr_function_d ('nthroot', -direction, z, n));
x3 = mpfr_function_d ('nthroot', direction, ...
        mpfr_function_d ('rdivide', direction, 1, z), n);

## Choose the most accurate result
if (direction > 0)
    x = min (min (x1, x2), x3);
else
    x = max (max (x1, x2), x3);
endif

endfunction

%!assert (nthroot (infsup (25, 36), 2) == infsup (5, 6));
