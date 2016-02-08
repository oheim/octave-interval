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
## @defmethod {@@infsupdec} round (@var{X})
## 
## Round each number in interval @var{X} to the nearest integer.  Ties are
## rounded away from zero (towards +Inf or -Inf depending on the sign).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## round (infsupdec (2.5, 3.5))
##   @result{} ans = [3, 4]_def
## round (infsupdec (-0.5, 5))
##   @result{} ans = [-1, +5]_def
## @end group
## @end example
## @seealso{@@infsupdec/floor, @@infsupdec/ceil, @@infsupdec/roundb, @@infsupdec/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = round (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (round (intervalpart (x)));
result.dec = min (result.dec, x.dec);

## Round is like a scaled fix function
discontinuous = not (issingleton (result));
result.dec (discontinuous) = min (result.dec (discontinuous), _def ());

onlyrestrictioncontinuous = issingleton (result) & not (...
    (sup (x) >= 0 | ...
            fix (sup (x)) == sup (x) | fix (sup (x) * 2) / 2 ~= sup (x)) & ...
    (inf (x) <= 0 | ...
            fix (inf (x)) == inf (x) | fix (inf (x) * 2) / 2 ~= inf (x)));
result.dec (onlyrestrictioncontinuous) = ...
    min (result.dec (onlyrestrictioncontinuous), _dac ());

endfunction

%!test "Empty interval";
%! assert (isequal (round (infsupdec ()), infsupdec ()));
%!test "Singleton intervals";
%! assert (isequal (round (infsupdec (0)), infsupdec (0)));
%! assert (isequal (round (infsupdec (0.5)), infsupdec (1, "dac")));
%! assert (isequal (round (infsupdec (0.25)), infsupdec (0)));
%! assert (isequal (round (infsupdec (0.75)), infsupdec (1)));
%! assert (isequal (round (infsupdec (-0.5)), infsupdec (-1, "dac")));
%!test "Bounded intervals";
%! assert (isequal (round (infsupdec (-0.5, 0)), infsupdec (-1, 0, "def")));
%! assert (isequal (round (infsupdec (0, 0.5)), infsupdec (0, 1, "def")));
%! assert (isequal (round (infsupdec (0.25, 0.5)), infsupdec (0, 1, "def")));
%! assert (isequal (round (infsupdec (-1, 0)), infsupdec (-1, 0, "def")));
%! assert (isequal (round (infsupdec (-1, 1)), infsupdec (-1, 1, "def")));
%! assert (isequal (round (infsupdec (-realmin, realmin)), infsupdec (0)));
%! assert (isequal (round (infsupdec (-realmax, realmax)), infsupdec (-realmax, realmax, "def")));
%!test "Unbounded intervals";
%! assert (isequal (round (infsupdec (-realmin, inf)), infsupdec (0, inf, "def")));
%! assert (isequal (round (infsupdec (-realmax, inf)), infsupdec (-realmax, inf, "def")));
%! assert (isequal (round (infsupdec (-inf, realmin)), infsupdec (-inf, 0, "def")));
%! assert (isequal (round (infsupdec (-inf, realmax)), infsupdec (-inf, realmax, "def")));
%! assert (isequal (round (infsupdec (-inf, inf)), infsupdec (-inf, inf, "def")));
