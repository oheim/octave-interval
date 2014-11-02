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
## @deftypefn {Interval Function} {} atan2 (@var{Y}, @var{X})
## @cindex IEEE1788 atan2
## 
## Compute the inverse tangent with two arguments for each pair of numbers from
## intervals @var{Y} and @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 5 ULPs of the exact enclosure.
##
## @example
## @group
## atan2 (infsupdec (1), infsupdec (-1))
##   @result{} [2.3561944901923435, 2.3561944901923462]_com
## @end group
## @end example
## @seealso{tan}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = atan2 (y, x)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (y))
    result = y;
    return
endif

result = infsupdec (atan2 (intervalpart (y), intervalpart (x)));
result.dec = mindec (result.dec, y.dec, x.dec);

## The function is discontinuous for x <= 0 and y == 0
discontinuos = ismember (0, y) & inf (x) < 0;
result.dec (discontinuos) = mindec (result.dec (discontinuos), "def");

## The only undefined input is <0,0>
result.dec (ismember (0, y) & ismember (0, x)) = "trv";

endfunction