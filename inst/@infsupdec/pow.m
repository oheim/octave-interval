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
## @defmethod {@@infsupdec} pow (@var{X}, @var{Y})
## 
## Compute the simple power function on intervals defined by 
## @code{exp (@var{Y} * log (@var{X}))}.
##
## The function is only defined where @var{X} is positive or where @var{X} is
## zero and @var{Y} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pow (infsupdec (5, 6), infsupdec (2, 3))
##   @result{} ans = [25, 216]_com
## @end group
## @end example
## @seealso{@@infsupdec/pown, @@infsupdec/pow2, @@infsupdec/pow10, @@infsupdec/exp, @@infsupdec/mpower}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pow (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (y))
    result = y;
    return
endif

result = newdec (pow (intervalpart (x), intervalpart (y)));
result.dec = min (result.dec, min (x.dec, y.dec));

## pow is continuous everywhere (where it is defined),
## but defined for x > 0 or (x = 0 and y > 0) only
nonnegative = infsupdec (0, inf);
domain = interior (x, nonnegative) | ...
        (subset (x, nonnegative) & interior (y, nonnegative));

result.dec (not (domain)) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (pow (infsupdec (5, 6), infsupdec (2, 3)), infsupdec (25, 216)));
