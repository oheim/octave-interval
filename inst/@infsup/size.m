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
## @defmethod {@@infsup} size (@var{A})
## @defmethodx {@@infsup} size (@var{A}, @var{DIM})
##
## Return the number of rows and columns of @var{A}.
##
## With one input argument and one output argument, the result is returned in a
## row vector.  If there are multiple output arguments, the number of rows is
## assigned to the first, and the number of columns to the second, etc.
##
## If given a second argument, @code{size} will return the size of the
## corresponding dimension.
## @seealso{@@infsup/length, @@infsup/numel, @@infsup/rows, @@infsup/columns}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function varargout = size (a, dim)

if (nargin == 0 || nargin > 2)
    print_usage ();
    return
endif

if (nargin == 1)
    if (nargout <= 1)
        varargout {1} = size (a.inf);
    else
        varargout = mat2cell (size (a.inf) (1 : nargout)', ones (nargout, 1));
    endif
else
    varargout {1} = size (a.inf, dim);
endif

endfunction

%!test;
%! assert (size (infsup (zeros (3, 4))), [3 4]);
