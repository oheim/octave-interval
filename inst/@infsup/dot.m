## Copyright 2014-2016 Oliver Heimlich
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
## @defmethod {@@infsup} dot (@var{X}, @var{Y})
## @defmethodx {@@infsup} dot (@var{X}, @var{Y}, @var{DIM})
## 
## Compute the dot product of two interval vectors.
## 
## If @var{X} and @var{Y} are matrices, calculate the dot products along the
## first non-singleton dimension.  If the optional argument @var{DIM} is given,
## calculate the dot products along this dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## dot ([infsup(1), 2, 3], [infsup(2), 3, 4])
##   @result{} ans = [20]
## @end group
## @group
## dot (infsup ([realmax; realmin; realmax]), [1; -1; -1], 1)
##   @result{} ans ⊂ [-2.2251e-308, -2.225e-308]
## @end group
## @end example
## @seealso{@@infsup/plus, @@infsup/sum, @@infsup/times, @@infsup/sumabs, @@infsup/sumsq}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function result = dot (x, y, dim)

if (nargin < 2 || nargin > 3)
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
        dim = find (any (size (x.inf), size (y.inf)) > 1, 1);
        if (isempty (dim))
            dim = 1;
        endif
    endif
endif

## null matrix input -> null matrix output
if (isempty (x.inf) || isempty (y.inf))
    result = infsup (zeros (min (size (x.inf), size (y.inf))));
    return
endif

## Only the sizes of non-singleton dimensions must agree. Singleton dimensions
## do broadcast (independent of parameter dim).
if ((min (size (x.inf, 1), size (y.inf, 1)) > 1 && ...
        size (x.inf, 1) ~= size (y.inf, 1)) || ...
    (min (size (x.inf, 2), size (y.inf, 2)) > 1 && ...
        size (x.inf, 2) ~= size (y.inf, 2)))
    error ("interval:InvalidOperand", "dot: sizes of X and Y must match")
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
    
    [l(n), u(n)] = vectordot (vector.x, vector.y);
endfor

result = infsup (l, u);

endfunction

## Dot product of two interval vectors; or one vector and one scalar.
## Accuracy is tightest.
function [l, u] = vectordot (x, y)

if (isscalar (x.inf) && isscalar (y.inf))
    ## Short-circuit: scalar × scalar
    z = x .* y;
    l = z.inf;
    u = z.sup;
    return
endif

[l, u] = mpfr_vector_dot_d (x.inf, y.inf, x.sup, y.sup);

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
%!test "from the documentation string";
%! assert (dot ([infsup(1), 2, 3], [infsup(2), 3, 4]) == 20);
%! assert (dot (infsup ([realmax; realmin; realmax]), [1; -1; -1], 1) == -realmin);
