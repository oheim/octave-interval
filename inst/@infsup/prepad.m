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
## @defmethod {@@infsup} prepad (@var{X}, @var{L})
## @defmethodx {@@infsup} prepad (@var{X}, @var{L}, @var{C})
## @defmethodx {@@infsup} prepad (@var{X}, @var{L}, @var{C}, @var{DIM})
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
## @example
## @group
## prepad (infsup (1 : 3), 5, 42)
##   @result{} ans = 1×5 interval vector
##      [42]   [42]   [1]   [2]   [3]
## @end group
## @end example
## @seealso{@@infsup/reshape, @@infsup/cat, @@infsup/postpad, @@infsup/resize}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function result = prepad (x, len, c, dim)

if (nargin < 2 || nargin > 4)
    print_usage ();
    return
endif

if (nargin < 3)
    c = infsup (0);
elseif (not (isa (c, "infsup")))
    c = infsup (c);
endif

if (nargin < 4)
    if (isvector (x.inf) && not (isscalar (x.inf)))
        dim = find (size (x.inf) ~= 1, 1);
    else
        dim = 1;
    endif
endif

l = prepad (x.inf, len, c.inf, dim);
u = prepad (x.sup, len, c.sup, dim);
result = infsup (l, u);

endfunction

%!assert (prepad (infsup (2:4), 4, 1) == infsup (1:4));
%!assert (prepad (infsup (0:2), 2, 1) == infsup (1:2));
