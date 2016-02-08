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
## @documentencoding utf-8
## @deftypemethod {@@infsup} {@var{X} =} fminsearch (@var{f}, @var{X0})
## @deftypemethodx {@@infsup} {[@var{X}, @var{FVAL}] =} fminsearch (@var{f}, @var{X0}, @var{options})
##
## Minimize the function @var{f} over the interval box @var{X0} and return
## rigorous bounds.
##
## The function @var{f} may be multivariate, that is, the interval box @var{X0}
## may be a vector or matrix of intervals.  The output of the function must be
## scalar.
##
## The rigorous bounds on @var{FVAL} satisfy 0 ≤ min @{f (@var{x}) |
## @var{x} ∈ @var{X0}@} - inf (@var{FVAL}) ≤ 1e-4 by default.  Different
## accuracy requirements may be defined using @var{options}.TolFun.
##
## @example
## @group
## [x, fval] = fminsearch (@@cos, infsup ("[0, 4]"))
##   @result{}
##     x ⊂ [3.114, 3.1858]
##     fval ⊂ [-1, -0.99996]
## @end group
## @end example
##
## During each iteration the interval is bisected at its widest coordinate
## until the desired accuracy has been reached.
##
## @example
## @group
## f = @@(x) x(1) .^ 2 - x(2) .^ 2;
## [x, fval] = fminsearch (f, infsup ("[-1, 1] [-1, 1]"))
##   @result{}
##     x ⊂ 1×2 interval vector
##
##        [7.8828e-11, 8.8786e-06]   [0.99991, 1]
##
##     fval ⊂ [-1, -0.99991]
## @end group
## @end example
##
## Note that the algorithm tries to minimize @var{FVAL} and the returned
## value for @var{X} need not contain the minimum value of the function over
## @var{X0}; the value @var{X} is just “close” to one of possibly several
## places where the minimum occurs, that is, hull (f (@var{X})) overlaps
## [@var{M}-ε, @var{M}+ε], where @var{M} is the actual minimum of the
## function f over @var{X0} and ε equals @var{options}.TolFun.  Also, it holds
## @var{M} ∈ @var{FVAL}, but in general it does @emph{not} hold
## f (@var{X}) ⊆ @var{FVAL}.
##
## It is possible to use the following optimization @var{options}:
## @option{Display}, @option{MaxFunEvals}, @option{MaxIter},
## @option{OutputFcn}, @option{TolFun}, @option{TolX}.
##
## @example
## @group
## f = @@(x) -sin (hypot (x(1), x(2))) / hypot (x(1), x(2));
## [x, fval] = fminsearch (f, infsup ("[-1, 1] [-1, 1]"), ...
##                         optimset ('MaxIter', 20))
##   @result{}
##     x ⊂ 1×2 interval vector
##
##        [0, 1.9763e-323]   [0, 1.9763e-323]
##
##     fval ⊂ [-Inf, -0.99999]
## @end group
## @end example
##
## The function utilizes the Skelboe-Moore algorithm and has been implemented
## after Algorithm 6.1 in R. E. Moore, R. B. Kearfott, and M. J. Cloud.  2009.
## Introduction to Interval Analysis.  Society for Industrial and Applied
## Mathematics.
##
## @seealso{optimset}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-09-18

function [X, FVAL, iter] = fminsearch (f, X, options)

if (nargin < 2)
    print_usage ();
    return
endif

if (not (is_function_handle (f)) && not (ischar (f)))
    error ("interval:InvalidOperand", ...
           "fminsearch: Parameter f is no function handle")
elseif (not (isa (X, "infsup")))
    error ("interval:InvalidOperand", ...
           "fminsearch: Parameter X0 is no interval")
endif

defaultoptions = optimset (optimset, 'TolFun', 1e-4);
if (nargin < 3)
    options = defaultoptions;
else
    options = optimset (defaultoptions, options);
endif

displayiter = strcmp (options.Display, "iter");

## 1 Rigorous upper bound on the minimum of f over X
fmX = feval (f, infsup (mid (X)));
if (not (isa (fmX, "infsup")) || not (isscalar (fmX)))
    error ("interval:InvalidOperand", ...
           "fminsearch: Function f does not return scalar intervals")
endif
if (isempty (fmX))
    f_ub = inf;
else
    f_ub = sup (fmX);
endif

## 3 Initialize queues
## C: Completed boxes where accuracy has been reached (it suffices to store a
##    single element, because this function doesn't return all candidates)
## L: Boxes where accuracy has not been reached yet
L.X = C.X = {};
L.fX = C.fX = infsup ([]);

iter = 0;
feval_count = 1;
cancel_algorithm = false ();
idx.type = "()";
while (true)
    iter ++;
    
    if (displayiter)
        display (X);
    endif
    
    ## 4 Bisect X at the coordinate i with the widest interval
    X1 = X2 = X;
    [~, i] = max (vec (wid (X)));
    idx.subs = {i};
    [pt1, pt2] = bisect (subsref (X, idx));
    X1 = subsasgn (X1, idx, pt1);
    X2 = subsasgn (X2, idx, pt2);
    
    if (not (isempty (options.OutputFcn)))
        feval (options.OutputFcn, X1);
        feval (options.OutputFcn, X2);
    endif    
    
    ## 5 Improve upper bound
    fmX1 = feval (f, infsup (mid (X1)));
    if (not (isempty (fmX1)))
        f_ub = min (f_ub, sup (fmX1));
    endif
    fmX2 = feval (f, infsup (mid (X2)));
    if (not (isempty (fmX2)))
        f_ub = min (f_ub, sup (fmX2));
    endif
    
    ## 6 Quit current X box if accuracy has been reached
    f1 = feval (f, X1);
    f2 = feval (f, X2);
    feval_count += 4;
    
    cancel_algorithm = feval_count >= options.MaxFunEvals || ...
                       iter >= options.MaxIter || ...
                       f_ub <= -realmax ();
    
    if (min (f_ub, max (sup (f1), sup (f2))) ...
                 - min (inf (f1), inf (f2)) < options.TolFun ...
        || max (max (wid (X1))) < options.TolX ...
        || cancel_algorithm)
        ## Accuracy has been reached for X1 and X2
        C = merge_candidates (C, X1, f1);
        C = merge_candidates (C, X2, f2);
    else
        ## Put intervals into work queue
        if (inf (f1) < f_ub)
            L = insert_ordered_list (L, X1, f1);
        endif
        if (inf (f2) < f_ub)
            L = insert_ordered_list (L, X2, f2);
        endif
    endif
    
    ## More refinement to do on other boxes?
    if (isempty (L.X) || cancel_algorithm)
        break
    endif
    ## (i) Use next item from L
    [L, X, fX] = pop_ordered_list (L);
    ## (ii) Check whether improvement is still possible
    if (inf (fX) > f_ub)
        break
    endif
endwhile

assert (not (isempty (C.X)));

[C, X, FVAL] = pop_ordered_list (C);
if (isfinite (f_ub))
    FVAL = intersect (FVAL, infsup (-inf, f_ub));
endif

if (any (strcmp (options.Display, {"iter", "final"})) || ...
    (cancel_algorithm && strcmp (options.Display, "notify")))
    printf ('\nTarget accuracy has%s been reached after %d step(s)\n', ...
            ' not'(1:end * cancel_algorithm), ...
            iter);
    display (X);
    display (FVAL);
endif

endfunction

function candidate = merge_candidates (candidate, X, fX)
    if (isempty (candidate.X) || inf (fX) < inf (candidate.fX))
        candidate.X = {X};
        candidate.fX = fX;
    endif
endfunction

function list = insert_ordered_list (list, X, fX)
    position = find (inf (list.fX) >= inf (fX), 1);
    if (isempty (position))
        list.fX = vertcat (list.fX, fX);
        list.X  = vertcat (list.X, {X});
    elseif (position == 1)
        list.fX = vertcat (fX, list.fX);
        list.X  = vertcat ({X}, list.X);
    else
        idx1.type = idx2.type = "()";
        idx1.subs = {1:(position - 1)};
        idx2.subs = {position:numel(list.X)};
        list.fX = vertcat (subsref (list.fX, idx1), ...
                           fX, ...
                           subsref (list.fX, idx2));
        idx.type = "{}";
        list.X = vertcat (subsref (list.X, idx1), ...
                          {X}, ...
                          subsref (list.X, idx2));
    endif
endfunction

function [list, X, fX] = pop_ordered_list (list)
    X = list.X {1};
    idx.type = "()";
    if (nargout >= 3)
        idx.subs = {1};
        fX = subsref (list.fX, idx);
    endif
    if (numel (list.X) == 1)
        list.fX = infsup ([]);
        list.X = {};
    else
        idx.subs = {2:numel(list.X)};
        list.fX = subsref (list.fX, idx);
        list.X = subsref (list.X, idx);
    endif
endfunction

%!test
%!  sqr = @(x) x .^ 2;
%!  [x, y] = fminsearch (sqr, infsup (-inf, inf));
%!  assert (y == 0);

%!demo
%!  clf
%!  hold on
%!  draw = @(x) plot (x(1), x(2), [238 232 213]/255, [88 110 117]/255);
%!  f = @(x) (x(1) - 2) .^ 2 - x(2) .^ 2;
%!  fminsearch (f, infsup ("[1, 3] [0, 1]"), ...
%!              optimset ('OutputFcn', draw));
%!  hold off
