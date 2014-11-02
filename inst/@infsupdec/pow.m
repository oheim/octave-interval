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
## @deftypefn {Interval Function} {} pow (@var{X}, @var{Y})
## @cindex IEEE1788 pow
## 
## Compute the simple power function on intervals defined by 
## @code{exp (@var{Y} * log (@var{X}))}.
##
## The function is only defined where @var{X} is positive, cf. log function.
## A general power function is implemented by @code{mpower}.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest in
## each of the following cases:  @var{X} in @{0, 1, 2, 10@}, or @var{Y} in
## @{-1, 0.5, 0, 1, 2@}, or @var{X} and @var{Y} integral with
## @code{abs (pow (@var{X}, @var{Y})) in [2^-53, 2^53]}
##
## @example
## @group
## pow (infsupdec (5, 6), infsupdec (2, 3))
##   @result{} [25, 216]_com
## @end group
## @end example
## @seealso{pown, pow2, pow10, exp, mpower}
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
