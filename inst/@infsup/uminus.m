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
## @defop Method {@@infsup} uminus (@var{X})
## @defopx Operator {@@infsup} {-@var{X}}
## 
## Negate all numbers in the interval.
##
## Accuracy: The result is exact.
##
## @example
## @group
## x = infsup (2, 3);
## -x
##   @result{} ans = [-3, -2]
## @end group
## @end example
## @seealso{@@infsup/uplus}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = uminus (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## This also works for empty / entire intervals
l = -x.sup;
u = -x.inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (-infsup (2, 3) == infsup (-3, -2));
