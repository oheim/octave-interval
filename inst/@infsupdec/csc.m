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
## @deftypefn {Function File} {} csc (@var{X})
## 
## Compute the cosecant in radians, that is the reciprocal sine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## csc (infsupdec (1))
##   @result{} [1.188395105778121, 1.1883951057781213]_com
## @end group
## @end example
## @seealso{@@infsupdec/sin, @@infsupdec/sec, @@infsupdec/cot}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = csc (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (csc (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

## Because csc (nextdown (pi)) < realmax, we can simple check for
## a singularity by comparing the result with entire for x ~= 0.
domain = not (isentire (result)) | (inf (x) <= 0 & sup (x) >= 0);
result.dec (not (domain)) = "trv";

endfunction

%!test "from the documentation string";
%! assert (isequal (csc (infsupdec (1)), infsupdec ("[0x1.303AA9620B223, 0x1.303AA9620B224]_com")));
