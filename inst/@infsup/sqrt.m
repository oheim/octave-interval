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
## @defmethod {@@infsup} sqrt (@var{X})
## 
## Compute the square root (for all non-negative numbers).
##
## Since intervals are only defined for real numbers, this function and
## @code{realsqrt} are equivalent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqrt (infsup (-6, 4))
##   @result{} ans = [0, 2]
## @end group
## @end example
## @seealso{@@infsup/sqr, @@infsup/pow, @@infsup/nthroot, @@infsup/cbrt}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = sqrt (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = realsqrt (x);

endfunction

%!test "from the documentation string";
%! assert (sqrt (infsup (-6, 4)) == infsup (0, 2));
