## Copyright 1995      Rolf Hammer, Matthias Hocks, Dietmar Ratz
## Copyright 1990-2000 Institut für Angewandte Mathematik,
##                     Universität Karlsruhe, Germany
## Copyright 2000-2014 Wissenschaftliches Rechnen/Softwaretechnologie,
##                     Universität Wuppertal, Germany
## Copyright 2015-2016 Oliver Heimlich
##
## This program is derived from RPolyEval in CXSC, C++ library for eXtended
## Scientific Computing (V 2.5.4), which is distributed under the terms of
## LGPLv2+.  Migration to Octave code has been performed by Oliver Heimlich.
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
## @defmethod {@@infsup} polyval (@var{P}, @var{X})
##
## Evaluate polynomial @var{P} with argument @var{X}.
##
## Horner's scheme is used to evaluate a first approximation.  The result is
## improved with iterative refinement.
##
## Accuracy: The result is a tight enclosure for polynomials of degree 1 or
## less.  For polynomials of higher degree the result is a valid enclosure.
## For @var{X} being no singleton interval, the algorithm suffers from the
## dependency problem.
##
## @example
## @group
## output_precision (16, 'local')
## polyval (infsup ([3 4 2 1]), 42) # 3x^3 + 4x^2 + 2x^1 + 1 | x = 42
##   @result{} [229405]
## polyval (infsup ([3 4 2 1]), "42?") # ... | x = 41.5 .. 42.5
##   @result{} [221393.125, 237607.875]
## @end group
## @end example
## @seealso{@@infsup/fzero}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-29

function result = polyval (p, x)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (p, "infsup")))
    p = infsup (p);
endif

if (not (isscalar (x)))
    error ('point of evaluation X must be a scalar')
endif

if (not (isvector (p)))
    error ('polynomial P must be a vector of coefficients')
endif

n = numel (p);
switch (n)
    case 0 # empty sum
        result = infsup (0);
        return
    case 1 # p .* x.^0
        result = p;
        return
    case 2 # p(1) .* x.^1 + p(2) .* x.^0
        result = fma (x, subsref (p, struct ('type', '()', 'subs', {{1}})), ...
                         subsref (p, struct ('type', '()', 'subs', {{2}})));
        return
endswitch

if (x == 0)
    result = subsref (p, struct ('type', '()', 'subs', {{n}}));
    return
elseif (x == 1)
    result = sum (p);
    return
elseif (x == -1)
    result = dot (p, (-1) .^ ((n : -1 : 1) - 1));
    return
endif

kMax = 20;

idxNext.type = '()';
idxLast.type = '()';

## Compute first approximation using Horner's scheme
yy = infsup (zeros (n, 1));
idxNext.subs = {1};
result = subsref (p, idxNext);
yy = subsasgn (yy, idxNext, result);
for i = 2 : n
    idxNext.subs = {i};
    result = fma (result, x, subsref (p, idxNext));
    yy = subsasgn (yy, idxNext, result);
endfor

y = zeros (n, kMax);
for k = 1 : kMax
    lastresult = result;

    ## Iterative refinement
    ## Store middle of residual as the next correction of y
    y (:, k) = mid (yy);

    ## Computation of the residual [r] and
    ## evaluation of the interval system A*[y] = [r]
    yy = infsup (zeros (n, 1));
    for i = 2 : n
        idxNext.subs = {i};
        idxLast.subs = {i-1};
        
        coef = subsref (p, idxNext);
        yy = subsasgn (yy, idxNext, dot (...
            [subsref(yy, idxLast), coef, y(i, 1 : k), y(i - 1, 1 : k)], ...
            [x,                    1,    -ones(1, k), x.*ones(1, k)]));
    endfor
    
    ## Determination of a new enclosure of p (x)
    idxLast.subs = {n};
    result = intersect (result, sum ([subsref(yy, idxLast), y(n, 1 : k)]));
    if (eq (result, lastresult))
        ## No improvement
        break
    endif
    if (mpfr_function_d ('plus', +inf, inf (result), pow2 (-1074)) >= ...
        sup (result))
        ## 1 ULP accuracy reached
        break
    endif
endfor

endfunction

%!assert (polyval (infsup (42), 0) == 42);
%!assert (polyval (infsup ([42 42]), 0) == 42);
%!assert (polyval (infsup ([42 42]), 1) == 84);
%!assert (polyval (infsup ([42 42]), -1) == 0);
%!assert (polyval (infsup ([-42 42 42]), .5) == -42*0.5^2 + 42*0.5 + 42);
%!assert (polyval (infsup (vec (pascal (3))), 0.1) == "[0X6.502E9A7231A08P+0, 0X6.502E9A7231A0CP+0]");
