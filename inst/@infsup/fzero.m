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
## @deftypemethod  {@@infsup} {@var{X} =} fzero (@var{F}, @var{X0})
## @deftypemethodx {@@infsup} {@var{X} =} fzero (@var{F}, @var{X0}, @var{DF})
## @deftypemethodx {@@infsup} {@var{X} =} fzero (@var{F}, @var{X0}, @var{OPTIONS})
## @deftypemethodx {@@infsup} {@var{X} =} fzero (@var{F}, @var{X0}, @var{DF}, @var{OPTIONS})
## 
## Compute the enclosure of all roots of function @var{F} in interval @var{X0}.
##
## Parameters @var{F} and (possibly) @var{DF} may either be a function handle,
## inline function, or string containing the name of the function to evaluate.
##
## The function must be an interval arithmetic function.
##
## Optional parameters are the function's derivative @var{DF} and the maximum
## recursion steps @var{OPTIONS}.MaxIter (default: 200) to use.  If @var{DF} is
## given, the algorithm tries to apply the interval newton method for finding
## the roots; otherwise pure bisection is used (which is slower).
##
## The result is a column vector with one element for each root enclosure that
## has been be found.  Each root enclosure may contain more than one root and
## each root enclosure must not contain any root.  However, all numbers in
## @var{X0} that are not covered by the result are guaranteed to be no roots of
## the function.
##
## Best results can be achieved when (a) the function @var{F} does not suffer
## from the dependency problem of interval arithmetic, (b) the derivative
## @var{DF} is given, (c) the derivative is non-zero at the function's roots,
## and (d) the derivative is continuous.
##
## It is possible to use the following optimization @var{options}:
## @option{Display}, @option{MaxFunEvals}, @option{MaxIter},
## @option{OutputFcn}, @option{TolFun}, @option{TolX}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## f = @@(x) cos (x);
## df = @@(x) -sin (x);
## fzero (f, infsup ("[-10, 10]"), df)
##   @result{} ans ⊂ 6×1 interval vector
##    
##        [-7.854, -7.8539]
##       [-4.7124, -4.7123]
##       [-1.5708, -1.5707]
##         [1.5707, 1.5708]
##         [4.7123, 4.7124]
##          [7.8539, 7.854]
## sqr = @@(x) x .^ 2;
## fzero (sqr, infsup ("[Entire]"))
##   @result{} ans ⊂ [-3.2968e-161, +3.2968e-161]
## @end group
## @end example
##
## @seealso{@@infsup/fsolve, optimset}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-01

function result = fzero (f, x0, df, options)

if (nargin > 4 || nargin < 2)
    print_usage ();
    return
endif

## Set default parameters
defaultoptions = optimset (optimset, 'MaxIter', 200);
if (nargin == 2)
    df = [];
    options = defaultoptions;
elseif (nargin == 3)
    if (isstruct (df))
        options = optimset (defaultoptions, options);
        df = [];
    else
        options = defaultoptions;
    endif
else
    options = optimset (defaultoptions, options);
endif

## Check parameters
if (not (isa (x0, "infsup")))
    error ("interval:InvalidOperand", "fzero: Parameter X0 is no interval")
elseif (not (isscalar (x0)))
    error ("interval:InvalidOperand", ...
           "fzero: Parameter X0 must be a scalar / F must be univariate")
elseif (isempty (x0))
    error ("interval:InvalidOperand", ...
           "fzero: Initial interval is empty, nothing to do")
elseif (not (is_function_handle (f)) && not (ischar (f)))
    error ("interval:InvalidOperand", ...
           "fzero: Parameter F is no function handle")
elseif (not (isempty (df)) && ...
        not (is_function_handle (df)) && ...
        not (ischar (df)))
    error ("interval:InvalidOperand", ...
           "fzero: Parameter DF is not function handle")
endif

## Does not work on decorated intervals, strip decoration part
if (isa (x0, "infsupdec"))
    if (isnai (x0))
        result = x0;
        return
    endif
    x0 = intervalpart (x0);
endif

[l, u] = findroots (f, df, x0, 0, options);

result = infsup (l, u);

endfunction

## This function will perform the recursive newton / bisection steps
function [l, u] = findroots (f, df, x0, stepcount, options)

l = u = zeros (0, 1);

## Try the newton step, if derivative is known
if (not (isempty (df)))
    m = infsup (mid (x0));
    [a, b] = mulrev (feval (df, x0), feval (f, m));
    if (isempty (a) && isempty (b))
        ## Function evaluated outside of its domain
        a = x0;
    else
        a = intersect (x0, m - a);
        b = intersect (x0, m - b);
        if (isempty (a))
            [a, b] = deal (b, a);
        endif
    endif
else
    a = x0;
    b = infsup ();
endif

## Switch to bisection if the newton step did not produce two intervals
if ((eq (x0, a) || isempty (b)) && not (issingleton (a)) && not (isempty (a)))
    ## When the interval is very large, bisection at the midpoint would
    ## take “forever” to converge, because floating point numbers are not
    ## distributed evenly on the real number lane.
    ##
    ## We enumerate all floating point numbers within a with
    ## 1, 2, ... 2n and split the interval at n.
    ##
    ## When the interval is small, this algorithm will choose
    ## approximately mid (a).
    [a, b] = bisect (a);
elseif (b < a)
    ## Sort the roots in ascending order
    [a, b] = deal (b, a);
endif

for x1 = {a, b}
    x1 = x1 {1};
    
    if (strcmp (options.Display, "iter"))
        display (x1);
    endif
    
    f_x1 = feval (f, x1);
    if  (not (ismember (0, f_x1)))
        ## The interval evaluation of f over x1 proves that there are no roots
        ## or x1 is empty
        continue
    endif
    if (isentire (f_x1) || ...
        wid (f_x1) / max (realmin (), wid (x1)) < pow2 (-20))
        ## Slow convergence detected, cancel iteration soon
        options.MaxIter = options.MaxIter / 1.5;
    endif
    
    if (eq (x1, x0) || stepcount >= options.MaxIter
        || wid (x1) <= options.TolX || wid (f_x1) <= options.TolFun)
        ## Stop recursion if result is accurate enough or if no improvement
        [newl, newu] = deal (x1.inf, x1.sup);
    else
        [newl, newu] = findroots (f, df, x1, stepcount + 1, options);
    endif
    if (not (isempty (newl)))
        if (isempty (l))
            l = newl;
            u = newu;
        elseif (u (end) == newl (1))
            ## Merge intersecting intervals
            u (end) = newu (1);
            l = [l; newl(2 : end, 1)];
            u = [u; newu(2 : end, 1)];
        else
            l = [l; newl];
            u = [u; newu];
        endif
    endif
endfor

endfunction

%!test "from the documentation string";
%! f = @(x) cos (x);
%! df = @(x) -sin (x);
%! zeros = fzero (f, infsup ("[-10, 10]"), df);
%! assert (all (subset (pi * (-2.5:1:2.5)', zeros)));
%! assert (max (rad (zeros)) < 8 * eps);
%! sqr = @(x) x .^ 2;
%! zeros = fzero (sqr, infsup ("[Entire]"));
%! assert (all (subset (0, zeros)));
%! assert (max (rad (zeros)) < eps);
