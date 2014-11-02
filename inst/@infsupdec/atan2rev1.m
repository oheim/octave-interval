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
## @deftypefn {Interval Function} {@var{Y} =} atan2rev1 (@var{B}, @var{C}, @var{Y})
## @deftypefnx {Interval Function} {@var{Y} =} atan2rev1 (@var{B}, @var{C})
## @cindex IEEE1788 atan2Rev1
## 
## Compute the reverse atan2 function with
## @code{atan2 (@var{Y}, @var{B}) = @var{C}}.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## atan2rev1 (infsupdec (1, 2), infsupdec ("pi") / 4)
##   @result{} [.9999999999999997, 2.0000000000000009]_trv
## @end group
## @end example
## @seealso{pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = atan2rev1 (b, c, y)

if (nargin < 2)
    print_usage ();
    return
endif
if (nargin < 3)
    y = infsupdec (-inf, inf);
endif
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (y))
    result = y;
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

result = atan2rev1 (intervalpart (b), intervalpart (c), intervalpart (y));
## inverse atan2 is not a point function
result = infsupdec (result, "trv");

endfunction