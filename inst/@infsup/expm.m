## Copyright 2016 Oliver Heimlich
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
## @defmethod {@@infsup} expm (@var{A})
## 
## Compute the matrix exponential of square matrix @var{A}.
##
## The matrix exponential is defined as the infinite Taylor series
##
## @tex
## $$
##  {\rm expm} (A) = \sum_{k = 0}^{\infty} {A^k \over k!}
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##                     A²     A³
## expm (A) = I + A + ---- + ---- + …
##                     2!     3!
## @end verbatim
## @end group
## @end ifnottex
##
## The function implements the following algorithm:  1. The matrix is scaled,
## 2. an enclosure of the Taylor series is computed using the Horner scheme,
## 3. the matrix is squared.  That is, the algorithm computes
## @code{expm (@var{A} ./ pow2 (@var{L})) ^ pow2 (@var{L})}.  The scaling
## reduces the matrix norm below 1, which reduces errors during exponentiation.
## Exponentiation typically is done by Padé approximation, but that doesn't
## work for interval matrices, so we compute a Horner evaluation of the Taylor
## series.  Finally, the exponentiation with @code{pow2 (@var{L})} is computed
## with @var{L} successive interval matrix square operations.  Interval matrix
## square operations can be done without dependency errors (regarding each
## single step).
##
## The algorithm has been published by Alexandre Goldsztejn and Arnold
## Neumaier (2009), “On the Exponentiation of Interval Matrices.” 
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## vec (expm (infsup(magic (3))))
##   @result{} ans ⊂ 9×1 interval vector
##
##        [1.0897e+06, 1.0898e+06]
##        [1.0896e+06, 1.0897e+06]
##        [1.0896e+06, 1.0897e+06]
##        [1.0895e+06, 1.0896e+06]
##        [1.0897e+06, 1.0898e+06]
##        [1.0897e+06, 1.0898e+06]
##        [1.0896e+06, 1.0897e+06]
##        [1.0896e+06, 1.0897e+06]
##        [1.0896e+06, 1.0897e+06]
##
## @end group
## @end example
## @seealso{@@infsup/mpower, @@infsup/exp}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-01-26

function result = expm (A)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isscalar (A))
    ## Short-circuit for scalars
    result = exp (A);
    return
endif

if (not (issquare (A.inf)))
    error ("interval:InvalidOperand", ...
           "expm: must be square matrix");
endif

## Choose L such that ||A|| / 2^L < 0.1 and 10 <= L <= 100
L = min (max (inf (ceil (log2 (10 * norm (A, inf)))), 10), 100);
## Choose K such that K + 2 > ||A|| and 10 <= K <= 170
K = min (max (inf (ceil (norm (A, inf) - 2)), 10), 170);

## 1. Scale
A = rdivide (A, pow2 (L));

## 2. Compute Taylor series
## Compute Horner scheme: I + A*(I + A/2*(I + A/3*( ... (I + A/K) ... )))
result = I = eye (size (A.inf));
for k = K : -1 : 1
    result = I + A ./ k * result;
endfor
## Truncation error for the exponential series
alpha = norm (A, inf);
rho = pown (alpha, K + 1) ./ ...
      (factorial (infsup (K + 1)) * (1 - alpha ./ (K + 2)));
warning ("off", "interval:ImplicitPromote", "local");
truncation_error = rho .* infsup (-1, 1);
result = result + truncation_error;

## 3. Squaring
result = mpower (result, pow2 (L));

endfunction

%!test "from the paper";
%! A = infsup ([0 1; 0 -3], [0 1; 0 -2]);
%! assert (all (all (subset (infsup ([1, 0.316738; 0, 0.0497871], [1, 0.432332; 0 0.135335]), expm (A)))));