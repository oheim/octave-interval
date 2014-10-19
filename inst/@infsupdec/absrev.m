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
## @deftypefn {Interval Function} {@var{X} =} absrev (@var{C}, @var{X})
## @deftypefnx {Interval Function} {@var{X} =} absrev (@var{C})
## @cindex IEEE1788 absRev
## 
## Compute the reverse absolute value function.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## absrev (infsupdec (-2, 1))
##   @result{} [-1, 1]_trv
## @end group
## @end example
## @seealso{abs}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = absrev (c, x)

if (nargin < 2)
    x = infsupdec (-inf, inf);
endif

## Convert first parameter into interval, if necessary
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif

## Convert second parameter into interval, if necessary
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (c))
    result = c;
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = absrev (intervalpart (c), intervalpart (x));
if (inf (x) >= 0 || sup (x) <= 0)
    ## For this restriction of x's domain, the reverse function is a continuous
    ## point function
    result = decorateresult (result, {x});
else
    ## reverse abs function can't be decorated, it is not a point function
    result = setdec (result, "trv");
endif

endfunction