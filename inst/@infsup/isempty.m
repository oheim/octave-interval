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
## @defmethod {@@infsup} isempty (@var{X})
## 
## Check if the interval represents the empty set.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## Warning: This function is not compatible with the builtin @code{isempty}
## function.
##
## @seealso{@@infsup/eq, @@infsup/isentire, @@infsup/issingleton}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function result = isempty (interval)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = (interval.inf > interval.sup);
return

%!assert (isempty (infsup (inf, -inf)));
%!assert (not (isempty (infsup (1, 2))));
