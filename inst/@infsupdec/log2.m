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
## @defmethod {@@infsupdec} log2 (@var{X})
## 
## Compute the binary (base-2) logarithm.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log2 (infsupdec (2))
##   @result{} ans = [1]_com
## @end group
## @end example
## @seealso{@@infsupdec/pow2, @@infsupdec/log, @@infsupdec/log10}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log2 (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (log2 (intervalpart (x)));
result.dec = min (result.dec, x.dec);

## log2 is continuous everywhere, but defined for x > 0 only
result.dec (not (interior (x, infsupdec (0, inf)))) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (log2 (infsupdec (2)), infsupdec (1)));
