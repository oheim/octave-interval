## Copyright 2014-2016 Oliver Heimlich
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
## @deftypemethod {@@infsup} {@var{x} =} gauss (@var{A}, @var{b})
## 
## Solve a linear interval system @var{A} * @var{x} = @var{b} using Gaussian
## elimination.
##
## The found enclosure is improved with the help of the Gauß-Seidel-method.
##
## Note: This algorithm is very inaccurate and slow for matrices of a dimension 
## greater than 3.  A better solver is provided by @code{mldivide}.  The
## inaccuracy mainly comes from the dependency problem of interval arithmetic
## during back-substitution of the solution's enclosure.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## gauss (infsup ([1, 0; 0, 2]), [2, 0; 0, 4])
##   @result{} ans = 2×2 interval matrix
##      [2]   [0]
##      [0]   [2]
## @end group
## @end example
## @seealso{@@infsup/mldivide}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = gauss (x, y)

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

if (isscalar (x) || isscalar (y))
    result = rdivide (y, x);
    return
endif

## x must be square
assert (size (x.inf, 1) == size (x.inf, 2), ...
        "gauss: nonconformant arguments, X is not square");
## vertical sizes of x and y must equal
assert (rows (x.inf) == rows (y.inf), ...
        "gauss: nonconformant arguments, first dimension mismatch");

n = length (x.inf);
m = columns (y.inf);

## We have to compute z = inv (x) * y.
## This can be done by Gaußian elimination by solving the following equation
## for the variable z: x * z = y

## Step 1: Perform LUP decomposition of x into triangular matrices L, U and
##         permutation matrix P
##         P * x = L * U

[L, U, P] = lu (x);

## Step 2: Forward substitution 
##         Solve L * s = inv (P) * y

s = permute (inv (P), y);
curelement.type = prevvars.type = Lrowidx.type =  "()";
for i = 1 : m
    ## Special case: k == 1
    ## s (k, i) already is correct
    for k = 2 : n
        curelement.subs = {k, i};
        prevvars.subs = {1 : k, i};
        Lrowidx.subs = {k, 1 : k};
        
        varcol = subsref (s, prevvars);
        Lrow = subsref (L, Lrowidx);
        
        ## We have to subtract varcol (1 : (k - 1)) * Lrow (1 : (k - 1)) from
        ## s (k, i). Since varcol (k) == s (k, i), we can simply set
        ## Lrow (k) = -1 and the dot product will compute the difference for us
        ## with high accurracy.
        Lrow.inf (k) = Lrow.sup (k) = -1;
        
        ## Then, we only have to flip the sign afterwards.
        s = subsasgn (s, curelement, -dot (Lrow, varcol));
    endfor
endfor

## Step 3: Backward substitution
##         Solve U * z = s

z = s;
Urowstart.type = Urowrest.type = "()";
for i = 1 : m
    ## Special case: k == n
    curelement.subs = {n, i};
    Urowstart.subs = {n, n};
    z = subsasgn (z, curelement, ...
                  mulrev (subsref (U, Urowstart), subsref (z, curelement)));
    for k = (n - 1) : -1 : 1
        curelement.subs = {k, i};
        Urowstart.subs = {k, k};
        prevvars.subs = {k : n, i};
        Urowrest.subs = {k, k : n};
        
        varcol = subsref (z, prevvars);
        Urow = subsref (U, Urowrest);
        
        ## Use the same trick like above during forward substitution.
        Urow.inf (1) = Urow.sup (1) = -1;
        
        ## Additionally we must divide the element by the current diagonal
        ## element of U.
        z = subsasgn (z, curelement, ...
                      mulrev (subsref (U, Urowstart), -dot (Urow, varcol)));
    endfor
endfor

## Now we have solved inv (P) * L * U * z = y for z.
##
## The current result for z is only a rough estimation in general, because
## inv (P) * L * U is only an enclosure of the original linear interval
## system x * z = y and the Gaußian elimination above introduces several
## inaccuracies because of aggregated intermediate results and accumulated
## rounding errors.
##
## We can further try to improve the boundaries of the result with the original
## linear system.  This is an iterative method using the mulrev operation.  It
## is quite accurate in each step, because it only depends on one (tightest)
## dot operation and one (tightest) mulrev operation.  However, the convergence
## speed is slow and each cycle is costly, so we have to cancel after one
## iteration.
##
## The method used here is similar to the Gauß-Seidel-method.  Instead of
## diagonal elements of the matrix we use an arbitrary element that does not
## contain zero as an inner element.

xrowidx.type = yidx.type = zcolidx.type = "()";
migx = mig (x);
migx (isnan (migx)) = 0;
for k = 1 : m
    zcolidx.subs = {1 : n, k};
    zcol = subsref (z, zcolidx);
    for j = n : -1 : 1
        z_jk = infsup (zcol.inf (j), zcol.sup (j));
        if (isempty (z_jk) || issingleton (z_jk))
            ## No improvement can be achieved.
            continue
        endif
        i = find (migx (:, j) == max (migx (:, j)), 1);
        xrowidx.subs = {i, 1 : n};
        xrow = subsref (x, xrowidx);
        if (xrow.inf (j) < 0 && xrow.sup (j) > 0)
            ## No improvement can be achieved.
            continue
        endif
        x_ij = infsup (xrow.inf (j), xrow.sup (j));
        yidx.subs = {i, k};
        yelement = subsref (y, yidx);
        
        ## x (i, 1 : n) * z (1 : n, k) shall equal y (i, k).
        ## 1. Solve this equation for x (i, j) * z (j, k).
        ## 2. Compute a (possibly better) enclosure for z (j, k).
        
        xrow.inf (j) = yelement.inf;
        xrow.sup (j) = yelement.sup;
        zcol.inf (j) = zcol.sup (j) = -1;
        z_jk = mulrev (x_ij, -dot (xrow, zcol), z_jk);
        
        zcol.inf (j) = z.inf (j, k) = z_jk.inf;
        zcol.sup (j) = z.sup (j, k) = z_jk.sup;
    endfor
endfor

result = z;

endfunction

## Apply permutation matrix P to an interval matrix: B = P * A.
## This is much faster than a matrix product, because the matrix product would
## use a lot of dot products.
function B = permute (P, A)
    ## Note: [B.inf, B.sup] = deal (P * A.inf, P * A.sup) is not possible,
    ## because empty or unbound intervals would create NaNs during
    ## multiplication with P.
    
    B = A;
    for i = 1 : rows (P)
        targetrow = find (P (i, :) == 1, 1);
        B.inf (targetrow, :) = A.inf (i, :);
        B.sup (targetrow, :) = A.sup (i, :);
    endfor
endfunction

%!test "from the documentation string";
%! assert (gauss (infsup ([1, 0; 0, 2]), [2, 0; 0, 4]) == [2, 0; 0, 2]);
