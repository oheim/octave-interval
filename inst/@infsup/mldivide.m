## Copyright 1990-2000 Institut für Angewandte Mathematik,
##                     Universität Karlsruhe, Germany
## Copyright 2000-2014 Wissenschaftliches Rechnen/Softwaretechnologie,
##                     Universität Wuppertal, Germany
## Copyright 2015-2016 Oliver Heimlich
## 
## This program is derived from FastLSS in CXSC, C++ library for eXtended
## Scientific Computing (V 2.5.4), which is distributed under the terms of
## LGPLv2+.  Original Author is Michael Zimmer.  Migration to Octave code has
## been performed by Oliver Heimlich.
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
## @defop Method {@@infsup} mldivide (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} \ @var{Y}}
## 
## Return the interval matrix left division of @var{X} and @var{Y}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## infsup ([1, 0; 0, 2]) \ [2, 0; 0, 4]
##   @result{} ans = 2×2 interval matrix
##      [2]   [0]
##      [0]   [2]
## @end group
## @end example
## @seealso{@@infsup/mtimes, @@infsup/gauss}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-17

function result = mldivide (A, b)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (A, "infsup")))
    A = infsup (A);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
elseif (isa (b, "infsupdec"))
    ## Workaround for bug #42735
    result = mldivide (A, b);
    return
endif

if (isscalar (A.inf))
    result = ldivide (A, b);
    return
elseif (not (issquare (A.inf)))
    error ("interval:InvalidOperand", "mldivide: Matrix is not square");
elseif (rows (A.inf) ~= rows (b.inf))
    error ("interval:InvalidOperand", ["mldivide: ", ...
        "nonconformant arguments ", ...
        "(op1 is " num2str(rows (A.inf)) "×" num2str(columns (A.inf)) ",", ...
        " op2 is " num2str(rows (b.inf)) "×" num2str(columns (b.inf)) ")"]);
elseif (isempty (A.inf))
    result = infsup (zeros (0, columns (b.inf)));
    return
endif

## Maximum number of iterations during the verification step
cfg.maxIterVer = 5;
## Epsilon for the verification step
## (used for the Epsilon inflation during verification)
cfg.epsVer = 1e-1;
## Maximum number of iterations during the refinement step
cfg.maxIterRef = 5;
## Epsilon for the refinement step (stopping criterion for refinement step)
cfg.epsRef = 1e-5;
## Maximum number of iterations during residual correction
## (not available for K=1)
cfg.maxIterResCorr = 10;
## Epsilon for the residual correction
cfg.epsResCorr = 1e-6;

## An approximate inverse R of A is computed.  Then an approximate solution
## x1 is computed applying a conventional residual iteration.  For the final
## verification, an interval residual iteration is performed.  An enclosure of
## the unique solution is returned.
##
## If this first step fails, the solver will try to compute a verified solution
## by using an approximate inverse of double length.  This second step takes
## considerably longer than the first step, because all computations must be
## performed using high precision scalar products.

## Compute midpoints of A and b for future reference
Am = mid (A);
bm = mid (b);

## Approximate inversion (non-interval computation)
[R, cond] = inv (Am);
if (cond == 0)
    result = gauss (A, b);
    return
endif

## Part 1 =====================================================================

## Approximate solution x1 (non-interval computation)
x1 = R * bm;
x1 += R * (bm - Am * x1);

## Interval residual x
x = mtimes (R, b - mtimes (A, x1, "valid"), "valid");

C = eye (rows (R)) - mtimes (R, A, "valid");

## Verify solution x1 + x
[x, verified] = verify_and_refine (x, C, cfg, "valid");
if (verified)
    result = x1 + x;
    return
endif

## Part 2 =====================================================================

## R2 = inv (R * Am), with correctly rounded dot product
R2 = zeros (size (R));
for i = 1 : rows (R)
    for j = 1 : columns (R)
        R2 (i, j) = mpfr_vector_dot_d (0.5, R (i, :), Am (:, j));
    endfor
endfor
[R2, cond] = inv (R2);
if (cond == 0)
    result = gauss (A, b);
    return
endif

## R = R2 * R with correctly rounded dot product; error in R2
R1_ = R2_ = zeros (size (R));
for i = 1 : rows (R)
    for j = 1 : columns (R)
        [R1_(i, j), R2_(i, j)] = mpfr_vector_dot_d (0.5, R2 (i, :), R (:, j));
    endfor
endfor
R = R1_; R2 = R2_; clear R1_ R2_;

## Loop over all right hand sides
C_computed = false ();
result = infsup (zeros (size (b.inf)));
for s = 1 : columns (b.inf)
    s_idx.type = "()";
    s_idx.subs = {":", s};
    
    ## x1 = R * bm + R2 * bm with correctly rounded dot product; error in x0
    x1 = x0 = zeros (rows (R), 1);
    parfor i = 1 : rows (R)
        [x1(i), x0(i)] = mpfr_vector_dot_d (0.5, [R(i, :), R2(i, :)], ...
                                                 [bm(:, s); bm(:, s)]);
    endparfor
    
    ## Residual iteration (non-interval computation)
    for k = 1 : cfg.maxIterResCorr
        ## d = bm - Am * x1 - Am * x0 with correctly rounded dot product
        d = zeros (rows (R), 1);
        parfor i = 1 : rows (R)
            d (i) = mpfr_vector_dot_d (0.5, ...
                        [bm(i, s), Am(i, :), Am(i, :)], ...
                        [1;        -x1;      -x0]);
        endparfor
        
        ## y0 = x0 + R * d + R2 * d with correctly rounded dot product
        y0 = zeros (rows (R), 1);
        parfor i = 1 : rows (R)
            y0 (i) = mpfr_vector_dot_d (0.5, ...
                        [x0(i), R(i, :), R2(i, :)], ...
                        [1;     d;       d]);
        endparfor
        
        d = x1 + y0;
        p = relative_error (d, x1 + x0);
        
        if (p >= cfg.epsResCorr && k < cfg.maxIterResCorr)
            ## x0 = x1 + x0 - d with correctly rounded sum
            parfor i = 1 : rows (R)
                x0 (i) = mpfr_vector_sum_d (0.5, [x1(i), x0(i), -d(i)]);
            endparfor
        endif
            
        x1 = d;
        
        if (p < cfg.epsResCorr)
            break
        endif
    endfor
    
    ## compute enclosure y+Y1 of the residuum b-A*x1 of the approximation x1
    ## and initialize x:= (R+R2)*(b-A*x1), C:= I-(R+R2)*A   
    
    ## y = mid (b - A * x1)
    y = mid ([subsref(b, s_idx), A] * [1; -x1]);
    
    ## Y1 = b - A * x1 - y
    Y1 = [subsref(b, s_idx), A, y] * [1; -x1; -1];
    
    ## x = R * y + R2 * y + R * Y1 + R2 * Y1
    x = [R, R2, R, R2] * [y; y; Y1; Y1];
    
    ## Verifying solution x1 + x ...
    if (all (x.inf == 0 & x.sup == 0))
        ## exact solution! (however, not necessarily unique!)
        subsasgn (result, s_idx, x1);
        continue
    endif
    
    if (not (C_computed))
        ## C = I - R * A - R2 * A (lazy computation)
        C = [eye(rows (R)), R, R2] * [eye(rows (R)); -A; -A];
        C_computed = true ();
    endif
    
    [x, verified] = verify_and_refine (x, C, cfg, "tight");
    if (not (verified))
        error ("Verification failed")
    endif
    
    ## The exact solution lies x1 + x
    subsasgn (result, s_idx, x1 + x);
endfor

endfunction

## Perform an epsilon inflation
function y = blow (x, eps)
    y = nextout ((1 + eps) .* x - eps .* x);
endfunction

## Compute component-wise the maximum relative error
function e = relative_error (new, old)
    nonzero = old ~= 0 & (1e6 * abs (new) >= abs (old));
    e = max (abs ((new (nonzero) - old (nonzero)) ./ old (nonzero)));
    
    if (isempty (e))
        e = 0;
    endif
endfunction

## Interval iteration until inclusion is obtained (or max. iteration count)
function [x, verified] = verify_and_refine (x0, C, cfg, accuracy)
    verified = false ();
    x = x0;
    for p = 1 : cfg.maxIterVer
        y = blow (x, cfg.epsVer); # epsilon inflation
        x = x0 + mtimes (C, y, accuracy); # new iterate
        
        verified = all (all (subset (x, y)));
        if (verified)
            break
        endif
    endfor
    
    if (verified)
        ## Iterative refinement
        for p = 1 : cfg.maxIterRef
            y = x;
            x = intersect (x0 + mtimes (C, x, accuracy), x);
            
            if (p == cfg.maxIterRef)
                break
            endif
            
            distance = max (abs (x.inf - y.inf), ...
                            abs (x.sup - y.sup));
            if (max (max (distance)) <= cfg.epsRef)
                break
            endif
        endfor
    endif
endfunction

%!test "unique solution";
%!  assert (infsup ([1, 0; 0, 2]) \ [2, 0; 0, 4] == [2, 0; 0 2]);
%!test "no solution";
%!  assert (all (isempty (infsup ([1, 0; 2, 0]) \ [3; 0])));
%!test "many solutions";
%!  assert (infsup ([1, 0; 2, 0]) \ [4; 8] == infsup ([4; -inf], [4; inf]));
%!assert (all (subset (infsup ([2, -1; -1, 2], [4, 1; 1, 4]) \ infsup ([-3; .8], [3; .8]), infsup ([-2.3; -1.1], [2.3; 1.6]))));
