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
## @documentencoding utf-8
## @deftypefn  {Function File} {@var{X} =} fzero (@var{F}, @var{X0}, @var{DF}, @var{MAXSTEPS})
## @deftypefnx {Function File} {@var{X} =} fzero (@var{F}, @var{X0}, @var{DF})
## @deftypefnx {Function File} {@var{X} =} fzero (@var{F}, @var{X0}, @var{MAXSTEPS})
## @deftypefnx {Function File} {@var{X} =} fzero (@var{F}, @var{X0})
## 
## Compute the enclosure of all roots of function @var{F} in interval @var{X0}.
##
## Parameters @var{F} and (possibly) @var{DF} may either be a function handle,
## inline function, or string containing the name of the function to evaluate.
##
## The function must be an interval arithmetic function.
##
## Optional parameters are the function's derivative @var{DF}, and the maximum
## recursion steps @var{MAXSTEPS} (default: 200) to use per root.  If @var{DF}
## is given, the algorithm tries to apply the interval newton method for
## finding the roots, otherwise pure bisection is used (which is slower).
##
## The result is a column vector with one element for each root enclosure that
## could be found.  Each root enclosure may contain more than one root.
## However, all numbers in @var{X0} that are not covered by the result are
## guaranteed to be no roots of the function.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## f = @@(x) cos (x);
## df = @@(x) -sin (x);
## fzero (f, infsup ("[-10, 10]"), df)
##   @result{} 6×1 interval vector
##    
##       [-7.8539816339744837, -7.8539816339744827]
##       [-4.7123889803846906, -4.7123889803846896]
##       [-1.5707963267948968, -1.5707963267948965]
##         [1.5707963267948965, 1.5707963267948968]
##         [4.7123889803846896, 4.7123889803846906]
##         [7.8539816339744827, 7.8539816339744837]
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-01

function result = fzero (f, x0, df, maxsteps)

if (nargin > 4 || nargin < 2)
    print_usage ();
    return
endif

## Set default parameters
if (nargin == 2)
    df = [];
    maxsteps = 200;
elseif (nargin == 3)
    if (isnumeric (df))
        maxsteps = df;
        df = [];
    else
        maxsteps = 200;
    endif
endif

## Check parameters
if (not (isa (x0, "infsup")))
    error ("fzero: Parameter X0 is no interval")
elseif (not (isscalar (x0)))
    error ("fzero: Parameter X0 must be a scalar / F must be univariate")
elseif (isempty (x0))
    error ("fzero: Initial interval is empty, nothing to do")
elseif (not (is_function_handle (f)) && not (ischar (f)))
    error ("fzero: Parameter F is no function handle")
elseif (not (isempty (df)) && ...
        not (is_function_handle (df)) && ...
        not (ischar (df)))
    error ("fzero: Parameter DF is not function handle")
elseif (not (isreal (maxsteps)) || maxsteps < 1)
    error ("fzero: Parameter MAXSTEPS must be a positive real number")
endif

## Does not work on decorated intervals, strip decoration part
if (isa (x0, "infsupdec"))
    if (isnai (x0))
        result = x0;
        return
    endif
    x0 = intervalpart (x0);
endif

[l, u] = findroots (f, df, x0, 0, maxsteps);

result = infsup (l, u);

endfunction

## This function will perform the recursive newton / bisection steps
function [l, u] = findroots (f, df, x0, stepcount, maxsteps)

l = u = zeros (0, 1);

## Try the newton step, if derivative is known
if (not (isempty (df)))
    m = infsup (mid (x0));
    [u, v] = mulrevtopair (feval (df, x0), feval (f, m));
    u = x0 & (m - u);
    v = x0 & (m - v);
else
    u = x0;
    v = infsup ();
endif

## Switch to bisection if the newton step did not produce two intervals
if ((eq (x0, u) || isempty (v)) && not (issingleton (u)))
    if (interior (0, u))
        m = 0;
    else
        ## When the interval is very large, bisection at the midpoint would
        ## take “forever” to converge, because floating point numbers are not
        ## distributed evenly on the real number lane.
        ##
        ## We enumerate all floating point numbers between u.inf and u.sup with
        ## 1, 2, ... 2n and split the interval at number n.
        s = sign (u);
        s = inf ((s & 1) | (s & -1));
        m = s .* min (realmax (), pow2 (max (-1074, mid (log2 (abs (u))))));
        if (not (ismember (m, u)))
            ## Fallback, if computation fails
            m = mid (u);
        endif
    endif
    v = infsup (m, sup (u));
    u = infsup (inf (u), m);
elseif (v < u)
    ## Sort the roots in ascending order
    [u, v] = deal (v, u);
endif

for x1 = {u, v}
    x1 = x1 {1};
    if (isempty (x1) || not (ismember (0, feval (f, x1))))
        ## The interval evaluation of f over x1 proves that there are no roots
        continue
    endif
    
    if (eq (x1, x0) || stepcount >= maxsteps)
        ## Stop recursion if result is accurate enough or if no improvement
        [newl, newu] = deal (x1.inf, x1.sup);
    else
        [newl, newu] = findroots (f, df, x1, stepcount + 1, maxsteps);
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
