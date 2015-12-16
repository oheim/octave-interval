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
## @documentencoding UTF-8
## @defmethod {@@infsupdec} recip (@var{X})
## 
## Compute the reciprocal of @var{X}.
##
## The result is equivalent to @code{1 ./ @var{X}}, but is computed more
## efficiently.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## recip (infsupdec (1, 4))
##   @result{} ans = [0.25, 1]_com
## @end group
## @end example
## @seealso{@@infsup/inv, @@infsupdec/rdivide}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-11-07

function result = recip (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = newdec (recip (intervalpart (x)));
result.dec = min (result.dec, x.dec);

divisionbyzero = ismember (0, x);
result.dec(divisionbyzero) = _trv ();

endfunction

%!test "from the documentation string";
%!  assert (recip (infsupdec (1, 4)) == infsupdec (0.25, 1));
