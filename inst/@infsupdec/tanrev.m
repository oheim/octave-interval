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
## @deftypefn {Interval Function} {@var{X} =} tanrev (@var{C}, @var{X})
## @deftypefnx {Interval Function} {@var{X} =} tanrev (@var{C})
## @cindex IEEE1788 tanRev
## 
## Compute the reverse tangent function.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## tanrev (infsupdec (0), infsupdec (2, 4))
##   @result{} [3.1415926535897931, 3.1415926535897936]_trv
## @end group
## @end example
## @seealso{tan}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = tanrev (c, x)

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

pi = infsup ("pi");

result = tanrev (intervalpart (c), intervalpart (x));
if (ceil (floor (sup (sup (x) / (pi / 2))) / 2) == ...
    floor (ceil (inf (inf (x) / (pi / 2))) / 2))
    ## For this restriction of x's domain, the reverse function is a continuous
    ## point function
    result = decorateresult (result, {x});
else
    result = setdec (result, "trv");
endif

endfunction