## Copyright 2015-2016 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## @defmethod {@@infsup} reshape (@var{A}, @var{M}, @var{N}, ...)
## @defmethodx {@@infsup} reshape (@var{X}, [@var{M} @var{N}, ...])
## @defmethodx {@@infsup} reshape (@var{X}, ..., @var{[]}, ...)
##
## Return an interval matrix with the specified dimensions (M, N, ...) whose
## elements are taken from the interval matrix @var{A}.  The elements of the
## matrix are accessed in column-major order (like Fortran arrays are stored).
##
## Note that the total number of elements in the original matrix
## (@code{prod (size (@var{A}))}) must match the total number of elements in
## the new matrix (@code{prod ([@var{M} @var{N}])}).
##
## A single dimension of the return matrix may be left unspecified and
## Octave will determine its size automatically.  An empty matrix ([])
## is used to flag the unspecified dimension.
##
## @example
## @group
## reshape (infsup (1 : 6), 2, 3)
##   @result{} ans = 2×3 interval matrix
##          [1]   [3]   [5]
##          [2]   [4]   [6]
## @end group
## @end example
## @seealso{@@infsup/resize, @@infsup/cat, @@infsup/postpad, @@infsup/prepad}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function a = reshape (a, varargin)

  if (not (isa (a, "infsup")))
    print_usage ();
    return
  endif

  a.inf = reshape (a.inf, varargin{:});
  a.sup = reshape (a.sup, varargin{:});

endfunction

%!assert (reshape (infsup (1 : 6), 2, 3) == infsup (reshape (1 : 6, 2, 3)));
%!assert (reshape (infsup (1 : 24), 2, [], 4) == infsup (reshape (1 : 24, 2, 3, 4)));
