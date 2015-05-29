## Copyright 1995      Rolf Hammer, Matthias Hocks, Dietmar Ratz
## Copyright 1990-2000 Institut für Angewandte Mathematik,
##                     Universität Karlsruhe, Germany
## Copyright 2000-2014 Wissenschaftliches Rechnen/Softwaretechnologie,
##                     Universität Wuppertal, Germany
## Copyright 2015      Oliver Heimlich
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
## @deftypefn {Function File} {} polyval_verified (@var{P}, @var{X})
## 
## Evaluate polynomial @var{P} at @var{X}.
##
## Accuracy: The result is a tight enclosure for polynomials of degree 1 or
## less.  For polynomials of higher degree the result is a valid enclosure, but
## the algorithm tries to compute a tight enclosure via iterative refinement.
##
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-29

function result = polyval_verified (p, x)

if (not (isfloat (x) && isreal (x) && isscalar (x)))
    error ('point of evaluation X must be a scalar real number')
endif

if (not (isfloat (p) && isreal (p) && isvector (p)))
    error ('polynomial P must be a vector of real numbers')
endif

p = vec (p);
n = numel (p);
switch (n)
    case 0 # empty sum
        result = infsupdec (0);
        return
    case 1 # p .* x.^0
        result = infsupdec (p);
        return
    case 2 # p(1) .* x.^1 + p(2) .* x.^0
        result = fma (infsupdec (x), infsupdec (p (1)), infsupdec (p (2)));
        return
endswitch

if (x == 0)
    result = infsupdec (p (n));
    return
elseif (x == 1)
    result = sum (infsupdec (p));
    return
elseif (x == -1)
    result = dot (infsupdec (p), ...
                  x .^ ((n : -1 : 1) - 1));
    return
endif

kMax = 20;

y = zeros (n, kMax);
yy = infsupdec (zeros (size (p)));
result = infsupdec ();
idxNext.type = '()';
idxLast.type = '()';

for k = 1 : kMax
    if (k == 1)
        ## Compute first approximation using Horner's scheme
        y (1, k) = p (1);
        for i = 2 : n
            y (i, k) = y (i - 1, k) .* x + p (i);
        endfor
        continue
    endif
    
    ## Iterative refinement
    ## Store middle of residual as the next correction of y
    y (:, k) = mid (yy);
    yy = infsupdec (zeros (size (p)));
    
    ## Computation of the residual [r] and
    ## evaluation of the interval system A*[y] = [r]
    for i = 2 : n
        idxNext.subs = {i};
        idxLast.subs = {i-1};
        
        yy = subsasgn (yy, idxNext, dot (...
            [subsref(yy, idxLast), p(i), y(i, 1 : k), y(i - 1, 1 : k)], ...
            [x,                    1,    -ones(1, k), x(ones (1, k))]));
    endfor
    
    ## Determination of a new enclosure of p (x)
    idxLast.subs = {n};
    lastresult = result;
    result = sum ([subsref(yy, idxLast), y(n, 1 : k)]);
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
