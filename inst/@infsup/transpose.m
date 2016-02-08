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
## @defop Method {@@infsup} transpose (@var{X})
## @defopx Operator {@@infsup} {@var{X}.'}
##
## Return the transpose of interval matrix or vector @var{X}.
##
## @example
## @group
## infsup (zeros (1, 3), ones (1, 3)) .'
##   @result{} ans = 3×1 interval vector
##      [0, 1]
##      [0, 1]
##      [0, 1]
## @end group
## @end example
## @seealso{@@infsup/ctranspose}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = transpose (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = transpose (x.inf);
u = transpose (x.sup);

result = infsup (l, u);

endfunction

%!assert (transpose (infsup (magic (3))) == infsup (magic (3).'));
%!test "from the documentation string";
%! assert (transpose (infsup (zeros (1, 3), ones (1, 3))) == infsup (zeros (3, 1), ones (3, 1)));
