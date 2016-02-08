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
## @defmethod {@@infsupdec} exp (@var{X})
## 
## Compute the exponential function.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## exp (infsupdec (1))
##   @result{} ans ⊂ [2.7182, 2.7183]_com
## @end group
## @end example
## @seealso{@@infsupdec/log, @@infsupdec/pow}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = exp (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (exp (intervalpart (x)));
## exp is defined and continuous everywhere
result.dec = min (result.dec, x.dec);

endfunction

%!test "from the documentation string";
%! assert (isequal (exp (infsupdec (1)), infsupdec ("e")));
