## Copyright 2015-2017 Oliver Heimlich
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
## @defmethod {@@infsupdec} prepad (@var{X}, @var{L})
## @defmethodx {@@infsupdec} prepad (@var{X}, @var{L}, @var{C})
## @defmethodx {@@infsupdec} prepad (@var{X}, @var{L}, @var{C}, @var{DIM})
##
## Prepend the scalar interval value @var{C} to the interval vector @var{X}
## until it is of length @var{L}.  If @var{C} is not given, a value of 0 is
## used.
##
## If @code{length (@var{X}) > L}, elements from the beginning of @var{X} are
## removed until an interval vector of length @var{L} is obtained.
##
## If @var{X} is an interval matrix, elements are prepended or removed from
## each row or column.
##
## If the optional argument DIM is given, operate along this dimension.
##
## If DIM is larger than the dimension of X, the result will have DIM
## dimensions.
##
## @example
## @group
## prepad (infsupdec (1 : 3), 5, 42)
##   @result{} ans = 1×5 interval vector
##      [42]_com   [42]_com   [1]_com   [2]_com   [3]_com
## @end group
## @end example
## @seealso{@@infsupdec/reshape, @@infsup/cat, @@infsupdec/postpad, @@infsupdec/resize}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function x = prepad (x, len, c, dim)

  if (nargin < 2 || nargin > 4)
    print_usage ();
    return
  endif

  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif

  if (nargin < 3)
    c = infsupdec (0);
  elseif (not (isa (c, "infsupdec")))
    c = infsupdec (c);
  endif

  if (nargin < 4)
    dim = find (size (x.dec) ~= 1, 1);
    if (isempty (dim))
      dim = 1;
    endif
  endif

  x.infsup = prepad (x.infsup, len, c.infsup, dim);
  x.dec = prepad (x.dec, len, c.dec, dim);

endfunction

%!assert (isequal (prepad (infsupdec (2:4), 4, 1), infsupdec (1:4)));
%!assert (isequal (prepad (infsupdec (0:2), 2, 1), infsupdec (1:2)));
%!test
%! if (compare_versions (OCTAVE_VERSION (), "4.0.0", ">="))
%!   assert (isequal (prepad (infsupdec (0), 10, 0, 3), infsupdec (zeros (1, 1, 10))));
%! else
%!   # In Octave 3.8.x it is not possible to increase the number of dimensions.
%! endif
%!assert (isequal (prepad (infsupdec (zeros (1, 2, 2)), 3), infsupdec (zeros (1, 3, 2))));
