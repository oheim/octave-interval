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
## @defmethod {@@infsupdec} abs (@var{X})
## 
## Compute the absolute value of numbers.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## abs (infsupdec (2.5, 3.5))
##   @result{} ans = [2.5, 3.5]_com
## abs (infsupdec (-0.5, 5.5))
##   @result{} ans = [0, 5.5]_com
## @end group
## @end example
## @seealso{@@infsupdec/mag, @@infsupdec/mig}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = abs (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (abs (intervalpart (x)));
## abs is defined and continuous everywhere
result.dec = min (result.dec, x.dec);

endfunction

%!test "Empty interval";
%! assert (isequal (abs (infsupdec ()), infsupdec ()));
%!test "Singleton intervals";
%! assert (isequal (abs (infsupdec (1)), infsupdec (1)));
%! assert (isequal (abs (infsupdec (0)), infsupdec (0)));
%! assert (isequal (abs (infsupdec (-1)), infsupdec (1)));
%! assert (isequal (abs (infsupdec (realmax)), infsupdec (realmax)));
%! assert (isequal (abs (infsupdec (realmin)), infsupdec (realmin)));
%! assert (isequal (abs (infsupdec (-realmin)), infsupdec (realmin)));
%! assert (isequal (abs (infsupdec (-realmax)), infsupdec (realmax)));
%!test "Bounded intervals";
%! assert (isequal (abs (infsupdec (1, 2)), infsupdec (1, 2)));
%! assert (isequal (abs (infsupdec (0, 1)), infsupdec (0, 1)));
%! assert (isequal (abs (infsupdec (-1, 1)), infsupdec (0, 1)));
%! assert (isequal (abs (infsupdec (-1, 0)), infsupdec (0, 1)));
%! assert (isequal (abs (infsupdec (-2, -1)), infsupdec (1, 2)));
%!test "Unbounded intervals";
%! assert (isequal (abs (infsupdec (0, inf)), infsupdec (0, inf)));
%! assert (isequal (abs (infsupdec (-inf, inf)), infsupdec (0, inf)));
%! assert (isequal (abs (infsupdec (-inf, 0)), infsupdec (0, inf)));
%! assert (isequal (abs (infsupdec (1, inf)), infsupdec (1, inf)));
%! assert (isequal (abs (infsupdec (-1, inf)), infsupdec (0, inf)));
%! assert (isequal (abs (infsupdec (-inf, -1)), infsupdec (1, inf)));
%! assert (isequal (abs (infsupdec (-inf, 1)), infsupdec (0, inf)));
%!test "from the documentation string";
%! assert (isequal (abs (infsupdec (2.5, 3.5)), infsupdec (2.5, 3.5)));
%! assert (isequal (abs (infsupdec (-0.5, 5.5)), infsupdec (0, 5.5)));
