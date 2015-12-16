## Copyright 2015 Oliver Heimlich
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
## @defmethod {@@infsup} isvector (@var{A})
##
## Return true if @var{A} is an interval vector.
##
## Scalars (1x1 vectors) are subsets of the more general vector and
## @code{isvector} will return true for these objects as well.
## @seealso{@@infsup/isscalar, @@infsup/ismatrix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-02

## FIXME This function is only required, because of regression #44498
function result = isvector (A)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = isvector (A.inf);

endfunction

%!assert (not (isvector (infsup ([]))));
%!assert (isvector (infsup (0)));
%!assert (isvector (infsup (zeros (1, 2))));
%!assert (isvector (infsup (zeros (2, 1))));
%!assert (not (isvector (infsup (zeros (5)))));
