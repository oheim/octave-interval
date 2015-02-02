## Copyright 2014–2015 Oliver Heimlich
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
## @documentencoding utf-8
## @deftypefn {Function File} {} ismatrix (@var{A})
##
## Return true if @var{A} is an interval matrix.
##
## Scalars (1x1 matrices) and vectors (1xN or Nx1 matrices) are subsets of the
## more general N-dimensional matrix and @code{ismatrix} will return true for
## these objects as well.
## @seealso{@@infsup/isscalar, @@infsup/isvector}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = ismatrix (A)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = ismatrix (A.inf);

endfunction
