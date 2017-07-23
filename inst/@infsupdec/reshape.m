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
## @defmethod {@@infsupdec} reshape (@var{A}, @var{M}, @var{N}, ...)
## @defmethodx {@@infsupdec} reshape (@var{X}, [@var{M} @var{N}, ...])
## @defmethodx {@@infsupdec} reshape (@var{X}, ..., @var{[]}, ...)
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
## reshape (infsupdec (1 : 6), 2, 3)
##   @result{} ans = 2×3 interval matrix
##          [1]_com   [3]_com   [5]_com
##          [2]_com   [4]_com   [6]_com
## @end group
## @end example
## @seealso{@@infsupdec/resize, @@infsup/cat, @@infsupdec/postpad, @@infsupdec/prepad}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function x = reshape (x, varargin)

  if (not (isa (x, "infsupdec")))
    print_usage ();
    return
  endif

  x.infsup = reshape (x.infsup, varargin{:});
  x.dec = reshape (x.dec, varargin{:});

endfunction

%!assert (isequal (reshape (infsupdec (1 : 6), 2, 3), infsupdec (reshape (1 : 6, 2, 3))));
%!assert (isequal (reshape (infsupdec (1 : 24), 2, [], 4), infsupdec (reshape (1 : 24, 2, 3, 4))));
