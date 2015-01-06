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
## @deftypefnx {Interval Function} {} dot (@var{X}, @var{Y}, @var{DIM}, @var{ACCURACY})
## @cindex IEEE1788 dot
## 
## Compute the dot product of two interval vectors.  If @var{X} and @var{Y} are
## matrices, calculate the dot products along the first non-singleton
## dimension.  If the optional argument @var{DIM} is given, calculate the dot
## products along this dimension.
##
## The function can be evaluated in fast (valid) or accurate (tight) mode.  The
## fast mode produces roundoff errors of intermediate results which will sum up
## and lead to poor results -- especially in cases where overflow occurs.  The
## accurate mode is significandly slower (approx. factor 10).
##
## Accuracy: The result either is a @code{tight} enclosure or is a @code{valid}
## enclosure, depending on the value of @var{ACCURACY} (default: tight).
##
## @example
## @group
## dot ([infsup(1), 2, 3], [infsup(2), 3, 4])
##   @result{} [20]
## @end group
## @group
## dot (infsup ([realmax; realmin; realmax]), [1; -1; -1], 1, "valid")
##   @result{} [-Inf, 0]
## dot (infsup ([realmax; realmin; realmax]), [1; -1; -1], 1, "tight")
##   @result{} [-2.2250738585072014e-308, -2.2250738585072013e-308]
## @end group
## @end example
## @seealso{plus, sum, times, sumabs, sumsquare}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function [result, isexact] = dot (x, y, dim, accuracy)

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
if (nargin < 4)
    accuracy = "valid";
else
    if (not (max (strcmp (accuracy, {"valid", "tight"}))))
        print_usage ();
        return
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

isexact = true (resultsize);
l = u = zeros (resultsize);

for n = 1 : numel (isexact)
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
        isexact (n) = true ();
    elseif (strcmp (accuracy, "tight"))
        ## accurate, but slow
        [l(n), u(n), isexact(n)] = tight_vectordot (vector.x, vector.y);
    else
        ## fast, but not accurate and prone to overflow
        [l(n), u(n), isexact(n)] = valid_vectordot (vector.x, vector.y);
    endif
endfor

result = infsup (l, u);

endfunction

## Dot product of two interval vectors; or one vector and one scalar.
## Accuracy is tightest. No interval must be empty.
function [l, u, isexact] = tight_vectordot (x, y)

## Initialize accumulators
l.e = int64 (0);
l.m = zeros (1, 0, "int8");
l.unbound = false ();
u.e = int64 (0);
u.m = zeros (1, 0, "int8");
u.unbound = false ();

for i = 1 : max (numel (x.inf), numel (y.inf))
    if (isscalar (x.inf))
        ## Broadcast scalar value
        x_inf = x.inf;
        x_sup = x.sup;
    else
        x_inf = x.inf (i);
        x_sup = x.sup (i);
    endif
    if (isscalar (y.inf))
        ## Broadcast scalar value
        y_inf = y.inf;
        y_sup = y.sup;
    else
        y_inf = y.inf (i);
        y_sup = y.sup (i);
    endif

    if ((x_inf == 0 && x_sup == 0) || ...
        (y_inf == 0 && y_sup == 0))
        continue
    endif
    
    if (y_sup <= 0)
        if (x_sup <= 0)
            if (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_sup);
            endif
            if (not (isfinite (x_inf) && isfinite (y_inf)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_inf, y_inf);
            endif
        elseif (x_inf >= 0)
            if (not (isfinite (x_sup) && isfinite (y_inf)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_inf);
            endif
            if (not (u.unbound))
                 u = accuaddproduct (u, x_inf, y_sup);
            endif
        else
            if (not (isfinite (x_sup) && isfinite (y_inf)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_inf);
            endif
            if (not (isfinite (x_inf) && isfinite (y_inf)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_inf, y_inf);
            endif
        endif
    elseif (y_inf >= 0)
        if (x_sup <= 0)
            if (not (isfinite (x_inf) && isfinite (y_sup)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_sup);
            endif
            if (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_inf);
            endif
        elseif (x_inf >= 0)
            if (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_inf);
            endif
            if (not (isfinite (x_sup) && isfinite (y_sup)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_sup);
            endif
        else
            if (not (isfinite (x_inf) && isfinite (y_sup)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_sup);
            endif
            if (not (isfinite (x_sup) && isfinite (y_sup)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_sup);
            endif
        endif
    else
        if (x_sup <= 0)
            if (not (isfinite (x_inf) && isfinite (y_sup)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_sup);
            endif
            if (not (isfinite (x_inf) && isfinite (y_inf)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_inf, y_inf);
            endif
        elseif (x_inf >= 0)
            if (not (isfinite (x_sup) && isfinite (y_inf)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_inf);
            endif
            if (not (isfinite (x_sup) && isfinite (y_sup)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_sup);
            endif
        else
            if (not (isfinite (x_inf) && isfinite (x_sup) && ...
                     isfinite (y_inf) && isfinite (y_sup)))
                l.unbound = true ();
                u.unbound = true ();
            else
                if (not (l.unbound))
                    if (x_inf * y_sup < x_sup * y_inf)
                        l = accuaddproduct (l, x_inf, y_sup);
                    else
                        l = accuaddproduct (l, x_sup, y_inf);
                    endif
                endif
                if (not (u.unbound))
                    if (x_inf * y_inf > x_sup * y_sup)
                        u = accuaddproduct (u, x_inf, y_inf);
                    else
                        u = accuaddproduct (u, x_sup, y_sup);
                    endif
                endif
            endif
        endif
    endif
endfor

## Conversion from accu to double
if (l.unbound)
    l = -inf;
    isexact = true ();
else
    [l, isexact] = accu2double (l, -inf);
endif

if (u.unbound)
    u = inf;
else
    [u, upperisexact] = accu2double (u, inf);
    isexact = and (isexact, upperisexact);
endif

endfunction

## Dot product of two interval vectors; or one vector and one scalar.
## Accuracy is valid. No interval must be empty.
function [l, u, isexact] = valid_vectordot (x, y)

isexact = false ();

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
q9 = q10 = y.inf < 0 & y.sup > 0 & x.inf < 0 & x.sup > 0;
a = b = zeros (size (x.inf));
a (q9) = x.inf (q9) .* y.sup (q9);
b (q9) = x.sup (q9) .* y.inf (q9);
q9 = q9 & (a <= b);
q10 = q10 & (a > b);

l = u = zeros (10, 1);
fesetround (-inf);
if (not (isempty (q1)))
    l (1) = x.sup (q1)' * y.sup (q1);
endif
if (not (isempty (q2)))
    l (2) = x.sup (q2)' * y.inf (q2);
endif
if (not (isempty (q3)))
    l (3) = x.sup (q3)' * y.inf (q3);
endif
if (not (isempty (q4)))
    l (4) = x.inf (q4)' * y.sup (q4);
endif
if (not (isempty (q5)))
    l (5) = x.inf (q5)' * y.inf (q5);
endif
if (not (isempty (q6)))
    l (6) = x.inf (q6)' * y.sup (q6);
endif
if (not (isempty (q7)))
    l (7) = x.inf (q7)' * y.sup (q7);
endif
if (not (isempty (q8)))
    l (8) = x.sup (q8)' * y.inf (q8);
endif
if (not (isempty (q9)))
    l (9) = x.inf (q9)' * y.sup (q9);
endif
if (not (isempty (q10)))
    l (10) = x.sup (q10)' * y.inf (q10);
endif
l = sum (l);
fesetround (inf);
if (not (isempty (q1)))
    u (1) = x.inf (q1)' * y.inf (q1);
endif
if (not (isempty (q2)))
    u (2) = x.inf (q2)' * y.sup (q2);
endif
if (not (isempty (q3)))
    u (3) = x.inf (q3)' * y.inf (q3);
endif
if (not (isempty (q4)))
    u (4) = x.sup (q4)' * y.inf (q4);
endif
if (not (isempty (q5)))
    u (5) = x.sup (q5)' * y.sup (q5);
endif
if (not (isempty (q6)))
    u (6) = x.sup (q6)' * y.sup (q6);
endif
if (not (isempty (q7)))
    u (7) = x.inf (q7)' * y.inf (q7);
endif
if (not (isempty (q8)))
    u (8) = x.sup (q8)' * y.sup (q8);
endif
if (not (isempty (q9)))
    u (9) = x.sup (q9)' * y.sup (q9);
endif
if (not (isempty (q10)))
    u (10) = x.inf (q10)' * y.inf (q10);
endif
u = sum (u);
fesetround (0.5);

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
