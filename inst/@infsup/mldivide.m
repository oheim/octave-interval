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
## @deftypefn {Interval Function} {} @var{X} \ @var{Y}
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
        "operator /: nonconformant arguments");
## vertical sizes of x and y must equal
assert (rows (x.inf) == rows (y.inf), ...
        "operator /: nonconformant arguments");

n = length (x.inf);
m = columns (y.inf);

## We have to compute z = inv (x) * y.
## This can be done by Gaussian elimination by solving the following equation
## for the variable z: x * z = y

## Step 1: Perform LUP decomposition of x into triangular matrices L, U and
##         permutation matrix P
##         P * x = L * U

## Compute P such that the computation of L below will not fail because of
## division by zero.  P * x should not have zeros in its main diagonal.
## The computation of P is a greedy heuristic algorithm, which I developed for
## the implementation of this function.
P = zeros (n);
migU = mig (x);
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
U = L = cell (n);
x = permute (P, x);
for i = 1 : n
    for k = 1 : n
        ## Store P * x in U
        U {i, k} = infsup (x.inf (i, k), x.sup (i, k));
        ## Store eye (n) in L
        L {i, k} = infsup (double (i == k));
    endfor
endfor

## Compute L and U
for i = 1 : (n - 1)
    ## Go through rows of the remaining matrix
    for k = (i + 1) : n
        ## Compute L
        L {k, i} = U {k, i} ./ U {i, i};
        ## Go through columns of the remaining matrix
        for j = i : n
            ## Compute U
            U {k, j} = U {k, j} - L {k, i} .* U {i, j};
        endfor
    endfor
endfor

## Step 2: Forward substitution 
##         Solve L * s = inv (P) * y

s = cell (n, m);
y = permute (inv (P), y);

for i = 1 : m
    s {1, i} = infsup (y.inf (1, i), y.sup (1, i));
    for k = 2 : n
        suml = sumu = zeros (k, 2);
        for j = 1 : (k - 1)
            suml (j, :) = [inf(L {k, j}), inf(s {j, i})];
            sumu (j, :) = [sup(L {k, j}), sup(s {j, i})];
        endfor
        suml (k, :) = [-1, y.inf(k, i)];
        sumu (k, :) = [-1, y.sup(k, i)];
        sum = dot (infsup (suml (:, 1), sumu (:, 1)), ...
                   infsup (suml (:, 2), sumu (:, 2)));
        
        s {k, i} = -sum;
    endfor
endfor

## Step 3: Backward substitution
##         Solve U * z = s

z = infsup (inf (n, m), -inf (n, m));
idx.type = "()"; # we cannot access subsref / subsasgn using operators
for i = 1 : m
    idx.subs = {n, i};
    z = subsasgn (z, idx, csdivide (s {n, i}, U {n, n}));
    for k = (n - 1) : -1 : 1
        suml = sumu = zeros (n - k + 1, 2);
        for j = (k + 1) : n
            idx.subs = {j, i};
            suml (j - k, :) = [inf(U {k, j}), inf(subsref (z, idx))];
            sumu (j - k, :) = [sup(U {k, j}), sup(subsref (z, idx))];
        endfor
        suml (n - k + 1, :) = [-1, inf(s {k, i})];
        sumu (n - k + 1, :) = [-1, sup(s {k, i})];
        sum = dot (infsup (suml (:, 1), sumu (:, 1)), ...
                   infsup (suml (:, 2), sumu (:, 2)));
        
        idx.subs = {k, i};
        z = subsasgn (z, idx, csdivide (-sum, U {k, k}));
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

## Containment-Set theoretic division
function z = csdivide (x, y)

if (ismember (0, y))
    if (isempty (x))
        z = infsup (inf, -inf);
    else
        z = infsup (-inf, inf);
    endif
else
    z = x ./ y;
endif

endfunction