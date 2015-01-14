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
## @deftypefn {Interval Function} {} dot (@var{X}, @var{Y})
## @deftypefnx {Interval Function} {} dot (@var{X}, @var{Y}, @var{DIM})
## 
## Compute the dot product of two interval vectors.  If @var{X} and @var{Y} are
## matrices, calculate the dot products along the first non-singleton
## dimension.  If the optional argument @var{DIM} is given, calculate the dot
## products along this dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## dot ([infsup(1), 2, 3], [infsup(2), 3, 4])
##   @result{} [20]
## @end group
## @group
## dot (infsup ([realmax; realmin; realmax]), [1; -1; -1], 1)
##   @result{} [-2.2250738585072014e-308, -2.2250738585072013e-308]
## @end group
## @end example
## @seealso{plus, sum, times, sumabs, sumsquare}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function result = dot (x, y, dim)

if (nargin < 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif
if (nargin < 3)
    if (isvector (x.inf) && isvector (y.inf))
        ## Align vectors along common dimension
        dim = 1;
        x.inf = vec (x.inf, dim);
        x.sup = vec (x.sup, dim);
        y.inf = vec (y.inf, dim);
        y.sup = vec (y.sup, dim);
    else
        ## Try to find non-singleton dimension
        dim = find (max (size (x.inf), size (y.inf)) > 1, 1);
        if (isempty (dim))
            dim = 1;
        endif
    endif
endif

## Empty input -> empty result
if (isempty (x.inf) || isempty (y.inf))
    isexact = true ();
    result = infsup (zeros (min (size (x.inf), size (y.inf))));
    return
endif

## Only the sizes of non-singleton dimensions must agree. Singleton dimensions
## do broadcast (independent of parameter dim).
if ((min (size (x.inf, 1), size (y.inf, 1)) > 1 && ...
        size (x.inf, 1) ~= size (y.inf, 1)) || ...
    (min (size (x.inf, 2), size (y.inf, 2)) > 1 && ...
        size (x.inf, 2) ~= size (y.inf, 2)))
    error ("dot: sizes of X and Y must match")
endif

resultsize = max (size (x.inf), size (y.inf));
resultsize (dim) = 1;

l = u = zeros (resultsize);

for n = 1 : numel (l)
    idx.type = "()";
    idx.subs = cell (1, 2);
    idx.subs {dim} = ":";
    idx.subs {3 - dim} = n;

    ## Select current vector in matrix or broadcast scalars and vectors.
    if (size (x.inf, 3 - dim) == 1)
        vector.x = x;
    else
        vector.x = subsref (x, idx);
    endif
    if (size (y.inf, 3 - dim) == 1)
        vector.y = y;
    else
        vector.y = subsref (y, idx);
    endif
    
    if (max (isempty (vector.x)) || max (isempty (vector.y)))
        ## One of the intervals is empty
        l (n) = inf;
        u (n) = -inf;
    else
        [l(n), u(n)] = vectordot (vector.x, vector.y);
    endif
endfor

result = infsup (l, u);

endfunction

## Dot product of two interval vectors; or one vector and one scalar.
## Accuracy is tightest. No interval must be empty.
function [l, u] = vectordot (x, y)

if (isscalar (x.inf) && isscalar (y.inf))
    ## Short-circuit: scalar × scalar
    z = x .* y;
    l = z.inf;
    u = z.sup;
    return
endif

## Resize, if scalar × vector
if (isscalar (x.inf) || isscalar (y.inf))
    x.inf = ones (size (y.inf)) .* x.inf;
    x.sup = ones (size (y.inf)) .* x.sup;
    y.inf = ones (size (x.inf)) .* y.inf;
    y.sup = ones (size (x.inf)) .* y.sup;
endif

x = vec (x);
y = vec (y);

## [0] × anything = [0] × [0]
## [Entire] × anything but [0] = [Entire] × [Entire]
## This prevents the cases where 0 × inf would produce NaNs.
entireproduct = isentire (x) | isentire (y);
zeroproduct = (x.inf == 0 & x.sup == 0) | (y.inf == 0 & y.sup == 0);
x.inf (entireproduct) = y.inf (entireproduct) = -inf;
x.sup (entireproduct) = y.sup (entireproduct) = inf;
x.inf (zeroproduct) = x.sup (zeroproduct) = ...
    y.inf (zeroproduct) = y.sup (zeroproduct) = 0;

## Partitionize the vectors, the interval dot product can be computed within
## each partition using BLAS routines on the interval boundaries with directed
## rounding.
## (cf. the times function on intervals)
q1 = y.sup <= 0 & x.sup <= 0;
q2 = y.sup <= 0 & x.inf >= 0 & x.sup > 0;
q3 = y.sup <= 0 & x.inf < 0 & x.sup > 0;
q4 = y.inf >= 0 & y.sup > 0 & x.sup <= 0;
q5 = y.inf >= 0 & y.sup > 0 & x.inf >= 0 & x.sup > 0;
q6 = y.inf >= 0 & y.sup > 0 & x.inf < 0 & x.sup > 0;
q7 = y.inf < 0 & y.sup > 0 & x.sup <= 0;
q8 = y.inf < 0 & y.sup > 0 & x.inf >= 0 & x.sup > 0;
q9 = y.inf < 0 & y.sup > 0 & x.inf < 0 & x.sup > 0;
a = b = zeros (size (x.inf));
## FIXME compare product size with higher accuracy?
a (q9) = mpfr_function_d ('times', .5, x.inf (q9), y.sup (q9));
b (q9) = mpfr_function_d ('times', .5, x.sup (q9), y.inf (q9));
q9_1 = q9 & (a <= b);
q9_2 = q9 & (a > b);

## Prepare Factors for dot product of lower boundary
l1 = x.inf;
l2 = y.inf;
l1 (q1) = x.sup (q1);
l2 (q1) = y.sup (q1);
l1 (q2) = x.sup (q2);
#l2 (q2) = y.inf (q2);
l1 (q3) = x.sup (q3);
#l2 (q3) = y.inf (q3);
#l1 (q4) = x.inf (q4);
l2 (q4) = y.sup (q4);
#l1 (q5) = x.inf (q5);
#l2 (q5) = y.inf (q5);
#l1 (q6) = x.inf (q6);
l2 (q6) = y.sup (q6);
#l1 (q7) = x.inf (q7);
l2 (q7) = y.sup (q7);
l1 (q8) = x.sup (q8);
#l2 (q8) = y.inf (q8);
#l1 (q9_1) = x.inf (q9_1);
l2 (q9_1) = y.sup (q9_1);
l1 (q9_2) = x.sup (q9_2);
#l2 (q9_2) = y.inf (q9_2);

## Prepare Factors for dot product of upper boundary
u1 = x.inf;
u2 = y.inf;
#u1 (q1) = x.inf (q1);
#u2 (q1) = y.inf (q1);
#u1 (q2) = x.inf (q2);
u2 (q2) = y.sup (q2);
#u1 (q3) = x.inf (q3);
#u2 (q3) = y.inf (q3);
u1 (q4) = x.sup (q4);
#u2 (q4) = y.inf (q4);
u1 (q5) = x.sup (q5);
u2 (q5) = y.sup (q5);
u1 (q6) = x.sup (q6);
u2 (q6) = y.sup (q6);
#u1 (q7) = x.inf (q7);
#u2 (q7) = y.inf (q7);
u1 (q8) = x.sup (q8);
u2 (q8) = y.sup (q8);
u1 (q9_1) = x.sup (q9_1);
u2 (q9_1) = y.sup (q9_1);
#u1 (q9_2) = x.inf (q9_2);
#u2 (q9_2) = y.inf (q9_2);

l = mpfr_vector_dot_d (-inf, l1, l2);
u = mpfr_vector_dot_d (+inf, u1, u2);

endfunction

%!test "matrix × matrix";
%! assert (dot (infsup (magic (3)), magic (3)) == [89, 107, 89]);
%! assert (dot (infsup (magic (3)), magic (3), 1) == [89, 107, 89]);
%! assert (dot (infsup (magic (3)), magic (3), 2) == [101; 83; 101]);
%!test "matrix × vector";
%! assert (dot (infsup (magic (3)), [1, 2, 3]) == [15, 30, 45]);
%! assert (dot (infsup (magic (3)), [1, 2, 3], 1) == [15, 30, 45]);
%! assert (dot (infsup (magic (3)), [1, 2, 3], 2) == [28; 34; 28]);
%! assert (dot (infsup (magic (3)), [1; 2; 3]) == [26, 38, 26]);
%! assert (dot (infsup (magic (3)), [1; 2; 3], 1) == [26, 38, 26]);
%! assert (dot (infsup (magic (3)), [1; 2; 3], 2) == [15; 30; 45]);
%!test "matrix × scalar";
%! assert (dot (infsup (magic (3)), 42) == [630, 630, 630]);
%! assert (dot (infsup (magic (3)), 42, 1) == [630, 630, 630]);
%! assert (dot (infsup (magic (3)), 42, 2) == [630; 630; 630]);
%!test "vector × scalar";
%! assert (dot (infsup ([1, 2, 3]), 42) == 252);
%! assert (dot (infsup ([1, 2, 3]), 42, 1) == [42, 84, 126]);
%! assert (dot (infsup ([1, 2, 3]), 42, 2) == 252);
%! assert (dot (infsup ([1; 2; 3]), 42) == 252);
%! assert (dot (infsup ([1; 2; 3]), 42, 1) == 252);
%! assert (dot (infsup ([1; 2; 3]), 42, 2) == [42; 84; 126]);
