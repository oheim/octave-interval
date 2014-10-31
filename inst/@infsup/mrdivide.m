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
## @deftypefn {Interval Function} {} @var{X} / @var{Y}
## 
## Return the interval matrix right division of @var{X} and @var{Y}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## infsup ([1, 2; 3, 4]) / [3, 4; 1, 2]
##   @result{} 2×2 interval matrix
##      [0]   [1]
##      [1]   [0]
## @end group
## @end example
## @seealso{mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = mrdivide (x, y)

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
    result = rdivide (x, y);
    return
endif

## y must be square
assert (size (y.inf, 1) == size (y.inf, 2), ...
        "operator /: nonconformant arguments");
## horizontal sizes of x and y must equal
assert (columns (x.inf) == columns (y.inf), ...
        "operator /: nonconformant arguments");

n = length (y.inf);
m = rows (x.inf);

## We have to compute z = x * inv (y), which is equivalent to
## z = (inv (y)' * x')'.
## This can be done by Gaussian elimination by solving the following equation
## for the variable z: y' * z' = x'

## Step 1: Perform LUP decomposition of y' into triangular matrices L, U and
##         permutation matrix P
##         P * y' = L * U

## Compute P such that the computation of L below will not fail because of
## division by zero.  P * y' should not have zeros in its main diagonal.
## The computation of P is a greedy heuristic algorithm, which I developed for
## the implementation of this function.
P = zeros (n);
migU = mig (y');
magU = mag (y');
for i = 1 : n
    ## Choose next pivot in one of the columns with the fewest mig (U) > 0.
    columnrating = sum (migU > 0, 1);
    ## Don't choose used columns
    columnrating (max (migU, [], 1) == inf) = inf;
    
    ## Use first possible column
    possiblecolumns = columnrating == min (columnrating);
    column = find (possiblecolumns, 1);
    assert (not (isempty (column)));
    
    if (columnrating (column) == 1)
        ## Take the only remaining useful row
        row = find (migU (:, column) > 0, 1);
    elseif (columnrating (column) == 0)
        ## Only intervals left which contain zero. Try to use the widest
        ## interval.
        possiblerows = migU (:, column) >= 0;
        rowrating = magU (:, column);
        rowrating (not (possiblerows)) = -inf;
        row = find (rowrating == max (rowrating), 1);
    else
        ## There are several good choices, take the one that will hopefully
        ## not hinder the choice of further pivot elements.
        ## That is, the row with the least mig (U) > 0.
        possiblerows = sum (migU (:, column) > 0, 2);
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
y = P * y';
for i = 1 : n
    for k = 1 : n
        ## Store P * y' in U
        U {i, k} = infsup (y.inf (i, k), y.sup (i, k));
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
##         Solve L * s = inv (P) * x'

s = cell (n, m);
x = inv (P) * x';

for i = 1 : m
    s {1, i} = infsup (x.inf (1, i), x.sup (1, i)) ./ L {1, 1};
    for k = 2 : n
        suml = sumu = zeros (k, 2);
        for j = 1 : (k - 1)
            suml (j, :) = [inf(L {k, j}), inf(s {j, i})];
            sumu (j, :) = [sup(L {k, j}), sup(s {j, i})];
        endfor
        suml (k, :) = [-1, x.inf(k, i)];
        sumu (k, :) = [-1, x.sup(k, i)];
        sum = dot (infsup (suml (:, 1), sumu (:, 1)), ...
                   infsup (suml (:, 2), sumu (:, 2)));
        
        s {k, i} = -sum ./ L {k, k};
    endfor
endfor

## Step 3: Backward substitution
##         Solve U * z' = s

zt = cell (n, m);
for i = 1 : m
    zt {n, i} = s {n, i} ./ U {n, n};
    for k = (n - 1) : -1 : 1
        suml = sumu = zeros (n - k + 1, 2);
        for j = (k + 1) : n
            suml (j - k, :) = [inf(U {k, j}), inf(zt {j, i})];
            sumu (j - k, :) = [sup(U {k, j}), sup(zt {j, i})];
        endfor
        suml (n - k + 1, :) = [-1, inf(s {k, i})];
        sumu (n - k + 1, :) = [-1, sup(s {k, i})];
        sum = dot (infsup (suml (:, 1), sumu (:, 1)), ...
                   infsup (suml (:, 2), sumu (:, 2)));
        zt {k, i} = -sum ./ U {k, k};
    endfor
endfor

## Transpose z' into z
z.inf = z.sup = zeros (fliplr (size (zt)));
for i = 1 : n
    for k = 1 : m
        z.inf (k, i) = inf (zt {i, k});
        z.sup (k, i) = sup (zt {i, k});
    endfor
endfor

result = infsup (z.inf, z.sup);

endfunction