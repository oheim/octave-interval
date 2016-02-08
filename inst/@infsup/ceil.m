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
## @defmethod {@@infsup} ceil (@var{X})
## 
## Round each number in interval @var{X} towards +Inf.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## ceil (infsup (2.5, 3.5))
##   @result{} ans = [3, 4]
## ceil (infsup (-0.5, 5))
##   @result{} ans = [0, 5]
## @end group
## @end example
## @seealso{@@infsup/floor, @@infsup/round, @@infsup/roundb, @@infsup/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = ceil (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = infsup (ceil (x.inf), ceil (x.sup));

endfunction

%!test "Empty interval";
%! assert (ceil (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (ceil (infsup (0)) == infsup (0));
%! assert (ceil (infsup (0.5)) == infsup (1));
%! assert (ceil (infsup (-0.5)) == infsup (0));
%!test "Bounded intervals";
%! assert (ceil (infsup (-0.5, 0)) == infsup (0));
%! assert (ceil (infsup (0, 0.5)) == infsup (0, 1));
%! assert (ceil (infsup (0.25, 0.5)) == infsup (1));
%! assert (ceil (infsup (-1, 0)) == infsup (-1, 0));
%! assert (ceil (infsup (-1, 1)) == infsup (-1, 1));
%! assert (ceil (infsup (-realmin, realmin)) == infsup (0, 1));
%! assert (ceil (infsup (-realmax, realmax)) == infsup (-realmax, realmax));
%!test "Unbounded intervals";
%! assert (ceil (infsup (-realmin, inf)) == infsup (0, inf));
%! assert (ceil (infsup (-realmax, inf)) == infsup (-realmax, inf));
%! assert (ceil (infsup (-inf, realmin)) == infsup (-inf, 1));
%! assert (ceil (infsup (-inf, realmax)) == infsup (-inf, realmax));
%! assert (ceil (infsup (-inf, inf)) == infsup (-inf, inf));
%!test "from the documentation string";
%! assert (ceil (infsup (2.5, 3.5)) == infsup (3, 4));
%! assert (ceil (infsup (-.5, 5)) == infsup (0, 5));
