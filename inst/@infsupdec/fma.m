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
## @deftypefn {Interval Function} {@var{R} =} fma (@var{X}, @var{Y}, @var{Z})
## @cindex IEEE1788 fma
## 
## Fused multiply and add @code{@var{X} * @var{Y} + @var{Z}}.  Multiply each
## number of interval @var{X} with each number of interval @var{Y} and add
## each number of interval @var{Z}.
##
## This function is semantically equivalent to evaluating multiplication and
## addition separately, but in addition guarantees a tight enclosure of the
## result.  The fused multiply and add is much slower.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fma (infsupdec (1+eps), infsupdec (7), infsupdec ("0.1"))
##   @result{} [7.1000000000000014, 7.1000000000000024]_com
## infsupdec (1+eps) * infsupdec (7) + infsupdec ("0.1")
##   @result{} [7.1000000000000005, 7.1000000000000024]_com
## @end group
## @end example
## @seealso{plus, mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = fma (x, y, z)

assert (nargin == 3);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

## Convert second parameter into interval, if necessary
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

## Convert third parameter into interval, if necessary
if (not (isa (z, "infsupdec")))
    z = infsupdec (z);
endif

if (isnai (x))
    result = x;
    return
endif

if (isnai (y))
    result = y;
    return
endif

if (isnai (z))
    result = z;
    return
endif

result = fma (intervalpart (x), intervalpart (y), intervalpart (z));
## fma is defined and continuous everywhere
result = decorateresult (result, {x, y, z});

endfunction