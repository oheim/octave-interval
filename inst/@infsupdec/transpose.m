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
## @defop Method {@@infsupdec} transpose (@var{X})
## @defopx Operator {@@infsupdec} {@var{X}.'}
##
## Return the transpose of interval matrix or vector @var{X}.
##
## @example
## @group
## infsupdec (zeros (1, 3), ones (1, 3)) .'
##   @result{} ans = 3×1 interval vector
##      [0, 1]_com
##      [0, 1]_com
##      [0, 1]_com
## @end group
## @end example
## @seealso{@@infsupdec/ctranspose}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-11-02

function result = transpose (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = newdec (transpose (intervalpart (x)));
result.dec = transpose (x.dec);

endfunction

%!xtest assert (isequal (transpose (infsupdec (magic (3))), infsupdec (magic (3).')));
%!xtest "from the documentation string";
%! assert (isequal (transpose (infsupdec (zeros (1, 3), ones (1, 3))), infsupdec (zeros (3, 1), ones (3, 1))));
