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
## @deftypefn {Interval Function} {@var{Y} =} round (@var{X})
## @cindex IEEE1788 roundTiesToAway
## 
## Round each number in interval @var{X} to the nearest integer.  Ties are
## rounded away from zero (towards +Inf or -Inf depending on the sign).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## round (infsupdec (2.5, 3.5))
##   @result{} [3, 4]_def
## round (infsupdec (-0.5, 5))
##   @result{} [-1, 5]_def
## @end group
## @end example
## @seealso{floor, ceil, roundb, fix}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = round (x)

if (isnai (x))
    result = x;
    return
endif

result = round (intervalpart (x));
if (issingleton (result) && ...
    (x.sup >= 0 || fix (x.sup) == x.sup || fix (x.sup * 2) / 2 ~= x.sup) && ...
    (x.inf <= 0 || fix (x.inf) == x.inf || fix (x.inf * 2) / 2 ~= x.inf))
    ## Round is like a scaled fix function
    result = decorateresult (result, {x});
else
    result = decorateresult (result, {x}, "def");
endif

endfunction