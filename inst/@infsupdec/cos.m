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
## @deftypefn {Function File} {} cos (@var{X})
## 
## Compute the cosine in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cos (infsupdec (1))
##   @result{} [.5403023058681396, .5403023058681398]_com
## @end group
## @end example
## @seealso{@@infsupdec/acos, @@infsupdec/cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = cos (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (cos (intervalpart (x)));
## cos is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec);

endfunction

%!test "from the documentation string";
%! assert (isequal (cos (infsupdec (1)), infsupdec ("[0x1.14A280FB5068Bp-1, 0x1.14A280FB5068Cp-1]")));
