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
## @defmethod {@@infsup} inv (@var{A})
## 
## Compute the inverse of the square matrix @var{A}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## inv (infsup ([2, 1, 1; 0, 1, 0; 1, 0, 0]))
##   @result{} ans = 3×3 interval matrix
##      [0]    [0]    [1]
##      [0]    [1]    [0]
##      [1]   [-1]   [-2]
## inv (infsup ([1, 2, 3; 4, 0, 6; 0, 0, 1]))
##   @result{} ans = 3×3 interval matrix
##        [0]     [0.25]    [-1.5]
##      [0.5]   [-0.125]   [-0.75]
##        [0]        [0]       [1]
## @end group
## @end example
## @seealso{@@infsup/mrdivide}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = inv (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

n = length (x);
if (n <= 1)
    result = rdivide (1, x);
    return
endif

result = mldivide (x, eye (n));

endfunction

%!test "from the wiki";
%!  A = infsup ([1, 2, 3; 4, 0, 0; 0, 0, 1]);
%!  A (2, 3) = "[0, 6]";
%!  B = inv (A);
%!  assert (inf (B) == [0, .25, -1.5; .5, -.125, -1.5; 0, 0, 1]);
%!  assert (sup (B) == [0, .25,    0; .5, -.125, -.75; 0, 0, 1]);
%!test "from the documentation string";
%!  assert (inv (infsup ([2, 1, 1; 0, 1, 0; 1, 0, 0])) == [0, 0, 1; 0, 1, 0; 1, -1, -2]);
%!  assert (inv (infsup ([1, 2, 3; 4, 0, 6; 0, 0, 1])) == [0, .25, -1.5; .5, -.125, -.75; 0, 0, 1]);
