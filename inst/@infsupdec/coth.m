## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} coth (@var{X})
## 
## Compute the hyperbolic cotangent, that is the reciprocal hyperbolic tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## coth (infsupdec (1))
##   @result{} ans ⊂ [1.313, 1.3131]_com
## @end group
## @end example
## @seealso{@@infsupdec/tanh, @@infsupdec/csch, @@infsupdec/sech}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = coth (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (coth (intervalpart (x)));
## coth is defined and continuous for x ~= 0
result.dec = min (result.dec, x.dec);
result.dec (inf (x) <= 0 & sup (x) >= 0) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (coth (infsupdec (1)), infsupdec ("[0x1.50231499B6B1D, 0x1.50231499B6B1E]_com")));
