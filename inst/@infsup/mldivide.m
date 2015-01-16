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
## @documentencoding utf-8
## @deftypefn {Function File} {} {} @var{X} \ @var{Y}
## 
## Return the interval matrix left division of @var{X} and @var{Y}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## infsup ([1, 0; 0, 2]) \ [2, 0; 0, 4]
##   @result{} 2×2 interval matrix
##      [2]   [0]
##      [0]   [2]
## @end group
## @end example
## @seealso{mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = mldivide (x, y)

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
        "operator \: nonconformant arguments, X is not square");
## vertical sizes of x and y must equal
assert (rows (x.inf) == rows (y.inf), ...
        "operator \: nonconformant arguments, first dimension mismatch");

n = length (x.inf);
m = columns (y.inf);

## We have to compute z = inv (x) * y.
## This can be done by Gaußian elimination by solving the following equation
## for the variable z: x * z = y

## Step 1: Perform LUP decomposition of x into triangular matrices L, U and
##         permutation matrix P
##         P * x = L * U

## Compute P such that the computation of L below will not fail because of
## division by zero.  P * x should not have zeros in its main diagonal.
## The computation of P is a greedy heuristic algorithm, which I developed for
## the implementation of this function.
P = zeros (n);
migU = migx = mig (x);
magU = mag (x);
## Empty intervals are as bad as intervals containing only zero.
migU (isnan (migU)) = 0;
magU (isnan (magU)) = 0;
for i = 1 : n
    ## Choose next pivot in one of the columns with the fewest mig (U) > 0.
    columnrating = sum (migU > 0, 1);
    ## Don't choose used columns
    columnrating (max (migU, [], 1) == inf) = inf;
    
    ## Use first possible column
    possiblecolumns = columnrating == min (columnrating);
    column = find (possiblecolumns, 1);
    assert (not (isempty (column)));
    
    if (columnrating (column) >= 1)
        ## Greedy: Use only intervals that do not contain zero.
        possiblerows = migU (:, column) > 0;
    else
        ## Only intervals left which contain zero. Try to use an interval
        ## that additionally contains other numbers.
        possiblerows = migU (:, column) >= 0 & magU (:, column) > 0;
        if (not (max (possiblerows)))
            ## All possible intervals contain only zero.
            possiblerows = migU (:, column) >= 0;
        endif
    endif

    if (sum (possiblerows) == 1)
        ## Short-ciruit: Take the only remaining useful row
        row = find (possiblerows, 1);
    else
        ## There are several good choices, take the one that will hopefully
        ## not hinder the choice of further pivot elements.
        ## That is, the row with the least mig (U) > 0.
        
        rowrating = sum (migU > 0, 2);
        ## We weight the rating in the columns with few mig (U) > 0 in order to
        ## prevent problems during the choice of pivots in the near future.
        rowrating += 0.5 * sum (migU (:, possiblecolumns) > 0, 2);
        rowrating (not (possiblerows)) = inf;
        row = find (rowrating == min (rowrating), 1);
    endif
    assert (not (isempty (row)));
    
    assert (0 <= migU (row, column) && migU (row, column) < inf);

    P (row, column) = 1;
    
    ## In mig (U), for the choice of further pivots:
    ##  - mark used columns with inf
    ##  - mark used rows in unused columns with -inf
    migU (row, :) -= inf;
    migU (isnan (migU)) = inf;
    migU (:, column) = inf;
endfor

## Initialize L and U
L = infsup (eye (n));
U = permute (P, x);

## Compute L and U
varidx.type = rowstart.type = Urefrow.type = Urow.type = "()";
for i = 1 : (n - 1)
    varidx.subs = {i, i};
    Urefrow.subs = {i, i : n};
    ## Go through rows of the remaining matrix
    for k = (i + 1) : n
        rowstart.subs = {k, i};
        ## Compute L
        Lcurrentelement = mulrev (subsref (U, varidx), subsref (U, rowstart));
        L = subsasgn (L, rowstart, Lcurrentelement);
        ## Go through columns of the remaining matrix
        Urow.subs = {k, i : n};
        
        ## Compute U
        minuend = subsref (U, Urow);        
        subtrahend = Lcurrentelement .* subsref (U, Urefrow);
        U = subsasgn (U, Urow, minuend - subtrahend);
    endfor
endfor

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

## Note: [B.inf, B.sup] = deal (P * A.inf, P * A.sup) is not possible, because
## empty or unbound intervals would create NaNs during multiplication with P.

l = u = zeros (size (A));
for i = 1 : rows (P)
    targetrow = find (P (i, :) == 1, 1);
    l (targetrow, :) = A.inf (i, :);
    u (targetrow, :) = A.sup (i, :);
endfor

B = infsup (l, u);

endfunction
