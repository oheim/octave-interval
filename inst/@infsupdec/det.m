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
## @defmethod {@@infsupdec} det (@var{A})
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
## det (infsupdec (magic (3)))
##   @result{} ans = [-360]_com
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-10-24

function result = det (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (det (intervalpart (x)));
result.dec = min (result.dec, min (min (x.dec)));

endfunction

%!test "from the documentation string";
%! assert (det (infsupdec (magic (3))) == -360);
