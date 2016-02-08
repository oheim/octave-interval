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
## @defmethod {@@infsupdec} floor (@var{X})
## 
## Round each number in interval @var{X} towards -Inf.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## floor (infsupdec (2.5, 3.5))
##   @result{} ans = [2, 3]_def
## floor (infsupdec (-0.5, 5))
##   @result{} ans = [-1, +5]_def
## @end group
## @end example
## @seealso{@@infsupdec/ceil, @@infsupdec/round, @@infsupdec/roundb, @@infsupdec/fix}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = floor (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (floor (intervalpart (x)));
result.dec = min (result.dec, x.dec);

## Between two integral numbers the function is constant, thus continuous
discontinuous = not (issingleton (result));
result.dec (discontinuous) = min (result.dec (discontinuous), _def ());

onlyrestrictioncontinuous = issingleton (result) & fix (inf (x)) == inf (x);
result.dec (onlyrestrictioncontinuous) = ...
    min (result.dec (onlyrestrictioncontinuous), _dac ());

endfunction

%!test "from the documentation string";
%! assert (isequal (floor (infsupdec (2.5, 3.5)), infsupdec (2, 3, "def")));
%! assert (isequal (floor (infsupdec (-0.5, 5)), infsupdec (-1, 5, "def")));
