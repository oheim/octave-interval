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
## @defop Method {@@infsup} uplus (@var{X})
## @defopx Operator {@@infsup} {+@var{X}}
## 
## Return the interval itself.
##
## Accuracy: The result is exact.
##
## @example
## @group
## x = infsup (2, 3);
## + x
##   @result{} ans = [2, 3]
## @end group
## @end example
## @seealso{@@infsup/uminus}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function x = uplus (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

endfunction

%!test "from the documentation string";
%! assert (+infsup (2, 3) == infsup (2, 3));
