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
## @defmethod {@@infsupdec} realsqrt (@var{X})
## 
## Compute the square root (for all non-negative numbers).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## realsqrt (infsupdec (-6, 4))
##   @result{} ans = [0, 2]_trv
## @end group
## @end example
## @seealso{@@infsupdec/sqr, @@infsupdec/rsqrt, @@infsupdec/pow, @@infsupdec/cbrt, @@infsupdec/nthroot}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = realsqrt (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (realsqrt (intervalpart (x)));
result.dec = min (result.dec, x.dec);

## realsqrt is continuous everywhere, but defined for x >= 0 only
defined = subset (x, infsupdec (0, inf));
result.dec (not (defined)) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (realsqrt (infsupdec (-6, 4)), infsupdec (0, 2, "trv")));
