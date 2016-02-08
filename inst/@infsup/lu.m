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
## @deftypemethod {@@infsup} {[@var{L}, @var{U}] = } lu (@var{A})
## @deftypemethodx {@@infsup} {[@var{L}, @var{U}, @var{P}] = } lu (@var{A})
## 
## Compute the LU decomposition of @var{A}.
##
## @var{A} will be a subset of @var{L} * @var{U}.
##
## The result is returned in a permuted form, according to the optional return
## value @var{P}.
##
## Accuracy: The result is a valid enclosure.
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function [L, U, P] = lu (x)

if (nargin ~= 1)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

if (isscalar (x))
    L = P = eye (size (x));
    U = x;
    return
endif

## x must be square
assert (size (x.inf, 1) == size (x.inf, 2), ...
        "operator \: nonconformant arguments, X is not square");

n = rows (x.inf);

if (nargout < 3)
    P = eye (n);
else
    ## Compute P such that the computation of L below will not fail because of
    ## division by zero.  P * x should not have zeros in its main diagonal.
    ## The computation of P is a greedy heuristic algorithm, which I developed
    ## for the implementation of this function.
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
            ## We weight the rating in the columns with few mig (U) > 0 in
            ## order to prevent problems during the choice of pivots in the
            ## near future.
            rowrating += 0.5 * sum (migU (:, possiblecolumns) > 0, 2);
            rowrating (not (possiblerows)) = inf;
            row = find (rowrating == min (rowrating), 1);
        endif
        
        # assert (0 <= migU (row, column) && migU (row, column) < inf);
    
        P (row, column) = 1;
        
        ## In mig (U), for the choice of further pivots:
        ##  - mark used columns with inf
        ##  - mark used rows in unused columns with -inf
        migU (row, :) -= inf;
        migU (isnan (migU)) = inf;
        migU (:, column) = inf;
    endfor
endif

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

## Cleanup U
U.inf = triu (U.inf);
U.sup = triu (U.sup);

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

%!test
%! [l, u] = lu (infsup (magic (3)));
%! assert (l == infsup ({1, 0, 0; .375, 1, 0; .5, "68/37", 1}));, ...
%! assert (subset (u, infsup ({8, 1, 6; 0, 4.625, 4.75; 0, 0, "-0x1.3759F2298375Bp3"}, ...
%!                            {8, 1, 6; 0, 4.625, 4.75; 0, 0, "-0x1.3759F22983759p3"})));
%! A = magic (3);
%! A ([1, 5, 9]) = 0;
%! [l, u, p] = lu (infsup (A));
%! assert (p, [0, 0, 1; 1, 0, 0; 0, 1, 0]);
%! assert (l == infsup ({1, 0, 0; "4/3", 1, 0; 0, "1/9", 1}));
%! assert (subset (u, infsup ({3, 0, 7; 0, 9, "-0x1.2AAAAAAAAAAACp3"; 0, 0, "0x1.C25ED097B425Ep2"}, ...
%!                            {3, 0, 7; 0, 9, "-0x1.2AAAAAAAAAAAAp3"; 0, 0, "0x1.C25ED097B426p2"})));
