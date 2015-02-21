## Copyright 2015 Oliver Heimlich
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
## @documentencoding utf-8
## @deftypefn {Function File} {} {} @var{X} * @var{Y}
## @deftypefnx {Function File} {} mtimes (@var{X}, @var{Y})
##
## Compute the interval matrix multiplication.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec ([1, 2; 7, 15], [2, 2; 7.5, 15]);
## y = infsupdec ([3, 3; 0, 1], [3, 3.25; 0, 2]);
## x * y
##   @result{} 2×2 interval matrix
##          [3, 6]_com      [5, 10.5]_com
##      [21, 22.5]_com   [36, 54.375]_com
## @end group
## @end example
## @seealso{@@infsupdec/mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-21

function result = mtimes (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

## null matrix input -> null matrix output
if (isempty (x.dec) || isempty (y.dec))
    result = infsupdec (zeros (0));
    return
endif

result = infsupdec (mtimes (intervalpart (x), intervalpart (y)));

dec_x = reducedec (x.dec, 2);
dec_y = reducedec (y.dec, 1);
parfor i = 1 : rows (x.dec)
    result.dec (:, i) = mindec (result.dec (:, i), dec_x, dec_y (i));
endparfor

endfunction

%!assert (isequal (infsupdec ([1, 2; 7, 15], [2, 2; 7.5, 15], {"com", "def"; "dac", "com"}) * infsupdec ([3, 3; 0, 1], [3, 3.25; 0, 2]), infsupdec ([3, 5; 21, 36], [6, 10.5; 22.5, 54.375], {"def", "def"; "dac", "dac"})));
%!test "from the documentation string";
%! assert (isequal (infsupdec ([1, 2; 7, 15], [2, 2; 7.5, 15]) * infsupdec ([3, 3; 0, 1], [3, 3.25; 0, 2]), infsupdec ([3, 5; 21, 36], [6, 10.5; 22.5, 54.375])));
