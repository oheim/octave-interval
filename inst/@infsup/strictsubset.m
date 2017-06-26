## Copyright 2016 Oliver Heimlich
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
## @defmethod {@@infsup} strictsubset (@var{A}, @var{B})
##
## Evaluate strict subset comparison on intervals.
##
## True, if all numbers from @var{A} are also contained in @var{B} and @var{B}
## contains a number that is not in @var{A}.
## False, if @var{A} contains a number which is not a member in @var{B} or if
## @var{A} and @var{B} are equal.
##
## Evaluated on interval arrays, this functions is applied element-wise.
##
## @seealso{@@infsup/subset, @@infsup/eq, @@infsup/interior}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-05-16

function result = strictsubset (a, b)

  if (nargin ~= 2)
    print_usage ();
    return
  endif
  if (not (isa (a, "infsup")))
    a = infsup (a);
  endif
  if (not (isa (b, "infsup")))
    b = infsup (b);
  endif

  result = (b.inf <= a.inf & a.sup <= b.sup) ...
           & (b.inf != a.inf | a.sup != b.sup);

endfunction

%!assert (strictsubset (infsup (1, 2), infsup (1, 3)));
%!assert (strictsubset (infsup (2, 3), infsup (1, 3)));
%!assert (not (strictsubset (infsup (1, 2), infsup (1, 2))));
%!assert (not (strictsubset (infsup (1, 3), infsup (1, 2))));
%!assert (strictsubset (infsup (), infsup (1, 3)));
%!assert (not (strictsubset (infsup (), infsup ())));
%!assert (strictsubset (infsup (), infsup (-inf, inf)));
%!assert (strictsubset (infsup (0, inf), infsup (-inf, inf)));
%!assert (strictsubset (infsup (-inf, 0), infsup (-inf, inf)));
%!assert (not (strictsubset (infsup (-inf, inf), infsup (-inf, inf))));
