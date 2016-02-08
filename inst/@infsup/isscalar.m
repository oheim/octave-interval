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
## @defmethod {@@infsup} isscalar (@var{A})
##
## Return true if @var{A} is an interval scalar.
##
## Scalars (1x1 matrices) are subsets of the more general vector or matrix and
## @code{isvector} and @code{ismatrix} will return true for these objects as
## well.
## @seealso{@@infsup/isvector, @@infsup/ismatrix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-02

## FIXME This function is only required, because of bug #43925
function result = isscalar (A)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = isscalar (A.inf);

endfunction

%!assert (not (isscalar (infsup ([]))));
%!assert (isscalar (infsup (0)));
%!assert (not (isscalar (infsup (zeros (1, 2)))));
%!assert (not (isscalar (infsup (zeros (2, 1)))));
%!assert (not (isscalar (infsup (zeros (5)))));
