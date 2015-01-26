## Copyright 2014 Oliver Heimlich
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
## @deftypefn {Function File} {} abs (@var{X})
## 
## Compute the absolute value of numbers.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## abs (infsupdec (2.5, 3.5))
##   @result{} [2.5, 3.5]_com
## abs (infsupdec (-0.5, 5.5))
##   @result{} [0, 5.5]_com
## @end group
## @end example
## @seealso{@@infsupdec/mag, @@infsupdec/mig}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = abs (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (abs (intervalpart (x)));
## abs is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec);

endfunction