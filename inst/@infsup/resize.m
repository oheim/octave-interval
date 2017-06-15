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
## @defmethod {@@infsup} resize (@var{X}, @var{M})
## @defmethodx {@@infsup} resize (@var{X}, @var{M}, @var{N}, ...)
## @defmethodx {@@infsup} resize (@var{X}, [@var{M} @var{N}, ...])
##
## Resize interval array @var{X} cutting off elements as necessary.
##
## In the result, element with certain indices is equal to the corresponding
## element of @var{X} if the indices are within the bounds of @var{X};
## otherwise, the element is set to zero.
##
## If only @var{M} is supplied, and it is a scalar, the dimension of the result
## is @var{M}-by-@var{M}.  If @var{M}, @var{N}, ... are all scalars, then the
## dimensions of the result are @var{M}-by-@var{N}-by-....  If given a vector as
## input, then the dimensions of the result are given by the elements of that
## vector.
##
## An object can be resized to more dimensions than it has; in such
## case the missing dimensions are assumed to be 1.  Resizing an
## object to fewer dimensions is not possible.
##
## @example
## @group
## resize (infsup (magic (3)), 4, 2)
##   @result{} ans = 4×2 interval matrix
##      [8]   [1]
##      [3]   [5]
##      [4]   [9]
##      [0]   [0]
## @end group
## @end example
## @seealso{@@infsup/reshape, @@infsup/cat, @@infsup/postpad, @@infsup/prepad}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function x = resize (x, varargin)

  if (not (isa (x, "infsup")))
    print_usage ();
    return
  endif

  x.inf = resize (x.inf, varargin{:});
  x.sup = resize (x.sup, varargin{:});

  x.inf(x.inf == 0) = -0;

endfunction

%!assert (resize (infsup (magic (3)), 4, 2) == infsup ([8, 1; 3, 5; 4, 9; 0, 0]));
%!assert (resize (infsup (ones (2, 2, 2)), 4, 1, 2) == infsup (resize (ones (2, 2, 2), 4, 1, 2)))
