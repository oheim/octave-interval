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
## @defmethod {@@infsupdec} roundb (@var{X})
## 
## Round each number in interval @var{X} to the nearest integer.  Ties are
## rounded towards the nearest even integer.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## roundb (infsupdec (2.5, 3.5))
##   @result{} ans = [2, 4]_def
## roundb (infsupdec (-0.5, 5.5))
##   @result{} ans = [0, 6]_def
## @end group
## @end example
## @seealso{@@infsupdec/floor, @@infsupdec/ceil, @@infsupdec/round, @@infsupdec/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = roundb (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (roundb (intervalpart (x)));
result.dec = min (result.dec, x.dec);

discontinuous = not (issingleton (result));
result.dec (discontinuous) = min (result.dec (discontinuous), _def ());

onlyrestrictioncontinuous = issingleton (result) & not (...
    (rem (inf (result), 2) ~= 0 | ...
        ((fix (sup (x)) == sup (x) | fix (sup (x) * 2) / 2 ~= sup (x)) & ...
         (fix (inf (x)) == inf (x) | fix (inf (x) * 2) / 2 ~= inf (x)))));
result.dec (onlyrestrictioncontinuous) = ...
    min (result.dec (onlyrestrictioncontinuous), _dac ());

endfunction

%!test "Empty interval";
%! assert (isequal (roundb (infsupdec ()), infsupdec ()));
%!test "Singleton intervals";
%! assert (isequal (roundb (infsupdec (0)), infsupdec (0)));
%! assert (isequal (roundb (infsupdec (0.5)), infsupdec (0, "dac")));
%! assert (isequal (roundb (infsupdec (0.25)), infsupdec (0)));
%! assert (isequal (roundb (infsupdec (0.75)), infsupdec (1)));
%! assert (isequal (roundb (infsupdec (1.5)), infsupdec (2, "dac")));
%! assert (isequal (roundb (infsupdec (-0.5)), infsupdec (0, "dac")));
%! assert (isequal (roundb (infsupdec (-1.5)), infsupdec (-2, "dac")));
%!test "Bounded intervals";
%! assert (isequal (roundb (infsupdec (-0.5, 0)), infsupdec (0, "dac")));
%! assert (isequal (roundb (infsupdec (0, 0.5)), infsupdec (0, "dac")));
%! assert (isequal (roundb (infsupdec (0.25, 0.5)), infsupdec (0, "dac")));
%! assert (isequal (roundb (infsupdec (-1, 0)), infsupdec (-1, 0, "def")));
%! assert (isequal (roundb (infsupdec (-1, 1)), infsupdec (-1, 1, "def")));
%! assert (isequal (roundb (infsupdec (-realmin, realmin)), infsupdec (0)));
%! assert (isequal (roundb (infsupdec (-realmax, realmax)), infsupdec (-realmax, realmax, "def")));
%!test "Unbounded intervals";
%! assert (isequal (roundb (infsupdec (-realmin, inf)), infsupdec (0, inf, "def")));
%! assert (isequal (roundb (infsupdec (-realmax, inf)), infsupdec (-realmax, inf, "def")));
%! assert (isequal (roundb (infsupdec (-inf, realmin)), infsupdec (-inf, 0, "def")));
%! assert (isequal (roundb (infsupdec (-inf, realmax)), infsupdec (-inf, realmax, "def")));
%! assert (isequal (roundb (infsupdec (-inf, inf)), infsupdec (-inf, inf, "def")));
