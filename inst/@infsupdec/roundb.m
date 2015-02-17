## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {} roundb (@var{X})
## 
## Round each number in interval @var{X} to the nearest integer.  Ties are
## rounded towards the nearest even integer.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## roundb (infsupdec (2.5, 3.5))
##   @result{} [2, 4]_def
## roundb (infsupdec (-0.5, 5.5))
##   @result{} [0, 6]_def
## @end group
## @end example
## @seealso{@@infsupdec/floor, @@infsupdec/ceil, @@infsupdec/round, @@infsupdec/fix}
## @end deftypefn

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

result = infsupdec (roundb (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

discontinuous = not (issingleton (result));
result.dec (discontinuous) = mindec (result.dec (discontinuous), "def");

onlyrestrictioncontinuous = issingleton (result) & not (...
    (rem (inf (result), 2) ~= 0 | ...
        ((fix (sup (x)) == sup (x) | fix (sup (x) * 2) / 2 ~= sup (x)) & ...
         (fix (inf (x)) == inf (x) | fix (inf (x) * 2) / 2 ~= inf (x)))));
result.dec (onlyrestrictioncontinuous) = ...
    mindec (result.dec (onlyrestrictioncontinuous), "dac");

endfunction
