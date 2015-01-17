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
## @deftypefn {Function File} {} cosh (@var{X})
## 
## Compute the hyperbolic cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cosh (infsupdec (1))
##   @result{} [1.5430806348152437, 1.543080634815244]_com
## @end group
## @end example
## @seealso{acosh, sinh, tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = cosh (x)

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (cosh (intervalpart (x)));
## cosh is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec);

endfunction