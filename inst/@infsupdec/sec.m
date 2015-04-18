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
## @deftypefn {Function File} {} sec (@var{X})
## 
## Compute the secant in radians, that is the reciprocal cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sec (infsupdec (1))
##   @result{} [1.8508157176809254, 1.8508157176809257]_com
## @end group
## @end example
## @seealso{@@infsupdec/cos, @@infsupdec/csc, @@infsupdec/cot}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = sec (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (sec (intervalpart (x)));
result.dec = min (result.dec, x.dec);

## Because sec (nextdown (pi/2)) < realmax, we can simple check for
## a singularity by comparing the result with entire.
domain = not (isentire (result));
result.dec (not (domain)) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (sec (infsupdec (1)), infsupdec ("[0x1.D9CF0F125CC29, 0x1.D9CF0F125CC2A]_com")));
