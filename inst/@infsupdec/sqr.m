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
## @deftypefn {Function File} {} sqr (@var{X})
## 
## Compute the square.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqr (infsupdec (-2, 1))
##   @result{} [0, 4]_com
## @end group
## @end example
## @seealso{@@infsupdec/sqrt, @@infsupdec/pown, @@infsupdec/pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = sqr (x)

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (sqr (intervalpart (x)));
## sqr is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec);

endfunction