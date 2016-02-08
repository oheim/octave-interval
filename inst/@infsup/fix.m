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
## @defmethod {@@infsup} fix (@var{X})
## 
## Truncate fractional portion of each number in interval @var{X}.  This is
## equivalent to rounding towards zero.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fix (infsup (2.5, 3.5))
##   @result{} ans = [2, 3]
## fix (infsup (-0.5, 5))
##   @result{} ans = [0, 5]
## @end group
## @end example
## @seealso{@@infsup/floor, @@infsup/ceil, @@infsup/round, @@infsup/roundb}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = fix (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = infsup (fix (x.inf), fix (x.sup));

endfunction

%!test "Empty interval";
%! assert (fix (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (fix (infsup (0)) == infsup (0));
%! assert (fix (infsup (1)) == infsup (1));
%! assert (fix (infsup (1+eps)) == infsup (1));
%! assert (fix (infsup (-1)) == infsup (-1));
%! assert (fix (infsup (0.5)) == infsup (0));
%! assert (fix (infsup (-0.5)) == infsup (0));
%!test "Bounded intervals";
%! assert (fix (infsup (-0.5, 0)) == infsup (0));
%! assert (fix (infsup (0, 0.5)) == infsup (0));
%! assert (fix (infsup (0.25, 0.5)) == infsup (0));
%! assert (fix (infsup (-1, 0)) == infsup (-1, 0));
%! assert (fix (infsup (-1, 1)) == infsup (-1, 1));
%! assert (fix (infsup (-realmin, realmin)) == infsup (0));
%! assert (fix (infsup (-realmax, realmax)) == infsup (-realmax, realmax));
%!test "Unbounded intervals";
%! assert (fix (infsup (-realmin, inf)) == infsup (0, inf));
%! assert (fix (infsup (-realmax, inf)) == infsup (-realmax, inf));
%! assert (fix (infsup (-inf, realmin)) == infsup (-inf, 0));
%! assert (fix (infsup (-inf, realmax)) == infsup (-inf, realmax));
%! assert (fix (infsup (-inf, inf)) == infsup (-inf, inf));
%!test "from the documentation string";
%! assert (fix (infsup (2.5, 3.5)) == infsup (2, 3));
%! assert (fix (infsup (-0.5, 5)) == infsup (0, 5));
