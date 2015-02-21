## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {} {} @var{X} * @var{Y}
## @deftypefnx {Function File} {} mtimes (@var{X}, @var{Y})
##
## Compute the interval matrix multiplication.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup ([1, 2; 7, 15], [2, 2; 7.5, 15]);
## y = infsup ([3, 3; 0, 1], [3, 3.25; 0, 2]);
## x * y
##   @result{} 2×2 interval matrix
##          [3, 6]      [5, 10.5]
##      [21, 22.5]   [36, 54.375]
## @end group
## @end example
## @seealso{@@infsup/mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = mtimes (x, y)

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

if (isscalar (x) || isscalar (y))
    result = times (x, y);
    return
endif

if (size (x.inf, 2) ~= size (y.inf, 1))
    error ("interval:InvalidOperand", ...
           "operator *: nonconformant arguments");
endif

## mtimes could also be computed with a for loop and the dot operation.
## However, that would take significantly longer (loop + missing JIT-compiler,
## several OCT-file calls), so we use an optimized
## OCT-file for that particular operation.

[l, u] = mpfr_matrix_mul_d (x.inf, y.inf, x.sup, y.sup);
result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (infsup ([1, 2; 7, 15], [2, 2; 7.5, 15]) * infsup ([3, 3; 0, 1], [3, 3.25; 0, 2]) == infsup ([3, 5; 21, 36], [6, 10.5; 22.5, 54.375]));
