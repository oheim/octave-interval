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
## @deftypefn {Function File} {} tan (@var{X})
## 
## Compute the tangent in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## tan (infsupdec (1))
##   @result{} [1.557407724654902, 1.5574077246549023]_com
## @end group
## @end example
## @seealso{@@infsupdec/atan, @@infsupdec/tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = tan (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (tan (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

## Because tan (nextdown (pi / 2)) < realmax, we can simple check for
## a singularity by comparing the result with entire.
domain = not (isentire (result));
result.dec (not (domain)) = "trv";

endfunction

%!test "from the documentation string";
%! assert (isequal (tan (infsupdec (1)), infsupdec ("[0x1.8EB245CBEE3A5, 0x1.8EB245CBEE3A6]")));
