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
## @deftypefn {Interval Function} {@var{X} =} mulrev (@var{B}, @var{C}, @var{X})
## @deftypefnx {Interval Function} {@var{X} =} mulrev (@var{B}, @var{C})
## @cindex IEEE1788 mulRev
## 
## Compute the reverse multiplication function.
##
## Accuracy: The result is a tight enclosure.
##
## @seealso{mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = mulrev (b, c, x)

assert (nargin >= 2)

if (nargin < 3)
    x = infsupdec (-inf, inf);
endif

## Convert first parameter into interval, if necessary
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif

## Convert second parameter into interval, if necessary
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif

## Convert third parameter into interval, if necessary
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (x))
    result = x;
    return
endif

if (isnai (b))
    result = b;
    return
endif

if (isnai (c))
    result = c;
    return
endif

result = mulrev (intervalpart (b), intervalpart (c), intervalpart (x));
## inverse multiplication is continuous, but not a point function for 0
if (not (ismember (0, x)))
    result = decorateresult (result, {x});
else
    result = setdec (result, "trv");
endif

endfunction