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
## @deftypefn {Function File} {} pow (@var{X}, @var{Y})
## 
## Compute the simple power function on intervals defined by 
## @code{exp (@var{Y} * log (@var{X}))}.
##
## The function is only defined where @var{X} is positive, cf. log function.
## A general power function is implemented by @code{power}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pow (infsupdec (5, 6), infsupdec (2, 3))
##   @result{} [25, 216]_com
## @end group
## @end example
## @seealso{@@infsupdec/pown, @@infsupdec/pow2, @@infsupdec/pow10, @@infsupdec/exp, @@infsupdec/mpower}
## @end deftypefn

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

result = infsupdec (pow (intervalpart (x), intervalpart (y)));
result.dec = mindec (result.dec, x.dec, y.dec);

## pow is continuous everywhere, but defined for x > 0 only
domain = interior (x, infsup (0, inf));
if (isscalar (x) && not (isscalar (y)))
    domain = domain * ones (size (y));
endif
result.dec (not (domain)) = "trv";

endfunction
