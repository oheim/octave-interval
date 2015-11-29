## Copyright 2015 Oliver Heimlich
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
## @deftypefn  {Function File} {@var{X} =} fsolve (@var{F})
## @deftypefnx {Function File} {@var{X} =} fsolve (@var{F}, @var{X0})
## @deftypefnx {Function File} {@var{X} =} fsolve (@var{F}, @var{X0}, @var{Y})
## @deftypefnx {Function File} {@var{X} =} fsolve (@dots{}, @var{OPTIONS})
## @deftypefnx {Function File} {[@var{X}, @var{X_PAVING}, @var{X_INNER_IDX}] =} fsolve (@dots{})
## 
## Compute the preimage of the set @var{Y} under function @var{F}.
##
## Parameter @var{Y} is optional and without it solve
## @code{@var{F}(@var{x}) = 0} for @var{x} ∈ @var{X0}.  Without a starting box
## @var{X0} the function is assumed to be univariate and the solution is
## searched among all real numbers.
##
## The function must be an interval arithmetic function and may be
## multivariate, that is, @var{X0} and @var{Y} may be vectors or matrices of
## intervals.  The computational complexity largely depends on the dimension of
## @var{X0}.
##
## Return value @var{X} is an interval enclosure of
## @code{@{@var{x} ∈ @var{X0} | @var{F}(@var{x}) ∈ @var{Y}@}}.  The optional
## return value @var{X_PAVING} is a cell array of non-overlapping intervals,
## which form a more detailed enclosure for the preimage of @var{Y}.  An index
## vector @var{X_INNER_IDX} indicates the components of @var{X_PAVING}, which
## are guaranteed to be subsets of the preimage of @var{Y}.
##
## The function uses the set inversion via interval arithmetic (SIVIA)
## algorithm.  That is, @var{X} is bisected until @var{F}(@var{X}) is either
## a subset of @var{Y} or until they are disjoint.
##
## Note on performance: The bisection method is a brute-force approach to
## exhaust the function's domain and requires a lot of function evaluations.
## It is highly recommended to vectorize the function @var{F} to speed up
## computation.  If @var{Y} is a vector and @var{F} accepts @var{n} input
## arguments, where @var{n} is the number of elements of @var{X0}, this
## function will try to use vectorized function evaluation for @var{F}.  If
## vectorized function evaluation is used, @var{X_PAVING} will be returned as
## vector with an @var{x} enclosure in each column (or row) and
## @var{X_INNER_IDX} will then be an row (or column) index vector.
##
## It is possible to use the following optimization @var{options}:
## @option{MaxFunEvals}, @option{MaxIter}, @option{TolFun}, @option{TolX}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## fsolve (@@cos, infsup(0, "pi"))
##   @result{} ans ⊂ [1.5646, 1.5708]
## @end group
## @end example
##
## @example
## @group
## # Solve x1 ^ 2 + x2 ^ 2 = 1 for -3 ≤ x1, x2 ≤ 3,
## # the exact solution is a unit circle
## x = fsolve (@@hypot, infsup ([-3; -3], [3; 3]), 1)
##   @result{} x ⊂ 2×1 interval vector
##
##       [-1.0002, +1.0002]
##       [-1.0002, +1.0002]
##
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-11-28

function [x, x_paving, x_inner_idx] = fsolve (f, x0, y, options)

## Set default parameters
defaultoptions = optimset (optimset, ...
                           'MaxIter',    100, ...
                           'MaxFunEval', 3000, ...
                           'TolX',       1e-2, ...
                           'TolFun',     1e-2);
switch (nargin)
    case 1
        x0 = infsup (-inf, inf);
        y = infsup (0);
        options = defaultoptions;
    case 2
        y = infsup (0);
        if (isstruct (x0))
            options = optimset (defaultoptions, x0);
            x0 = infsup (-inf, inf);
        else
            options = defaultoptions;
        endif
    case 3
        if (isstruct (y))
            options = optimset (defaultoptions, y);
            y = infsup (0);
        else
            options = defaultoptions;
        endif
    case 4
        options = optimset (defaultoptions, options);
    otherwise
        print_usage ();
        return
endswitch

## Convert x0 and y to intervals
if (not (isa (x0, "infsup")))
    if (isa (y, "infsupdec"))
        x0 = infsupdec (x0);
    else
        x0 = infsup (x0);
    endif
endif
if (not (isa (y, "infsup")))
    if (isa (x0, "infsupdec"))
        y = infsupdec (y);
    else
        y = infsup (y);
    endif
endif

## Check parameters
if (isempty (x0) || isempty (y) || numel (x0) == 0 || numel (y) == 0)
    error ("interval:InvalidOperand", ...
           "fsolve: Initial interval is empty, nothing to do")
elseif (not (is_function_handle (f)) && not (ischar (f)))
    error ("interval:InvalidOperand", ...
           "fsolve: Parameter F is no function handle")
endif

## Strip decoration part
if (isa (x0, "infsupdec"))
    if (isnai (x0))
        x = x0;
        x_paving = {x0};
        x_inner_idx = false;
        return
    endif
    x0 = intervalpart (x0);
endif
if (isa (y, "infsupdec"))
    if (isnai (y))
        x = y;
        x_paving = {y};
        x_inner_idx = false;
        return
    endif
    y = intervalpart (y);
endif

warning ("off", "interval:ImplicitPromote", "local");

## Try to vectorize function evaluation
if (isvector (y))
    try
        f_argn = nargin (f);
    catch
        ## nargin doesn't work for built-in functions, which happen to agree
        ## with infsup methods
        f_argn = 0;
    end_try_catch
    if (f_argn != 1 || numel (x0) == 1)
        try
            [x, x_paving, x_inner_idx] = vectorized (f, x0, y, options);
            return
        catch
            ## Unable to use vectorized evaluation, fall back to cellfun usage
            warning ('interval:fsolve:vectorize', lasterr)
            warning ('interval:fsolve:vectorize', ...
                     ['fsolve: unable to use vectorization, ' ...
                      'falling back to slow algorithm'])
        end_try_catch
    endif
endif

x = empty (size (x0));
x_paving = {};
x_inner_idx = false (0);
queue = {x0};
x_scalar = isscalar (x0);

## Test functions
verify_subset = @(fval) all (all (subset (fval, y)));
verify_disjoint = @(fval) any (any (disjoint (fval, y)));
max_wid = @(interval) max (max (wid (interval)));

## Utility functions for bisection
if (x_scalar)
    bisect_coord = {1};
    exchange_coordinate = @(interval, coord, l, u) infsup (l, u);
else
    largest_coordinate = @(interval, max_wid) ...
                         find (wid (interval) == max_wid, 1);
    exchange_coordinate = @replace_coordinate;
endif

while (not (isempty (queue)))
    ## Evaluate f(x)
    fval = cellfun (f, queue, "UniformOutput", false);
    options.MaxFunEvals -= numel (queue);
    options.MaxIter --;
    ## Check whether x is outside of the preimage of y
    ## or x is inside the preimage of y
    is_outside = cellfun (verify_disjoint, fval);
    is_inside = cellfun (verify_subset, fval) & not (is_outside);
    ## Store the verified subsets of the preimage of y and continue only on
    ## elements that are not verified
    x = hull (x, queue(is_inside){:});
    x_paving = vertcat (x_paving, queue(is_inside));
    x_inner_idx = vertcat (x_inner_idx, true (sum (is_inside), 1));
    queue = queue(not (is_inside | is_outside));
    ## Stop after MaxIter or MaxFunEvals
    if (options.MaxIter <= 0 || options.MaxFunEvals <= 0)
        x = hull (x, queue{:});
        x_paving = vertcat (x_paving, queue);
        x_inner_idx = vertcat (x_inner_idx, false (numel (queue), 1));
        break
    endif
    ## Stop iteration for small intervals
    if (not (isempty (options.TolFun)))
        fval = fval(not (is_inside | is_outside));
        widths = cellfun (max_wid, fval);
        is_small = widths < options.TolFun;
    else
        is_small = false (size (queue));
    endif
    widths = cellfun (max_wid, queue);
    is_small = is_small | (widths < options.TolX);
    x = hull (x, queue(is_small){:});
    x_paving = vertcat (x_paving, queue(is_small));
    x_inner_idx = vertcat (x_inner_idx, false (sum (is_small), 1));
    queue = queue(not (is_small));
    widths = widths(not (is_small));
    ## Bisect remaining intervals at the largest coordinate.
    ##
    ## Since the bisect function is the most costly, we want to call it only
    ## once. Thus, we extract the largest coordinate from each interval matrix
    ## inside queue and combine them into an interval vector [l_coord, u_coord]
    ## with the length of queue. We call the bisect function on this vector,
    ## which bisects each interval component and produces vectors
    ## [l_coord, m_coord] and [m_coord, u_coord]. These are used to replace the
    ## largest coordinate from each original interval matrix.
    if (x_scalar)
        [l_coord, u_coord] = ...
            cellfun (@(interval) ...
                     deal (interval.inf, interval.sup), ...
                     queue);
    else
        bisect_coord = cellfun (largest_coordinate, ...
                                queue, num2cell (widths), ...
                                "UniformOutput", false);
        [l_coord, u_coord] = ...
            cellfun (@(interval, coord) ...
                     deal (interval.inf(coord), interval.sup(coord)), ...
                     queue, bisect_coord);
    endif
    m_coord = mid (infsup (l_coord, u_coord));
    l_coord = num2cell (l_coord);
    m_coord = num2cell (m_coord);
    u_coord = num2cell (u_coord);
    queue = vertcat (...
        cellfun (exchange_coordinate, ...
                 queue, bisect_coord, l_coord, m_coord, ...
                 "UniformOutput", false), ...
        cellfun (exchange_coordinate, ...
                 queue, bisect_coord, m_coord, u_coord, ...
                 "UniformOutput", false));
    ## Short-circuit if no paving must be computed and remaining intervals
    ## are subsets of the already computed interval enclosure.
    if (nargout < 2)
        x_bare = intervalpart (x);
        queue = queue(not (cellfun (@(q) all (all (subset (q, x_bare))), ...
                                    queue)));
    endif
endwhile

x = intervalpart (x);

endfunction

function interval = replace_coordinate (interval, coord, l, u)
interval.inf(coord) = l;
interval.sup(coord) = u;
endfunction

## Variant of above algorithm, which utilized vectorized evaluation of f
function [x, x_paving, x_inner_idx] = vectorized (f, x0, y, options)

if (iscolumn (y))
    x0 = vec (x0);
    data_dim = 1;
    cat_dim = 2;
else
    assert (isrow (y));
    x0 = transpose (vec (x0));
    data_dim = 2;
    cat_dim = 1;
endif

x = intervalpart (empty (size (x0)));
s = size (x0);
s(cat_dim) = 0;
x_paving = infsup (zeros (s));
x_inner_idx = false (0);
queue = x0;
x_scalar = isscalar (x0);

## Test functions
verify_subset = @(fval) all (subset (fval, y), data_dim);
verify_disjoint = @(fval) any (disjoint (fval, y), data_dim);

## Utility functions for indexing the queue
idx.type = '()';
idx.subs = {:, :};

while (not (isempty (queue.inf)))
    ## Evaluate f(x)
    l_args = num2cell (queue.inf, cat_dim);
    u_args = num2cell (queue.sup, cat_dim);
    f_args = cellfun (@(l, u) infsup (l, u), ...
                      l_args, u_args, ...
                      "UniformOutput", false);
    fval = feval (f, f_args{:});
    options.MaxFunEvals --;
    options.MaxIter --;
    ## Check whether x is outside of the preimage of y
    ## or x is inside the preimage of y
    is_outside = verify_disjoint (fval);
    is_inside = verify_subset (fval) & not (is_outside);
    ## Store the verified subsets of the preimage of y and continue only on
    ## elements that are not verified
    idx.subs{cat_dim} = is_inside;
    queue_inside = subsref (queue, idx);
    x = union (cat (cat_dim, x, queue_inside), [], cat_dim);
    x_paving = cat (cat_dim, x_paving, queue_inside);
    x_inner_idx = cat (cat_dim, x_inner_idx, is_inside(is_inside));
    idx.subs{cat_dim} = not (is_inside | is_outside);
    queue = subsref (queue, idx);
    ## Stop after MaxIter or MaxFunEvals
    if (options.MaxIter <= 0 || options.MaxFunEvals <= 0)
        x = union (cat (cat_dim, x, queue), [], cat_dim);
        x_paving = cat (cat_dim, x_paving, queue);
        s = size (queue);
        s(data_dim) = 1
        x_inner_idx = cat (cat_dim, x_inner_idx, false (s));
        break
    endif
    ## Stop iteration for small intervals
    if (not (isempty (options.TolFun)))
        idx.subs{cat_dim} = not (is_inside | is_outside);
        fval = subsref (fval, idx);
        widths = max (wid (fval), [], data_dim);
        is_small = widths < options.TolFun;
    else
        s = size (queue);
        s(data_dim) = 1
        is_small = false (s);
    endif
    [widths, bisect_coord] = max (wid (queue), [], data_dim);
    is_small = is_small | (widths < options.TolX);
    idx.subs{cat_dim} = is_small;
    queue_is_small = subsref (queue, idx);
    x = union (cat (cat_dim, x, queue_is_small), [], cat_dim);
    x_paving = cat (cat_dim, x_paving, queue_is_small);
    x_inner_idx = cat (cat_dim, x_inner_idx, not (is_small(is_small)));
    idx.subs{cat_dim} = not (is_small);
    queue = subsref (queue, idx);
    widths = widths(not (is_small));
    bisect_coord = bisect_coord(not (is_small));
    ## Bisect remaining intervals at the largest coordinate.
    x1 = x2 = queue;
    if (x_scalar)
        coord = queue;
    else
        coord_idx.type = "()";
        coord_idx.subs = {:, :};
        coord_idx.subs{data_dim} = bisect_coord;
        coord = subsref (queue, coord_idx);
    endif
    m_coord = mid (coord);
    if (x_scalar)
        x1.sup = x2.inf = m_coord;
    else
        x1.sup = subsasgn (x1.sup, coord_idx, m_coord);
        x2.inf = subsasgn (x2.inf, coord_idx, m_coord);
    endif
    queue = cat (cat_dim, x1, x2);
    ## Short-circuit if no paving must be computed and remaining intervals
    ## are subsets of the already computed interval enclosure.
    if (nargout < 2)
        idx.subs{cat_dim} = all (subset (queue, x), data_dim);
        queue = subsref (queue, idx);
    endif
endwhile

endfunction

%!assert (subset (sqrt (infsup (2)), fsolve (@sqr, infsup (0, 3), 2)));

%!demo
%! clf
%! hold on
%! grid on
%! axis equal
%! shade = [238 232 213] / 255;
%! blue = [38 139 210] / 255;
%! cyan = [42 161 152] / 255;
%! red = [220 50 47] / 255;
%! # 2D ring
%! f = @(x, y) hypot (x, y);
%! [outer, paving, inner] = fsolve (f, infsup ([-3; -3], [3; 3]), ...
%!                                  infsup (0.5, 2), ...
%!                                  optimset ('TolX', 0.1));
%! # Plot the outer interval enclosure
%! plot (outer(1), outer(2), shade)
%! # Plot the guaranteed inner interval enclosures of the preimage
%! plot (paving(1, inner), paving(2, inner), blue, cyan);
%! # Plot the boundary of the preimage
%! plot (paving(1, not (inner)), paving(2, not (inner)), red);

%!demo
%! clf
%! hold on
%! grid on
%! shade = [238 232 213] / 255;
%! blue = [38 139 210] / 255;
%! # This 3D ring is difficult to approximate with interval boxes
%! f = @(x, y, z) hypot (hypot (x, y) - 2, z);
%! [~, paving, inner] = fsolve (f, infsup ([-4; -4; -2], [4; 4; 2]), ...
%!                                 infsup (0, 0.5), ...
%!                                 optimset ('TolX', 0.2));
%! plot3 (paving(1, not (inner)), ...
%!        paving(2, not (inner)), ...
%!        paving(3, not (inner)), shade, blue);
%! view (50, 60)
