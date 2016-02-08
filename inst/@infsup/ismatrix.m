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
## @defmethod {@@infsup} ismatrix (@var{A})
##
## Return true if @var{A} is an interval matrix.
##
## Scalars (1x1 matrices) and vectors (1xN or Nx1 matrices) are subsets of the
## more general N-dimensional matrix and @code{ismatrix} will return true for
## these objects as well.
## @seealso{@@infsup/isscalar, @@infsup/isvector}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

## FIXME: One happy day this function can be removed, because bug #42422 has
## been solved with GNU Octave 4.0.
function result = ismatrix (A)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = ismatrix (A.inf);

endfunction

%!assert (ismatrix (infsup ([])));
%!assert (ismatrix (infsup (0)));
%!assert (ismatrix (infsup (zeros (3, 1))));
%!assert (ismatrix (infsup (zeros (1, 4))));
%!assert (ismatrix (infsup (zeros (3, 4))));
