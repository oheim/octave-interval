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
## @defmethod {@@infsup} sqr (@var{X})
## 
## Compute the square for each entry in @var{X}.
##
## THIS FUNCTION IS DEPRECATED AND WILL BE REMOVED IN A FUTURE RELEASE OF THIS
## SOFTWARE.  PLEASE USE @code{@var{X} .^ 2} INSTEAD.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqr (infsup (-2, 1)) @c doctest: +SKIP
##   @result{} ans = [0, 4]
## @end group
## @end example
## @seealso{@@infsup/realsqrt, @@infsup/pown, @@infsup/pow}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = sqr (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

warning ("interval:deprecated", ...
         "sqr: This function is deprecated, please use x .^ 2 instead")

result = power (x, 2);

endfunction
