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
## @defmethod {@@infsup} det (@var{A})
## 
## Compute the determinant of matrix @var{A}.
##
## The determinant for matrices of size 3×3 or greater is computed via L-U
## decomposition and may be affected by overestimation due to the dependency
## problem.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## det (infsup (magic (3)))
##   @result{} ans = [-360]
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-10-23

function result = det (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (not (issquare (x.inf)))
    error ("det: argument must be a square matrix");
endif

if (any (any (isempty (x))))
    result = infsup ();
    return
endif

switch (rows (x.inf))
    case 0
        result = infsup (1);
        return
    case 1
        result = x;
        return
    case 2
        ## det ([1, 3; 2, 4]) = 4*1 - 3*2
        ## The result will be tightest.
        result = mtimes (infsup ([x.inf(4), -x.sup(3)], ...
                                 [x.sup(4), -x.inf(3)]), ...
                         infsup (x.inf(:, 1), x.sup(:, 1)));
        return
endswitch

zero = x.inf == 0 & x.sup == 0;
if (any (all (zero, 1)) || any (all (zero, 2)))
    ## One column or row being zero
    result = infsup (0);
    return
endif

## P * x = L * U, with
## det (P) = ±1 and det (L) = 1 and det (U) = prod (diag (U))
##
## => det (x) = det (P) * det (U)
[~, U, P] = lu (x);
result = times (det (P), prod (diag (U)));

## Integer matrix, determinant must be integral
if (all (all (fix (x.inf) == x.inf & fix (x.sup) == x.sup)))
    result.inf = ceil (result.inf);
    result.sup = floor (result.sup);
endif

endfunction

%!test "from the documentation string";
%! assert (det (infsup (magic (3))) == -360);
