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
## @defmethod {@@infsupdec} fix (@var{X})
## 
## Truncate fractional portion of each number in interval @var{X}.  This is
## equivalent to rounding towards zero.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fix (infsupdec (2.5, 3.5))
##   @result{} ans = [2, 3]_def
## fix (infsupdec (-0.5, 5))
##   @result{} ans = [0, 5]_def
## @end group
## @end example
## @seealso{@@infsupdec/floor, @@infsupdec/ceil, @@infsupdec/round, @@infsupdec/roundb}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = fix (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (fix (intervalpart (x)));
result.dec = min (result.dec, x.dec);

## Between two integral numbers the function is constant, thus continuous
## At x == 0 the function is continuous.
discontinuous = not (issingleton (result));
result.dec (discontinuous) = min (result.dec (discontinuous), _def ());

onlyrestrictioncontinuous = issingleton (result) & ...
    ((sup (x) < 0 & fix (sup (x)) == sup (x)) | ...
     (inf (x) > 0 & fix (inf (x)) == inf (x)));
result.dec (onlyrestrictioncontinuous) = ...
    min (result.dec (onlyrestrictioncontinuous), _dac ());

endfunction

%!test "from the documentation string";
%! assert (isequal (fix (infsupdec (2.5, 3.5)), infsupdec (2, 3, "def")));
%! assert (isequal (fix (infsupdec (-0.5, 5)), infsupdec (0, 5, "def")));
