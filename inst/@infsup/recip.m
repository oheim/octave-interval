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
## @defmethod {@@infsup} recip (@var{X})
## 
## Compute the reciprocal of @var{X}.
##
## THIS FUNCTION IS DEPRECATED AND WILL BE REMOVED IN A FUTURE RELEASE OF THIS
## SOFTWARE.  PLEASE USE @code{1 ./ @var{X}} INSTEAD.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## recip (infsup (1, 4)) @c doctest: +SKIP
##   @result{} ans = [0.25, 1]
## @end group
## @end example
## @seealso{@@infsup/inv, @@infsup/rdivide}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-11-07

function result = recip (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

warning ("interval:deprecated", ...
         "recip: This function is deprecated, please use 1 ./ x instead")

result = rdivide (1, x);

endfunction
